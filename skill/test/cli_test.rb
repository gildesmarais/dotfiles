# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "pathname"
require "rbconfig"
require "tmpdir"

class SkillCliTest < Minitest::Test
  Result = Struct.new(:output, :exitstatus)

  def setup
    @tmpdir = Dir.mktmpdir("skill-cli-test")
    @dotfiles_root = File.join(@tmpdir, "dotfiles")
    @project_root = File.join(@tmpdir, "project")
    @home = File.join(@tmpdir, "home")
    @xdg_config_home = File.join(@home, ".config")
    @script_path = File.join(@dotfiles_root, "scripts", "skill")
    @skill_root = File.join(@dotfiles_root, "skill")
    @skills_dir = File.join(@dotfiles_root, "skills")
    @cli_path = File.join(@skill_root, "src", "cli.rb")

    FileUtils.mkdir_p(@xdg_config_home)
    FileUtils.mkdir_p(File.dirname(@script_path))
    FileUtils.mkdir_p(@skills_dir)
    FileUtils.mkdir_p(@skill_root)
    FileUtils.mkdir_p(File.join(@skill_root, "config"))

    FileUtils.cp(File.expand_path("../../scripts/skill", __dir__), @script_path)
    FileUtils.cp_r(File.expand_path("../src", __dir__), @skill_root)
    FileUtils.cp_r(File.expand_path("../config", __dir__), @skill_root)
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

  def test_unknown_command_exits_with_explicit_error
    result = run_skill("wat")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "skill: unknown command: wat")
  end

  def test_link_rejects_existing_non_symlink
    create_store_skill("ruby-dev")
    FileUtils.mkdir_p(File.join(@project_root, ".codex", "skills", "ruby-dev"))

    result = run_skill("link", "ruby-dev")

    assert_equal(1, result.exitstatus)
    assert(File.directory?(File.join(@project_root, ".codex", "skills", "ruby-dev")))
    refute(File.symlink?(File.join(@project_root, ".codex", "skills", "ruby-dev")))
    assert_includes(result.output, "failed to link ruby-dev in 1 destination(s)")
  end

  def test_global_project_option_applies_to_mutating_commands
    create_store_skill("ruby-dev")
    custom_project = File.join(@tmpdir, "custom-project")
    FileUtils.mkdir_p(custom_project)

    result = run_skill("--project", custom_project, "link", "ruby-dev")

    assert_equal(0, result.exitstatus)
    assert(File.symlink?(File.join(custom_project, ".codex", "skills", "ruby-dev")))
    refute_path_exists(File.join(@project_root, ".codex", "skills", "ruby-dev"))
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

  def test_status_reports_linked_local_and_file_entries
    create_store_skill("ruby-dev")
    create_link("ruby-dev")

    local_path = File.join(@project_root, ".codex", "skills", "local-skill")
    file_path = File.join(@project_root, ".codex", "skills", "notes.txt")
    FileUtils.mkdir_p(local_path)
    File.write(file_path, "notes")

    result = run_skill("status")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "authoring destination: #{File.realpath(@project_root)}/.codex/skills")
    assert_includes(result.output, "linked\truby-dev -> #{@skills_dir}/ruby-dev")
    assert_includes(result.output, "local\tlocal-skill")
    assert_includes(result.output, "file\tnotes.txt")
  end

  def test_clean_removes_broken_symlinks_only
    create_store_skill("ruby-dev")
    live_link = create_link("ruby-dev")
    broken_link = create_broken_link("missing")

    result = run_skill("clean")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "removed broken symlink missing")
    assert(File.symlink?(live_link))
    refute_path_exists(broken_link)
  end

  def test_clean_refuses_to_remove_broken_symlink_outside_store
    broken_link = File.join(@project_root, ".codex", "skills", "foreign")
    FileUtils.mkdir_p(File.dirname(broken_link))
    File.symlink("../elsewhere/missing", broken_link)

    result = run_skill("clean")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "refusing to remove broken symlink outside store")
    assert(File.symlink?(broken_link))
  end

  def test_promote_moves_local_project_skill_into_store_and_relinks
    local_skill = File.join(@project_root, ".codex", "skills", "my-skill")
    FileUtils.mkdir_p(local_skill)
    File.write(File.join(local_skill, "SKILL.md"), "# My Skill\n")

    result = run_skill("promote", "my-skill")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "promoted my-skill -> #{File.realpath(@skills_dir)}/my-skill")
    assert(File.directory?(File.join(@skills_dir, "my-skill")))
    assert(File.symlink?(local_skill))
    store_skill = Pathname.new(File.join(File.realpath(@skills_dir), "my-skill"))
    link_dir = Pathname.new(File.realpath(File.dirname(local_skill)))
    expected_target = store_skill.relative_path_from(link_dir).to_s
    assert_equal(expected_target, File.readlink(local_skill))
  end

  def test_rename_leaves_project_symlink_alone_when_it_points_elsewhere
    create_store_skill("old-name")
    create_store_skill("other")

    old_link = File.join(@project_root, ".codex", "skills", "old-name")
    FileUtils.mkdir_p(File.dirname(old_link))
    File.symlink(File.join(@skills_dir, "other"), old_link)

    result = run_skill("rename", "old-name", "new-name")

    assert_equal(0, result.exitstatus)
    expected_note = [
      "project symlink in #{File.realpath(@project_root)}/.codex/skills",
      "left unchanged because it pointed elsewhere"
    ].join(" ")
    assert_includes(result.output, expected_note)
    assert_equal(File.join(@skills_dir, "other"), File.readlink(old_link))
    assert(File.directory?(File.join(@skills_dir, "new-name")))
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

  def test_doctor_exits_zero_with_warning_only
    create_store_skill("ruby-dev")
    FileUtils.mkdir_p(File.join(@project_root, ".codex", "skills"))

    result = run_skill("doctor")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "warning\tstored skill not linked in project ruby-dev")
    assert_includes(result.output, "doctor found 0 issue(s), 1 warning(s)")
  end

  def test_doctor_missing_authoring_destination_is_an_issue
    write_central_config(<<~YAML)
      store_dir: #{@skills_dir}
      tools:
        codex:
          destinations:
            - .codex/skills
          authoring: true
        generic:
          destinations:
            - .skills
      defaults:
        tools:
          - codex
          - generic
        authoring_tool: codex
    YAML
    create_store_skill("ruby-dev")
    FileUtils.mkdir_p(File.join(@project_root, ".skills"))

    result = run_skill("doctor")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "issue\tmissing authoring skill directory")
    assert_includes(result.output, "warning\tstored skill not linked")
  end

  def test_doctor_accepts_relative_symlink_into_store
    create_store_skill("ruby-dev")
    link_path = File.join(@project_root, ".codex", "skills", "ruby-dev")
    FileUtils.mkdir_p(File.dirname(link_path))
    store_path = Pathname.new(File.join(@skills_dir, "ruby-dev"))
    link_dir = Pathname.new(File.dirname(link_path))
    relative_target = store_path.relative_path_from(link_dir)
    File.symlink(relative_target.to_s, link_path)

    result = run_skill("doctor")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "ok\tlinked ruby-dev")
    assert_includes(result.output, "skill: doctor found no issues")
  end

  def test_cli_file_runs_when_executed_directly
    output, status = Open3.capture2e(
      default_env,
      RbConfig.ruby,
      @cli_path,
      "help",
      chdir: @project_root
    )

    assert_equal(0, status.exitstatus)
    assert_includes(output, "Usage: skill")
    assert_includes(output, "Central config: #{@xdg_config_home}/skill/config.yml")
  end

  def test_central_config_can_link_into_multiple_destinations
    write_central_config(<<~YAML)
      store_dir: #{@skills_dir}
      tools:
        codex:
          destinations:
            - .codex/skills
          authoring: true
        generic:
          destinations:
            - .skills
      defaults:
        tools:
          - codex
          - generic
    YAML
    create_store_skill("ruby-dev")

    result = run_skill("link", "ruby-dev")

    assert_equal(0, result.exitstatus)
    assert(File.symlink?(File.join(@project_root, ".codex", "skills", "ruby-dev")))
    assert(File.symlink?(File.join(@project_root, ".skills", "ruby-dev")))
  end

  def test_status_marks_foreign_symlinks_as_foreign
    create_store_skill("ruby-dev")
    foreign_target = File.join(@project_root, "external-target")
    FileUtils.mkdir_p(foreign_target)
    foreign_link = File.join(@project_root, ".codex", "skills", "ruby-dev")
    FileUtils.mkdir_p(File.dirname(foreign_link))
    File.symlink(foreign_target, foreign_link)

    result = run_skill("status")

    assert_equal(0, result.exitstatus)
    assert_includes(result.output, "foreign\truby-dev -> #{foreign_target}")
  end

  def test_config_init_writes_default_template
    result = run_skill("config", "init")
    config_path = File.join(@xdg_config_home, "skill", "config.yml")
    template_path = File.join(@skill_root, "config", "default-config.yml")

    assert_equal(0, result.exitstatus)
    assert(File.exist?(config_path))
    assert_equal(File.read(template_path), File.read(config_path))
    assert_includes(result.output, "initialized config at #{config_path}")
  end

  def test_config_init_refuses_to_overwrite_existing_config
    write_central_config("store_dir: skills\n")

    result = run_skill("config", "init")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "config already exists:")
  end

  def test_config_requires_subcommand
    result = run_skill("config")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "config requires a subcommand")
  end

  def test_config_rejects_unknown_subcommand
    result = run_skill("config", "wat")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "unknown config subcommand: wat")
  end

  def test_config_init_rejects_extra_arguments
    result = run_skill("config", "init", "extra")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "config init does not accept extra arguments")
  end

  def test_promote_uses_single_mirror_fallback_when_authoring_destination_is_missing
    write_central_config(<<~YAML)
      store_dir: #{@skills_dir}
      tools:
        codex:
          destinations:
            - .codex/skills
          authoring: true
        generic:
          destinations:
            - .skills
      defaults:
        tools:
          - codex
          - generic
    YAML

    mirror_skill = File.join(@project_root, ".skills", "mirror-skill")
    FileUtils.mkdir_p(mirror_skill)
    File.write(File.join(mirror_skill, "SKILL.md"), "# Mirror Skill\n")

    result = run_skill("promote", "mirror-skill")

    assert_equal(0, result.exitstatus)
    fallback_note = "using mirror destination for promote fallback: #{File.realpath(@project_root)}/.skills"
    assert_includes(result.output, fallback_note)
    assert(File.directory?(File.join(@skills_dir, "mirror-skill")))
    assert(File.symlink?(File.join(@project_root, ".codex", "skills", "mirror-skill")))
    assert(File.symlink?(File.join(@project_root, ".skills", "mirror-skill")))
  end

  def test_promote_fails_when_multiple_destinations_have_local_skill_directories
    write_central_config(<<~YAML)
      store_dir: #{@skills_dir}
      tools:
        codex:
          destinations:
            - .codex/skills
          authoring: true
        generic:
          destinations:
            - .skills
      defaults:
        tools:
          - codex
          - generic
    YAML

    FileUtils.mkdir_p(File.join(@project_root, ".codex", "skills", "shared-skill"))
    FileUtils.mkdir_p(File.join(@project_root, ".skills", "shared-skill"))

    result = run_skill("promote", "shared-skill")

    assert_equal(1, result.exitstatus)
    assert_includes(result.output, "multiple local skill directories found for promotion")
  end

  def test_link_reports_partial_failure_after_linking_other_destinations
    write_central_config(<<~YAML)
      store_dir: #{@skills_dir}
      tools:
        codex:
          destinations:
            - .codex/skills
          authoring: true
        generic:
          destinations:
            - .skills
      defaults:
        tools:
          - codex
          - generic
    YAML
    create_store_skill("ruby-dev")
    FileUtils.mkdir_p(File.join(@project_root, ".codex", "skills", "ruby-dev"))

    result = run_skill("link", "ruby-dev")

    assert_equal(1, result.exitstatus)
    assert(File.directory?(File.join(@project_root, ".codex", "skills", "ruby-dev")))
    assert(File.symlink?(File.join(@project_root, ".skills", "ruby-dev")))
    linked_note = "linked ruby-dev -> #{@skills_dir}/ruby-dev in #{File.realpath(@project_root)}/.skills"
    assert_includes(result.output, linked_note)
    assert_includes(result.output, "failed to link ruby-dev in 1 destination(s)")
  end

  private

  def run_skill(*args)
    output, status = Open3.capture2e(
      default_env,
      RbConfig.ruby,
      @script_path,
      *args,
      chdir: @project_root
    )

    Result.new(output, status.exitstatus)
  end

  def default_env
    {
      "HOME" => @home,
      "XDG_CONFIG_HOME" => @xdg_config_home
    }
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
    link_path
  end

  def create_broken_link(name)
    link_path = File.join(@project_root, ".codex", "skills", name)
    FileUtils.mkdir_p(File.dirname(link_path))
    File.symlink(File.join(@skills_dir, "#{name}-target"), link_path)
    link_path
  end

  def refute_path_exists(path)
    refute(File.exist?(path) || File.symlink?(path), "Expected #{path} to be absent")
  end

  def write_central_config(contents)
    path = File.join(@xdg_config_home, "skill", "config.yml")
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, contents)
  end
end
