# frozen_string_literal: true

require "json"
require "open3"

module OpsGithub
  # Boundary adapter: the only module that invokes `gh`. Inject +runner+ for tests.
  # Read-only: discovery and PR state; mutations belong to Hands / pull-request / gh.
  class Github
    BATCH_SIZE = 25
    PARALLELISM = 6
    THREAD_BODY_MAX = 160
    FAILING_STATES = %w[FAILURE ERROR TIMED_OUT STARTUP_FAILURE].freeze
    BOT_AUTHORS = %w[
      copilot-pull-request-reviewer
      copilot-swe-agent
      github-actions
      dependabot
      renovate
    ].freeze

    attr_reader :login

    def initialize(runner: nil)
      @runner = runner || method(:default_run)
      @login = nil
    end

    def setup_facts
      user = json_run(%w[api user --jq .login])
      @login = user.is_a?(String) ? user.strip : ""
      orgs = json_run(%w[api user/orgs --jq .[].login])
      org_list = case orgs
                 when Array then orgs.map(&:to_s)
                 when String then orgs.split("\n").map(&:strip).reject(&:empty?)
                 else []
                 end
      {
        "login" => @login,
        "owners" => ([@login] + org_list).uniq.sort,
        "auth_ok" => !@login.empty?
      }
    end

    def search_prs(owners, role)
      owners = Array(owners)
      results = []
      owners.each do |owner|
        flag = role == "review-requested" ? "--review-requested=@me" : "--author=@me"
        args = [
          "search", "prs", flag, "--owner=#{owner}", "--state=open",
          "--json", "url,repository,title,number,updatedAt,isDraft,author",
          "--limit", "50"
        ]
        rows = json_run(args)
        Array(rows).each do |row|
          results << normalize_search_row(row, role)
        end
      end
      results
    end

    def pr_states(urls)
      urls = Array(urls).uniq
      return [] if urls.empty?

      out = []
      urls.each_slice(BATCH_SIZE) do |batch|
        out.concat(pr_states_batch(batch))
      end
      out
    end

    private

    def default_run(argv)
      cmd = ["gh"] + argv
      out, err, status = Open3.capture3(*cmd)
      raise ExitError, "gh failed: #{err.strip}" unless status.success?

      out
    end

    def run(argv)
      @runner.call(argv)
    end

    def json_run(argv)
      raw = run(argv)
      return nil if raw.nil? || raw.strip.empty?

      JSON.parse(raw)
    rescue JSON::ParserError
      raw.strip
    end

    def normalize_search_row(row, role)
      repo = row["repository"] || {}
      name = repo.is_a?(Hash) ? (repo["nameWithOwner"] || repo["name"]) : repo.to_s
      {
        "url" => row["url"],
        "repository" => name,
        "title" => row["title"],
        "number" => row["number"],
        "updatedAt" => row["updatedAt"],
        "isDraft" => row["isDraft"],
        "author" => (row["author"] || {})["login"],
        "role" => role
      }
    end

    def pr_states_batch(urls)
      return urls.map { |url| pr_state(url) } if urls.size <= 1

      results = Array.new(urls.size)
      queue = Queue.new
      urls.each_with_index { |url, idx| queue << [idx, url] }
      workers = [PARALLELISM, urls.size].min
      threads = Array.new(workers) do
        Thread.new do
          loop do
            idx, url = begin
              queue.pop(true)
            rescue ThreadError
              break
            end
            results[idx] = pr_state(url)
          end
        end
      end
      threads.each(&:join)
      results
    end

    def pr_state(url)
      fields = %w[
        url number title author isDraft baseRefName headRefName headRefOid
        mergeable mergeStateStatus reviewDecision
        statusCheckRollup updatedAt
      ].join(",")
      raw = json_run(["pr", "view", url, "--json", fields])
      threads = review_threads(url)
      checks = normalize_checks(raw["statusCheckRollup"])
      {
        "url" => raw["url"] || url,
        "number" => raw["number"],
        "title" => raw["title"],
        "author" => (raw["author"] || {})["login"],
        "isDraft" => raw["isDraft"],
        "baseRefName" => raw["baseRefName"],
        "headRefName" => raw["headRefName"],
        "headRefOid" => raw["headRefOid"],
        "mergeable" => raw["mergeable"],
        "mergeStateStatus" => raw["mergeStateStatus"],
        "reviewDecision" => raw["reviewDecision"],
        "updatedAt" => raw["updatedAt"],
        "failing_checks" => checks.select { |c| FAILING_STATES.include?(c["state"]) },
        "checks" => checks,
        "threads" => threads,
        "repository" => repo_from_url(raw["url"] || url)
      }
    end

    def review_threads(url)
      owner, repo, number = parse_pr_url(url)
      return [] unless owner

      query = <<~GRAPHQL
        query($o:String!,$r:String!,$n:Int!){
          repository(owner:$o,name:$r){
            pullRequest(number:$n){
              reviewThreads(first:100){
                nodes{
                  id isResolved isOutdated
                  comments(first:20){
                    nodes{ databaseId author{login} body createdAt path }
                  }
                }
              }
            }
          }
        }
      GRAPHQL
      raw = json_run(
        ["api", "graphql",
         "-f", "query=#{query}",
         "-F", "o=#{owner}",
         "-F", "r=#{repo}",
         "-F", "n=#{number}"]
      )
      nodes = ((raw || {}).dig("data", "repository", "pullRequest", "reviewThreads") || {})["nodes"] || []
      nodes.map { |node| normalize_thread(node) }
    rescue ExitError
      []
    end

    def normalize_thread(node)
      comments = ((node["comments"] || {})["nodes"] || []).map do |c|
        {
          "databaseId" => c["databaseId"],
          "author" => (c["author"] || {})["login"],
          "body" => truncate((c["body"] || "").to_s, THREAD_BODY_MAX),
          "createdAt" => c["createdAt"],
          "path" => c["path"]
        }
      end
      first = comments.first
      last = comments.last
      {
        "id" => node["id"],
        "isResolved" => node["isResolved"],
        "isOutdated" => node["isOutdated"],
        "path" => first && first["path"],
        "first" => first,
        "last" => last,
        "bot" => first && BOT_AUTHORS.include?(first["author"].to_s)
      }
    end

    def normalize_checks(rollup)
      Array(rollup).map do |c|
        {
          "name" => c["name"] || c["context"],
          "state" => (c["conclusion"] || c["state"]).to_s.upcase,
          "link" => c["detailsUrl"] || c["targetUrl"]
        }
      end
    end

    def truncate(text, max)
      return text if text.length <= max

      "#{text[0, max - 1]}…"
    end

    def parse_pr_url(url)
      m = %r{github\.com/([^/]+)/([^/]+)/pull/(\d+)}.match(url.to_s)
      return [nil, nil, nil] unless m

      [m[1], m[2], m[3].to_i]
    end

    def repo_from_url(url)
      owner, repo, = parse_pr_url(url)
      owner ? "#{owner}/#{repo}" : nil
    end
  end
end
