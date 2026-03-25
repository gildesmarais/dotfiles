# frozen_string_literal: true

require "fileutils"

require_relative "error"
require_relative "filesystem"
require_relative "state"

module Skill
  class Operations
    def initialize(paths:, shell_ui:)
      @paths = paths
      @shell_ui = shell_ui
    end

    def state
      @state ||= State.new(paths: @paths)
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
      @shell_ui.note("authoring destination: #{@paths.project_skills_dir}")

      @paths.project_skills_dirs.each do |dir|
        @shell_ui.note("checking: #{dir}")
        unless Dir.exist?(dir)
          @shell_ui.note("  project skill directory does not exist: #{dir}")
          next
        end

        entries = state.inspect_destination_entries(dir)
        if entries.empty?
          @shell_ui.note("  no project skills found in #{dir}")
          next
        end

        entries.each do |entry|
          puts("  #{status_label(entry)}\t#{entry[:name]}#{status_suffix(entry)}")
        end
      end
    end

    def link_one(name)
      @paths.ensure_store!
      @paths.ensure_project_skills_dirs!
      Filesystem.assert_skill_name!(name)

      source = @paths.store_skill_path(name)
      raise ExitError, "stored skill not found: #{source}" unless File.directory?(source)

      failures = []
      state.inspect_skill(name).each do |entry|
        case entry[:kind]
        when :missing
          Filesystem.create_symlink(source, entry[:path])
          @shell_ui.note("linked #{name} -> #{source} in #{entry[:destination]}")
        when :symlink_to_store
          @shell_ui.note("already linked: #{name} in #{entry[:destination]}")
        when :symlink_elsewhere
          @shell_ui.note("refusing to replace existing symlink: #{entry[:path]} -> #{entry[:target]}")
          failures << entry[:path]
        when :broken_symlink
          @shell_ui.note("refusing to replace broken symlink: #{entry[:path]} -> #{entry[:target]}")
          failures << entry[:path]
        else
          @shell_ui.note("refusing to replace existing path: #{entry[:path]}")
          failures << entry[:path]
        end
      end

      raise ExitError, "failed to link #{name} in #{failures.length} destination(s)" unless failures.empty?
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

      failures = []
      state.inspect_skill(name).each do |entry|
        case entry[:kind]
        when :symlink_to_store
          File.delete(entry[:path])
          @shell_ui.note("unlinked #{name} from #{entry[:destination]}")
        when :missing
          @shell_ui.note("not linked: #{name} in #{entry[:destination]}")
        when :symlink_elsewhere
          @shell_ui.note("refusing to remove foreign symlink: #{entry[:path]} -> #{entry[:target]}")
          failures << entry[:path]
        when :broken_symlink
          @shell_ui.note("refusing to remove broken symlink outside clean: #{entry[:path]} -> #{entry[:target]}")
          failures << entry[:path]
        else
          @shell_ui.note("refusing to remove non-symlink path: #{entry[:path]}")
          failures << entry[:path]
        end
      end

      raise ExitError, "failed to unlink #{name} in #{failures.length} destination(s)" unless failures.empty?
    end

    def clean_links
      @paths.project_skills_dirs.each do |dir|
        unless Dir.exist?(dir)
          @shell_ui.note("nothing to clean; missing #{dir}")
          next
        end

        cleaned = 0
        failures = []
        state.inspect_destination_entries(dir).each do |entry|
          next unless entry[:kind] == :broken_symlink

          if inside_store?(entry[:resolved_target])
            File.delete(entry[:path])
            @shell_ui.note("removed broken symlink #{entry[:name]} from #{dir}")
            cleaned += 1
          else
            @shell_ui.note("refusing to remove broken symlink outside store: #{entry[:path]} -> #{entry[:target]}")
            failures << entry[:path]
          end
        end

        @shell_ui.note("no broken symlinks found in #{dir}") if cleaned.zero?
        raise ExitError, "failed to clean #{failures.length} broken symlink(s) in #{dir}" unless failures.empty?
      end
    end

    def promote_skill(name)
      @paths.ensure_store!
      @paths.ensure_project_skills_dirs!
      Filesystem.assert_skill_name!(name)

      states = state.inspect_skill(name)
      local_states = states.select { |entry| entry[:kind] == :local_directory }
      if local_states.length > 1
        local_paths = local_states.map { |entry| entry[:path] }.sort.join(", ")
        raise ExitError, "multiple local skill directories found for promotion: #{local_paths}"
      end

      if local_states.empty?
        if states.any? { |entry| entry[:kind] == :symlink_to_store }
          @shell_ui.note("already promoted: #{name}")
          return
        end

        raise ExitError, "project skill directory not found for promotion: #{name}"
      end

      source = local_states.first
      if source[:destination] != @paths.project_skills_dir
        @shell_ui.note("using mirror destination for promote fallback: #{source[:destination]}")
      end

      assert_linkable_destinations!(states, name, allow_local_path: source[:path])
      target = @paths.store_skill_path(name)
      if File.exist?(target) || File.symlink?(target)
        raise ExitError, "destination already exists in dotfiles: #{target}"
      end

      FileUtils.mv(source[:path], target)
      @shell_ui.note("promoted #{name} -> #{target}")

      link_one(name)
    end

    def adopt_skill(source_input, name = nil)
      @paths.ensure_store!
      @paths.ensure_project_skills_dirs!

      raise ExitError, "adopt requires a source path" if source_input.nil? || source_input.empty?

      name = File.basename(source_input) if name.nil? || name.empty?
      Filesystem.assert_skill_name!(name)

      if source_input == name && state.inspect_skill(name).any? { |entry| entry[:kind] == :local_directory }
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
      if File.exist?(target) || File.symlink?(target)
        raise ExitError, "destination already exists in dotfiles: #{target}"
      end

      allow_local_path = nil
      states = state.inspect_skill(name)
      match = states.find { |entry| entry[:kind] == :local_directory && same_path?(entry[:path], source) }
      allow_local_path = match[:path] unless match.nil?
      assert_linkable_destinations!(states, name, allow_local_path: allow_local_path)

      FileUtils.mv(source, target)
      @shell_ui.note("adopted #{name} -> #{target}")

      link_one(name)
    end

    def rename_skill(old_name, new_name)
      @paths.ensure_store!
      @paths.ensure_project_skills_dirs!
      Filesystem.assert_skill_name!(old_name)
      Filesystem.assert_skill_name!(new_name)
      raise ExitError, "old and new skill names are identical" if old_name == new_name

      old_target = @paths.store_skill_path(old_name)
      new_target = @paths.store_skill_path(new_name)

      raise ExitError, "stored skill not found: #{old_target}" unless File.directory?(old_target)
      if File.exist?(new_target) || File.symlink?(new_target)
        raise ExitError, "destination already exists in dotfiles: #{new_target}"
      end

      state.inspect_skill(new_name).each do |entry|
        next if entry[:kind] == :missing

        raise ExitError, "destination already exists in project: #{entry[:path]}"
      end

      old_states = state.inspect_skill(old_name)
      FileUtils.mv(old_target, new_target)
      @shell_ui.note("renamed #{old_name} -> #{new_name} in store")

      old_states.each do |entry|
        new_link = File.join(entry[:destination], new_name)

        case entry[:kind]
        when :symlink_to_store
          File.delete(entry[:path])
          Filesystem.create_symlink(new_target, new_link)
          @shell_ui.note("updated project link #{old_name} -> #{new_name} in #{entry[:destination]}")
        when :symlink_elsewhere
          @shell_ui.note("project symlink in #{entry[:destination]} left unchanged because it pointed elsewhere")
        when :broken_symlink
          @shell_ui.note("project symlink in #{entry[:destination]} left unchanged because it is broken")
        when :local_directory, :foreign_file
          @shell_ui.note("project path #{entry[:path]} left unchanged because it is not a symlink")
        end
      end
    end

    def init_config
      target_path = @paths.config.central_config_path
      source_path = @paths.config_template_path

      raise ExitError, "config template not found: #{source_path}" unless File.file?(source_path)
      raise ExitError, "config already exists: #{target_path}" if File.exist?(target_path) || File.symlink?(target_path)

      FileUtils.mkdir_p(File.dirname(target_path))
      FileUtils.cp(source_path, target_path)
      @shell_ui.note("initialized config at #{target_path}")
    end

    private

    def assert_linkable_destinations!(states, name, allow_local_path: nil)
      failures = []

      states.each do |entry|
        next if entry[:kind] == :missing
        next if entry[:kind] == :symlink_to_store
        next if entry[:kind] == :local_directory && !allow_local_path.nil? && same_path?(entry[:path], allow_local_path)

        failures << entry
      end

      return if failures.empty?

      failures.each do |entry|
        case entry[:kind]
        when :symlink_elsewhere
          @shell_ui.note("refusing to replace existing symlink: #{entry[:path]} -> #{entry[:target]}")
        when :broken_symlink
          @shell_ui.note("refusing to replace broken symlink: #{entry[:path]} -> #{entry[:target]}")
        else
          @shell_ui.note("refusing to replace existing path: #{entry[:path]}")
        end
      end

      raise ExitError, "failed to prepare #{name} in #{failures.length} destination(s)"
    end

    def same_path?(left, right)
      Filesystem.normalized_path(left) == Filesystem.normalized_path(right)
    end

    def status_label(entry)
      case entry[:kind]
      when :broken_symlink
        "broken"
      when :symlink_elsewhere
        "foreign"
      when :local_directory
        "local"
      when :foreign_file
        "file"
      else
        "linked"
      end
    end

    def status_suffix(entry)
      return "" unless %i[symlink_to_store symlink_elsewhere broken_symlink].include?(entry[:kind])

      " -> #{entry[:target]}"
    end

    def inside_store?(path)
      Filesystem.within_directory?(path, @paths.store_dir)
    end
  end
end
