# frozen_string_literal: true

require_relative "test_helper"

class GithubTest < Minitest::Test
  include OpsGithubTest

  def test_truncate_thread_body
    gh = OpsGithub::Github.new(runner: ->(_) { "{}" })
    long = "x" * 300
    node = {
      "id" => "t1",
      "isResolved" => false,
      "first" => {
        "nodes" => [
          { "databaseId" => 1, "author" => { "login" => "copilot-pull-request-reviewer" },
            "body" => long, "createdAt" => "t", "path" => "a.rb" }
        ]
      }
    }
    thread = gh.send(:normalize_thread, node)
    assert_operator(thread["first"]["body"].length, :<=, OpsGithub::Github::THREAD_BODY_MAX)
    assert(thread["bot"])
  end

  def test_discover_one_call_scoped_to_owners_with_roles
    calls = []
    response = search_response(
      authored: [pr_node("pr_bundler_audit.json")],
      requested: [pr_node("pr_review_requested.json"), pr_node("pr_bundler_audit.json")]
    )
    runner = lambda do |argv|
      calls << argv
      response
    end
    rows = OpsGithub::Github.new(runner: runner).discover(%w[acme beta])
    assert_equal(1, calls.size)
    assert_includes(calls.first, "authored=is:pr is:open author:@me user:acme user:beta")
    assert_includes(calls.first, "requested=is:pr is:open review-requested:@me user:acme user:beta")
    assert_equal({ 2 => "both", 9 => "review-requested" }, rows.map { |r| [r["number"], r["role"]] }.to_h)
    assert_equal("2026-11-02T11:00:00Z|FAILURE", rows.first["signature"])
    assert_equal("PR_app2", rows.first["id"])
    refute_includes(calls.first.join(" "), "reviewDecision")
  end

  def test_discover_assigned_issues_as_issue_rows
    calls = []
    response = search_response(authored: [pr_node("pr_bundler_audit.json")], assigned: [issue_node(5)])
    runner = lambda do |argv|
      calls << argv
      response
    end
    rows = OpsGithub::Github.new(runner: runner).discover(%w[acme beta])
    assert_equal(1, calls.size)
    assert_includes(calls.first, "assigned=is:issue is:open assignee:@me user:acme user:beta")
    issue = rows.find { |r| r["kind"] == "issue" }
    assert_equal(["acme/app#5", "assigned", "2026-11-02T09:00:00Z", %w[bug]],
                 [OpsGithub::Github.pr_key(issue), issue["role"], issue["signature"], issue["labels"]])
    assert_equal(%w[pr], rows.reject { |r| r["kind"] == "issue" }.map { |r| r["kind"] })
  end

  def test_states_fetches_only_pr_ids
    calls = []
    runner = lambda do |argv|
      calls << argv
      nodes_response([pr_node("pr_bundler_audit.json")])
    end
    issue_row = OpsGithub::Github.new(runner: ->(_) { search_response(assigned: [issue_node(5)]) })
                                 .discover(%w[acme]).first
    states = OpsGithub::Github.new(runner: runner).states([{ "id" => "PR_app2", "kind" => "pr" }, issue_row])
    assert_equal([["ids[]=PR_app2"]], calls.map { |argv| argv.grep(/\Aids\[\]=/) })
    assert_equal(%w[acme/app#2 acme/app#5], states.map { |st| OpsGithub::Github.pr_key(st) })
    assert_equal("issue", states.last["kind"])
  end

  def test_discover_pages_each_alias_until_exhausted
    pages = [
      { "authored" => search_page([pr_node("pr_authored_clean.json")], "A1"),
        "requested" => search_page([pr_node("pr_review_requested.json")]) },
      { "authored" => search_page([pr_node("pr_bundler_audit.json")]) }
    ]
    calls = []
    runner = lambda do |argv|
      calls << argv
      JSON.generate("data" => pages[calls.size - 1])
    end
    rows = OpsGithub::Github.new(runner: runner).discover(%w[acme])
    assert_equal([1, 9, 2], rows.map { |r| r["number"] })
    assert_includes(calls.last, "ac=A1")
    assert_includes(calls.last, "withR=false")
  end

  def test_pr_states_normalizes_failing_checks
    node = pr_node("pr_bundler_audit.json")
    node["commits"]["nodes"][0]["commit"]["statusCheckRollup"]["contexts"]["nodes"] <<
      { "__typename" => "StatusContext", "context" => "ci/legacy", "state" => "ERROR", "targetUrl" => "https://ci" }
    response = nodes_response([node])
    state = OpsGithub::Github.new(runner: ->(_) { response }).pr_states(%w[PR_app2]).first
    assert_equal(
      [%w[bundler_audit FAILURE], %w[ci/legacy ERROR]],
      state["failing_checks"].map { |c| [c["name"], c["state"]] }
    )
    assert_equal("https://ci", state["failing_checks"].last["link"])
  end

  def test_pr_states_keeps_newest_run_per_check_name
    node = pr_node("pr_bundler_audit.json")
    contexts = node["commits"]["nodes"][0]["commit"]["statusCheckRollup"]["contexts"]["nodes"]
    contexts[0]["startedAt"] = "2026-11-03T14:22:40Z"
    contexts << { "__typename" => "CheckRun", "name" => "bundler_audit", "conclusion" => "SUCCESS",
                  "detailsUrl" => "https://ci/2", "startedAt" => "2026-11-03T14:25:05Z" }
    response = nodes_response([node])
    state = OpsGithub::Github.new(runner: ->(_) { response }).pr_states(%w[id]).first
    assert_empty(state["failing_checks"])
  end

  def test_pr_states_normalizes_label_names
    node = pr_node("pr_authored_clean.json").merge("labels" => { "nodes" => [{ "name" => "on-hold" }] })
    response = nodes_response([node])
    state = OpsGithub::Github.new(runner: ->(_) { response }).pr_states(%w[id]).first
    assert_equal(%w[on-hold], state["labels"])
  end

  def test_pr_states_retries_gateway_timeout_once_at_half_chunk
    sizes = []
    runner = lambda do |argv|
      ids = argv.grep(/\Aids\[\]=/)
      sizes << ids.size
      raise OpsGithub::ExitError, "gh failed: gh: HTTP 502" if ids.size > 5

      nodes_response(ids.map { |_| pr_node("pr_authored_clean.json") })
    end
    states = OpsGithub::Github.new(runner: runner).pr_states((1..10).map { |n| "PR_#{n}" })
    assert_equal([10, 5, 5], sizes)
    assert_equal(10, states.size)
  end

  def test_pr_states_fails_when_half_chunk_also_times_out
    runner = ->(_) { raise OpsGithub::ExitError, "gh failed: gh: HTTP 504" }
    assert_raises(OpsGithub::ExitError) do
      OpsGithub::Github.new(runner: runner).pr_states((1..4).map { |n| "PR_#{n}" })
    end
  end

  NOT_FOUND_MESSAGE = "gh failed: Could not resolve to a node with the global id of 'PR_bogus'"

  def not_found_runner(bogus, calls = [])
    lambda do |argv|
      ids = argv.grep(/\Aids\[\]=/).map { |a| a.split("=", 2).last }
      calls << ids
      raise OpsGithub::ExitError, NOT_FOUND_MESSAGE if ids.include?(bogus)

      nodes_response(ids.map { |id| pr_node("pr_authored_clean.json").merge("id" => id) })
    end
  end

  def test_pr_states_drops_single_not_found_id_by_bisecting
    calls = []
    states = OpsGithub::Github.new(runner: not_found_runner("PR_bogus", calls)).pr_states(%w[PR_a PR_bogus PR_b])
    assert_equal(2, states.size)
    assert_includes(calls, %w[PR_bogus])
  end

  def test_pr_states_fails_closed_on_other_single_id_error
    runner = ->(_) { raise OpsGithub::ExitError, "gh failed: HTTP 401" }
    assert_raises(OpsGithub::ExitError) { OpsGithub::Github.new(runner: runner).pr_states(%w[PR_a PR_b]) }
  end

  def test_pr_states_non_gateway_error_raises_without_bisecting
    calls = 0
    runner = lambda do |_|
      calls += 1
      raise OpsGithub::ExitError, "gh failed: HTTP 401"
    end
    assert_raises(OpsGithub::ExitError) do
      OpsGithub::Github.new(runner: runner).pr_states((1..10).map { |n| "PR_#{n}" })
    end
    assert_equal(1, calls)
  end

  def test_pr_states_skips_nodes_that_are_not_open
    closed = pr_node("pr_authored_clean.json").merge("state" => "CLOSED")
    response = nodes_response([closed, pr_node("pr_bundler_audit.json")])
    states = OpsGithub::Github.new(runner: ->(_) { response }).pr_states(%w[a b])
    assert_equal([2], states.map { |s| s["number"] })
  end

  def test_setup_facts_reads_login_and_orgs
    runner = lambda do |argv|
      joined = argv.join(" ")
      return "me\n" if joined.include?("api user --jq .login")
      return %w[acme beta].to_json if joined.include?("api user/orgs")

      "{}"
    end
    gh = OpsGithub::Github.new(runner: runner)
    facts = gh.setup_facts
    assert_equal("me", facts["login"])
    assert_includes(facts["owners"], "acme")
    assert_equal(true, facts["auth_ok"])
  end

  def test_discover_reads_head_commit_and_last_thread_comment
    state = state_from_fixture("pr_authored_clean.json", "threads_handled.json")
    assert_equal("2026-11-02T09:30:00Z", state["headCommittedAt"])
    assert_equal("me", state["threads"].first["last"]["author"])
    assert_equal("alice", state["threads"].first["first"]["author"])
  end
end
