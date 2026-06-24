# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "tmpdir"

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
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_promote_moves_agents_skill_into_store
    source = @paths.project_skill_path("my-skill")
    FileUtils.mkdir_p(source)

    @operations.promote_skill("my-skill")

    assert(File.directory?(@paths.store_skill_path("my-skill")))
    refute(File.exist?(source))
    assert_includes(@ui.notes, "promoted my-skill -> #{@paths.store_skill_path('my-skill')}")
  end

  def test_promote_rejects_legacy_codex_skills_path
    legacy_source = @paths.legacy_codex_skill_path("my-skill")
    FileUtils.mkdir_p(legacy_source)

    error = assert_raises(Skill::ExitError) do
      @operations.promote_skill("my-skill")
    end

    assert_equal(1, error.status)
    assert_match(%r{refusing to promote from deprecated \.codex/skills/my-skill}, error.message)
    assert(File.directory?(legacy_source))
    refute(File.exist?(@paths.store_skill_path("my-skill")))
  end

  def test_rename_moves_store_directory_only
    create_store_skill("old-name")

    @operations.rename_skill("old-name", "new-name")

    assert(File.directory?(@paths.store_skill_path("new-name")))
    refute(File.exist?(@paths.store_skill_path("old-name")))
    assert_includes(@ui.notes, "renamed old-name -> new-name")
    assert_match(/npx skills remove old-name/, @ui.notes.join("\n"))
  end

  def test_rename_raises_when_destination_exists_in_store
    create_store_skill("old-name")
    create_store_skill("new-name")

    error = assert_raises(Skill::ExitError) do
      @operations.rename_skill("old-name", "new-name")
    end

    assert_equal(1, error.status)
    assert_equal("destination already exists in dotfiles: #{@paths.store_skill_path('new-name')}", error.message)
  end

  def test_project_skills_dir_uses_agents_path
    assert_equal(File.join(@project_root, ".agents", "skills"), @paths.project_skills_dir)
  end

  private

  def create_store_skill(name)
    FileUtils.mkdir_p(File.join(@skills_dir, name))
  end
end
