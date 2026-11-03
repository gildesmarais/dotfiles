# frozen_string_literal: true

require "json"
require "open3"

module OpsGithub
  # Boundary adapter: the only module that invokes `gh`. Inject +runner+ for tests.
  # Read-only: discovery and PR state; mutations belong to Hands / pull-request / gh.
  class Github
    THREAD_BODY_MAX = 160
    FAILING_STATES = %w[FAILURE ERROR TIMED_OUT STARTUP_FAILURE].freeze
    BOT_AUTHORS = %w[
      copilot-pull-request-reviewer
      copilot-swe-agent
      github-actions
      dependabot
      renovate
    ].freeze
    SEARCH_ROLES = { "authored" => "authored", "requested" => "review-requested" }.freeze
    CURSOR_VARS = { "authored" => "ac", "requested" => "rc" }.freeze
    # Full-state chunk; sized from a live measurement (see AGENTS.md).
    STATE_CHUNK = 10
    RETRYABLE = /HTTP 50[24]/.freeze
    # Phase 1: cheap. No mergeable/contexts/threads: merge-state computation is what
    # pushes a full search past GitHub's ~10s timeout.
    SEARCH_QUERY = <<~GRAPHQL
      query($authored:String!,$requested:String!,$ac:String,$rc:String,$withA:Boolean!,$withR:Boolean!){
        authored: search(type:ISSUE,first:50,query:$authored,after:$ac) @include(if:$withA){ ...page }
        requested: search(type:ISSUE,first:50,query:$requested,after:$rc) @include(if:$withR){ ...page }
      }
      fragment page on SearchResultItemConnection {
        pageInfo{ hasNextPage endCursor }
        nodes{
          ... on PullRequest {
            id url number title author{login} isDraft updatedAt
            repository{ nameWithOwner }
            commits(last:1){ nodes{ commit{ statusCheckRollup{ state } } } }
          }
        }
      }
    GRAPHQL
    # Phase 2: full state for changed PRs only.
    STATE_QUERY = <<~GRAPHQL
      query($ids:[ID!]!){ nodes(ids:$ids){ ...pr } }
      fragment comment on PullRequestReviewComment {
        databaseId author{login} body createdAt path
      }
      fragment pr on PullRequest {
        url number title author{login} isDraft baseRefName headRefName headRefOid
        mergeable mergeStateStatus reviewDecision updatedAt
        repository{ nameWithOwner }
        commits(last:1){
          nodes{
            commit{
              committedDate
              statusCheckRollup{
                state
                contexts(first:50){
                  nodes{
                    ... on CheckRun{ name conclusion detailsUrl }
                    ... on StatusContext{ context state targetUrl }
                  }
                }
              }
            }
          }
        }
        reviewThreads(first:100){
          nodes{
            id isResolved
            first: comments(first:1){ nodes{ ...comment } }
            last: comments(last:1){ nodes{ ...comment } }
          }
        }
      }
    GRAPHQL

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

    # Phase 1: one `gh api graphql` call per page, both roles aliased in one
    # query. Rows carry id, role (authored|review-requested|both), and signature.
    def discover(owners)
      scope = Array(owners).map { |owner| "user:#{owner}" }.join(" ")
      cursors = { "authored" => nil, "requested" => nil }
      pending = SEARCH_ROLES.keys
      rows_by_url = {}
      until pending.empty?
        data = graphql(
          SEARCH_QUERY,
          "-F", "authored=is:pr is:open author:@me #{scope}".strip,
          "-F", "requested=is:pr is:open review-requested:@me #{scope}".strip,
          "-F", "withA=#{pending.include?('authored')}",
          "-F", "withR=#{pending.include?('requested')}",
          *cursor_args(cursors)
        )
        pending = pending.select do |field|
          page = data[field] || {}
          Array(page["nodes"]).each { |node| merge_row(rows_by_url, node, SEARCH_ROLES[field]) }
          cursors[field] = page.dig("pageInfo", "endCursor")
          page.dig("pageInfo", "hasNextPage") && cursors[field]
        end
      end
      rows_by_url.values
    end

    # Phase 2: full classifier states for node ids, STATE_CHUNK per call. A 502/504
    # retries that chunk once as two halves; any other failure fails the caller.
    def pr_states(ids)
      Array(ids).each_slice(STATE_CHUNK).flat_map do |chunk|
        state_nodes(chunk)
      rescue ExitError => e
        raise unless chunk.size > 1 && RETRYABLE.match?(e.message)

        chunk.each_slice((chunk.size + 1) / 2).flat_map { |half| state_nodes(half) }
      end
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

    def graphql(query, *args)
      raw = json_run(["api", "graphql", "-f", "query=#{query}", *args])
      (raw.is_a?(Hash) && raw["data"]) || {}
    end

    def cursor_args(cursors)
      cursors.flat_map { |field, cursor| cursor ? ["-f", "#{CURSOR_VARS[field]}=#{cursor}"] : [] }
    end

    def state_nodes(ids)
      args = ids.flat_map { |id| ["-f", "ids[]=#{id}"] }
      Array(graphql(STATE_QUERY, *args)["nodes"]).compact.map { |node| normalize_state(node) }
    end

    def merge_row(rows_by_url, node, role)
      url = node["url"]
      return if url.nil?

      existing = rows_by_url[url]
      if existing
        existing["role"] = "both" if existing["role"] != role
      else
        rows_by_url[url] = search_row(node, role)
      end
    end

    def normalize_state(node)
      commit = node.dig("commits", "nodes", 0, "commit") || {}
      rollup = commit["statusCheckRollup"] || {}
      checks = normalize_checks((rollup["contexts"] || {})["nodes"])
      {
        "url" => node["url"],
        "number" => node["number"],
        "title" => node["title"],
        "author" => (node["author"] || {})["login"],
        "isDraft" => node["isDraft"],
        "baseRefName" => node["baseRefName"],
        "headRefName" => node["headRefName"],
        "headRefOid" => node["headRefOid"],
        "headCommittedAt" => commit["committedDate"],
        "mergeable" => node["mergeable"],
        "mergeStateStatus" => node["mergeStateStatus"],
        "reviewDecision" => node["reviewDecision"],
        "updatedAt" => node["updatedAt"],
        "failing_checks" => checks.select { |c| FAILING_STATES.include?(c["state"]) },
        "threads" => Array((node["reviewThreads"] || {})["nodes"]).map { |t| normalize_thread(t) },
        "repository" => (node["repository"] || {})["nameWithOwner"]
      }
    end

    # Signature owner: updatedAt does not move when CI turns red, so the head
    # commit's rollup state joins it (a review bumps updatedAt).
    def search_row(node, role)
      rollup_state = node.dig("commits", "nodes", 0, "commit", "statusCheckRollup", "state")
      {
        "id" => node["id"],
        "url" => node["url"],
        "repository" => (node["repository"] || {})["nameWithOwner"],
        "title" => node["title"],
        "number" => node["number"],
        "updatedAt" => node["updatedAt"],
        "isDraft" => node["isDraft"],
        "author" => (node["author"] || {})["login"],
        "role" => role,
        "signature" => [node["updatedAt"], rollup_state].map(&:to_s).join("|")
      }
    end

    def normalize_thread(node)
      first = normalize_comment(node.dig("first", "nodes", 0))
      last = normalize_comment(node.dig("last", "nodes", 0))
      {
        "id" => node["id"],
        "isResolved" => node["isResolved"],
        "path" => first && first["path"],
        "first" => first,
        "last" => last,
        "bot" => first && BOT_AUTHORS.include?(first["author"].to_s)
      }
    end

    def normalize_comment(comment)
      return nil if comment.nil?

      {
        "databaseId" => comment["databaseId"],
        "author" => (comment["author"] || {})["login"],
        "body" => truncate((comment["body"] || "").to_s, THREAD_BODY_MAX),
        "createdAt" => comment["createdAt"],
        "path" => comment["path"]
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
  end
end
