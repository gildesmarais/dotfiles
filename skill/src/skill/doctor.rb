# frozen_string_literal: true

require_relative "filesystem"

module Skill
  class Doctor
    def initialize(paths:, shell_ui:)
      @paths = paths
      @shell_ui = shell_ui
    end

    def run
      @paths.ensure_store!

      issues = 0
      warnings = 0

      @shell_ui.note("project: #{@paths.project_root}")
      @shell_ui.note("store: #{@paths.store_dir}")

      unless Dir.exist?(@paths.project_skills_dir)
        puts("warning\tmissing project skill directory #{@paths.project_skills_dir}")
        warnings += 1
        @shell_ui.note("doctor found #{issues} issue(s), #{warnings} warning(s)")
        return
      end

      @paths.project_entries.each do |name|
        path = @paths.project_skill_path(name)

        if File.symlink?(path)
          target = File.readlink(path)
          resolved_target = Filesystem.symlink_target_path(path)

          unless File.exist?(path)
            puts("issue\tbroken symlink #{name} -> #{target}")
            issues += 1
            next
          end

          if inside_store?(resolved_target)
            if File.basename(resolved_target) != name
              puts("issue\tname mismatch #{name} -> #{target}")
              issues += 1
            else
              puts("ok\tlinked #{name}")
            end
          else
            puts("issue\tsymlink outside store #{name} -> #{target}")
            issues += 1
          end
        elsif File.directory?(path)
          puts("issue\tlocal directory still present #{name}")
          issues += 1
        else
          puts("issue\tnon-directory path present #{name}")
          issues += 1
        end
      end

      @paths.store_skill_names.each do |name|
        path = @paths.store_skill_path(name)
        link_path = @paths.project_skill_path(name)
        next if Filesystem.symlink_points_to?(link_path, path)

        puts("warning\tstored skill not linked in project #{name}")
        warnings += 1
      end

      if issues.zero? && warnings.zero?
        @shell_ui.note("doctor found no issues")
        return
      end

      @shell_ui.note("doctor found #{issues} issue(s), #{warnings} warning(s)")
      raise ExitError.new(status: 1) unless issues.zero?
    end

    private

    def inside_store?(resolved_target)
      Filesystem.within_directory?(resolved_target, @paths.store_dir)
    end
  end
end
