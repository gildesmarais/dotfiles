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

  def test_watcher_pid_carries_to_next_day
    day = Date.new(2026, 11, 1)
    first = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme], date: day)
    first.watcher_pid = Process.pid
    second = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme], date: day + 1)
    assert(second.watcher_alive?)
  end

  def test_changed_since_seen_compares_signature
    ledger = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    assert(ledger.changed_since_seen?("acme/app#1", signature: "t1|SUCCESS"))
    ledger.mark_seen!("acme/app#1", signature: "t1|SUCCESS")
    refute(ledger.changed_since_seen?("acme/app#1", signature: "t1|SUCCESS"))
    assert(ledger.changed_since_seen?("acme/app#1", signature: "t1|FAILURE"))
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

  def test_undecided_requires_all_pr_keys_live
    ledger = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    ledger.upsert_item!("id" => "a", "pr_keys" => %w[acme/app#1], "fingerprint" => "f")
    ledger.upsert_item!("id" => "c", "pr_keys" => %w[acme/app#2 acme/app#3], "fingerprint" => "f")
    ledger.upsert_item!("id" => "d", "pr_keys" => %w[acme/app#4], "fingerprint" => "f")
    ledger.decide!("d", "asked")
    ids = ->(keys) { ledger.undecided(keys).map { |i| i["id"] }.sort }
    assert_equal(%w[a c], ids.call(%w[acme/app#1 acme/app#2 acme/app#3 acme/app#4]))
    assert_equal(%w[a], ids.call(%w[acme/app#1 acme/app#3]))
    assert_empty(ids.call(%w[acme/app#9]))
  end

  def test_retire_stale_deletes_only_new_items_of_changed_prs
    ledger = OpsGithub::Ledger.init(@tmpdir, owners: %w[acme])
    ledger.upsert_item!("id" => "old", "pr_keys" => %w[acme/app#1 acme/app#2], "fingerprint" => "f")
    ledger.upsert_item!("id" => "fresh", "pr_keys" => %w[acme/app#1], "fingerprint" => "f")
    ledger.upsert_item!("id" => "snz", "pr_keys" => %w[acme/app#1], "fingerprint" => "f")
    ledger.decide!("snz", "snoozed")
    ledger.upsert_item!("id" => "other", "pr_keys" => %w[acme/app#9], "fingerprint" => "f")
    ledger.retire_stale!(%w[acme/app#1], %w[fresh])
    assert_equal(%w[fresh other snz], ledger.items.keys.sort)
    assert_equal(%w[fresh other snz], OpsGithub::Ledger.load(ledger.path).items.keys.sort)
  end
end
