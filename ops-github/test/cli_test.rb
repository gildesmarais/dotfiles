# frozen_string_literal: true

require "stringio"
require_relative "test_helper"

class CliTest < Minitest::Test
  include OpsGithubTest

  FakeGithub = Struct.new(:facts, :rows, :states, :login) do
    def setup_facts
      self.login = facts["login"]
      facts
    end

    def search_prs(_owners, role)
      rows.select { |r| [role, "both"].include?(r["role"]) }
    end

    def pr_states(urls)
      states.select { |s| urls.include?(s["url"]) }
    end
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

  def test_setup_facts_emits_owners
    gh = FakeGithub.new(
      { "login" => "me", "owners" => %w[acme me], "auth_ok" => true },
      [],
      [],
      nil
    )
    status = run_cli(["setup-facts"], github: gh)
    assert_equal(0, status)
    payload = JSON.parse(@stdout.string)
    assert_equal("me", payload["login"])
    assert_includes(payload["owners"], "acme")
  end

  def test_probe_quiet_when_seen_matches
    state = state_from_fixture("pr_authored_clean.json")
    row = search_row(state, "authored")
    gh = FakeGithub.new(
      { "login" => "me", "owners" => %w[acme], "auth_ok" => true },
      [row],
      [state],
      "me"
    )
    ledger = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    # Tick stores a real oid; probe must quiet on matching updatedAt alone.
    ledger.mark_seen!("acme/app#1", updated_at: row["updatedAt"], head_sha: state["headRefOid"])
    status = run_cli(["probe"], github: gh)
    assert_equal(0, status)
    assert_equal("quiet", JSON.parse(@stdout.string)["status"])
  end

  def test_probe_delta_on_new_updated_at
    state = state_from_fixture("pr_authored_clean.json")
    row = search_row(state, "authored")
    gh = FakeGithub.new(
      { "login" => "me", "owners" => %w[acme], "auth_ok" => true },
      [row],
      [state],
      "me"
    )
    OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    status = run_cli(["probe"], github: gh)
    assert_equal(10, status)
  end

  def test_tick_envelope_schema
    state = state_from_fixture("pr_bundler_audit.json")
    row = search_row(state, "authored")
    gh = FakeGithub.new(
      { "login" => "me", "owners" => %w[acme], "auth_ok" => true },
      [row],
      [state],
      "me"
    )
    status = run_cli(["tick"], github: gh)
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

  def test_doctor_ok
    gh = FakeGithub.new(
      { "login" => "me", "owners" => %w[me], "auth_ok" => true },
      [],
      [],
      "me"
    )
    status = run_cli(["doctor"], github: gh)
    assert_equal(0, status)
    payload = JSON.parse(@stdout.string)
    assert_equal(true, payload["state_dir_writable"])
    assert_equal(true, payload["auth_ok"])
    assert_equal(false, payload["watcher_alive"])
  end

  def test_doctor_fails_when_auth_bad
    gh = FakeGithub.new(
      { "login" => "", "owners" => [], "auth_ok" => false },
      [],
      [],
      ""
    )
    status = run_cli(["doctor"], github: gh)
    assert_equal(1, status)
  end

  def test_owners_flag_updates_existing_ledger
    OpsGithub::Ledger.init(@tmpdir, owners: %w[acme other])
    gh = FakeGithub.new(
      { "login" => "me", "owners" => %w[acme], "auth_ok" => true },
      [],
      [],
      "me"
    )
    status = run_cli(["tick"], github: gh)
    assert_includes([0, 10], status)
    ledger = OpsGithub::Ledger.load(OpsGithub::Ledger.day_path(@tmpdir))
    assert_equal(%w[acme], ledger.owners)
  end

  def test_unknown_command
    gh = FakeGithub.new({ "login" => "me", "owners" => [], "auth_ok" => true }, [], [], "me")
    status = run_cli(["wat"], github: gh)
    assert_equal(1, status)
    assert_match(/unknown command/, @stderr.string)
  end

  def test_watch_max_ticks_quiet_emits_no_wake
    state = state_from_fixture("pr_authored_clean.json")
    row = search_row(state, "authored")
    gh = FakeGithub.new(
      { "login" => "me", "owners" => %w[acme], "auth_ok" => true },
      [row],
      [state],
      "me"
    )
    ledger = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    ledger.mark_seen!("acme/app#1", updated_at: row["updatedAt"], head_sha: state["headRefOid"])
    status = run_cli(["watch", "--max-ticks", "1"], github: gh)
    assert_equal(0, status)
    refute_match(/OPS_GITHUB_WAKE/, @stdout.string)
  end

  def test_watch_max_ticks_delta_emits_wake
    state = state_from_fixture("pr_authored_clean.json")
    row = search_row(state, "authored")
    gh = FakeGithub.new(
      { "login" => "me", "owners" => %w[acme], "auth_ok" => true },
      [row],
      [state],
      "me"
    )
    OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    status = run_cli(["watch", "--max-ticks", "1"], github: gh)
    assert_equal(0, status)
    assert_match(/OPS_GITHUB_WAKE/, @stdout.string)
  end

  def test_tick_both_role_authored_pr_reports_red_ci
    state = state_from_fixture("pr_bundler_audit.json")
    gh = FakeGithub.new(
      { "login" => "me", "owners" => %w[acme], "auth_ok" => true },
      [search_row(state, "both")],
      [state],
      "me"
    )
    assert_equal(10, run_cli(["tick"], github: gh))
    env = JSON.parse(@stdout.string)
    classes = (env["auto"] + env["ask"] + env["judge"]).select { |i| i["pr"] == "acme/app#2" }.map { |i| i["class"] }
    assert_includes(classes, "red-ci-base")
  end

  def test_report_lists_in_flight_items_capped_at_three
    gh = FakeGithub.new(
      { "login" => "me", "owners" => %w[acme], "auth_ok" => true },
      [],
      [],
      "me"
    )
    assert_equal(0, run_cli(["ledger", "decide", "acme/app#1", "in_flight"], github: gh))
    @stdout.truncate(0)
    @stdout.rewind
    run_cli(["tick"], github: gh)
    report = JSON.parse(@stdout.string)["report_md"]
    assert_includes(report, "## In flight\n- acme/app#1\n## Waiting on others")

    %w[2 3 4].each { |n| run_cli(["ledger", "decide", "acme/app##{n}", "in_flight"], github: gh) }
    @stdout.truncate(0)
    @stdout.rewind
    run_cli(["tick"], github: gh)
    report = JSON.parse(@stdout.string)["report_md"]
    assert_equal(3, report[/## In flight\n(.*?)## Waiting/m, 1].lines.size)
    assert_includes(report, "## Waiting on others")
  end

  def test_watch_survives_probe_crash
    gh = FakeGithub.new({ "login" => "me", "owners" => %w[acme], "auth_ok" => true }, [], [], "me")
    def gh.search_prs(*)
      raise Errno::ENOENT, "gh"
    end
    OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    assert_equal(0, run_cli(["watch", "--max-ticks", "1"], github: gh))
    assert_match(/"urgency":"env"/, @stdout.string)
    assert_match(/probe: Errno::ENOENT/, @stderr.string)
  end
end
