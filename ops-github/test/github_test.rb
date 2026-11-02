# frozen_string_literal: true

require_relative "test_helper"

class GithubTest < Minitest::Test
  include OpsGithubTest

  def test_read_back_accepts_matching_body
    runner = lambda do |_argv|
      JSON.generate("id" => 42, "html_url" => "https://example/c/42", "body" => "hello")
    end
    gh = OpsGithub::Github.new(runner: runner)
    result = gh.post_issue_comment("o", "r", 1, "hello")
    assert_equal(true, result["ok"])
    assert_equal(42, result["id"])
  end

  def test_read_back_rejects_mismatch
    runner = lambda do |_argv|
      JSON.generate("id" => 42, "body" => "other")
    end
    gh = OpsGithub::Github.new(runner: runner)
    err = assert_raises(OpsGithub::ExitError) do
      gh.post_issue_comment("o", "r", 1, "hello")
    end
    assert_match(/mismatch/, err.message)
  end

  def test_truncate_thread_body
    gh = OpsGithub::Github.new(runner: ->(_) { "{}" })
    long = "x" * 300
    node = {
      "id" => "t1",
      "isResolved" => false,
      "isOutdated" => false,
      "comments" => {
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
end
