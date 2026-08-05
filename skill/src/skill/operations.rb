# frozen_string_literal: true

require "fileutils"

require_relative "classifier"
require_relative "error"
require_relative "filesystem"

module Skill
  class Operations
    LEGACY_CODEX_ERROR = "refusing to promote from deprecated .codex/skills/%<name>s; " \
                         "move skills to .agents/skills/"
    HOME_ONLY_BACKFILL_ERROR = "refusing to backfill home-only skill: %<name>s"
    BROKEN_BACKFILL_ERROR = "refusing to backfill broken agent path: %<name>s"
    NO_DRIFT_BACKFILL_ERROR = "no real-file drift for %<name>s"
    TYPE_CLASH_BACKFILL_ERROR = "refusing to backfill over non-file store path: %<path>s"
    RCUP_HINT = "run rcup (or wait for topgrade) to install into ~/.agents/skills"

    def initialize(paths:, shell_ui:)
      @paths = paths
      @shell_ui = shell_ui
    end

    def list_store_skills
      names = @paths.store_skill_names

      if names.empty?
        @shell_ui.note("no non-hidden skills found in #{@paths.store_dir}")
        return
      end

      names.each { |name| puts(name) }
    end

    def doctor_skills
      @paths.ensure_store!
      entries = classifier.report_entries
      return if entries.empty?

      width = [entries.map { |name, _status| name.length }.max, 24].max
      drifted = false
      entries.each do |name, status|
        puts(format("%-#{width}s  %s", name, status))
        drifted = true if status == "drift"
      end

      raise ExitError.new(status: 1) if drifted
    end

    def backfill_skill(name)
      @paths.ensure_store!
      Filesystem.assert_skill_name!(name)

      status = classifier.status_for(name)
      case status
      when "home-only"
        raise ExitError, format(HOME_ONLY_BACKFILL_ERROR, name: name)
      when "broken"
        raise ExitError, format(BROKEN_BACKFILL_ERROR, name: name)
      end

      store = @paths.store_skill_path(name)
      raise ExitError, "stored skill not found: #{store}" unless File.directory?(store)

      drifted = classifier.drift_paths(name)
      raise ExitError, format(NO_DRIFT_BACKFILL_ERROR, name: name) if drifted.empty?

      agent = @paths.agents_skill_path(name)
      drifted.each do |relative|
        source = File.join(agent, relative)
        destination = File.join(store, relative)
        if File.exist?(destination) && !File.file?(destination)
          raise ExitError, format(TYPE_CLASH_BACKFILL_ERROR, path: destination)
        end

        FileUtils.mkdir_p(File.dirname(destination))
        FileUtils.cp(source, destination)
        puts(relative)
      end

      @shell_ui.note("backfilled #{name} (#{drifted.length} files)")
      @shell_ui.note(RCUP_HINT)
    end

    def promote_skill(name)
      @paths.ensure_store!
      Filesystem.assert_skill_name!(name)

      legacy_source = @paths.legacy_codex_skill_path(name)
      if File.exist?(legacy_source) || File.symlink?(legacy_source)
        raise ExitError, format(LEGACY_CODEX_ERROR, name: name)
      end

      source = @paths.project_skill_path(name)
      target = @paths.store_skill_path(name)

      raise ExitError, "project skill not found in .agents/skills/: #{source}" unless File.directory?(source)
      if File.exist?(target) || File.symlink?(target)
        raise ExitError, "destination already exists in dotfiles: #{target}"
      end

      FileUtils.mv(source, target)
      @shell_ui.note("promoted #{name} -> #{target}")
      @shell_ui.note(RCUP_HINT)
    end

    def rename_skill(old_name, new_name)
      @paths.ensure_store!
      Filesystem.assert_skill_name!(old_name)
      Filesystem.assert_skill_name!(new_name)
      raise ExitError, "old and new skill names are identical" if old_name == new_name

      old_target = @paths.store_skill_path(old_name)
      new_target = @paths.store_skill_path(new_name)

      raise ExitError, "stored skill not found: #{old_target}" unless File.directory?(old_target)
      if File.exist?(new_target) || File.symlink?(new_target)
        raise ExitError, "destination already exists in dotfiles: #{new_target}"
      end

      FileUtils.mv(old_target, new_target)
      @shell_ui.note("renamed #{old_name} -> #{new_name}")
      @shell_ui.note(RCUP_HINT)
    end

    private

    def classifier
      @classifier ||= Classifier.new(paths: @paths)
    end
  end
end
