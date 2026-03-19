# frozen_string_literal: true

require "fileutils"

require_relative "error"
require_relative "filesystem"

module Skill
  class Operations
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

    def show_status
      @shell_ui.note("project: #{@paths.project_root}")
      @shell_ui.note("store: #{@paths.store_dir}")

      unless Dir.exist?(@paths.project_skills_dir)
        @shell_ui.note("project skill directory does not exist: #{@paths.project_skills_dir}")
        return
      end

      entries = @paths.project_entries
      if entries.empty?
        @shell_ui.note("no project skills found in #{@paths.project_skills_dir}")
        return
      end

      entries.each do |name|
        path = @paths.project_skill_path(name)

        if File.symlink?(path)
          target = File.readlink(path)
          state = File.exist?(path) ? "linked" : "broken"
          puts("#{state}\t#{name} -> #{target}")
        elsif File.directory?(path)
          puts("local\t#{name}")
        else
          puts("file\t#{name}")
        end
      end
    end

    def link_one(name)
      @paths.ensure_store!
      @paths.ensure_project_skills_dir!
      Filesystem.assert_skill_name!(name)

      source = @paths.store_skill_path(name)
      target = @paths.project_skill_path(name)

      raise ExitError, "stored skill not found: #{source}" unless File.directory?(source)

      if File.symlink?(target)
        current = File.readlink(target)
        if Filesystem.symlink_points_to?(target, source)
          @shell_ui.note("already linked: #{name}")
          return
        end

        raise ExitError, "refusing to replace existing symlink: #{target} -> #{current}"
      end

      raise ExitError, "refusing to replace existing path: #{target}" if File.exist?(target)

      File.symlink(source, target)
      @shell_ui.note("linked #{name} -> #{source}")
    end

    def link_all
      names = @paths.store_skill_names

      if names.empty?
        @shell_ui.note("no non-hidden skills to link")
        return
      end

      names.each { |name| link_one(name) }
    end

    def unlink_one(name)
      Filesystem.assert_skill_name!(name)
      target = @paths.project_skill_path(name)

      if File.symlink?(target)
        File.delete(target)
        @shell_ui.note("unlinked #{name}")
        return
      end

      raise ExitError, "refusing to remove non-symlink path: #{target}" if File.exist?(target)

      @shell_ui.note("not linked: #{name}")
    end

    def clean_links
      unless Dir.exist?(@paths.project_skills_dir)
        @shell_ui.note("nothing to clean; missing #{@paths.project_skills_dir}")
        return
      end

      cleaned = 0
      @paths.project_entries.each do |name|
        path = @paths.project_skill_path(name)
        next unless File.symlink?(path)
        next if File.exist?(path)

        File.delete(path)
        @shell_ui.note("removed broken symlink #{name}")
        cleaned += 1
      end

      @shell_ui.note("no broken symlinks found") if cleaned.zero?
    end

    def promote_skill(name)
      @paths.ensure_store!
      @paths.ensure_project_skills_dir!
      Filesystem.assert_skill_name!(name)

      source = @paths.project_skill_path(name)
      target = @paths.store_skill_path(name)

      raise ExitError, "project skill not found: #{source}" unless File.exist?(source) || File.symlink?(source)

      if File.symlink?(source)
        current = File.readlink(source)
        if Filesystem.symlink_points_to?(source, target)
          @shell_ui.note("already promoted: #{name}")
          return
        end

        raise ExitError, "refusing to promote existing symlink: #{source} -> #{current}"
      end

      raise ExitError, "project skill must be a directory: #{source}" unless File.directory?(source)
      if File.exist?(target) || File.symlink?(target)
        raise ExitError, "destination already exists in dotfiles: #{target}"
      end

      FileUtils.mv(source, target)
      File.symlink(target, source)
      @shell_ui.note("promoted #{name} -> #{target}")
    end

    def adopt_skill(source_input, name = nil)
      @paths.ensure_store!
      @paths.ensure_project_skills_dir!

      raise ExitError, "adopt requires a source path" if source_input.nil? || source_input.empty?

      name = File.basename(source_input) if name.nil? || name.empty?
      Filesystem.assert_skill_name!(name)

      if source_input == name && File.directory?(@paths.project_skill_path(name))
        promote_skill(name)
        return
      end

      source = if source_input.start_with?("/")
                 source_input
               else
                 File.expand_path(source_input)
               end

      raise ExitError, "source skill directory not found: #{source}" unless File.directory?(source)

      target = @paths.store_skill_path(name)
      link_path = @paths.project_skill_path(name)

      if File.exist?(target) || File.symlink?(target)
        raise ExitError, "destination already exists in dotfiles: #{target}"
      end

      if File.symlink?(link_path)
        current = File.readlink(link_path)
        if Filesystem.symlink_points_to?(link_path, target)
          raise ExitError, "project already links #{name} to #{target}"
        end

        raise ExitError, "refusing to replace existing symlink: #{link_path} -> #{current}"
      end

      if File.exist?(link_path) && source != link_path
        raise ExitError, "refusing to replace existing project path: #{link_path}"
      end

      FileUtils.mv(source, target)
      FileUtils.rm_rf(link_path) if File.exist?(link_path) || File.symlink?(link_path)
      File.symlink(target, link_path)
      @shell_ui.note("adopted #{name} -> #{target}")
    end

    def rename_skill(old_name, new_name)
      @paths.ensure_store!
      @paths.ensure_project_skills_dir!
      Filesystem.assert_skill_name!(old_name)
      Filesystem.assert_skill_name!(new_name)
      raise ExitError, "old and new skill names are identical" if old_name == new_name

      old_target = @paths.store_skill_path(old_name)
      new_target = @paths.store_skill_path(new_name)
      old_link = @paths.project_skill_path(old_name)
      new_link = @paths.project_skill_path(new_name)

      raise ExitError, "stored skill not found: #{old_target}" unless File.directory?(old_target)
      if File.exist?(new_target) || File.symlink?(new_target)
        raise ExitError, "destination already exists in dotfiles: #{new_target}"
      end
      if File.exist?(new_link) || File.symlink?(new_link)
        raise ExitError, "destination already exists in project: #{new_link}"
      end

      linked_to_old_target = File.symlink?(old_link) && File.exist?(old_link) && File.identical?(old_link, old_target)
      FileUtils.mv(old_target, new_target)

      if linked_to_old_target
        File.delete(old_link)
        File.symlink(new_target, new_link)
        @shell_ui.note("updated project link #{old_name} -> #{new_name}")
      elsif File.symlink?(old_link)
        @shell_ui.note("stored skill renamed; project symlink left unchanged because it pointed elsewhere")
      elsif File.exist?(old_link)
        @shell_ui.note("stored skill renamed; project path #{old_link} left unchanged because it is not a symlink")
      end

      @shell_ui.note("renamed #{old_name} -> #{new_name}")
    end
  end
end
