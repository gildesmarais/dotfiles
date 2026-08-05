# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "tmpdir"

require_relative "../src/skill/error"
require_relative "../src/skill/filesystem"
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
    @home_dir = File.join(@tmpdir, "home")
    @skills_dir = File.join(@dotfiles_root, "skills")

    FileUtils.mkdir_p(@skills_dir)
    FileUtils.mkdir_p(@project_root)
    FileUtils.mkdir_p(@home_dir)

    @ui = FakeUI.new([])
    @paths = Skill::Paths.new(
      dotfiles_root: @dotfiles_root,
      project_root: @project_root,
      home_dir: @home_dir
    )
    @operations = Skill::Operations.new(paths: @paths, shell_ui: @ui)
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_promote_moves_agents_skill_into_store_and_links
    source = @paths.project_skill_path("my-skill")
    FileUtils.mkdir_p(source)

    @operations.promote_skill("my-skill")

    assert(File.directory?(@paths.store_skill_path("my-skill")))
    refute(File.exist?(source))
    assert_includes(@ui.notes, "promoted my-skill -> #{@paths.store_skill_path('my-skill')}")
    assert_includes(@ui.notes, "linked my-skill -> #{@paths.agents_skill_path('my-skill')}")
    assert_agent_symlink("my-skill")
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

  def test_rename_retargets_agent_symlink
    create_store_skill("old-name")
    FileUtils.mkdir_p(@paths.agents_skills_dir)
    FileUtils.ln_s(@paths.store_skill_path("old-name"), @paths.agents_skill_path("old-name"))

    @operations.rename_skill("old-name", "new-name")

    assert(File.directory?(@paths.store_skill_path("new-name")))
    refute(File.exist?(@paths.store_skill_path("old-name")))
    refute(File.exist?(@paths.agents_skill_path("old-name")) || File.symlink?(@paths.agents_skill_path("old-name")))
    assert_includes(@ui.notes, "renamed old-name -> new-name")
    assert_includes(@ui.notes, "linked new-name -> #{@paths.agents_skill_path('new-name')}")
    assert_agent_symlink("new-name")
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

  def test_sync_is_noop_when_symlink_already_correct
    create_store_skill("alpha")
    FileUtils.mkdir_p(@paths.agents_skills_dir)
    FileUtils.ln_s(File.expand_path(@paths.store_skill_path("alpha")), @paths.agents_skill_path("alpha"))

    @operations.sync_skills

    assert(@ui.notes.none? { |note| note.include?("linked alpha") || note.include?("relinked alpha") })
    assert_agent_symlink("alpha")
  end

  def test_sync_fail_closed_on_real_directory
    create_store_skill("alpha")
    FileUtils.mkdir_p(@paths.agents_skill_path("alpha"))

    error = assert_raises(Skill::ExitError) do
      @operations.sync_skills
    end

    assert_equal(1, error.status)
    assert_equal(
      "refusing to overwrite non-symlink at #{@paths.agents_skill_path('alpha')}; remove it then re-run skill sync",
      error.message
    )
    assert(File.directory?(@paths.agents_skill_path("alpha")))
    refute(File.symlink?(@paths.agents_skill_path("alpha")))
  end

  def test_sync_prunes_stale_store_owned_symlinks
    create_store_skill("kept")
    FileUtils.mkdir_p(@paths.agents_skills_dir)
    FileUtils.ln_s(File.expand_path(@paths.store_skill_path("kept")), @paths.agents_skill_path("kept"))
    FileUtils.ln_s(File.join(@paths.store_dir, "gone"), @paths.agents_skill_path("gone"))
    FileUtils.ln_s("/tmp", @paths.agents_skill_path("other"))
    FileUtils.mkdir_p(@paths.agents_skill_path("vendor"))

    @operations.sync_skills

    assert_includes(@ui.notes, "pruned stale symlink #{@paths.agents_skill_path('gone')}")
    refute(File.exist?(@paths.agents_skill_path("gone")) || File.symlink?(@paths.agents_skill_path("gone")))
    assert(File.symlink?(@paths.agents_skill_path("other")))
    assert(File.directory?(@paths.agents_skill_path("vendor")))
    assert_agent_symlink("kept")
  end

  def test_project_skills_dir_uses_agents_path
    assert_equal(File.join(@project_root, ".agents", "skills"), @paths.project_skills_dir)
  end

  def test_agents_skills_dir_uses_home
    assert_equal(File.join(@home_dir, ".agents", "skills"), @paths.agents_skills_dir)
  end

  private

  def create_store_skill(name)
    FileUtils.mkdir_p(File.join(@skills_dir, name))
  end

  def assert_agent_symlink(name)
    link_path = @paths.agents_skill_path(name)
    store_path = @paths.store_skill_path(name)

    assert(File.symlink?(link_path), "Expected symlink at #{link_path}")
    assert(
      Skill::Filesystem.symlink_points_to?(link_path, store_path),
      "Expected #{link_path} to point at #{store_path}"
    )
  end
end
