# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "tmpdir"

require_relative "../src/ops_github/error"
require_relative "../src/ops_github/github"
require_relative "../src/ops_github/ledger"
require_relative "../src/ops_github/classifier"
require_relative "../src/cli"

# Isolate default state-dir resolution (OPS_GITHUB_STATE_DIR, XDG_STATE_HOME, ~/.local/state)
# so nothing, including mutated code, can touch the real ~/.local/state/ops-github.
ISOLATED_STATE_ROOT = Dir.mktmpdir("ops-github-home")
ENV["HOME"] = ISOLATED_STATE_ROOT
ENV["XDG_STATE_HOME"] = File.join(ISOLATED_STATE_ROOT, "state")
ENV.delete("OPS_GITHUB_STATE_DIR")
Minitest.after_run { FileUtils.rm_rf(ISOLATED_STATE_ROOT) }

module OpsGithubTest
  FIXTURES = File.expand_path("fixtures", __dir__)

  def fixture(name)
    JSON.parse(File.read(File.join(FIXTURES, name)))
  end

  def state_from_fixture(name, threads_name = nil)
    raw = fixture(name)
    state = {
      "url" => raw["url"],
      "number" => raw["number"],
      "title" => raw["title"],
      "author" => (raw["author"] || {})["login"],
      "isDraft" => raw["isDraft"],
      "baseRefName" => raw["baseRefName"],
      "headRefName" => raw["headRefName"],
      "headRefOid" => raw["headRefOid"],
      "mergeable" => raw["mergeable"],
      "mergeStateStatus" => raw["mergeStateStatus"],
      "reviewDecision" => raw["reviewDecision"],
      "updatedAt" => raw["updatedAt"],
      "failing_checks" => failing_checks_from(raw),
      "checks" => Array(raw["statusCheckRollup"]),
      "threads" => [],
      "repository" => raw["url"][%r{github\.com/([^/]+/[^/]+)/}, 1]
    }
    if threads_name
      nodes = fixture(threads_name).dig("data", "repository", "pullRequest", "reviewThreads", "nodes") || []
      gh = OpsGithub::Github.new(runner: ->(_) { "{}" })
      state["threads"] = nodes.map { |n| gh.send(:normalize_thread, n) }
    end
    state
  end

  def failing_checks_from(raw)
    failed = Array(raw["statusCheckRollup"]).select do |c|
      %w[FAILURE ERROR].include?((c["conclusion"] || c["state"]).to_s.upcase)
    end
    failed.map do |c|
      { "name" => c["name"], "state" => (c["conclusion"] || c["state"]).to_s.upcase }
    end
  end

  def search_row(state, role)
    {
      "url" => state["url"],
      "repository" => state["repository"],
      "title" => state["title"],
      "number" => state["number"],
      "updatedAt" => state["updatedAt"],
      "isDraft" => state["isDraft"],
      "author" => state["author"],
      "role" => role
    }
  end
end

class StateIsolationTest < Minitest::Test
  def test_default_state_dir_resolves_under_tmp
    cli = OpsGithub::CLI.new(["doctor"])
    default = cli.send(:state_dir)
    assert_equal(File.join(ISOLATED_STATE_ROOT, "state", "ops-github"), default)
    assert_equal(ISOLATED_STATE_ROOT, Dir.home)
  end
end
