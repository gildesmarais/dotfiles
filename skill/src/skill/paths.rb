# frozen_string_literal: true

require "fileutils"
require "open3"

require_relative "error"

module Skill
  class Paths
    # Root docs that own identifiers and make up a project's always-loaded context.
    ROOT_DOCS = %w[AGENTS.md CONTEXT.md CLAUDE.md].freeze
    # Project-relative store locations, in lint order.
    PROJECT_STORES = %w[.agents/skills .claude/skills].freeze
    # rcup install roots under $HOME (~/.<root>/skills), in prune order.
    INSTALL_ROOTS = %w[agents claude].freeze

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

    # Repo-side entries rcup links into ~/.claude/skills (Claude Code does not
    # read ~/.agents/skills). Each one is a relative symlink into the store.
    def claude_dir
      File.join(@dotfiles_root, "claude", "skills")
    end

    # Top-level store files that skills cite as ../<file> and rcup must install.
    SHARED_FILES = ["CONTEXT.md"].freeze

    def shared_store_files
      SHARED_FILES.select { |name| File.file?(File.join(store_dir, name)) }
    end

    def claude_entry_path(name)
      File.join(claude_dir, name)
    end

    def claude_entry_target(name)
      File.join("..", "..", "agents", "skills", name)
    end

    def home_dir
      return @home_dir unless @home_dir.nil? || @home_dir.empty?

      ENV.fetch("HOME")
    end

    def agents_skills_dir
      install_dir("agents")
    end

    def install_dir(root)
      File.join(home_dir, ".#{root}", "skills")
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

    # Stores `skill --project` lints, as { "<dir>/skills" => real path }: each of
    # .agents/skills and .claude/skills that exists, symlinks resolved, one entry
    # per distinct real path. Empty when neither exists.
    def project_stores
      stores = {}
      PROJECT_STORES.each do |label|
        path = File.join(project_root, label)
        next unless File.directory?(path)

        real = File.realpath(path)
        stores[label] = real unless stores.value?(real)
      end
      stores
    rescue Errno::ENOENT
      {}
    end

    # Existing root docs (distinct real files) of the project, or of the
    # dotfiles repo when project is false.
    def root_doc_paths(project:)
      root = project ? project_root : @dotfiles_root
      ROOT_DOCS.map { |name| File.join(root, name) }
               .select { |path| File.file?(path) }
               .uniq { |path| File.realpath(path) }
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
      install_skill_names("agents")
    end

    def install_skill_names(root)
      dir = install_dir(root)
      return [] unless File.directory?(dir)

      skill_entry_names(dir)
    end

    private

    def skill_entry_names(dir)
      Dir.children(dir).sort.select do |name|
        next false if name.start_with?(".")

        path = File.join(dir, name)
        # Skill installs are directories (or dir symlinks). Include broken symlinks
        # so doctor can report `broken`. Exclude file symlinks (e.g. CONTEXT.md).
        File.directory?(path) || (File.symlink?(path) && !File.file?(path))
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
