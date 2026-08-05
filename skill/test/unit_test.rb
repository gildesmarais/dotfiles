# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "tmpdir"

require_relative "../src/skill/classifier"
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
    @skills_dir = File.join(@dotfiles_root, "agents", "skills")

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

  def test_promote_moves_agents_skill_into_store
    source = @paths.project_skill_path("my-skill")
    FileUtils.mkdir_p(source)

    @operations.promote_skill("my-skill")

    assert(File.directory?(@paths.store_skill_path("my-skill")))
    refute(File.exist?(source))
    assert_includes(@ui.notes, "promoted my-skill -> #{@paths.store_skill_path('my-skill')}")
    assert_includes(@ui.notes, Skill::Operations::RCUP_HINT)
    refute(@ui.notes.any? { |note| note.start_with?("linked ") })
    refute(File.exist?(@paths.agents_skill_path("my-skill")) || File.symlink?(@paths.agents_skill_path("my-skill")))
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

  def test_rename_updates_store_and_hints_rcup
    create_store_skill("old-name")

    @operations.rename_skill("old-name", "new-name")

    assert(File.directory?(@paths.store_skill_path("new-name")))
    refute(File.exist?(@paths.store_skill_path("old-name")))
    assert_includes(@ui.notes, "renamed old-name -> new-name")
    assert_includes(@ui.notes, Skill::Operations::RCUP_HINT)
    refute(@ui.notes.any? { |note| note.start_with?("linked ") })
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

  def test_store_dir_uses_agents_skills
    assert_equal(File.join(@dotfiles_root, "agents", "skills"), @paths.store_dir)
  end

  def test_project_skills_dir_uses_agents_path
    assert_equal(File.join(@project_root, ".agents", "skills"), @paths.project_skills_dir)
  end

  def test_agents_skills_dir_uses_home
    assert_equal(File.join(@home_dir, ".agents", "skills"), @paths.agents_skills_dir)
  end

  def test_agents_skill_names_returns_empty_when_agents_dir_missing
    assert_equal([], @paths.agents_skill_names)
  end

  def test_agents_skill_names_includes_broken_dirlinks
    FileUtils.mkdir_p(@paths.agents_skills_dir)
    create_store_skill("live")
    FileUtils.ln_s("missing-target", @paths.agents_skill_path("broken-link"))
    FileUtils.ln_s(@paths.store_skill_path("live"), @paths.agents_skill_path("live"))
    FileUtils.mkdir_p(File.join(@paths.agents_skills_dir, ".hidden"))

    assert_equal(%w[broken-link live], @paths.agents_skill_names)
  end

  def test_classifier_statuses_are_frozen_closed_set
    assert_equal(%w[ok drift home-only broken], Skill::Classifier::STATUSES)
    assert(Skill::Classifier::STATUSES.frozen?)
  end

  def test_classifier_status_broken_when_agent_symlink_dangling
    create_store_skill("skill-a")
    FileUtils.mkdir_p(@paths.agents_skills_dir)
    FileUtils.ln_s("missing", @paths.agents_skill_path("skill-a"))

    classifier = Skill::Classifier.new(paths: @paths)

    assert_equal("broken", classifier.status_for("skill-a"))
    assert_equal([], classifier.drift_paths("skill-a"))
  end

  def test_classifier_status_home_only_when_store_absent
    FileUtils.mkdir_p(@paths.agents_skill_path("third-party"))
    File.write(File.join(@paths.agents_skill_path("third-party"), "SKILL.md"), "# Home\n")

    classifier = Skill::Classifier.new(paths: @paths)

    assert_equal("home-only", classifier.status_for("third-party"))
    assert_equal([], classifier.drift_paths("third-party"))
  end

  def test_classifier_status_ok_for_store_only
    create_store_skill("store-only")
    File.write(File.join(@paths.store_skill_path("store-only"), "SKILL.md"), "# Store\n")

    classifier = Skill::Classifier.new(paths: @paths)

    assert_equal("ok", classifier.status_for("store-only"))
    assert_equal([], classifier.drift_paths("store-only"))
  end

  def test_classifier_status_ok_when_files_identical
    create_paired_skill("paired", store_body: "# Same\n", agent_body: "# Same\n")

    classifier = Skill::Classifier.new(paths: @paths)

    assert_equal("ok", classifier.status_for("paired"))
    assert_equal([], classifier.drift_paths("paired"))
  end

  def test_classifier_status_ok_when_agent_files_are_symlinks
    create_store_skill("linked")
    store_file = File.join(@paths.store_skill_path("linked"), "SKILL.md")
    File.write(store_file, "# Linked\n")
    FileUtils.mkdir_p(@paths.agents_skill_path("linked"))
    FileUtils.ln_s(store_file, File.join(@paths.agents_skill_path("linked"), "SKILL.md"))

    classifier = Skill::Classifier.new(paths: @paths)

    assert_equal("ok", classifier.status_for("linked"))
    assert_equal([], classifier.drift_paths("linked"))
  end

  def test_classifier_drift_paths_detects_content_diff_and_new_file
    create_paired_skill("drifted", store_body: "# Store\n", agent_body: "# Agent\n")
    File.write(File.join(@paths.agents_skill_path("drifted"), "extra.md"), "new\n")
    File.write(File.join(@paths.store_skill_path("drifted"), "store-only.md"), "keep\n")

    classifier = Skill::Classifier.new(paths: @paths)

    assert_equal("drift", classifier.status_for("drifted"))
    assert_equal(%w[SKILL.md extra.md], classifier.drift_paths("drifted"))
  end

  def test_classifier_drift_paths_skips_symlinks_and_hidden_components
    create_paired_skill("noisy", store_body: "# Store\n", agent_body: "# Agent\n")
    agent = @paths.agents_skill_path("noisy")
    FileUtils.ln_s(
      File.join(@paths.store_skill_path("noisy"), "SKILL.md"),
      File.join(agent, "linked.md")
    )
    FileUtils.mkdir_p(File.join(agent, ".git"))
    File.write(File.join(agent, ".git", "config"), "secret\n")
    File.write(File.join(agent, ".DS_Store"), "noise\n")
    FileUtils.mkdir_p(File.join(agent, "nested", ".cache"))
    File.write(File.join(agent, "nested", ".cache", "x"), "hidden\n")

    classifier = Skill::Classifier.new(paths: @paths)

    assert_equal(%w[SKILL.md], classifier.drift_paths("noisy"))
    assert_equal("drift", classifier.status_for("noisy"))
  end

  def test_classifier_report_entries_sorted_union
    create_store_skill("alpha")
    FileUtils.mkdir_p(@paths.agents_skill_path("beta"))
    FileUtils.mkdir_p(@paths.agents_skills_dir)
    FileUtils.ln_s("missing", @paths.agents_skill_path("gamma"))
    create_paired_skill("delta", store_body: "# A\n", agent_body: "# B\n")

    classifier = Skill::Classifier.new(paths: @paths)

    assert_equal(
      [
        %w[alpha ok],
        %w[beta home-only],
        %w[delta drift],
        %w[gamma broken]
      ],
      classifier.report_entries
    )
  end

  def test_doctor_skills_silent_when_empty
    @operations.doctor_skills

    assert_equal([], @ui.notes)
  end

  def test_backfill_skill_copies_and_notes_rcup
    create_paired_skill("drifted", store_body: "# Store\n", agent_body: "# Agent\n")
    File.write(File.join(@paths.agents_skill_path("drifted"), "extra.md"), "new\n")

    @operations.backfill_skill("drifted")

    assert_equal("# Agent\n", File.read(File.join(@paths.store_skill_path("drifted"), "SKILL.md")))
    assert_equal("new\n", File.read(File.join(@paths.store_skill_path("drifted"), "extra.md")))
    assert_includes(@ui.notes, "backfilled drifted (2 files)")
    assert_includes(@ui.notes, Skill::Operations::RCUP_HINT)
  end

  def test_backfill_skill_refuses_home_only
    FileUtils.mkdir_p(@paths.agents_skill_path("third-party"))

    error = assert_raises(Skill::ExitError) do
      @operations.backfill_skill("third-party")
    end

    assert_equal(1, error.status)
    assert_equal(format(Skill::Operations::HOME_ONLY_BACKFILL_ERROR, name: "third-party"), error.message)
  end

  def test_backfill_skill_refuses_type_clash
    create_store_skill("clash")
    FileUtils.mkdir_p(File.join(@paths.store_skill_path("clash"), "nested"))
    FileUtils.mkdir_p(@paths.agents_skill_path("clash"))
    File.write(File.join(@paths.agents_skill_path("clash"), "nested"), "file\n")

    error = assert_raises(Skill::ExitError) do
      @operations.backfill_skill("clash")
    end

    dest = File.join(@paths.store_skill_path("clash"), "nested")
    assert_equal(format(Skill::Operations::TYPE_CLASH_BACKFILL_ERROR, path: dest), error.message)
    assert(File.directory?(dest))
  end

  private

  def create_store_skill(name)
    FileUtils.mkdir_p(File.join(@skills_dir, name))
  end

  def create_paired_skill(name, store_body:, agent_body:)
    create_store_skill(name)
    File.write(File.join(@paths.store_skill_path(name), "SKILL.md"), store_body)
    FileUtils.mkdir_p(@paths.agents_skill_path(name))
    File.write(File.join(@paths.agents_skill_path(name), "SKILL.md"), agent_body)
  end
end
