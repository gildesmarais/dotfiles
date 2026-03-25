# frozen_string_literal: true

require "optparse"

require_relative "skill/doctor"
require_relative "skill/error"
require_relative "skill/operations"
require_relative "skill/paths"
require_relative "skill/ui"

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
      "config" => :run_config,
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
      "skill rename ruby-dev ruby",
      "skill config init"
    ].freeze

    def self.run(argv = ARGV)
      new(argv).run
    end

    attr_accessor :project_root

    def initialize(argv)
      @argv = argv.dup
      @dotfiles_root = File.expand_path("../..", __dir__)
      @project_root = nil
    end

    def run
      command, command_args = parse_args(@argv)
      handler = COMMANDS[command]
      raise ExitError, "unknown command: #{command}" unless handler

      send(handler, command_args)
    rescue ExitError => e
      ui.error(e.message) unless e.message.nil? || e.message.empty?
      exit(e.status)
    end

    private

    def paths
      @paths ||= Paths.new(dotfiles_root: @dotfiles_root, project_root: @project_root)
    end

    def ui
      @ui ||= UI.new
    end

    def operations
      @operations ||= Operations.new(paths: paths, shell_ui: ui)
    end

    def doctor
      @doctor ||= Doctor.new(paths: paths, shell_ui: ui)
    end

    def usage
      puts <<~USAGE
        Usage: skill [--project PATH] <command> [args]

        Manage project skill links using dotfiles as the canonical store.

        Central config: #{Skill::Config.central_config_path}
        Project config: <project>/.skill.yml

        Commands:
          list                         List skills available in #{paths.store_dir}
          status                       Show skills linked in the project
          link <name> [name ...]       Link one or more stored skills into the project
          link --all                   Link every non-hidden skill from the store
          unlink <name> [name ...]     Remove one or more project skill symlinks
          clean                        Remove broken symlinks from the project
          doctor                       Diagnose project skill links and local copies
          adopt <path> [name]          Move a local skill directory into dotfiles and link it here
          promote <name>               Move the project-local skill into dotfiles and relink it
          rename <old> <new>           Rename a stored skill and update this project's symlink if needed
          config init                  Initialize ~/.config/skill/config.yml from the bundled template
          help                         Show this help

        Options:
        #{build_option_parser.summarize.map(&:chomp).join("\n")}

        Examples:
        #{USAGE_EXAMPLES.map { |example| "  #{example}" }.join("\n")}
      USAGE
    end

    def run_list(args)
      ui.reject_extra_args("list", args)
      operations.list_store_skills
    end

    def run_status(args)
      ui.reject_extra_args("status", args)
      operations.show_status
    end

    def run_link(args)
      return operations.link_all if args == ["--all"]

      raise ExitError, "link requires at least one skill name or --all" if args.empty?

      args.each { |name| operations.link_one(name) }
    end

    def run_unlink(args)
      raise ExitError, "unlink requires at least one skill name" if args.empty?

      args.each { |name| operations.unlink_one(name) }
    end

    def run_clean(args)
      ui.reject_extra_args("clean", args)
      operations.clean_links
    end

    def run_doctor(args)
      ui.reject_extra_args("doctor", args)
      doctor.run
    end

    def run_adopt(args)
      raise ExitError, "adopt requires a source path" if args.empty?
      raise ExitError, "adopt accepts a source path and optional name" if args.length > 2

      operations.adopt_skill(*args)
    end

    def run_promote(args)
      raise ExitError, "promote requires exactly one skill name" unless args.length == 1

      operations.promote_skill(args.first)
    end

    def run_rename(args)
      raise ExitError, "rename requires old and new skill names" unless args.length == 2

      operations.rename_skill(args[0], args[1])
    end

    def run_help(args)
      ui.reject_extra_args("help", args)
      usage
    end

    def run_config(args)
      raise ExitError, "config requires a subcommand" if args.empty?
      raise ExitError, "unknown config subcommand: #{args.first}" unless args.first == "init"
      raise ExitError, "config init does not accept extra arguments" unless args.length == 1

      operations.init_config
    end

    def parse_args(argv)
      args = argv.dup
      parser = build_option_parser

      parser.order!(args)

      if args.empty?
        usage
        raise ExitError.new(status: 1)
      end

      [args.first, args.drop(1)]
    rescue OptionParser::ParseError => e
      raise ExitError, e.message
    end

    def build_option_parser
      OptionParser.new do |parser|
        parser.on("-p", "--project PATH", "Project root. Defaults to the git root or current directory.") do |path|
          self.project_root = path
          paths.project_root = path if defined?(@paths) && @paths
        end
        parser.on_tail("-h", "--help", "Show this help") do
          usage
          raise ExitError.new(status: 0)
        end
      end
    end
  end
end

Skill::CLI.run(ARGV) if $PROGRAM_NAME == __FILE__
