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
    ledger.mark_seen!("acme/app#1", updated_at: row["updatedAt"], head_sha: row["updatedAt"])
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
  end

  def test_unknown_command
    gh = FakeGithub.new({ "login" => "me", "owners" => [], "auth_ok" => true }, [], [], "me")
    status = run_cli(["wat"], github: gh)
    assert_equal(1, status)
    assert_match(/unknown command/, @stderr.string)
  end
end
