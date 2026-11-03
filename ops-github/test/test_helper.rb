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

  # PullRequest node as recorded inside a search response; +threads_name+
  # supplies its reviewThreads fragment.
  def pr_node(name, threads_name = nil)
    node = fixture(name)
    node["reviewThreads"] = fixture(threads_name)["reviewThreads"] if threads_name
    node
  end

  def search_page(nodes, cursor = nil)
    { "pageInfo" => { "hasNextPage" => !cursor.nil?, "endCursor" => cursor }, "nodes" => nodes }
  end

  def search_response(authored: [], requested: [], assigned: [])
    JSON.generate("data" => { "authored" => search_page(authored), "requested" => search_page(requested),
                              "assigned" => search_page(assigned) })
  end

  # Issue node as the assigned search alias returns it.
  def issue_node(number, updated_at: "2026-11-02T09:00:00Z", repo: "acme/app")
    { "id" => "I_#{number}", "url" => "https://github.com/#{repo}/issues/#{number}", "number" => number,
      "title" => "issue #{number}", "author" => { "login" => "alice" }, "updatedAt" => updated_at,
      "repository" => { "nameWithOwner" => repo } }
  end

  def nodes_response(nodes)
    JSON.generate("data" => { "nodes" => nodes })
  end

  # Builds the state through the production normalizer (Github#pr_states).
  def state_from_fixture(name, threads_name = nil)
    response = nodes_response([pr_node(name, threads_name)])
    OpsGithub::Github.new(runner: ->(_) { response }).pr_states(%w[id]).first
  end

  # Row through the production discover path (Github#discover), not a copy of it.
  def search_row(state, role)
    node = state.slice("id", "url", "number", "title", "updatedAt", "isDraft")
    node.merge!("author" => { "login" => state["author"] }, "repository" => { "nameWithOwner" => state["repository"] })
    page = role == "authored" ? { authored: [node] } : { requested: [node] }
    response = search_response(**page)
    OpsGithub::Github.new(runner: ->(_) { response }).discover(%w[acme]).first
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
