# frozen_string_literal: true

require_relative "test_helper"

class ClassifierTest < Minitest::Test
  include OpsGithubTest

  def setup
    @tmpdir = Dir.mktmpdir("ops-github-classifier")
    @ledger = OpsGithub::Ledger.init(@tmpdir, owners: ["acme"])
    @classifier = OpsGithub::Classifier.new(login: "me")
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_base_caused_bundler_audit_is_auto_merge_base
    state = state_from_fixture("pr_bundler_audit.json")
    items = @classifier.classify(
      search_rows: [search_row(state, "authored")],
      states: [state],
      ledger: @ledger
    )
    red = items.find { |i| i["class"] == "red-ci-base" }
    refute_nil(red)
    assert_equal("auto", red["action"])
    assert_match(/merge-base/, red["invoke"])
  end

  def test_shared_red_ci_clusters_into_one_ask
    a = state_from_fixture("pr_bundler_audit.json")
    b = state_from_fixture("pr_bundler_audit.json")
    b["url"] = "https://github.com/acme/app/pull/22"
    b["number"] = 22
    b["repository"] = "acme/app"
    items = @classifier.classify(
      search_rows: [search_row(a, "authored"), search_row(b, "authored")],
      states: [a, b],
      ledger: @ledger
    )
    shared = items.select { |i| i["class"] == "red-ci-shared" }
    assert_equal(1, shared.size)
    assert_equal("ask", shared.first["action"])
    assert_equal(%w[acme/app#2 acme/app#22], shared.first["evidence"]["prs"])
  end

  def test_open_bot_thread_is_judge
    state = state_from_fixture("pr_bot_thread.json", "threads_bot_open.json")
    items = @classifier.classify(
      search_rows: [search_row(state, "authored")],
      states: [state],
      ledger: @ledger
    )
    bot = items.find { |i| i["class"] == "bot-thread" }
    refute_nil(bot)
    assert_equal("judge", bot["action"])
  end

  def test_handled_thread_suppressed
    state = state_from_fixture("pr_authored_clean.json", "threads_handled.json")
    items = @classifier.classify(
      search_rows: [search_row(state, "authored")],
      states: [state],
      ledger: @ledger
    )
    unresolved = items.select { |i| i["class"] == "unresolved-review" }
    assert_empty(unresolved)
  end

  def test_review_requested_is_urgent_ask
    state = state_from_fixture("pr_review_requested.json")
    items = @classifier.classify(
      search_rows: [search_row(state, "review-requested")],
      states: [state],
      ledger: @ledger
    )
    req = items.find { |i| i["class"] == "review-requested" }
    refute_nil(req)
    assert_equal("urgent", req["urgency"])
    assert_equal("ask", req["action"])
  end

  def test_envelope_report_md_within_15_lines
    state = state_from_fixture("pr_bundler_audit.json")
    items = @classifier.classify(
      search_rows: [search_row(state, "authored")],
      states: [state],
      ledger: @ledger
    )
    env = @classifier.envelope(items, ledger: @ledger)
    lines = env["report_md"].split("\n")
    assert_operator(lines.size, :<=, 15)
    assert_includes(%w[quiet changes], env["status"])
  end

  def test_decided_items_not_reasked
    state = state_from_fixture("pr_bundler_audit.json")
    items = @classifier.classify(
      search_rows: [search_row(state, "authored")],
      states: [state],
      ledger: @ledger
    )
    id = items.first["id"]
    @ledger.decide!(id, "snoozed")
    again = @classifier.classify(
      search_rows: [search_row(state, "authored")],
      states: [state],
      ledger: @ledger
    )
    env = @classifier.envelope(again, ledger: @ledger)
    assert_equal("quiet", env["status"])
  end

  def test_approved_turning_red_is_urgent
    state = state_from_fixture("pr_bundler_audit.json")
    state["reviewDecision"] = "APPROVED"
    # Use a non-base-caused failing check so approved-red wins.
    state["failing_checks"] = [{ "name" => "unit-test", "state" => "FAILURE" }]
    items = @classifier.classify(
      search_rows: [search_row(state, "authored")],
      states: [state],
      ledger: @ledger
    )
    hit = items.find { |i| i["class"] == "approved-red" }
    refute_nil(hit)
    assert_equal("urgent", hit["urgency"])
  end
end
