# frozen_string_literal: true

require "fileutils"

require_relative "classifier"
require_relative "error"
require_relative "filesystem"
require_relative "linter"
require_relative "paths"

module Skill
  class Operations
    LEGACY_CODEX_ERROR = "refusing to promote from deprecated .codex/skills/%<name>s; " \
                         "move skills to .agents/skills/"
    HOME_ONLY_BACKFILL_ERROR = "refusing to backfill home-only skill: %<name>s"
    BROKEN_BACKFILL_ERROR = "refusing to backfill broken agent path: %<name>s"
    NO_DRIFT_BACKFILL_ERROR = "no real-file drift for %<name>s"
    TYPE_CLASH_BACKFILL_ERROR = "refusing to backfill over non-file store path: %<path>s"
    RCUP_HINT = "run rcup (or wait for topgrade) to install into ~/.agents/skills and ~/.claude/skills"
    CLAUDE_DRIFT_HINT = "%<names>s drift: copy local edits into the store and remove extra files, " \
                        "then rerun rcup (rcup overwrites replaced links and keeps extra files)"
    STORE_OVERLAP_HINT = "%<dir>s overlaps the skill store; make it a real directory and rerun rcup"
    STORE_OVERLAP_PRUNE_ERROR = "refusing to prune: #{STORE_OVERLAP_HINT}"
    PRUNE_HINT = "run skill prune to remove orphan links"

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
      entries = Paths::INSTALL_ROOTS.flat_map do |root|
        # One row for an overlapping root: its skill rows would compare the store with itself.
        next [[root, @paths.install_dir(root), "overlap"]] if classifier.overlaps_store?(root)

        classifier.report_entries(root: root).map { |name, status| [root, install_label(root, name), status] }
      end
      return if entries.empty?

      width = [entries.map { |_root, label, _status| label.length }.max, 24].max
      entries.each { |_root, label, status| puts(format("%-#{width}s  %s", label, status)) }
      note_doctor_hints(entries)

      raise ExitError.new(status: 1) if (entries.map(&:last) & %w[drift orphan overlap]).any?
    end

    def lint_skills(project: false, measure: false, since: nil)
      @paths.ensure_store! unless project
      linter = Linter.new(paths: @paths, project: project, since: since)
      errors = linter.run
      linter.measure_lines.each { |line| puts(line) } if measure
      if errors.empty?
        @shell_ui.note("lint ok")
        return
      end

      errors.each { |message| puts(message) }
      raise ExitError.new(status: 1)
    end

    def prune_skills
      @paths.ensure_store!
      Paths::INSTALL_ROOTS.each do |root|
        next unless classifier.overlaps_store?(root)

        raise ExitError, format(STORE_OVERLAP_PRUNE_ERROR, dir: @paths.install_dir(root))
      end
      removed = 0

      Paths::INSTALL_ROOTS.each do |root|
        @paths.install_skill_names(root).each do |name|
          orphans = classifier.orphan_paths(name, root: root)
          next if orphans.empty?

          install = File.join(@paths.install_dir(root), name)
          orphans.each do |relative|
            File.unlink(File.join(install, relative))
            puts("#{install_label(root, name)}/#{relative}")
            removed += 1
            remove_emptied_parents(install, relative)
          end
        end
      end

      if removed.zero?
        @shell_ui.note("no orphans to prune")
      else
        @shell_ui.note("pruned #{removed} orphan links")
      end
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
      add_claude_entry(name)
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
      remove_claude_entry(old_name)
      add_claude_entry(new_name)
      @shell_ui.note("renamed #{old_name} -> #{new_name}")
      @shell_ui.note(RCUP_HINT)
    end

    private

    # Notes for doctor's [root, label, status] rows, after the table.
    def note_doctor_hints(entries)
      claude_drift = entries.select { |root, _label, status| root == "claude" && status == "drift" }
      unless claude_drift.empty?
        @shell_ui.note(format(CLAUDE_DRIFT_HINT, names: claude_drift.map { |_root, label, _status| label }.join(", ")))
      end
      @shell_ui.note(PRUNE_HINT) if entries.any? { |_root, _label, status| status == "orphan" }
      entries.each do |_root, label, status|
        @shell_ui.note(format(STORE_OVERLAP_HINT, dir: label)) if status == "overlap"
      end
    end

    # Rows from ~/.agents/skills stay bare; other install roots carry "<root>:".
    def install_label(root, name)
      root == "agents" ? name : "#{root}:#{name}"
    end

    def add_claude_entry(name)
      entry = @paths.claude_entry_path(name)
      return if File.symlink?(entry) || File.exist?(entry)

      FileUtils.mkdir_p(@paths.claude_dir)
      File.symlink(@paths.claude_entry_target(name), entry)
    end

    def remove_claude_entry(name)
      entry = @paths.claude_entry_path(name)
      File.unlink(entry) if File.symlink?(entry)
    end

    def classifier
      @classifier ||= Classifier.new(paths: @paths)
    end

    # Removes the parents of a pruned link that it left empty, deepest first,
    # up to and including the skill's install dir. A symlink, hidden component,
    # or non-empty directory ends the walk.
    def remove_emptied_parents(install, relative)
      parts = File.dirname(relative).split(File::SEPARATOR) - ["."]
      return if parts.any? { |part| part.start_with?(".") }

      parts.length.downto(0) do |depth|
        dir = File.join(install, *parts.first(depth))
        break if File.symlink?(dir) || !File.directory?(dir) || !Dir.empty?(dir)

        Dir.rmdir(dir)
      end
    rescue Errno::ENOTEMPTY, Errno::ENOENT, Errno::ENOTDIR
      # Changed underneath us; leave the rest in place.
    end
  end
end
