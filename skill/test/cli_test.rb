# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "rbconfig"
require "tmpdir"

require_relative "../src/skill/filesystem"

class SkillCliTest < Minitest::Test
  Result = Struct.new(:output, :exitstatus)

  def setup
    @tmpdir = Dir.mktmpdir("skill-cli-test")
    @dotfiles_root = File.join(@tmpdir, "dotfiles")
    @project_root = File.join(@tmpdir, "project")
    @home_dir = File.join(@tmpdir, "home")
    @agents_skills_dir = File.join(@home_dir, ".agents", "skills")
    @script_path = File.join(@dotfiles_root, "scripts", "skill")
    @skill_root = File.join(@dotfiles_root, "skill")
    @skills_dir = File.join(@dotfiles_root, "skills")
    @cli_path = File.join(@skill_root, "src", "cli.rb")

    FileUtils.mkdir_p(File.dirname(@script_path))
    FileUtils.mkdir_p(@skills_dir)
    FileUtils.mkdir_p(@skill_root)
    FileUtils.mkdir_p(@home_dir)

    FileUtils.cp(File.expand_path("../../scripts/skill", __dir__), @script_path)
    FileUtils.cp_r(File.expand_path("../src", __dir__), @skill_root)
    FileUtils.chmod("+x", @script_path)

    FileUtils.mkdir_p(@project_root)
    system("git", "init", "-q", @project_root, exception: true)
    system("git", "-C", @project_root, "config", "user.name", "Test User", exception: true)
    system("git", "-C", @project_root, "config", "user.email", "test@example.com", exception: true)
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_unknown_command_exits_with_explicit_error
    result = run_skill("wat")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "skill: unknown command: wat")
  end

  def test_list_ignores_hidden_store_directories
    create_store_skill(".hidden")
    create_store_skill("ruby-dev")

    result = run_skill("list")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "ruby-dev")
    refute_includes(result.output, ".hidden")
  end

  def test_promote_moves_agents_skill_into_store_and_links
    local_skill = File.join(@project_root, ".agents", "skills", "my-skill")
    FileUtils.mkdir_p(local_skill)
    File.write(File.join(local_skill, "SKILL.md"), "# My Skill\n")

    result = run_skill("promote", "my-skill")

    assert_equal(0, result.exitstatus)
    assert_match(%r{promoted my-skill -> .*/skills/my-skill}, result.output)
    assert_match(%r{linked my-skill -> .*/\.agents/skills/my-skill}, result.output)
    refute_includes(result.output, "npx skills")
    assert(File.directory?(File.join(@skills_dir, "my-skill")))
    refute_path_exists(local_skill)
    assert_agent_symlink("my-skill")
  end

  def test_promote_rejects_legacy_codex_skills_path
    legacy_skill = File.join(@project_root, ".codex", "skills", "my-skill")
    FileUtils.mkdir_p(legacy_skill)
    File.write(File.join(legacy_skill, "SKILL.md"), "# Legacy\n")

    result = run_skill("promote", "my-skill")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "refusing to promote from deprecated .codex/skills/my-skill")
    assert(File.directory?(legacy_skill))
    refute_path_exists(File.join(@skills_dir, "my-skill"))
  end

  def test_promote_uses_custom_project_root
    custom_project = File.join(@tmpdir, "custom-project")
    local_skill = File.join(custom_project, ".agents", "skills", "my-skill")
    FileUtils.mkdir_p(local_skill)

    result = run_skill("--project", custom_project, "promote", "my-skill")

    assert_equal(0, result.exitstatus)
    assert(File.directory?(File.join(@skills_dir, "my-skill")))
    refute_path_exists(local_skill)
    assert_agent_symlink("my-skill")
  end

  def test_rename_retargets_agent_symlink
    create_store_skill("old-name")
    FileUtils.mkdir_p(@agents_skills_dir)
    FileUtils.ln_s(File.join(@skills_dir, "old-name"), File.join(@agents_skills_dir, "old-name"))

    result = run_skill("rename", "old-name", "new-name")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "renamed old-name -> new-name")
    assert_match(%r{linked new-name -> .*/\.agents/skills/new-name}, result.output)
    refute_includes(result.output, "npx skills")
    assert(File.directory?(File.join(@skills_dir, "new-name")))
    refute_path_exists(File.join(@skills_dir, "old-name"))
    refute_path_exists(File.join(@agents_skills_dir, "old-name"))
    assert_agent_symlink("new-name")
  end

  def test_rename_raises_when_destination_exists_in_store
    create_store_skill("old-name")
    create_store_skill("new-name")

    result = run_skill("rename", "old-name", "new-name")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "destination already exists in dotfiles")
    assert(File.directory?(File.join(@skills_dir, "old-name")))
    assert(File.directory?(File.join(@skills_dir, "new-name")))
  end

  def test_sync_creates_and_replaces_symlinks
    create_store_skill("alpha")
    create_store_skill("beta")
    FileUtils.mkdir_p(@agents_skills_dir)
    FileUtils.ln_s("/tmp/wrong-target", File.join(@agents_skills_dir, "beta"))

    result = run_skill("sync")

    assert_equal(0, result.exitstatus)
    assert_match(%r{linked alpha -> .*/\.agents/skills/alpha}, result.output)
    assert_match(%r{relinked beta -> .*/\.agents/skills/beta}, result.output)
    assert_agent_symlink("alpha")
    assert_agent_symlink("beta")
  end

  def test_sync_fail_closed_on_real_directory
    create_store_skill("alpha")
    collision = File.join(@agents_skills_dir, "alpha")
    FileUtils.mkdir_p(collision)
    File.write(File.join(collision, "SKILL.md"), "# real copy\n")

    result = run_skill("sync")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "refusing to overwrite non-symlink at #{collision}")
    assert_includes(result.output, "remove it then re-run skill sync")
    assert(File.directory?(collision))
    refute(File.symlink?(collision))
  end

  def test_sync_prunes_stale_store_owned_symlinks_only
    create_store_skill("kept")
    FileUtils.mkdir_p(@agents_skills_dir)
    FileUtils.ln_s(File.join(@skills_dir, "kept"), File.join(@agents_skills_dir, "kept"))
    FileUtils.ln_s(File.join(@skills_dir, "gone"), File.join(@agents_skills_dir, "gone"))
    FileUtils.ln_s("/usr/bin", File.join(@agents_skills_dir, "vendor-link"))
    vendor_dir = File.join(@agents_skills_dir, "vendor-real")
    FileUtils.mkdir_p(vendor_dir)

    result = run_skill("sync")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "pruned stale symlink #{File.join(@agents_skills_dir, 'gone')}")
    assert_agent_symlink("kept")
    refute_path_exists(File.join(@agents_skills_dir, "gone"))
    assert(File.symlink?(File.join(@agents_skills_dir, "vendor-link")))
    assert(File.directory?(vendor_dir))
  end

  def test_cli_file_runs_when_executed_directly
    output, status = Open3.capture2e(
      { "HOME" => @home_dir },
      RbConfig.ruby,
      @cli_path,
      "help",
      chdir: @project_root
    )

    assert_equal(0, status.exitstatus)
    assert_includes(output, "Usage: skill")
    assert_includes(output, "sync")
    refute_match(/^\s+link\s/m, output)
    refute_includes(output, "doctor")
  end

  private

  def run_skill(*args)
    output, status = Open3.capture2e(
      { "HOME" => @home_dir },
      RbConfig.ruby,
      @script_path,
      *args,
      chdir: @project_root
    )

    Result.new(output, status.exitstatus)
  end

  def create_store_skill(name)
    FileUtils.mkdir_p(File.join(@skills_dir, name))
  end

  def assert_agent_symlink(name)
    link_path = File.join(@agents_skills_dir, name)
    store_path = File.join(@skills_dir, name)

    assert(File.symlink?(link_path), "Expected symlink at #{link_path}")
    assert(
      Skill::Filesystem.symlink_points_to?(link_path, store_path),
      "Expected #{link_path} to point at #{store_path}"
    )
  end

  def refute_path_exists(path)
    refute(File.exist?(path) || File.symlink?(path), "Expected #{path} to be absent")
  end
end
