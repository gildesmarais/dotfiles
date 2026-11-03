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
