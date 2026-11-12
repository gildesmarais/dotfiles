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
    SEARCH_ROLES = {
      "authored" => "authored", "requested" => "review-requested", "assigned" => "assigned", "reviewed" => "reviewed"
    }.freeze
    CURSOR_VARS = { "authored" => "ac", "requested" => "rc", "assigned" => "ic", "reviewed" => "vc" }.freeze
    # Aliases whose rows are issues; every other alias returns pull requests.
    ISSUE_ALIASES = %w[assigned].freeze
    # Full-state chunk; sized from a live measurement (see AGENTS.md).
    STATE_CHUNK = 10
    # gh stderr for an id GitHub cannot resolve (deleted or transferred PR).
    NOT_FOUND = /Could not resolve to a node/.freeze
    # Failures worth bisecting: an unresolvable id, or a gateway timeout on a big chunk.
    BISECTABLE = Regexp.union(NOT_FOUND, /HTTP 50[24]|Bad Gateway|Gateway Timeout/).freeze
    # Phase 1: cheap. No mergeable/contexts/threads: merge-state computation is what
    # pushes a full search past GitHub's ~10s timeout.
    SEARCH_QUERY = <<~GRAPHQL
      query($authored:String!,$requested:String!,$assigned:String!,$reviewed:String!,
            $ac:String,$rc:String,$ic:String,$vc:String,
            $withA:Boolean!,$withR:Boolean!,$withI:Boolean!,$withV:Boolean!){
        authored: search(type:ISSUE,first:50,query:$authored,after:$ac) @include(if:$withA){ ...page }
        requested: search(type:ISSUE,first:50,query:$requested,after:$rc) @include(if:$withR){ ...page }
        assigned: search(type:ISSUE,first:50,query:$assigned,after:$ic) @include(if:$withI){ ...page }
        reviewed: search(type:ISSUE,first:50,query:$reviewed,after:$vc) @include(if:$withV){ ...page }
      }
      fragment page on SearchResultItemConnection {
        pageInfo{ hasNextPage endCursor }
        nodes{
          ... on PullRequest {
            id url number title author{login} isDraft updatedAt
            repository{ nameWithOwner }
            commits(last:1){ nodes{ commit{ statusCheckRollup{ state } } } }
          }
          ... on Issue {
            id url number title author{login} updatedAt
            repository{ nameWithOwner }
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
        url number title state author{login} isDraft baseRefName headRefName headRefOid
        mergeable mergeStateStatus reviewDecision updatedAt
        repository{ nameWithOwner }
        labels(first:20){ nodes{ name } }
        reviews(last:20){ nodes{ author{login} state submittedAt commit{ oid } } }
        commits(last:1){
          nodes{
            commit{
              committedDate
              statusCheckRollup{
                state
                contexts(first:50){
                  nodes{
                    ... on CheckRun{ name conclusion detailsUrl startedAt }
                    ... on StatusContext{ context state targetUrl createdAt }
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

    # Phase 1: one `gh api graphql` call per page, all roles aliased in one query.
    # Rows carry id, kind (pr|issue), role (authored|review-requested|both|assigned|reviewed)
    # and signature. +reviewed+ is a PR you reviewed that no longer requests your review.
    def discover(owners)
      scope = Array(owners).map { |owner| "user:#{owner}" }.join(" ")
      cursors = SEARCH_ROLES.keys.map { |field| [field, nil] }.to_h
      pending = SEARCH_ROLES.keys
      rows_by_url = {}
      until pending.empty?
        data = graphql(
          SEARCH_QUERY,
          "-F", "authored=is:pr is:open author:@me #{scope}".strip,
          "-F", "requested=is:pr is:open review-requested:@me #{scope}".strip,
          "-F", "assigned=is:issue is:open assignee:@me #{scope}".strip,
          "-F", "reviewed=is:pr is:open reviewed-by:@me -author:@me #{scope}".strip,
          "-F", "withA=#{pending.include?('authored')}",
          "-F", "withR=#{pending.include?('requested')}",
          "-F", "withI=#{pending.include?('assigned')}",
          "-F", "withV=#{pending.include?('reviewed')}",
          *cursor_args(cursors)
        )
        pending = pending.select do |field|
          page = data[field] || {}
          Array(page["nodes"]).each { |node| merge_row(rows_by_url, node, field) }
          cursors[field] = page.dig("pageInfo", "endCursor")
          page.dig("pageInfo", "hasNextPage") && cursors[field]
        end
      end
      rows_by_url.values
    end

    # Single owner of the PR key string ("owner/repo#n") for rows, states and items.
    def self.pr_key(record)
      "#{record['repository']}##{record['number']}"
    end

    # Phase 2: full classifier states for node ids, STATE_CHUNK per call. A failed
    # chunk is bisected down to single ids; a single id GitHub cannot resolve
    # (NOT_FOUND) is dropped, any other failure fails the caller.
    def pr_states(ids)
      Array(ids).each_slice(STATE_CHUNK).flat_map { |chunk| chunk_states(chunk) }
    end

    # Phase 2 for changed discover rows: PR rows go through pr_states; issue rows
    # are already complete from discovery and never reach nodes(ids:).
    def states(rows)
      issues, prs = Array(rows).partition { |row| row["kind"] == "issue" }
      issue_states = issues.map { |row| row.reject { |k, _| %w[id role signature].include?(k) } }
      pr_states(prs.map { |row| row["id"] }) + issue_states
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

    def chunk_states(ids)
      state_nodes(ids)
    rescue ExitError => e
      return [] if ids.size == 1 && NOT_FOUND.match?(e.message)
      raise if ids.size == 1 || !BISECTABLE.match?(e.message)

      ids.each_slice((ids.size + 1) / 2).flat_map { |half| chunk_states(half) }
    end

    # Closed or merged between discovery and this fetch: nothing to act on.
    def state_nodes(ids)
      args = ids.flat_map { |id| ["-f", "ids[]=#{id}"] }
      nodes = Array(graphql(STATE_QUERY, *args)["nodes"]).compact
      nodes.select { |node| node["state"] == "OPEN" }.map { |node| normalize_state(node) }
    end

    def merge_row(rows_by_url, node, field)
      url = node["url"]
      return if url.nil?

      role = SEARCH_ROLES[field]
      existing = rows_by_url[url]
      if existing
        existing["role"] = merge_role(existing["role"], role)
      elsif ISSUE_ALIASES.include?(field)
        rows_by_url[url] = issue_row(node, role)
      else
        rows_by_url[url] = search_row(node, role)
      end
    end

    # One PR in several searches: authored + review-requested is "both"; a live review
    # request outranks a past review; authorship outranks everything but "both".
    def merge_role(existing, incoming)
      return existing if existing == incoming || existing == "both"

      pair = [existing, incoming]
      return "both" if pair.sort == %w[authored review-requested]
      return "authored" if pair.include?("authored") && pair.include?("reviewed")
      return "review-requested" if pair.include?("review-requested") && pair.include?("reviewed")

      "both"
    end

    def normalize_state(node)
      commit = node.dig("commits", "nodes", 0, "commit") || {}
      rollup = commit["statusCheckRollup"] || {}
      checks = normalize_checks((rollup["contexts"] || {})["nodes"])
      {
        "kind" => "pr",
        "url" => node["url"],
        "number" => node["number"],
        "title" => node["title"],
        "author" => (node["author"] || {})["login"],
        "isDraft" => node["isDraft"],
        "labels" => Array((node["labels"] || {})["nodes"]).map { |l| l["name"] },
        "reviews" => Array((node["reviews"] || {})["nodes"]).map { |r| normalize_review(r) },
        "baseRefName" => node["baseRefName"],
        "headRefName" => node["headRefName"],
        "headRefOid" => node["headRefOid"],
        "headCommittedAt" => commit["committedDate"],
        "mergeable" => node["mergeable"],
        "mergeStateStatus" => node["mergeStateStatus"],
        "reviewDecision" => node["reviewDecision"],
        "updatedAt" => node["updatedAt"],
        "rollup_state" => rollup["state"].to_s.upcase,
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
        "kind" => "pr",
        "role" => role,
        "signature" => [node["updatedAt"], rollup_state].map(&:to_s).join("|")
      }
    end

    # Constant signature: only a new assignment (unseen key) is a delta; comments and
    # label edits bump updatedAt and would wake the watcher for nothing.
    def issue_row(node, role)
      {
        "id" => node["id"],
        "url" => node["url"],
        "repository" => (node["repository"] || {})["nameWithOwner"],
        "title" => node["title"],
        "number" => node["number"],
        "updatedAt" => node["updatedAt"],
        "author" => (node["author"] || {})["login"],
        "kind" => "issue",
        "role" => role,
        "signature" => "issue"
      }
    end

    def normalize_review(review)
      {
        "author" => (review["author"] || {})["login"],
        "state" => review["state"],
        "submittedAt" => review["submittedAt"],
        "commit_oid" => (review["commit"] || {})["oid"]
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

    # Newest run per check name, as the PR checks view shows it: the rollup also keeps
    # superseded runs on the same commit (e.g. a closed PR that shared the head SHA).
    def normalize_checks(rollup)
      latest = {}
      Array(rollup).each do |c|
        name = c["name"] || c["context"]
        at = (c["startedAt"] || c["createdAt"]).to_s
        next if latest[name] && latest[name][:at] > at

        latest[name] = {
          at: at,
          check: {
            "name" => name,
            "state" => (c["conclusion"] || c["state"]).to_s.upcase,
            "link" => c["detailsUrl"] || c["targetUrl"]
          }
        }
      end
      latest.values.map { |v| v[:check] }
    end

    def truncate(text, max)
      return text if text.length <= max

      "#{text[0, max - 1]}…"
    end
  end
end
