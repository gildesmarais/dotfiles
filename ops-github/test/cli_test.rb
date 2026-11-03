# frozen_string_literal: true

require "stringio"
require_relative "test_helper"

class CliTest < Minitest::Test
  include OpsGithubTest

  # Real Github over a recorded-shape runner: search returns +nodes+ (one page),
  # nodes(ids:) returns the requested ones. Counts gh invocations.
  class FakeRunner
    include OpsGithubTest

    attr_reader :calls

    def initialize(login: "me", orgs: [], authored: [], requested: [], missing: [])
      @missing = missing
      @login = login
      @orgs = orgs
      @authored = authored
      @requested = requested
      @calls = []
    end

    def call(argv)
      @calls << argv
      return "#{@login}\n" if argv[0, 2] == %w[api user]
      return JSON.generate(@orgs) if argv[0, 2] == %w[api user/orgs]
      raise "unexpected gh call: #{argv.inspect}" unless argv[0, 2] == %w[api graphql]
      return search_response(authored: @authored, requested: @requested) unless state_call?(argv)

      ids = argv.grep(/\Aids\[\]=/).map { |arg| arg.split("=", 2).last }
      if (bogus = ids.find { |id| @missing.include?(id) })
        raise OpsGithub::ExitError, "gh failed: Could not resolve to a node with the global id of '#{bogus}'"
      end

      nodes_response((@authored + @requested).uniq.select { |node| ids.include?(node["id"]) })
    end

    def state_call?(argv)
      argv.any? { |arg| arg.include?("nodes(ids:") }
    end

    def graphql_calls
      calls.count { |argv| argv[0, 2] == %w[api graphql] }
    end

    def state_calls
      calls.count { |argv| state_call?(argv) }
    end
  end

  def github_for(runner)
    OpsGithub::Github.new(runner: runner)
  end

  def setup
    @tmpdir = Dir.mktmpdir("ops-github-cli")
    @stdout = StringIO.new
    @stderr = StringIO.new
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def run_cli(argv, github:)
    cli = OpsGithub::CLI.new(
      ["--state-dir", @tmpdir, "--owners", "acme"] + argv,
      github: github,
      stdout: @stdout,
      stderr: @stderr
    )
    begin
      cli.run
      0
    rescue SystemExit => e
      e.status
    end
  end

  def runner_with(authored: [], requested: [], missing: [])
    FakeRunner.new(authored: authored, requested: requested, missing: missing)
  end

  def numbered_nodes(range)
    range.map do |n|
      pr_node("pr_bundler_audit.json").merge("id" => "PR_#{n}", "number" => n,
                                             "url" => "https://github.com/acme/app/pull/#{n}")
    end
  end

  def reset_output
    @stdout.truncate(0)
    @stdout.rewind
  end

  def seen_signature(node)
    github_for(runner_with(authored: [node])).discover(%w[acme]).first["signature"]
  end

  def test_setup_facts_emits_owners
    runner = FakeRunner.new(orgs: %w[acme])
    status = run_cli(["setup-facts"], github: github_for(runner))
    assert_equal(0, status)
    payload = JSON.parse(@stdout.string)
    assert_equal("me", payload["login"])
    assert_includes(payload["owners"], "acme")
  end

  def test_probe_quiet_when_seen_matches
    node = pr_node("pr_authored_clean.json")
    ledger = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    ledger.mark_seen!("acme/app#1", signature: seen_signature(node))
    status = run_cli(["probe"], github: github_for(runner_with(authored: [node])))
    assert_equal(0, status)
    assert_equal("quiet", JSON.parse(@stdout.string)["status"])
  end

  def test_probe_delta_on_new_updated_at
    OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    status = run_cli(["probe"], github: github_for(runner_with(authored: [pr_node("pr_authored_clean.json")])))
    assert_equal(10, status)
  end

  def test_probe_delta_when_rollup_fails_with_same_updated_at
    node = pr_node("pr_authored_clean.json")
    ledger = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    ledger.mark_seen!("acme/app#1", signature: seen_signature(node))
    red = JSON.parse(JSON.generate(node))
    red["commits"]["nodes"][0]["commit"]["statusCheckRollup"]["state"] = "FAILURE"
    status = run_cli(["probe"], github: github_for(runner_with(authored: [red])))
    assert_equal(node["updatedAt"], red["updatedAt"])
    assert_equal(10, status)
  end

  def test_probe_one_call_and_tick_one_plus_chunks
    nodes = (1..11).map do |n|
      pr_node("pr_authored_clean.json").merge("id" => "PR_#{n}", "number" => n,
                                              "url" => "https://github.com/acme/app/pull/#{n}")
    end
    runner = runner_with(authored: nodes)
    gh = github_for(runner)
    run_cli(["probe"], github: gh)
    assert_equal([1, 1], [runner.graphql_calls, runner.calls.size])
    run_cli(["tick"], github: gh)
    chunks = (11.0 / OpsGithub::Github::STATE_CHUNK).ceil
    assert_equal([1 + 1 + chunks, chunks], [runner.graphql_calls, runner.state_calls])
    run_cli(["tick"], github: gh)
    assert_equal([1 + (1 + chunks) + 1, chunks], [runner.graphql_calls, runner.state_calls])
  end

  def test_tick_envelope_schema
    status = run_cli(["tick"], github: github_for(runner_with(authored: [pr_node("pr_bundler_audit.json")])))
    assert_equal(10, status)
    env = JSON.parse(@stdout.string)
    assert(env.key?("status"))
    assert(env.key?("report_md"))
    assert(env.key?("auto"))
    assert(env.key?("ask"))
    assert(env.key?("judge"))
    assert_operator(env["report_md"].split("\n").size, :<=, 15)
    refute_empty(env["auto"])
  end

  def test_tick_writes_status_txt_with_line
    run_cli(["tick"], github: github_for(runner_with(authored: [pr_node("pr_bundler_audit.json")])))
    env = JSON.parse(@stdout.string)
    text = File.read(File.join(@tmpdir, "status.txt"))
    assert_match(/\A#{Regexp.escape(env['line'])} · \d\d:\d\d\n\z/, text)
  end

  def test_dry_env_demotes_auto_to_ask
    old = ENV["OPS_GITHUB_DRY"]
    ENV["OPS_GITHUB_DRY"] = "1"
    run_cli(["tick"], github: github_for(runner_with(authored: [pr_node("pr_bundler_audit.json")])))
    env = JSON.parse(@stdout.string)
    assert_equal(true, env["dry"])
    assert_empty(env["auto"])
    refute_empty(env["ask"])
  ensure
    old.nil? ? ENV.delete("OPS_GITHUB_DRY") : ENV["OPS_GITHUB_DRY"] = old
  end

  def test_tick_stamps_signature_and_skips_unchanged_on_second_tick
    gh = github_for(runner_with(authored: [pr_node("pr_bundler_audit.json")]))
    assert_equal(10, run_cli(["tick"], github: gh))
    ledger = OpsGithub::Ledger.load(OpsGithub::Ledger.day_path(@tmpdir))
    assert_equal("2026-11-02T11:00:00Z|FAILURE", ledger.seen["acme/app#2"])
    assert_equal(0, run_cli(["probe"], github: gh))
  end

  def test_doctor_ok
    status = run_cli(["doctor"], github: github_for(FakeRunner.new))
    assert_equal(0, status)
    payload = JSON.parse(@stdout.string)
    assert_equal(true, payload["state_dir_writable"])
    assert_equal(true, payload["auth_ok"])
    assert_equal(false, payload["watcher_alive"])
  end

  def test_doctor_fails_when_auth_bad
    status = run_cli(["doctor"], github: github_for(FakeRunner.new(login: "")))
    assert_equal(1, status)
  end

  def test_owners_flag_updates_existing_ledger
    OpsGithub::Ledger.init(@tmpdir, owners: %w[acme other])
    status = run_cli(["tick"], github: github_for(FakeRunner.new))
    assert_includes([0, 10], status)
    ledger = OpsGithub::Ledger.load(OpsGithub::Ledger.day_path(@tmpdir))
    assert_equal(%w[acme], ledger.owners)
  end

  def test_unknown_command
    status = run_cli(["wat"], github: github_for(FakeRunner.new))
    assert_equal(1, status)
    assert_match(/unknown command/, @stderr.string)
  end

  def test_watch_max_ticks_quiet_emits_no_wake
    node = pr_node("pr_authored_clean.json")
    ledger = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    ledger.mark_seen!("acme/app#1", signature: seen_signature(node))
    status = run_cli(["watch", "--max-ticks", "1"], github: github_for(runner_with(authored: [node])))
    assert_equal(0, status)
    refute_match(/OPS_GITHUB_WAKE/, @stdout.string)
  end

  def test_watch_max_ticks_delta_emits_wake
    OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    gh = github_for(runner_with(authored: [pr_node("pr_authored_clean.json")]))
    status = run_cli(["watch", "--max-ticks", "1"], github: gh)
    assert_equal(0, status)
    assert_match(/OPS_GITHUB_WAKE/, @stdout.string)
  end

  def test_tick_both_role_authored_pr_reports_red_ci
    node = pr_node("pr_bundler_audit.json")
    runner = runner_with(authored: [node], requested: [node])
    assert_equal(%w[both], github_for(runner).discover(%w[acme]).map { |r| r["role"] })
    assert_equal(10, run_cli(["tick"], github: github_for(runner)))
    env = JSON.parse(@stdout.string)
    classes = (env["auto"] + env["ask"] + env["judge"]).select { |i| i["pr"] == "acme/app#2" }.map { |i| i["class"] }
    assert_includes(classes, "red-ci-base")
  end

  def test_report_lists_in_flight_items_capped_at_three
    gh = github_for(FakeRunner.new)
    assert_equal(0, run_cli(["ledger", "decide", "acme/app#1", "in_flight"], github: gh))
    @stdout.truncate(0)
    @stdout.rewind
    run_cli(["tick"], github: gh)
    report = JSON.parse(@stdout.string)["report_md"]
    assert(report.end_with?("## In flight\n- acme/app#1"), report)

    %w[2 3 4].each { |n| run_cli(["ledger", "decide", "acme/app##{n}", "in_flight"], github: gh) }
    @stdout.truncate(0)
    @stdout.rewind
    run_cli(["tick"], github: gh)
    report = JSON.parse(@stdout.string)["report_md"]
    assert_equal(3, report.split("## In flight\n").last.lines.size)
  end

  def test_watch_survives_probe_crash
    gh = github_for(FakeRunner.new)
    def gh.discover(*)
      raise Errno::ENOENT, "gh"
    end
    OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    assert_equal(0, run_cli(["watch", "--max-ticks", "1"], github: gh))
    assert_match(/"urgency":"env"/, @stdout.string)
    assert_match(/probe: Errno::ENOENT/, @stderr.string)
  end

  def test_dry_switch_off_values_and_on_values
    old = ENV["OPS_GITHUB_DRY"]
    node = pr_node("pr_bundler_audit.json")
    { "0" => false, "false" => false, "NO" => false, "No" => false, "1" => true, "yes" => true, "on" => true }
      .each do |value, expected|
      ENV["OPS_GITHUB_DRY"] = value
      FileUtils.rm_rf(@tmpdir)
      reset_output
      run_cli(["tick"], github: github_for(runner_with(authored: [node])))
      assert_equal(expected, JSON.parse(@stdout.string)["dry"], value)
    end
  ensure
    old.nil? ? ENV.delete("OPS_GITHUB_DRY") : ENV["OPS_GITHUB_DRY"] = old
  end

  def test_undecided_item_reappears_with_unchanged_signature_until_pr_leaves
    gh = github_for(runner_with(authored: [pr_node("pr_bundler_audit.json")]))
    assert_equal(10, run_cli(["tick"], github: gh))
    first = JSON.parse(@stdout.string)
    refute_empty(first["auto"])
    reset_output
    assert_equal(10, run_cli(["tick"], github: gh))
    assert_equal(first["auto"], JSON.parse(@stdout.string)["auto"])
    reset_output
    assert_equal(0, run_cli(["tick"], github: github_for(runner_with)))
    assert_empty(JSON.parse(@stdout.string)["auto"])
  end

  def bumped(node, updated_at, green: false)
    node = Marshal.load(Marshal.dump(node)).merge("updatedAt" => updated_at)
    return node unless green

    commit = node["commits"]["nodes"][0]["commit"]
    commit["statusCheckRollup"]["state"] = "SUCCESS"
    commit["statusCheckRollup"]["contexts"]["nodes"].each { |c| c["conclusion"] = "SUCCESS" }
    node
  end

  def tick_json(nodes)
    reset_output
    status = run_cli(["tick"], github: github_for(runner_with(authored: nodes)))
    [status, JSON.parse(@stdout.string)]
  end

  def test_reclassified_green_pr_retires_its_stale_new_item
    red = pr_node("pr_bundler_audit.json")
    assert_equal(10, tick_json([red]).first)
    _, env = tick_json([bumped(red, "2026-11-02T12:00:00Z", green: true)])
    assert_empty(env["auto"])
    status, env = tick_json([bumped(red, "2026-11-02T12:00:00Z", green: true)])
    assert_equal(0, status)
    assert_empty(env["auto"])
    ledger = OpsGithub::Ledger.load(OpsGithub::Ledger.day_path(@tmpdir))
    assert_empty(ledger.items)
  end

  def test_cluster_with_changed_member_does_not_come_back_via_unchanged_member
    a, b = numbered_nodes(1..2)
    _, first = tick_json([a, b])
    assert_equal(%w[red-ci-shared], (first["ask"] + first["auto"]).map { |i| i["class"] }.uniq)
    _, env = tick_json([bumped(a, "2026-11-02T12:00:00Z"), b])
    reported = (env["ask"] + env["auto"]).map { |i| i["pr"] }
    assert_equal(["acme/app#1"], reported)
  end

  def test_changed_pr_keeps_its_decided_item
    red = pr_node("pr_bundler_audit.json")
    tick_json([red])
    ledger = OpsGithub::Ledger.load(OpsGithub::Ledger.day_path(@tmpdir))
    id = ledger.items.keys.first
    ledger.decide!(id, "snoozed")
    tick_json([bumped(red, "2026-11-02T12:00:00Z", green: true)])
    reloaded = OpsGithub::Ledger.load(OpsGithub::Ledger.day_path(@tmpdir))
    assert_equal("snoozed", reloaded.items[id]["status"])
  end

  def test_tick_drops_not_found_node_and_stamps_its_row
    runner = runner_with(authored: numbered_nodes(1..3), missing: %w[PR_2])
    assert_equal(10, run_cli(["tick"], github: github_for(runner)))
    assert_empty(@stderr.string)
    ledger = OpsGithub::Ledger.load(OpsGithub::Ledger.day_path(@tmpdir))
    assert_equal(%w[acme/app#1 acme/app#2 acme/app#3], ledger.seen.keys.sort)
    classified = ledger.items.values.flat_map { |i| i["pr_keys"] }.uniq.sort
    assert_equal(%w[acme/app#1 acme/app#3], classified)
  end

  def test_tick_skips_pr_closed_between_phases
    closed = pr_node("pr_bundler_audit.json").merge("state" => "CLOSED")
    assert_equal(0, run_cli(["tick"], github: github_for(runner_with(authored: [closed]))))
    assert_empty(JSON.parse(@stdout.string)["auto"])
  end

  def test_failed_state_fetch_leaves_seen_empty
    gh = github_for(runner_with(authored: [pr_node("pr_bundler_audit.json")]))
    def gh.pr_states(_ids)
      raise OpsGithub::ExitError, "gh failed: HTTP 401"
    end
    assert_equal(1, run_cli(["tick"], github: gh))
    assert_empty(OpsGithub::Ledger.load(OpsGithub::Ledger.day_path(@tmpdir)).seen)
  end
end
