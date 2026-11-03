# frozen_string_literal: true

require_relative "test_helper"

class GithubTest < Minitest::Test
  include OpsGithubTest

  def test_truncate_thread_body
    gh = OpsGithub::Github.new(runner: ->(_) { "{}" })
    long = "x" * 300
    node = {
      "id" => "t1",
      "isResolved" => false,
      "first" => {
        "nodes" => [
          { "databaseId" => 1, "author" => { "login" => "copilot-pull-request-reviewer" },
            "body" => long, "createdAt" => "t", "path" => "a.rb" }
        ]
      }
    }
    thread = gh.send(:normalize_thread, node)
    assert_operator(thread["first"]["body"].length, :<=, OpsGithub::Github::THREAD_BODY_MAX)
    assert(thread["bot"])
  end

  def test_pr_states_batch_preserves_order
    urls = %w[
      https://github.com/acme/app/pull/1
      https://github.com/acme/app/pull/2
      https://github.com/acme/app/pull/3
    ]
    calls = Queue.new
    runner = lambda do |argv|
      if argv[0] == "pr" && argv[1] == "view"
        url = argv[2]
        calls << url
        sleep 0.01
        num = url[%r{/pull/(\d+)}, 1].to_i
        JSON.generate(
          "url" => url,
          "number" => num,
          "title" => "t#{num}",
          "author" => { "login" => "me" },
          "isDraft" => false,
          "baseRefName" => "main",
          "headRefName" => "feat",
          "headRefOid" => "abc",
          "mergeable" => "MERGEABLE",
          "mergeStateStatus" => "CLEAN",
          "reviewDecision" => nil,
          "updatedAt" => "t",
          "statusCheckRollup" => []
        )
      elsif argv[0] == "api" && argv[1] == "graphql"
        JSON.generate("data" => { "repository" => { "pullRequest" => { "reviewThreads" => { "nodes" => [] } } } })
      else
        "{}"
      end
    end
    gh = OpsGithub::Github.new(runner: runner)
    states = gh.send(:pr_states_batch, urls)
    assert_equal([1, 2, 3], states.map { |s| s["number"] })
    assert_equal(3, states.size)
  end

  def test_setup_facts_reads_login_and_orgs
    runner = lambda do |argv|
      joined = argv.join(" ")
      return "me\n" if joined.include?("api user --jq .login")
      return %w[acme beta].to_json if joined.include?("api user/orgs")

      "{}"
    end
    gh = OpsGithub::Github.new(runner: runner)
    facts = gh.setup_facts
    assert_equal("me", facts["login"])
    assert_includes(facts["owners"], "acme")
    assert_equal(true, facts["auth_ok"])
  end

  def test_pr_state_reads_head_commit_and_last_thread_comment
    url = "https://github.com/acme/app/pull/1"
    threads = fixture("threads_handled.json")
    threads["data"]["repository"]["pullRequest"]["commits"] =
      { "nodes" => [{ "commit" => { "committedDate" => "2026-11-02T10:30:00Z" } }] }
    runner = lambda do |argv|
      return File.read(File.join(FIXTURES, "pr_authored_clean.json")) if argv[0] == "pr"

      JSON.generate(threads)
    end
    state = OpsGithub::Github.new(runner: runner).pr_states([url]).first
    assert_equal("2026-11-02T10:30:00Z", state["headCommittedAt"])
    assert_equal("me", state["threads"].first["last"]["author"])
    assert_equal("alice", state["threads"].first["first"]["author"])
  end
end
