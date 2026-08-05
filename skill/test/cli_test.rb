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
    @skills_dir = File.join(@dotfiles_root, "agents", "skills")
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

  def test_promote_moves_agents_skill_into_store
    local_skill = File.join(@project_root, ".agents", "skills", "my-skill")
    FileUtils.mkdir_p(local_skill)
    File.write(File.join(local_skill, "SKILL.md"), "# My Skill\n")

    result = run_skill("promote", "my-skill")

    assert_equal(0, result.exitstatus)
    assert_match(%r{promoted my-skill -> .*/agents/skills/my-skill}, result.output)
    assert_includes(result.output, "run rcup")
    refute_includes(result.output, "linked ")
    refute_includes(result.output, "npx skills")
    assert(File.directory?(File.join(@skills_dir, "my-skill")))
    refute_path_exists(local_skill)
    refute_path_exists(File.join(@agents_skills_dir, "my-skill"))
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
    assert_includes(result.output, "run rcup")
  end

  def test_rename_updates_store_and_hints_rcup
    create_store_skill("old-name")

    result = run_skill("rename", "old-name", "new-name")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "renamed old-name -> new-name")
    assert_includes(result.output, "run rcup")
    refute_includes(result.output, "linked ")
    refute_includes(result.output, "npx skills")
    assert(File.directory?(File.join(@skills_dir, "new-name")))
    refute_path_exists(File.join(@skills_dir, "old-name"))
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
    refute_includes(output, "sync")
    refute_match(/^\s+link\s/m, output)
    assert_includes(output, "doctor")
    assert_includes(output, "backfill")
  end

  def test_doctor_help_after_command_exits_zero
    result = run_skill("doctor", "--help")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "Usage: skill")
    refute_includes(result.output, "does not accept extra arguments")
    refute_includes(result.output, "Skill::ExitError")
  end

  def test_backfill_help_after_command_exits_zero
    result = run_skill("backfill", "-h")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "Usage: skill")
    refute_includes(result.output, "stored skill not found")
    refute_includes(result.output, "backfill requires exactly one skill name")
    refute_includes(result.output, "Skill::ExitError")
  end

  def test_doctor_all_ok_exits_zero
    create_store_skill("linked")
    store_file = File.join(@skills_dir, "linked", "SKILL.md")
    File.write(store_file, "# Linked\n")
    FileUtils.mkdir_p(File.join(@agents_skills_dir, "linked"))
    FileUtils.ln_s(store_file, File.join(@agents_skills_dir, "linked", "SKILL.md"))

    result = run_skill("doctor")

    assert_equal(0, result.exitstatus)
    assert_match(/^linked\s+ok$/m, result.output)
  end

  def test_doctor_mixed_union_exits_one
    create_store_skill("alpha")
    File.write(File.join(@skills_dir, "alpha", "SKILL.md"), "# A\n")

    FileUtils.mkdir_p(File.join(@agents_skills_dir, "beta"))
    File.write(File.join(@agents_skills_dir, "beta", "SKILL.md"), "# Home\n")

    create_store_skill("delta")
    File.write(File.join(@skills_dir, "delta", "SKILL.md"), "# Store\n")
    FileUtils.mkdir_p(File.join(@agents_skills_dir, "delta"))
    File.write(File.join(@agents_skills_dir, "delta", "SKILL.md"), "# Agent\n")

    FileUtils.mkdir_p(@agents_skills_dir)
    FileUtils.ln_s("missing", File.join(@agents_skills_dir, "gamma"))

    result = run_skill("doctor")

    assert_equal(1, result.exitstatus)
    lines = result.output.lines.map(&:chomp).reject(&:empty?)
    assert_equal(4, lines.length)
    lines.each { |line| assert_match(/^\S+\s+\S+$/, line) }
    status_offsets = lines.map { |line| line.index(/\S+\z/) }
    assert_equal([status_offsets.first], status_offsets.uniq, "status column should be aligned")
    assert_match(/^alpha\s+ok$/m, result.output)
    assert_match(/^beta\s+home-only$/m, result.output)
    assert_match(/^delta\s+drift$/m, result.output)
    assert_match(/^gamma\s+broken$/m, result.output)
  end

  def test_doctor_identical_real_files_ok
    create_store_skill("paired")
    File.write(File.join(@skills_dir, "paired", "SKILL.md"), "# Same\n")
    FileUtils.mkdir_p(File.join(@agents_skills_dir, "paired"))
    File.write(File.join(@agents_skills_dir, "paired", "SKILL.md"), "# Same\n")

    result = run_skill("doctor")

    assert_equal(0, result.exitstatus)
    assert_match(/^paired\s+ok$/m, result.output)
  end

  def test_doctor_pads_to_longest_name
    long_name = "improve-codebase-architecture"
    create_store_skill("grilling")
    File.write(File.join(@skills_dir, "grilling", "SKILL.md"), "# G\n")
    create_store_skill(long_name)
    File.write(File.join(@skills_dir, long_name, "SKILL.md"), "# L\n")

    result = run_skill("doctor")

    assert_equal(0, result.exitstatus)
    lines = result.output.lines.map(&:chomp).reject(&:empty?)
    status_offsets = lines.map { |line| line.index(/\S+\z/) }
    assert_equal([status_offsets.first], status_offsets.uniq, "status column should be aligned")
    assert_operator(status_offsets.first, :>=, long_name.length + 2)
    assert_match(/^grilling\s+ok$/m, result.output)
    assert_match(/^improve-codebase-architecture\s+ok$/m, result.output)
  end

  def test_doctor_empty_store_is_silent
    result = run_skill("doctor")

    assert_equal(0, result.exitstatus)
    assert_equal("", result.output)
  end

  def test_backfill_copies_drifted_files_and_preserves_store_only
    create_store_skill("drifted")
    File.write(File.join(@skills_dir, "drifted", "SKILL.md"), "# Store\n")
    File.write(File.join(@skills_dir, "drifted", "keep.md"), "keep\n")
    FileUtils.mkdir_p(File.join(@agents_skills_dir, "drifted"))
    File.write(File.join(@agents_skills_dir, "drifted", "SKILL.md"), "# Agent\n")
    File.write(File.join(@agents_skills_dir, "drifted", "extra.md"), "new\n")
    agent_skill_before = File.read(File.join(@agents_skills_dir, "drifted", "SKILL.md"))

    result = run_skill("backfill", "drifted")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "SKILL.md")
    assert_includes(result.output, "extra.md")
    assert_includes(result.output, "run rcup")
    assert_equal("# Agent\n", File.read(File.join(@skills_dir, "drifted", "SKILL.md")))
    assert_equal("new\n", File.read(File.join(@skills_dir, "drifted", "extra.md")))
    assert_equal("keep\n", File.read(File.join(@skills_dir, "drifted", "keep.md")))
    assert_equal(agent_skill_before, File.read(File.join(@agents_skills_dir, "drifted", "SKILL.md")))
  end

  def test_backfill_refuses_home_only
    FileUtils.mkdir_p(File.join(@agents_skills_dir, "third-party"))
    File.write(File.join(@agents_skills_dir, "third-party", "SKILL.md"), "# Home\n")

    result = run_skill("backfill", "third-party")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "refusing to backfill home-only skill: third-party")
  end

  def test_backfill_refuses_broken
    create_store_skill("broken")
    FileUtils.mkdir_p(@agents_skills_dir)
    FileUtils.ln_s("missing", File.join(@agents_skills_dir, "broken"))

    result = run_skill("backfill", "broken")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "refusing to backfill broken agent path: broken")
  end

  def test_backfill_refuses_when_no_drift
    create_store_skill("paired")
    File.write(File.join(@skills_dir, "paired", "SKILL.md"), "# Same\n")
    FileUtils.mkdir_p(File.join(@agents_skills_dir, "paired"))
    File.write(File.join(@agents_skills_dir, "paired", "SKILL.md"), "# Same\n")

    result = run_skill("backfill", "paired")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "no real-file drift for paired")
  end

  def test_backfill_refuses_missing_store_skill
    result = run_skill("backfill", "missing")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "stored skill not found:")
  end

  def test_backfill_refuses_type_clash
    create_store_skill("clash")
    FileUtils.mkdir_p(File.join(@skills_dir, "clash", "nested"))
    File.write(File.join(@skills_dir, "clash", "nested", "keep.md"), "dir\n")
    FileUtils.mkdir_p(File.join(@agents_skills_dir, "clash"))
    File.write(File.join(@agents_skills_dir, "clash", "nested"), "file\n")

    result = run_skill("backfill", "clash")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "refusing to backfill over non-file store path:")
    assert(File.directory?(File.join(@skills_dir, "clash", "nested")))
    assert_equal("dir\n", File.read(File.join(@skills_dir, "clash", "nested", "keep.md")))
  end

  def test_backfill_requires_exactly_one_name
    result = run_skill("backfill")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "backfill requires exactly one skill name")
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

  def refute_path_exists(path)
    refute(File.exist?(path) || File.symlink?(path), "Expected #{path} to be absent")
  end
end
