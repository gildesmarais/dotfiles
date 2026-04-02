# frozen_string_literal: true

require_relative "filesystem"
require_relative "state"

module Skill
  class Doctor
    def initialize(paths:, shell_ui:)
      @paths = paths
      @shell_ui = shell_ui
    end

    def state
      @state ||= State.new(paths: @paths)
    end

    def run
      @paths.ensure_store!

      issues = 0
      warnings = 0

      @shell_ui.note("project: #{@paths.project_root}")
      @shell_ui.note("store: #{@paths.store_dir}")
      @shell_ui.note("authoring destination: #{@paths.project_skills_dir}")

      @paths.project_skills_dirs.each do |dir|
        @shell_ui.note("checking: #{dir}")
        unless Dir.exist?(dir)
          if dir == @paths.project_skills_dir
            puts("issue\tmissing authoring skill directory #{dir}")
            issues += 1
          else
            puts("warning\tmissing project skill directory #{dir}")
            warnings += 1
          end
          next
        end

        state.inspect_destination_entries(dir).each do |entry|
          case entry[:kind]
          when :symlink_to_store
            puts("ok\tlinked #{entry[:name]} in #{dir}")
          when :broken_symlink
            puts("issue\tbroken symlink #{entry[:name]} -> #{entry[:target]} in #{dir}")
            issues += 1
          when :symlink_elsewhere
            if inside_store?(entry[:resolved_target])
              puts("issue\tsymlink to different stored skill #{entry[:name]} -> #{entry[:target]} in #{dir}")
            else
              puts("issue\tsymlink outside store #{entry[:name]} -> #{entry[:target]} in #{dir}")
            end
            issues += 1
          when :local_directory
            puts("issue\tlocal directory still present #{entry[:name]} in #{dir}")
            issues += 1
          when :foreign_file
            puts("issue\tnon-directory path present #{entry[:name]} in #{dir}")
            issues += 1
          end
        end

        @paths.store_skill_names.each do |name|
          entry = state.inspect_destination_skill(dir, name, @paths.store_skill_path(name))
          next if entry[:kind] == :symlink_to_store

          if @paths.config.required.include?(name)
            puts("issue\trequired skill not linked in project #{name} in #{dir}")
            issues += 1
          else
            puts("warning\tstored skill not linked in project #{name} in #{dir}")
            warnings += 1
          end
        end
      end

      if issues.zero? && warnings.zero?
        @shell_ui.note("doctor found no issues")
        return
      end

      @shell_ui.note("doctor found #{issues} issue(s), #{warnings} warning(s)")
      raise ExitError.new(status: 1) unless issues.zero?
    end

    private

    def inside_store?(path)
      Filesystem.within_directory?(path, @paths.store_dir)
    end
  end
end
