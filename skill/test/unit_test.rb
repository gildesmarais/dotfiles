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

    FileUtils.mkdir_p(@skills_dir)
    FileUtils.mkdir_p(@project_root)

    @ui = FakeUI.new([])
    @paths = Skill::Paths.new(dotfiles_root: @dotfiles_root, project_root: @project_root)
    @operations = Skill::Operations.new(paths: @paths, shell_ui: @ui)
    @doctor = Skill::Doctor.new(paths: @paths, shell_ui: @ui)
  end

  def teardown
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

  private

  def create_store_skill(name)
    FileUtils.mkdir_p(File.join(@skills_dir, name))
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
