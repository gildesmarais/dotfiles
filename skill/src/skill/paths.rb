# frozen_string_literal: true

require "fileutils"
require "open3"

require_relative "error"

module Skill
  class Paths
    attr_writer :project_root

    def initialize(dotfiles_root:, project_root: nil, home_dir: nil)
      @dotfiles_root = dotfiles_root
      @project_root = project_root
      @home_dir = home_dir
      @project_skills_dir = nil
    end

    def store_dir
      File.join(@dotfiles_root, "agents", "skills")
    end

    def home_dir
      return @home_dir unless @home_dir.nil? || @home_dir.empty?

      ENV.fetch("HOME")
    end

    def agents_skills_dir
      File.join(home_dir, ".agents", "skills")
    end

    def agents_skill_path(name)
      File.join(agents_skills_dir, name)
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
      @project_skills_dir = File.join(project_root, ".agents", "skills")
    end

    def legacy_codex_skills_dir
      File.join(project_root, ".codex", "skills")
    end

    def legacy_codex_skill_path(name)
      File.join(legacy_codex_skills_dir, name)
    end

    def ensure_store!
      return if File.directory?(store_dir)

      raise ExitError, "skill store not found: #{store_dir}"
    end

    def store_skill_path(name)
      File.join(store_dir, name)
    end

    def project_skill_path(name)
      File.join(project_skills_dir, name)
    end

    def store_skill_names
      ensure_store!

      skill_entry_names(store_dir)
    end

    def agents_skill_names
      return [] unless File.directory?(agents_skills_dir)

      skill_entry_names(agents_skills_dir)
    end

    private

    def skill_entry_names(dir)
      Dir.children(dir).sort.select do |name|
        next false if name.start_with?(".")

        path = File.join(dir, name)
        File.directory?(path) || File.symlink?(path)
      end
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
