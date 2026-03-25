# frozen_string_literal: true

require "fileutils"
require "open3"

require_relative "error"
require_relative "config"

module Skill
  class Paths
    def initialize(dotfiles_root:, project_root: nil)
      @dotfiles_root = dotfiles_root
      @project_root = project_root
      @config = nil
    end

    def project_root=(value)
      @project_root = value
      @config = nil
    end

    def config
      @config ||= Config.load(project_root, @dotfiles_root)
    end

    def store_dir
      config.store_dir
    end

    def project_root
      return @project_root unless @project_root.nil? || @project_root.empty?

      git_root = capture_command("git", "rev-parse", "--show-toplevel")
      @project_root = if git_root && !git_root.empty?
                        git_root
                      else
                        Dir.pwd
                      end
    end

    def project_skills_dir
      resolve_project_destination(config.authoring_destination)
    end

    def project_skills_dirs
      config.destinations.map { |dest| resolve_project_destination(dest) }
    end

    def ensure_store!
      return if File.directory?(store_dir)

      raise ExitError, "skill store not found: #{store_dir}"
    end

    def ensure_project_skills_dirs!
      project_skills_dirs.each { |dir| FileUtils.mkdir_p(dir) }
    end

    def store_skill_path(name)
      File.join(store_dir, name)
    end

    def config_template_path
      File.join(@dotfiles_root, "skill", "config", "default-config.yml")
    end

    def project_skill_path(name)
      File.join(project_skills_dir, name)
    end

    def project_skill_paths(name)
      project_skills_dirs.map { |dir| File.join(dir, name) }
    end

    def store_skill_names
      ensure_store!

      Dir.children(store_dir).sort.select do |name|
        next false if name.start_with?(".")
        next false if config.ignored?(name)

        File.directory?(store_skill_path(name))
      end
    end

    def project_entries(dir)
      return [] unless Dir.exist?(dir)

      Dir.entries(dir).reject { |name| [".", ".."].include?(name) }.sort
    end

    private

    def resolve_project_destination(destination)
      File.expand_path(destination, project_root)
    end

    def capture_command(*command)
      output, status = Open3.capture2(*command, err: File::NULL)
      return nil unless status.success?

      output.to_s.strip
    rescue StandardError
      nil
    end
  end
end
