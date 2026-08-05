# frozen_string_literal: true

require "fileutils"

require_relative "error"
require_relative "filesystem"

module Skill
  class Operations
    LEGACY_CODEX_ERROR = "refusing to promote from deprecated .codex/skills/%<name>s; " \
                         "move skills to .agents/skills/"
    COLLISION_ERROR = "refusing to overwrite non-symlink at %<path>s; remove it then re-run skill sync"

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

    def sync_skills
      @paths.ensure_store!
      names = @paths.store_skill_names

      names.each do |name|
        case ensure_agent_symlink(name)
        when :created
          @shell_ui.note("linked #{name} -> #{@paths.agents_skill_path(name)}")
        when :replaced
          @shell_ui.note("relinked #{name} -> #{@paths.agents_skill_path(name)}")
        end
      end

      prune_stale_agent_symlinks(names)
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
      ensure_agent_symlink(name)
      @shell_ui.note("linked #{name} -> #{@paths.agents_skill_path(name)}")
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
      remove_store_owned_agent_symlink(old_name)
      ensure_agent_symlink(new_name)
      @shell_ui.note("renamed #{old_name} -> #{new_name}")
      @shell_ui.note("linked #{new_name} -> #{@paths.agents_skill_path(new_name)}")
    end

    private

    def ensure_agent_symlink(name)
      Filesystem.assert_skill_name!(name)
      store_path = @paths.store_skill_path(name)
      raise ExitError, "stored skill not found: #{store_path}" unless File.directory?(store_path)

      FileUtils.mkdir_p(@paths.agents_skills_dir)
      link_path = @paths.agents_skill_path(name)
      absolute_store = Filesystem.normalized_path(store_path)

      if File.symlink?(link_path)
        return :ok if Filesystem.symlink_points_to?(link_path, absolute_store)

        FileUtils.rm(link_path)
        action = :replaced
      elsif File.exist?(link_path)
        raise ExitError, format(COLLISION_ERROR, path: link_path)
      else
        action = :created
      end

      FileUtils.ln_s(absolute_store, link_path)
      action
    end

    def remove_store_owned_agent_symlink(name)
      link_path = @paths.agents_skill_path(name)
      return unless File.symlink?(link_path)

      target = Filesystem.symlink_target_path(link_path)
      return unless Filesystem.within_directory?(target, @paths.store_dir)

      FileUtils.rm(link_path)
    end

    def prune_stale_agent_symlinks(store_names)
      agents_dir = @paths.agents_skills_dir
      return unless File.directory?(agents_dir)

      store_name_set = store_names.each_with_object({}) { |name, set| set[name] = true }

      Dir.children(agents_dir).sort.each do |name|
        next if name.start_with?(".")
        next if store_name_set[name]

        link_path = @paths.agents_skill_path(name)
        next unless File.symlink?(link_path)

        target = Filesystem.symlink_target_path(link_path)
        next unless Filesystem.within_directory?(target, @paths.store_dir)

        FileUtils.rm(link_path)
        @shell_ui.note("pruned stale symlink #{link_path}")
      end
    end
  end
end
