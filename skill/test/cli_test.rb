require "fileutils"
require "minitest/autorun"
require "open3"
require "rbconfig"
require "tmpdir"

class SkillCliTest < Minitest::Test
  Result = Struct.new(:output, :exitstatus)

  def setup
    @tmpdir = Dir.mktmpdir("skill-cli-test")
    @dotfiles_root = File.join(@tmpdir, "dotfiles")
    @project_root = File.join(@tmpdir, "project")
    @script_path = File.join(@dotfiles_root, "scripts", "skill")
    @skills_dir = File.join(@dotfiles_root, "skills")
    @cli_path = File.join(@dotfiles_root, "skill", "src", "cli.rb")

    FileUtils.mkdir_p(File.dirname(@script_path))
    FileUtils.mkdir_p(File.dirname(@cli_path))
    FileUtils.mkdir_p(@skills_dir)

    FileUtils.cp(File.expand_path("../../scripts/skill", __dir__), @script_path)
    FileUtils.cp(File.expand_path("../src/cli.rb", __dir__), @cli_path)
    FileUtils.chmod("+x", @script_path)

    FileUtils.mkdir_p(@project_root)
    system("git", "init", "-q", @project_root, exception: true)
    system("git", "-C", @project_root, "config", "user.name", "Test User", exception: true)
    system("git", "-C", @project_root, "config", "user.email", "test@example.com", exception: true)
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_global_project_option_applies_before_command
    result = run_skill("--project", "/tmp/custom-project", "status")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "skill: project: /tmp/custom-project")
  end

  def test_option_parsing_stops_at_command_boundary
    create_store_skill("ruby-dev")

    result = run_skill("link", "--project")

    assert_equal(1, result.exitstatus)
    refute(File.symlink?(File.join(@project_root, ".codex", "skills", "--project")))
  end

  def test_link_rejects_existing_non_symlink
    create_store_skill("ruby-dev")
    FileUtils.mkdir_p(File.join(@project_root, ".codex", "skills", "ruby-dev"))

    result = run_skill("link", "ruby-dev")

    assert_equal(1, result.exitstatus)
    assert(File.directory?(File.join(@project_root, ".codex", "skills", "ruby-dev")))
    refute(File.symlink?(File.join(@project_root, ".codex", "skills", "ruby-dev")))
  end

  def test_adopt_rejects_existing_symlink_to_other_target
    create_store_skill("other")
    create_local_skill("incoming")

    link_path = File.join(@project_root, ".codex", "skills", "incoming")
    FileUtils.mkdir_p(File.dirname(link_path))
    File.symlink(File.join(@skills_dir, "other"), link_path)

    result = run_skill("adopt", File.join(@project_root, "incoming"))

    assert_equal(1, result.exitstatus)
    assert(File.symlink?(link_path))
    assert_equal(File.join(@skills_dir, "other"), File.readlink(link_path))
    assert(File.directory?(File.join(@project_root, "incoming")))
  end

  def test_list_ignores_hidden_store_directories
    create_store_skill(".hidden")
    create_store_skill("ruby-dev")

    result = run_skill("list")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "ruby-dev")
    refute_includes(result.output, ".hidden")
  end

  def test_rename_updates_matching_project_symlink
    create_store_skill("old-name")
    create_link("old-name")

    result = run_skill("rename", "old-name", "new-name")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "updated project link old-name -> new-name")
    assert(File.symlink?(File.join(@project_root, ".codex", "skills", "new-name")))
    refute_path_exists(File.join(@project_root, ".codex", "skills", "old-name"))
  end

  def test_doctor_exits_non_zero_when_issues_are_present
    create_store_skill("ruby-dev")
    broken_link = File.join(@project_root, ".codex", "skills", "ruby-dev")
    FileUtils.mkdir_p(File.dirname(broken_link))
    File.symlink(File.join(@skills_dir, "missing"), broken_link)

    result = run_skill("doctor")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "issue\tbroken symlink ruby-dev")
  end

  def test_cli_file_runs_when_executed_directly
    output, status = Open3.capture2e(
      RbConfig.ruby,
      @cli_path,
      "help",
      chdir: @project_root
    )

    assert_equal(0, status.exitstatus)
    assert_includes(output, "Usage: skill")
  end

  private

  def run_skill(*args)
    output, status = Open3.capture2e(
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

  def create_local_skill(name)
    FileUtils.mkdir_p(File.join(@project_root, name))
  end

  def create_link(name)
    link_path = File.join(@project_root, ".codex", "skills", name)
    FileUtils.mkdir_p(File.dirname(link_path))
    File.symlink(File.join(@skills_dir, name), link_path)
  end

  def refute_path_exists(path)
    refute(File.exist?(path) || File.symlink?(path), "Expected #{path} to be absent")
  end
end
