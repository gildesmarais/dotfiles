# frozen_string_literal: true

require_relative "test_helper"
require_relative "../src/ops_github/workspace"

class WorkspaceTest < Minitest::Test
  include OpsGithubTest

  def setup
    @tmpdir = Dir.mktmpdir("ops-github-wt")
    @calls = []
    @files = {
      "status" => "",
      "head" => "abc123\n",
      "branch" => "feat\n",
      "diff" => "a.rb\nb.rb\n",
      "grep" => ""
    }
    # Simpler exact matcher runner:
    @path = File.join(@tmpdir, "wt")
    FileUtils.mkdir_p(@path)
    @ws = OpsGithub::Workspace.new(
      cache_dir: File.join(@tmpdir, "cache"),
      runner: method(:run_git)
    )
  end

  def run_git(argv)
    @calls << argv
    joined = argv.join(" ")
    return @files["status"] if joined.include?("status --porcelain")
    return @files["head"] if joined.include?("rev-parse HEAD")
    return @files["branch"] if joined.include?("abbrev-ref")
    return @files["diff"] if joined.include?("diff --name-only")
    return @files["grep"] if joined.include?("grep")

    ""
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_claimed_when_tracked_changes
    @files["status"] = " M a.rb\n"
    assert(@ws.claimed?(@path))
  end

  def test_unclaimed_with_only_untracked
    @files["status"] = "?? tmp.log\n"
    refute(@ws.claimed?(@path))
  end

  def test_verify_merge_ok_when_fileset_matches
    @files["status"] = ""
    @files["grep"] = ""
    @files["diff"] = "a.rb\nb.rb\n"
    result = @ws.verify_merge(@path, base_ref: "main", before_files: %w[a.rb b.rb])
    assert_equal(true, result["ok"])
    assert_equal("abc123", result["head"])
  end

  def test_verify_merge_rejects_fileset_drift
    @files["diff"] = "a.rb\nb.rb\nc.rb\n"
    err = assert_raises(OpsGithub::ExitError) do
      @ws.verify_merge(@path, base_ref: "main", before_files: %w[a.rb b.rb])
    end
    assert_match(/file set changed/, err.message)
  end

  def test_verify_merge_rejects_conflict_markers
    @files["grep"] = "a.rb\n"
    err = assert_raises(OpsGithub::ExitError) do
      @ws.verify_merge(@path, base_ref: "main", before_files: %w[a.rb b.rb])
    end
    assert_match(/conflict markers/, err.message)
  end
end
