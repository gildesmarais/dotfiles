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

  def test_parked_label_suppresses_authored_blockers
    state = state_from_fixture("pr_bundler_audit.json")
    state["labels"] = ["On-Hold"]
    items = @classifier.classify(search_rows: [search_row(state, "authored")], states: [state], ledger: @ledger)
    assert_empty(items)
  end

  def test_parked_labels_are_configurable
    state = state_from_fixture("pr_bundler_audit.json")
    state["labels"] = ["on-hold"]
    classifier = OpsGithub::Classifier.new(login: "me", parked_labels: %w[waiting-on-product])
    items = classifier.classify(search_rows: [search_row(state, "authored")], states: [state], ledger: @ledger)
    refute_empty(items)
    state["labels"] = ["Waiting-On-Product"]
    assert_empty(classifier.classify(search_rows: [search_row(state, "authored")], states: [state], ledger: @ledger))
  end

  def test_parked_label_keeps_review_request_on_others_pr
    state = state_from_fixture("pr_review_requested.json")
    state["labels"] = ["do-not-merge"]
    items = @classifier.classify(search_rows: [search_row(state, "review-requested")], states: [state],
                                 ledger: @ledger)
    assert_equal(%w[review-requested], items.map { |i| i["class"] })
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
    assert_equal(%w[acme/app#2 acme/app#22], shared.first["pr_keys"])
    assert_equal(%w[acme/app#2 acme/app#22], @ledger.items[shared.first["id"]]["pr_keys"])
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
    env = @classifier.envelope(items, ledger: @ledger)
    assert_equal(state["title"], env["ask"].first["title"])
    assert_equal(state["title"], @ledger.items[req["id"]]["title"])
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

  # Issue state through the production discover + states path.
  def issue_state(number)
    gh = OpsGithub::Github.new(runner: ->(_) { search_response(assigned: [issue_node(number)]) })
    gh.states(gh.discover(%w[acme])).first
  end

  def test_issue_yields_one_ask_and_never_auto
    state = issue_state(5).merge("isDraft" => true, "failing_checks" => [{ "name" => "bundler_audit" }])
    items = @classifier.classify(search_rows: [], states: [state], ledger: @ledger)
    assert_equal([%w[issue-assigned ask batch]], items.map { |i| i.values_at("class", "action", "urgency") })
    env = @classifier.envelope(items, ledger: @ledger, dry: true)
    assert_empty(env["auto"])
    assert_equal(%w[issue-assigned], env["ask"].map { |i| i["class"] })
  end

  def test_report_ranks_pr_items_ahead_of_issues_at_equal_urgency
    issues = (11..19).map { |n| issue_state(n) }
    pr = state_from_fixture("pr_bot_thread.json", "threads_bot_open.json")
    items = @classifier.classify(search_rows: [search_row(pr, "authored")], states: issues + [pr], ledger: @ledger)
    lines = @classifier.envelope(items, ledger: @ledger)["report_md"].lines.select { |l| l.start_with?("- ") }
    assert_equal(8, lines.size)
    assert_includes(lines.first, "bot-thread")
    assert_includes(lines.last, "acme/app#17: issue-assigned")
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

  def classes_for(state, role)
    @classifier.classify(search_rows: [search_row(state, role)], states: [state], ledger: @ledger)
  end

  def approved_state
    state = state_from_fixture("pr_authored_clean.json")
    state["reviewDecision"] = "APPROVED"
    state
  end

  def reviewed_state
    state = state_from_fixture("pr_review_requested.json")
    state["reviews"] = [{ "author" => "me", "state" => "COMMENTED", "submittedAt" => "2026-11-02T12:10:00Z",
                          "commit_oid" => state["headRefOid"] }]
    state
  end

  def thread_reply(author, created_at, id: 3001, first_author: "me", resolved: false)
    comment = ->(who, at, cid) { { "databaseId" => cid, "author" => who, "body" => "b", "createdAt" => at } }
    { "id" => "PRRT_#{id}", "isResolved" => resolved, "bot" => false,
      "first" => comment.call(first_author, "2026-11-02T12:10:00Z", id - 1),
      "last" => comment.call(author, created_at, id) }
  end

  def test_ticket_key_prefers_title_then_branch
    key = ->(title, branch = nil) { OpsGithub::Classifier.ticket_key("title" => title, "headRefName" => branch) }
    assert_equal("ABC-1476", key.call("[ABC-1476] align things"))
    assert_equal("ABC-1476", key.call("ABC-1476: align", "feat/OPS-2950/x"))
    assert_equal("OPS-2950", key.call("no key here", "feat/OPS-2950/some-thing"))
    assert_equal("ABC-1476", key.call("x", "ABC-1476-align-things"))
    assert_nil(key.call("no key", "main"))
    assert_nil(key.call(nil, nil))
  end

  def test_ticket_key_ignores_pseudo_keys_and_lowercase
    key = ->(title, branch = nil) { OpsGithub::Classifier.ticket_key("title" => title, "headRefName" => branch) }
    %w[UTF-8 SHA-1 SHA-256 ISO-8601 HTTP-2 CVE-2024-1234 RFC-7231 PEP-8].each do |pseudo|
      assert_nil(key.call("support #{pseudo} here"), pseudo)
    end
    assert_equal("ABC-12", key.call("use UTF-8 and SHA-256 for ABC-12"))
    assert_equal("ABC-9", key.call("Fix UTF-8 handling", "ABC-9-fix"))
    assert_nil(key.call("abc-12 lower", "xABC-12"))
  end

  def test_ticket_is_stamped_on_items_board_and_envelope
    state = state_from_fixture("pr_bundler_audit.json").merge("title" => "[ABC-77] bump")
    items = classes_for(state, "authored")
    assert_equal(["ABC-77"], items.map { |i| i["ticket"] }.uniq)
    assert_equal("ABC-77", @classifier.envelope(items, ledger: @ledger)["auto"].first["ticket"])
    assert_equal("ABC-77", @ledger.items[items.first["id"]]["ticket"])
    plain = classes_for(state_from_fixture("pr_review_requested.json"), "review-requested")
    assert_nil(plain.first["ticket"])
    assert(plain.first.key?("ticket"))
  end

  def test_ready_to_merge_is_a_urgent_click
    items = classes_for(approved_state, "authored")
    assert_equal([%w[ready-to-merge click urgent]], items.map { |i| i.values_at("class", "action", "urgency") })
    assert_equal("merge https://github.com/acme/app/pull/1", items.first["invoke"])
    env = @classifier.envelope(items, ledger: @ledger, dry: true)
    assert_equal(%w[ready-to-merge], env["clicks"].map { |i| i["class"] })
    assert_empty(env["auto"] + env["ask"] + env["judge"])
    assert_equal("changes", env["status"])
    assert_equal("ops: 1 click · dry", env["line"])
    assert_includes(env["report_md"], "- click acme/app#1: ready-to-merge")
  end

  def test_ready_to_merge_requires_every_condition
    mutations = {
      "pending" => ->(s) { s["rollup_state"] = "PENDING" },
      "behind" => ->(s) { s["mergeStateStatus"] = "BEHIND" },
      "not approved" => ->(s) { s["reviewDecision"] = "REVIEW_REQUIRED" },
      "failing" => ->(s) { s["failing_checks"] = [{ "name" => "unit", "state" => "FAILURE" }] },
      "draft" => ->(s) { s["isDraft"] = true },
      "parked" => ->(s) { s["labels"] = ["on-hold"] }
    }
    mutations.each do |name, mutate|
      state = approved_state
      mutate.call(state)
      assert_empty(classes_for(state, "authored").select { |i| i["class"] == "ready-to-merge" }, name)
    end
    assert_empty(classes_for(approved_state, "review-requested").select { |i| i["class"] == "ready-to-merge" })
  end

  def test_unresolved_human_thread_blocks_ready_to_merge
    state = approved_state
    state["threads"] = [thread_reply("alice", "2026-11-02T12:30:00Z")]
    classes = classes_for(state, "authored").map { |i| i["class"] }
    assert_includes(classes, "unresolved-review")
    refute_includes(classes, "ready-to-merge")
    state["threads"] = [thread_reply("alice", "2026-11-02T12:30:00Z", resolved: true)]
    assert_includes(classes_for(state, "authored").map { |i| i["class"] }, "ready-to-merge")
  end

  def test_two_clicks_pluralize_in_line
    a = approved_state
    b = approved_state.merge("url" => "https://github.com/acme/app/pull/5", "number" => 5)
    items = @classifier.classify(search_rows: [search_row(a, "authored"), search_row(b, "authored")],
                                 states: [a, b], ledger: @ledger)
    assert_equal("ops: 2 clicks", @classifier.envelope(items, ledger: @ledger)["line"])
  end

  def test_decided_click_is_hidden
    item = classes_for(approved_state, "authored").first
    @ledger.decide!(item["id"], "deferred")
    env = @classifier.envelope(classes_for(approved_state, "authored"), ledger: @ledger)
    assert_empty(env["clicks"])
    assert_equal("quiet", env["status"])
  end

  def test_reviewed_pr_with_new_push_is_re_review_ask
    state = reviewed_state
    assert_empty(classes_for(state, "reviewed").select { |i| i["class"] == "re-review" })
    state["headRefOid"] = "eee555"
    item = classes_for(state, "reviewed").first
    assert_equal(%w[re-review ask urgent], item.values_at("class", "action", "urgency"))
    assert_equal("/ops-github review #{state['url']}", item["invoke"])
    assert_equal({ "since_oid" => "ddd444", "head_oid" => "eee555" }, item["evidence"])
    other = classes_for(state.merge("headRefOid" => "fff666"), "reviewed").first
    assert_equal(item["id"], other["id"])
    refute_equal(item["fingerprint"], other["fingerprint"])
  end

  def test_reviewed_pr_with_author_reply_after_review_is_re_review
    state = reviewed_state
    state["rollup_state"] = "PENDING"
    state["threads"] = [thread_reply("alice", "2026-11-02T12:30:00Z")]
    item = classes_for(state, "reviewed").first
    assert_equal("re-review", item["class"])
    assert_equal({ "comment_id" => 3001 }, item["evidence"])
    state["threads"] = [thread_reply("alice", "2026-11-02T12:05:00Z")]
    assert_empty(classes_for(state, "reviewed"))
    state["threads"] = [thread_reply("me", "2026-11-02T12:30:00Z")]
    assert_empty(classes_for(state, "reviewed"))
  end

  def test_reviewed_pr_skipped_without_my_review_or_when_approved
    state = reviewed_state
    state["headRefOid"] = "eee555"
    state["reviews"] = [{ "author" => "bob", "state" => "COMMENTED", "submittedAt" => "t", "commit_oid" => "x" }]
    assert_empty(classes_for(state, "reviewed"))
    state["reviews"] = [{ "author" => "me", "state" => "COMMENTED", "submittedAt" => "2026-11-02T12:00:00Z",
                          "commit_oid" => "ddd444" },
                        { "author" => "me", "state" => "APPROVED", "submittedAt" => "2026-11-02T12:20:00Z",
                          "commit_oid" => "ddd444" }]
    assert_empty(classes_for(state, "reviewed"))
  end

  def test_approved_then_commented_review_stays_approved
    state = reviewed_state.merge("reviewDecision" => "REVIEW_REQUIRED", "headRefOid" => "eee555")
    state["reviews"] = [{ "author" => "me", "state" => "APPROVED", "submittedAt" => "2026-11-02T12:00:00Z",
                          "commit_oid" => "ddd444" },
                        { "author" => "me", "state" => "COMMENTED", "submittedAt" => "2026-11-02T12:40:00Z",
                          "commit_oid" => "eee555" }]
    assert_empty(classes_for(state, "reviewed"))
    state["reviews"] << { "author" => "me", "state" => "CHANGES_REQUESTED", "submittedAt" => "2026-11-02T12:50:00Z",
                          "commit_oid" => "eee555" }
    assert_equal(%w[ready-to-approve], classes_for(state, "reviewed").map { |i| i["class"] })
  end

  def test_reviewed_pr_uses_latest_review_of_mine
    state = reviewed_state
    state["headRefOid"] = "eee555"
    state["reviews"] << { "author" => "me", "state" => "COMMENTED", "submittedAt" => "2026-11-02T12:40:00Z",
                          "commit_oid" => "eee555" }
    assert_equal(%w[ready-to-approve], classes_for(state, "reviewed").map { |i| i["class"] })
  end

  def test_ready_to_approve_is_a_urgent_click_when_settled
    state = reviewed_state
    item = classes_for(state, "reviewed").first
    assert_equal(%w[ready-to-approve click urgent], item.values_at("class", "action", "urgency"))
    assert_equal("approve #{state['url']}", item["invoke"])
    bot_thread = thread_reply("copilot-pull-request-reviewer", "2026-11-02T12:30:00Z", first_author: "copilot")
    bot_thread["bot"] = true
    state["threads"] = [bot_thread, thread_reply("me", "2026-11-02T12:00:00Z", resolved: true)]
    assert_equal(%w[ready-to-approve], classes_for(state, "reviewed").map { |i| i["class"] })
  end

  def test_ready_to_approve_requires_every_condition
    mutations = {
      "pending" => ->(s) { s["rollup_state"] = "PENDING" },
      "no checks" => ->(s) { s["rollup_state"] = "" },
      "failing" => ->(s) { s["failing_checks"] = [{ "name" => "unit", "state" => "FAILURE" }] },
      "approved already" => ->(s) { s["reviewDecision"] = "APPROVED" },
      "open human thread" => ->(s) { s["threads"] = [thread_reply("me", "2026-11-02T12:00:00Z")] }
    }
    mutations.each do |name, mutate|
      state = reviewed_state
      mutate.call(state)
      assert_empty(classes_for(state, "reviewed"), name)
    end
  end

  def test_reviewed_role_never_yields_authored_items
    state = reviewed_state.merge("labels" => [], "mergeable" => "CONFLICTING", "reviewDecision" => "CHANGES_REQUESTED",
                                 "failing_checks" => [{ "name" => "unit", "state" => "FAILURE" }])
    assert_empty(classes_for(state, "reviewed"))
    assert_equal(%w[review-requested], classes_for(state, "review-requested").map { |i| i["class"] })
  end

  def board_state(number, **fields)
    state = state_from_fixture("pr_authored_clean.json")
    state.merge!("url" => "https://github.com/acme/app/pull/#{number}", "number" => number,
                 "title" => "[ABC-#{number}] t#{number}")
    state.merge(fields.transform_keys(&:to_s))
  end

  def test_board_summarizes_authored_prs_and_survives_partial_ticks
    states = [
      board_state(1, mergeStateStatus: "BEHIND", reviewDecision: "APPROVED"),
      board_state(2, reviewDecision: "REVIEW_REQUIRED", mergeStateStatus: "BLOCKED"),
      board_state(3, reviewDecision: "REVIEW_REQUIRED", mergeStateStatus: "DIRTY", mergeable: "CONFLICTING"),
      board_state(4, isDraft: true, reviewDecision: "REVIEW_REQUIRED"),
      board_state(5, labels: ["on-hold"], mergeStateStatus: "BEHIND"),
      board_state(6, mergeStateStatus: "BEHIND", failing_checks: [{ "name" => "u", "state" => "FAILURE" }]),
      board_state(7, reviewDecision: "REVIEW_REQUIRED", mergeStateStatus: "BEHIND")
    ]
    rows = states.map { |s| search_row(s, "authored") }
    @classifier.classify(search_rows: rows, states: states, ledger: @ledger)
    board = @classifier.envelope([], ledger: @ledger)["board"]
    assert_equal(%w[acme/app#1 acme/app#7], board["behind"].map { |e| e["pr"] })
    assert_equal({ "pr" => "acme/app#1", "url" => states[0]["url"], "title" => "[ABC-1] t1", "ticket" => "ABC-1",
                   "reviewDecision" => "APPROVED" }, board["behind"].first)
    assert_equal([{ "pr" => "acme/app#2", "url" => states[1]["url"], "title" => "[ABC-2] t2", "ticket" => "ABC-2",
                    "rollup_state" => "SUCCESS" }], board["waiting_review"])
    assert_equal(2, board["parked_count"])
    # A later tick that refetches only PR 2 leaves the other entries intact.
    changed = board_state(2, reviewDecision: "APPROVED")
    @classifier.classify(search_rows: [search_row(changed, "authored")], states: [changed], ledger: @ledger)
    board = @classifier.envelope([], ledger: @ledger)["board"]
    assert_empty(board["waiting_review"])
    assert_equal(%w[acme/app#1 acme/app#7], board["behind"].map { |e| e["pr"] })
  end

  def test_board_ignores_reviewed_and_requested_prs
    state = reviewed_state.merge("mergeStateStatus" => "BEHIND")
    classes_for(state, "reviewed")
    classes_for(state, "review-requested")
    assert_equal({ "behind" => [], "waiting_review" => [], "parked_count" => 0 },
                 @classifier.envelope([], ledger: @ledger)["board"])
  end
end
