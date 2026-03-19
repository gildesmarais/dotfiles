# frozen_string_literal: true

require_relative "error"

module Skill
  class UI
    def note(message)
      puts("skill: #{message}")
    end

    def error(message)
      $stderr.write("skill: #{message}\n")
    end

    def reject_extra_args(command, args)
      return if args.empty?

      raise ExitError, "#{command} does not accept extra arguments"
    end
  end
end
