# frozen_string_literal: true

require "fileutils"

require_relative "error"
require_relative "filesystem"

module Skill
  class Operations
    INSTALL_HINT_TEMPLATE = "install: npx skills add gildesmarais/dotfiles --skill %<name>s -a cursor -a codex -y"
    RENAME_HINT_TEMPLATE = "refresh agent installs: npx skills remove %<old>s && " \
                           "npx skills add gildesmarais/dotfiles --skill %<new>s -a cursor -a codex -y"
    LEGACY_CODEX_ERROR = "refusing to promote from deprecated .codex/skills/%<name>s; " \
                         "move skills to .agents/skills/ or reinstall with npx skills"

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
      @shell_ui.note(install_hint(name))
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
      @shell_ui.note(format(RENAME_HINT_TEMPLATE, old: old_name, new: new_name))
    end

    private

    def install_hint(name)
      format(INSTALL_HINT_TEMPLATE, name: name)
    end
  end
end
