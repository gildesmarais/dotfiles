# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "pathname"
require "stringio"
require "tmpdir"

require_relative "../src/skill/doctor"
require_relative "../src/skill/error"
require_relative "../src/skill/operations"
require_relative "../src/skill/paths"
require_relative "../src/skill/state"

class SkillUnitTest < Minitest::Test
  FakeUI = Struct.new(:notes) do
    def note(message)
      notes << message
    end
  end

  def setup
    @tmpdir = Dir.mktmpdir("skill-unit-test")
    @dotfiles_root = File.join(@tmpdir, "dotfiles")
    @project_root = File.join(@tmpdir, "project")
    @skills_dir = File.join(@dotfiles_root, "skills")
    @original_home = ENV["HOME"]
    @original_xdg_config_home = ENV["XDG_CONFIG_HOME"]

    FileUtils.mkdir_p(@skills_dir)
    FileUtils.mkdir_p(@project_root)

    @ui = FakeUI.new([])
    @paths = Skill::Paths.new(dotfiles_root: @dotfiles_root, project_root: @project_root)
    @operations = Skill::Operations.new(paths: @paths, shell_ui: @ui)
    @doctor = Skill::Doctor.new(paths: @paths, shell_ui: @ui)
  end

  def teardown
    ENV["HOME"] = @original_home
    ENV["XDG_CONFIG_HOME"] = @original_xdg_config_home
    FileUtils.rm_rf(@tmpdir)
  end

  def test_rename_raises_when_destination_project_path_exists
    create_store_skill("old-name")
    FileUtils.mkdir_p(File.join(@project_root, ".codex", "skills", "new-name"))

    error = assert_raises(Skill::ExitError) do
      @operations.rename_skill("old-name", "new-name")
    end

    assert_equal(1, error.status)
    assert_equal("destination already exists in project: #{@paths.project_skill_path('new-name')}", error.message)
  end

  def test_adopt_accepts_relative_source_path
    source = File.join(@project_root, "incoming")
    FileUtils.mkdir_p(source)
    File.write(File.join(source, "SKILL.md"), "# Incoming\n")

    Dir.chdir(@project_root) do
      @operations.adopt_skill("incoming")
    end

    assert(File.directory?(File.join(@skills_dir, "incoming")))
    assert(File.symlink?(@paths.project_skill_path("incoming")))
    assert_includes(@ui.notes, "adopted incoming -> #{@paths.store_skill_path('incoming')}")
  end

  def test_doctor_accepts_noncanonical_store_symlink_target
    create_store_skill("ruby-dev")
    raw_paths = Skill::Paths.new(dotfiles_root: @dotfiles_root, project_root: @project_root)
    canonical_paths = Skill::Paths.new(dotfiles_root: File.realpath(@dotfiles_root), project_root: @project_root)
    doctor = Skill::Doctor.new(paths: canonical_paths, shell_ui: @ui)

    FileUtils.mkdir_p(raw_paths.project_skills_dir)
    File.symlink(raw_paths.store_skill_path("ruby-dev"), raw_paths.project_skill_path("ruby-dev"))

    output = capture_output { doctor.run }

    assert_includes(output, "ok\tlinked ruby-dev")
    assert_includes(@ui.notes, "doctor found no issues")
  end

  def test_config_prefers_xdg_config_home_central_config
    home = File.join(@tmpdir, "home")
    xdg_config_home = File.join(home, ".config")
    FileUtils.mkdir_p(File.join(xdg_config_home, "skill"))
    File.write(
      File.join(xdg_config_home, "skill", "config.yml"),
      <<~YAML
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
    )

    ENV["HOME"] = home
    ENV["XDG_CONFIG_HOME"] = xdg_config_home

    config = Skill::Config.load(@project_root, @dotfiles_root)

    assert_equal(%w[codex generic], config.active_tools)
    assert_equal(".codex/skills", config.authoring_destination)
    assert_includes(config.destinations, ".skills")
  end

  def test_central_config_path_uses_supplied_home_when_xdg_config_home_is_unset
    env = { "HOME" => "/tmp/skill-home" }

    path = Skill::Config.central_config_path(env)

    assert_equal("/tmp/skill-home/.config/skill/config.yml", path)
  end

  def test_config_loads_supported_project_config_shape
    fixture_path = File.expand_path("../test_project/.skill.yml", __dir__)
    FileUtils.cp(fixture_path, File.join(@project_root, ".skill.yml"))
    write_central_config(
      <<~YAML
        store_dir: #{@skills_dir}
        tools:
          codex:
            destinations:
              - .codex/skills
            authoring: true
          github:
            destinations:
              - .github/skills
        defaults:
          tools:
            - codex
      YAML
    )

    config = Skill::Config.load(@project_root, @dotfiles_root)

    assert_equal(%w[codex github], config.active_tools)
    assert_equal(".codex/skills", config.authoring_destination)
    assert_equal(%w[ruby-dev], config.required)
    assert_equal(%w[secret-skill], config.ignored)
    assert_includes(config.destinations, ".skills")
    assert_includes(config.destinations, ".github/skills")
  end

  def test_config_rejects_unknown_project_keys
    File.write(
      File.join(@project_root, ".skill.yml"),
      <<~YAML
        destinations:
          - .codex/skills
        name_mappings:
          ruby-dev: ruby
      YAML
    )

    error = assert_raises(Skill::ExitError) do
      Skill::Config.load(@project_root, @dotfiles_root)
    end

    assert_equal(1, error.status)
    assert_includes(error.message, "unknown config key(s)")
    assert_includes(error.message, "destinations")
    assert_includes(error.message, "name_mappings")
  end

  def test_state_reports_broken_symlink_with_resolved_target
    link_path = File.join(@project_root, ".codex", "skills", "ruby-dev")
    FileUtils.mkdir_p(File.dirname(link_path))
    File.symlink("../missing-target", link_path)

    entry = Skill::State.new(paths: @paths).inspect_destination_skill(@paths.project_skills_dir, "ruby-dev")

    assert_equal(:broken_symlink, entry[:kind])
    assert_includes(entry[:resolved_target], "missing-target")
  end

  private

  def create_store_skill(name)
    FileUtils.mkdir_p(File.join(@skills_dir, name))
  end

  def write_central_config(contents)
    config_path = File.join(@tmpdir, "home", ".config", "skill", "config.yml")
    FileUtils.mkdir_p(File.dirname(config_path))
    File.write(config_path, contents)

    ENV["HOME"] = File.join(@tmpdir, "home")
    ENV["XDG_CONFIG_HOME"] = File.join(@tmpdir, "home", ".config")
  end

  def capture_output
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
