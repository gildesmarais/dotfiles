# frozen_string_literal: true

require "fileutils"
require "open3"
require "optparse"

module Skill
  class CLI
    COMMANDS = {
      "list" => :run_list,
      "status" => :run_status,
      "link" => :run_link,
      "unlink" => :run_unlink,
      "clean" => :run_clean,
      "doctor" => :run_doctor,
      "adopt" => :run_adopt,
      "promote" => :run_promote,
      "rename" => :run_rename,
      "help" => :run_help
    }.freeze

    USAGE_EXAMPLES = [
      "skill list",
      "skill status",
      "skill link ruby-dev",
      "skill link --all",
      "skill unlink ruby-dev",
      "skill clean",
      "skill doctor",
      "skill adopt ../my-skill",
      "skill promote my-skill",
      "skill rename ruby-dev ruby"
    ].freeze

    def self.run(argv = ARGV)
      new(argv).run
    end

    attr_accessor :project_root

    def initialize(argv)
      @argv = argv.dup
      @dotfiles_root = File.expand_path("../..", __dir__)
      @store_dir = File.join(@dotfiles_root, "skills")
      @project_root = nil
      @project_skills_dir = nil
    end

    def run
      command, command_args = parse_args(@argv)
      handler = COMMANDS[command]
      die("unknown command: #{command}") unless handler

      send(handler, command_args)
    end

    private

    attr_reader :store_dir

    def usage
      puts <<~USAGE
        Usage: skill [--project PATH] <command> [args]

        Manage symlinked Codex skills for a project using dotfiles as the canonical store.

        Commands:
          list                         List skills available in #{store_dir}
          status                       Show skills linked in the project
          link <name> [name ...]       Link one or more stored skills into the project
          link --all                   Link every non-hidden skill from the store
          unlink <name> [name ...]     Remove one or more project skill symlinks
          clean                        Remove broken symlinks from the project
          doctor                       Diagnose project skill links and local copies
          adopt <path> [name]          Move a local skill directory into dotfiles and link it here
          promote <name>               Move project .codex/skills/<name> into dotfiles and relink it
          rename <old> <new>           Rename a stored skill and update this project's symlink if needed
          help                         Show this help

        Options:
        #{build_option_parser.summarize.map(&:chomp).join("\n")}

        Examples:
        #{USAGE_EXAMPLES.map { |example| "  #{example}" }.join("\n")}
      USAGE
    end

    def die(message)
      warn("skill: #{message}")
      exit(1)
    end

    def note(message)
      puts("skill: #{message}")
    end

    def reject_extra_args(command, args)
      die("#{command} does not accept extra arguments") unless args.empty?
    end

    def symlink_target_path(path)
      File.expand_path(File.readlink(path), File.dirname(path))
    end

    def symlink_points_to?(path, target)
      File.symlink?(path) && symlink_target_path(path) == File.expand_path(target)
    end

    def run_list(args)
      reject_extra_args("list", args)
      list_store_skills
    end

    def run_status(args)
      reject_extra_args("status", args)
      show_status
    end

    def run_link(args)
      return link_all if args == ["--all"]

      die("link requires at least one skill name or --all") if args.empty?
      args.each { |name| link_one(name) }
    end

    def run_unlink(args)
      die("unlink requires at least one skill name") if args.empty?
      args.each { |name| unlink_one(name) }
    end

    def run_clean(args)
      reject_extra_args("clean", args)
      clean_links
    end

    def run_doctor(args)
      reject_extra_args("doctor", args)
      doctor_skills
    end

    def run_adopt(args)
      die("adopt requires a source path") if args.empty?
      die("adopt accepts a source path and optional name") if args.length > 2
      adopt_skill(*args)
    end

    def run_promote(args)
      die("promote requires exactly one skill name") unless args.length == 1
      promote_skill(args.first)
    end

    def run_rename(args)
      die("rename requires old and new skill names") unless args.length == 2
      rename_skill(args[0], args[1])
    end

    def run_help(args)
      reject_extra_args("help", args)
      usage
    end

    def resolve_project_root
      return if @project_root && !@project_root.empty?

      git_root = capture_command("git", "rev-parse", "--show-toplevel")
      @project_root = if git_root && !git_root.empty?
                        git_root
                      else
                        Dir.pwd
                      end
    end

    def init_project_paths
      resolve_project_root
      @project_skills_dir = File.join(@project_root, ".codex", "skills")
    end

    def ensure_store
      die("skill store not found: #{store_dir}") unless File.directory?(store_dir)
    end

    def ensure_project_skills_dir
      init_project_paths
      FileUtils.mkdir_p(@project_skills_dir)
    end

    def store_skill_path(name)
      File.join(store_dir, name)
    end

    def project_skill_path(name)
      init_project_paths
      File.join(@project_skills_dir, name)
    end

    def assert_skill_name(name)
      die("skill name cannot be empty") if name.nil? || name.empty?
      die("skill name must not contain '/': #{name}") if name.include?("/")
      die("invalid skill name: #{name}") if [".", ".."].include?(name)
    end

    def store_skill_names
      ensure_store

      Dir.children(store_dir).sort.select do |name|
        next false if name.start_with?(".")

        path = store_skill_path(name)
        File.directory?(path)
      end
    end

    def project_entries
      init_project_paths
      return [] unless Dir.exist?(@project_skills_dir)

      Dir.entries(@project_skills_dir).reject { |name| [".", ".."].include?(name) }.sort
    end

    def list_store_skills
      names = store_skill_names

      if names.empty?
        note("no non-hidden skills found in #{store_dir}")
        return
      end

      names.each { |name| puts(name) }
    end

    def show_status
      init_project_paths

      note("project: #{@project_root}")
      note("store: #{store_dir}")

      unless Dir.exist?(@project_skills_dir)
        note("project skill directory does not exist: #{@project_skills_dir}")
        return
      end

      entries = project_entries
      if entries.empty?
        note("no project skills found in #{@project_skills_dir}")
        return
      end

      entries.each do |name|
        path = File.join(@project_skills_dir, name)

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
      ensure_store
      ensure_project_skills_dir
      assert_skill_name(name)

      source = store_skill_path(name)
      target = project_skill_path(name)

      die("stored skill not found: #{source}") unless File.directory?(source)

      if File.symlink?(target)
        current = File.readlink(target)
        if symlink_points_to?(target, source)
          note("already linked: #{name}")
          return
        end

        die("refusing to replace existing symlink: #{target} -> #{current}")
      end

      die("refusing to replace existing path: #{target}") if File.exist?(target)

      File.symlink(source, target)
      note("linked #{name} -> #{source}")
    end

    def link_all
      names = store_skill_names

      if names.empty?
        note("no non-hidden skills to link")
        return
      end

      names.each { |name| link_one(name) }
    end

    def unlink_one(name)
      assert_skill_name(name)
      target = project_skill_path(name)

      if File.symlink?(target)
        File.delete(target)
        note("unlinked #{name}")
        return
      end

      die("refusing to remove non-symlink path: #{target}") if File.exist?(target)

      note("not linked: #{name}")
    end

    def clean_links
      init_project_paths

      unless Dir.exist?(@project_skills_dir)
        note("nothing to clean; missing #{@project_skills_dir}")
        return
      end

      cleaned = 0
      project_entries.each do |name|
        path = File.join(@project_skills_dir, name)
        next unless File.symlink?(path)
        next if File.exist?(path)

        File.delete(path)
        note("removed broken symlink #{name}")
        cleaned += 1
      end

      note("no broken symlinks found") if cleaned.zero?
    end

    def promote_skill(name)
      ensure_store
      ensure_project_skills_dir
      assert_skill_name(name)

      source = project_skill_path(name)
      target = store_skill_path(name)

      unless File.exist?(source) || File.symlink?(source)
        die("project skill not found: #{source}")
      end

      if File.symlink?(source)
        current = File.readlink(source)
        if symlink_points_to?(source, target)
          note("already promoted: #{name}")
          return
        end

        die("refusing to promote existing symlink: #{source} -> #{current}")
      end

      die("project skill must be a directory: #{source}") unless File.directory?(source)
      die("destination already exists in dotfiles: #{target}") if File.exist?(target) || File.symlink?(target)

      FileUtils.mv(source, target)
      File.symlink(target, source)
      note("promoted #{name} -> #{target}")
    end

    def adopt_skill(source_input, name = nil)
      ensure_store
      ensure_project_skills_dir

      die("adopt requires a source path") if source_input.nil? || source_input.empty?

      name = File.basename(source_input) if name.nil? || name.empty?
      assert_skill_name(name)

      if source_input == name && File.directory?(project_skill_path(name))
        promote_skill(name)
        return
      end

      source = if source_input.start_with?("/")
                 source_input
               else
                 File.expand_path(source_input)
               end

      die("source skill directory not found: #{source}") unless File.directory?(source)

      target = store_skill_path(name)
      link_path = project_skill_path(name)

      die("destination already exists in dotfiles: #{target}") if File.exist?(target) || File.symlink?(target)

      if File.symlink?(link_path)
        current = File.readlink(link_path)
        die("project already links #{name} to #{target}") if symlink_points_to?(link_path, target)
        die("refusing to replace existing symlink: #{link_path} -> #{current}")
      end

      if File.exist?(link_path) && source != link_path
        die("refusing to replace existing project path: #{link_path}")
      end

      FileUtils.mv(source, target)
      FileUtils.rm_rf(link_path) if File.exist?(link_path) || File.symlink?(link_path)
      File.symlink(target, link_path)
      note("adopted #{name} -> #{target}")
    end

    def rename_skill(old_name, new_name)
      ensure_store
      ensure_project_skills_dir
      assert_skill_name(old_name)
      assert_skill_name(new_name)
      die("old and new skill names are identical") if old_name == new_name

      old_target = store_skill_path(old_name)
      new_target = store_skill_path(new_name)
      old_link = project_skill_path(old_name)
      new_link = project_skill_path(new_name)

      die("stored skill not found: #{old_target}") unless File.directory?(old_target)
      die("destination already exists in dotfiles: #{new_target}") if File.exist?(new_target) || File.symlink?(new_target)
      die("destination already exists in project: #{new_link}") if File.exist?(new_link) || File.symlink?(new_link)

      linked_to_old_target = File.symlink?(old_link) && File.exist?(old_link) && File.identical?(old_link, old_target)
      FileUtils.mv(old_target, new_target)

      if linked_to_old_target
        File.delete(old_link)
        File.symlink(new_target, new_link)
        note("updated project link #{old_name} -> #{new_name}")
      elsif File.symlink?(old_link)
        note("stored skill renamed; project symlink left unchanged because it pointed elsewhere")
      elsif File.exist?(old_link)
        note("stored skill renamed; project path #{old_link} left unchanged because it is not a symlink")
      end

      note("renamed #{old_name} -> #{new_name}")
    end

    def doctor_skills
      ensure_store
      init_project_paths

      issues = 0
      warnings = 0

      note("project: #{@project_root}")
      note("store: #{store_dir}")

      unless Dir.exist?(@project_skills_dir)
        puts("warning\tmissing project skill directory #{@project_skills_dir}")
        warnings += 1
        note("doctor found #{issues} issue(s), #{warnings} warning(s)")
        return
      end

      project_entries.each do |name|
        path = File.join(@project_skills_dir, name)

        if File.symlink?(path)
          target = File.readlink(path)

          unless File.exist?(path)
            puts("issue\tbroken symlink #{name} -> #{target}")
            issues += 1
            next
          end

          if target.start_with?("#{store_dir}/")
            if File.basename(target) != name
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

      store_skill_names.each do |name|
        path = store_skill_path(name)
        link_path = project_skill_path(name)
        next if symlink_points_to?(link_path, path)

        puts("warning\tstored skill not linked in project #{name}")
        warnings += 1
      end

      if issues.zero? && warnings.zero?
        note("doctor found no issues")
        return
      end

      note("doctor found #{issues} issue(s), #{warnings} warning(s)")
      exit(1) unless issues.zero?
    end

    def parse_args(argv)
      args = argv.dup
      parser = build_option_parser

      parser.order!(args)

      if args.empty?
        usage
        exit(1)
      end

      [args.first, args.drop(1)]
    rescue OptionParser::ParseError => e
      die(e.message)
    end

    def build_option_parser
      OptionParser.new do |parser|
        parser.on("-p", "--project PATH", "Project root. Defaults to the git root or current directory.") do |path|
          self.project_root = path
        end
        parser.on_tail("-h", "--help", "Show this help") do
          usage
          exit(0)
        end
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

Skill::CLI.run(ARGV) if $PROGRAM_NAME == __FILE__
