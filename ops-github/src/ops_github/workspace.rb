# frozen_string_literal: true

require "fileutils"
require "open3"

module OpsGithub
  # Local worktrees + post-merge verification. Never force-pushes.
  class Workspace
    def initialize(cache_dir:, runner: nil)
      @cache_dir = cache_dir
      @runner = runner || method(:default_run)
    end

    # Ensure a worktree for owner/repo @ branch. Returns path hash.
    def ensure(owner_repo, branch)
      owner, repo = owner_repo.to_s.split("/", 2)
      raise ExitError, "owner/repo required" if owner.nil? || repo.nil?

      mirror = File.join(@cache_dir, "repos", owner, "#{repo}.git")
      wt = File.join(@cache_dir, "worktrees", owner, repo, branch.gsub(%r{[/\\]}, "_"))
      FileUtils.mkdir_p(File.dirname(mirror))
      FileUtils.mkdir_p(File.dirname(wt))

      unless File.directory?(mirror)
        @runner.call(["git", "clone", "--mirror", "https://github.com/#{owner}/#{repo}.git", mirror])
      end
      @runner.call(["git", "--git-dir", mirror, "fetch", "--prune", "origin"])

      if File.directory?(wt)
        ff_only!(wt)
      else
        @runner.call(["git", "--git-dir", mirror, "worktree", "add", "--detach", wt, "origin/#{branch}"])
        @runner.call(["git", "-C", wt, "checkout", "-B", branch, "origin/#{branch}"])
      end

      {
        "path" => wt,
        "branch" => branch,
        "claimed" => claimed?(wt),
        "head" => head_sha(wt)
      }
    end

    def claimed?(path)
      out = @runner.call(["git", "-C", path, "status", "--porcelain"])
      out.each_line.any? { |line| !line.start_with?("??") && !line.strip.empty? }
    end

    def head_sha(path)
      @runner.call(["git", "-C", path, "rev-parse", "HEAD"]).strip
    end

    def ff_only!(path)
      @runner.call(["git", "-C", path, "fetch", "origin"])
      branch = @runner.call(["git", "-C", path, "rev-parse", "--abbrev-ref", "HEAD"]).strip
      raise ExitError, "detached HEAD; refuse ff" if branch == "HEAD"
      raise ExitError, "worktree claimed; refuse ff" if claimed?(path)

      @runner.call(["git", "-C", path, "merge", "--ff-only", "origin/#{branch}"])
    end

    # Verify merge did not expand the PR file set vs the PR's own base.
    def verify_merge(path, base_ref:, before_files:)
      raise ExitError, "tracked changes present" if claimed?(path)

      markers = begin
        @runner.call(["git", "-C", path, "grep", "-l", "-E", "^(<<<<<<<|>>>>>>>)", "--", "."])
      rescue ExitError
        ""
      end
      raise ExitError, "conflict markers present" unless markers.to_s.strip.empty?

      after = @runner.call(["git", "-C", path, "diff", "--name-only", "#{base_ref}...HEAD"])
                     .split("\n").map(&:strip).reject(&:empty?).sort
      before = Array(before_files).map(&:strip).reject(&:empty?).sort
      unless after == before
        extra = after - before
        missing = before - after
        raise ExitError, "file set changed vs base #{base_ref}: +#{extra.inspect} -#{missing.inspect}"
      end

      { "ok" => true, "files" => after, "head" => head_sha(path) }
    end

    private

    def default_run(argv)
      out, err, status = Open3.capture3(*argv)
      raise ExitError, "command failed: #{argv.join(' ')}: #{err.strip}" unless status.success?

      out
    end
  end
end
