# frozen_string_literal: true

require "optparse"

require_relative "skill/error"
require_relative "skill/operations"
require_relative "skill/paths"
require_relative "skill/ui"

module Skill
  class CLI
    COMMANDS = {
      "list" => :run_list,
      "promote" => :run_promote,
      "rename" => :run_rename,
      "help" => :run_help
    }.freeze

    USAGE_EXAMPLES = [
      "skill list",
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

    def usage
      puts <<~USAGE
        Usage: skill [--project PATH] <command> [args]

        Manage the dotfiles skill store (~/.dotfiles/skills). Install skills into agents with npx skills.

        Commands:
          list                         List skills available in #{paths.store_dir}
          promote <name>               Move .agents/skills/<name> into dotfiles
          rename <old> <new>           Rename a stored skill
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
