# frozen_string_literal: true

require "fileutils"
require "open3"

require_relative "error"

module Skill
  class Paths
    attr_writer :project_root

    def initialize(dotfiles_root:, project_root: nil)
      @dotfiles_root = dotfiles_root
      @project_root = project_root
      @project_skills_dir = nil
    end

    def store_dir
      File.join(@dotfiles_root, "skills")
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
      @project_skills_dir = File.join(project_root, ".codex", "skills")
    end

    def ensure_store!
      return if File.directory?(store_dir)

      raise ExitError, "skill store not found: #{store_dir}"
    end

    def ensure_project_skills_dir!
      FileUtils.mkdir_p(project_skills_dir)
    end

    def store_skill_path(name)
      File.join(store_dir, name)
    end

    def project_skill_path(name)
      File.join(project_skills_dir, name)
    end

    def store_skill_names
      ensure_store!

      Dir.children(store_dir).sort.select do |name|
        next false if name.start_with?(".")

        File.directory?(store_skill_path(name))
      end
    end

    def project_entries
      return [] unless Dir.exist?(project_skills_dir)

      Dir.entries(project_skills_dir).reject { |name| [".", ".."].include?(name) }.sort
    end

    private

    def capture_command(*command)
      output, status = Open3.capture2(*command, err: File::NULL)
      return nil unless status.success?

      output.to_s.strip
    rescue StandardError
      nil
    end
  end
end
