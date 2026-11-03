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

  def test_base_caused_bundler_audit_is_auto_merge_main
    state = state_from_fixture("pr_bundler_audit.json")
    items = @classifier.classify(
      search_rows: [search_row(state, "authored")],
      states: [state],
      ledger: @ledger
    )
    red = items.find { |i| i["class"] == "red-ci-base" }
    refute_nil(red)
    assert_equal("auto", red["action"])
    assert_equal("/ops-github act #{red['id']}", red["invoke"])
    assert_equal("fix", red["headRefName"])
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
    assert_match(%r{/pull-request fix-ci}, shared.first["invoke"])
  end

  def test_red_ci_clusters_only_within_a_repo
    a = state_from_fixture("pr_bundler_audit.json")
    b = state_from_fixture("pr_bundler_audit.json")
    b["url"] = "https://github.com/acme/web/pull/2"
    b["repository"] = "acme/web"
    items = @classifier.classify(
      search_rows: [search_row(a, "authored"), search_row(b, "authored")],
      states: [a, b],
      ledger: @ledger
    )
    assert_equal(%w[red-ci-base red-ci-base], items.map { |i| i["class"] })
  end

  def test_approved_red_not_demoted_by_cluster
    a = state_from_fixture("pr_bundler_audit.json")
    a["reviewDecision"] = "APPROVED"
    a["failing_checks"] = [{ "name" => "unit-test", "state" => "FAILURE" }]
    b = Marshal.load(Marshal.dump(a))
    b["reviewDecision"] = nil
    b["url"] = "https://github.com/acme/app/pull/22"
    b["number"] = 22
    items = @classifier.classify(
      search_rows: [search_row(a, "authored"), search_row(b, "authored")],
      states: [a, b],
      ledger: @ledger
    )
    hit = items.find { |i| i["class"] == "approved-red" }
    assert_equal("urgent", hit["urgency"])
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
    assert(bot["evidence"].key?("comment_id"))
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

  def test_dependabot_review_requested_is_batch_and_clustered
    a = state_from_fixture("pr_review_requested.json")
    a["author"] = "app/dependabot"
    a["url"] = "https://github.com/acme/app/pull/10"
    a["number"] = 10
    a["repository"] = "acme/app"
    b = state_from_fixture("pr_review_requested.json")
    b["author"] = "app/dependabot"
    b["url"] = "https://github.com/acme/app/pull/11"
    b["number"] = 11
    b["repository"] = "acme/app"
    items = @classifier.classify(
      search_rows: [search_row(a, "review-requested"), search_row(b, "review-requested")],
      states: [a, b],
      ledger: @ledger
    )
    triage = items.select { |i| i["class"] == "dependabot-triage" }
    assert_equal(1, triage.size)
    assert_equal("batch", triage.first["urgency"])
    assert_match(%r{/dependabot triage acme/app}, triage.first["invoke"])
  end

  def test_report_md_ranks_urgent_before_batch
    urgent = state_from_fixture("pr_bundler_audit.json")
    urgent["reviewDecision"] = "APPROVED"
    urgent["failing_checks"] = [{ "name" => "unit-test", "state" => "FAILURE" }]
    batch = state_from_fixture("pr_bot_thread.json", "threads_bot_open.json")
    batch["url"] = "https://github.com/acme/app/pull/9"
    batch["number"] = 9
    batch["repository"] = "acme/app"
    items = @classifier.classify(
      search_rows: [search_row(batch, "authored"), search_row(urgent, "authored")],
      states: [batch, urgent],
      ledger: @ledger
    )
    env = @classifier.envelope(items, ledger: @ledger)
    needs_lines = env["report_md"].lines.select { |l| l.start_with?("- ") }
    assert(needs_lines.first.include?("urgent"), needs_lines.first)
  end

  def test_cluster_report_line_is_compact_without_urls
    states = (10..36).map do |n|
      s = state_from_fixture("pr_review_requested.json")
      s.merge("author" => "app/dependabot", "repository" => "acme/app", "number" => n,
              "url" => "https://github.com/acme/app/pull/#{n}")
    end
    items = @classifier.classify(
      search_rows: states.map { |s| search_row(s, "review-requested") },
      states: states,
      ledger: @ledger
    )
    env = @classifier.envelope(items, ledger: @ledger)
    line = env["report_md"].lines.find { |l| l.start_with?("- ") }
    assert_operator(line.chomp.length, :<=, 80, line)
    assert_includes(line, "acme/app (27 PRs)")
    refute_includes(env["report_md"], "https://")
    assert_match(%r{/dependabot triage}, env["ask"].first["invoke"])
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

  def test_conflicts_on_others_pr_not_reported
    state = state_from_fixture("pr_review_requested.json")
    state["mergeable"] = "CONFLICTING"
    items = @classifier.classify(
      search_rows: [search_row(state, "review-requested")],
      states: [state],
      ledger: @ledger
    )
    assert_equal(%w[review-requested], items.map { |i| i["class"] })
  end

  def test_timed_out_check_is_red_and_flaky
    gh = OpsGithub::Github.new(runner: ->(_) { "{}" })
    checks = gh.send(:normalize_checks, [{ "name" => "unit", "conclusion" => "TIMED_OUT" }])
    state = state_from_fixture("pr_authored_clean.json")
    state["failing_checks"] = checks.select { |c| OpsGithub::Github::FAILING_STATES.include?(c["state"]) }
    items = @classifier.classify(
      search_rows: [search_row(state, "authored")],
      states: [state],
      ledger: @ledger
    )
    assert_equal(%w[red-ci-flaky], items.map { |i| i["class"] })
  end

  def test_ready_ping_only_when_changes_requested
    state = state_from_fixture("pr_authored_clean.json", "threads_handled.json")
    state["headCommittedAt"] = "2026-11-02T10:30:00Z"
    state["reviewDecision"] = nil
    items = @classifier.classify(
      search_rows: [search_row(state, "authored")],
      states: [state],
      ledger: @ledger
    )
    assert_empty(items.select { |i| i["class"] == "ready-ping" })

    state["reviewDecision"] = "CHANGES_REQUESTED"
    again = @classifier.classify(
      search_rows: [search_row(state, "authored")],
      states: [state],
      ledger: @ledger
    )
    ping = again.find { |i| i["class"] == "ready-ping" }
    refute_nil(ping)
    assert_equal("alice", ping["evidence"]["reviewer"])
  end

  def test_ready_ping_waits_for_push_after_review
    state = state_from_fixture("pr_authored_clean.json", "threads_handled.json")
    state["reviewDecision"] = "CHANGES_REQUESTED"
    [nil, "2026-11-02T09:00:00Z"].each do |committed|
      state["headCommittedAt"] = committed
      items = @classifier.classify(search_rows: [search_row(state, "authored")], states: [state], ledger: @ledger)
      assert_empty(items.select { |i| i["class"] == "ready-ping" }, committed.inspect)
    end
  end

  def test_ready_ping_id_unique_per_reviewer
    state = state_from_fixture("pr_authored_clean.json", "threads_handled.json")
    state["reviewDecision"] = "CHANGES_REQUESTED"
    state["headCommittedAt"] = "2026-11-02T10:30:00Z"
    bob = Marshal.load(Marshal.dump(state["threads"].first))
    bob["id"] = "PRRT_human2"
    bob["first"]["author"] = "bob"
    state["threads"] << bob
    items = @classifier.classify(search_rows: [search_row(state, "authored")], states: [state], ledger: @ledger)
    pings = items.select { |i| i["class"] == "ready-ping" }
    assert_equal(%w[alice bob], pings.map { |i| i["evidence"]["reviewer"] }.sort)
    assert_equal(2, pings.map { |i| i["id"] }.uniq.size)
  end

  def line_item(id, action, urgency = "batch")
    { "id" => id, "pr" => "acme/r##{id}", "class" => "x", "urgency" => urgency,
      "action" => action, "invoke" => "/x", "fingerprint" => id }
  end

  def test_line_quiet
    env = @classifier.envelope([], ledger: @ledger)
    assert_equal("ops: quiet", env["line"])
    assert_equal(false, env["dry"])
  end

  def test_line_mixed_counts
    items = [line_item("a", "ask", "urgent"), line_item("b", "judge"), line_item("c", "auto")]
    @ledger.upsert_item!(line_item("z", "ask").merge("status" => "in_flight"))
    env = @classifier.envelope(items, ledger: @ledger)
    assert_equal("ops: 2 need you (1 urgent) · 1 auto · 1 in flight", env["line"])
  end

  def test_dry_moves_auto_to_ask
    items = [line_item("a", "auto"), line_item("b", "ask")]
    env = @classifier.envelope(items, ledger: @ledger, dry: true)
    assert_empty(env["auto"])
    assert_equal(%w[ask ask], env["ask"].map { |i| i["action"] })
    assert_equal(true, env["dry"])
    assert_equal("ops: 2 need you · dry", env["line"])
    assert_equal("ops: quiet · dry", @classifier.envelope([], ledger: @ledger, dry: true)["line"])
  end

  def test_line_within_80_chars_with_many_items
    items = (1..300).map { |n| line_item(n.to_s, %w[ask judge auto][n % 3], "urgent") }
    line = @classifier.envelope(items, ledger: @ledger, dry: false)["line"]
    assert_operator(line.length, :<=, 80)
    refute_includes(line, "\n")
  end
end
