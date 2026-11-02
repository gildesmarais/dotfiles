# frozen_string_literal: true

require_relative "test_helper"

class LedgerTest < Minitest::Test
  include OpsGithubTest

  def setup
    @tmpdir = Dir.mktmpdir("ops-github-ledger")
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_init_creates_day_file_and_md
    ledger = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme me])
    assert(File.file?(ledger.path))
    assert(File.file?(ledger.path.sub(/\.json\z/, ".md")))
    assert_equal(%w[acme me], ledger.owners)
  end

  def test_init_updates_owners_on_existing_day_file
    OpsGithub::Ledger.init(@tmpdir, owners: %w[acme other])
    ledger = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    assert_equal(%w[acme], ledger.owners)
  end

  def test_decide_accepts_done
    ledger = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    item = ledger.decide!("abc", "done")
    assert_equal("done", item["status"])
  end

  def test_carry_over_exclusions_and_decisions
    day = Date.new(2026, 11, 1)
    first = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme], date: day)
    first.exclude!("acme/app#1")
    first.decide!("abc", "snoozed", "pr" => "acme/app#2")
    second = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme], date: day + 1)
    assert_includes(second.exclusions, "acme/app#1")
    assert_equal("snoozed", second.items["abc"]["status"])
  end

  def test_echo_suppression
    ledger = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    ledger.mark_seen!("acme/app#1", updated_at: "t1", head_sha: "sha1")
    ledger.record_echo!(shas: ["sha2"])
    refute(ledger.changed_since_seen?("acme/app#1", updated_at: "t2", head_sha: "sha2"))
    assert(ledger.changed_since_seen?("acme/app#1", updated_at: "t2", head_sha: "sha3"))
  end

  def test_probe_ignores_head_when_only_timestamp_compared
    ledger = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    ledger.mark_seen!("acme/app#1", updated_at: "t1", head_sha: "sha1")
    refute(ledger.changed_since_seen?("acme/app#1", updated_at: "t1"))
    assert(ledger.changed_since_seen?("acme/app#1", updated_at: "t2"))
  end

  def test_upsert_does_not_reset_asked_same_fingerprint
    ledger = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    item = { "id" => "x1", "fingerprint" => "fp1", "class" => "red-ci", "status" => "new" }
    ledger.upsert_item!(item)
    ledger.decide!("x1", "asked")
    again = ledger.upsert_item!(item.merge("status" => "new"))
    assert_equal("asked", again["status"])
  end

  def test_watcher_alive_false_for_missing_pid
    ledger = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    ledger.watcher_pid = 9_999_999
    refute(ledger.watcher_alive?)
  end
end
