# frozen_string_literal: true

require_relative "error"

module Skill
  module Filesystem
    module_function

    def assert_skill_name!(name)
      raise ExitError, "skill name cannot be empty" if name.nil? || name.empty?
      raise ExitError, "skill name must not contain '/': #{name}" if name.include?("/")
      raise ExitError, "invalid skill name: #{name}" if [".", ".."].include?(name)
    end

    def symlink_target_path(path)
      normalized_path(File.expand_path(File.readlink(path), File.dirname(path)))
    end

    def symlink_points_to?(path, target)
      File.symlink?(path) && symlink_target_path(path) == normalized_path(target)
    end

    def within_directory?(path, directory)
      expanded_path = normalized_path(path)
      expanded_directory = normalized_path(directory)
      expanded_path == expanded_directory || expanded_path.start_with?("#{expanded_directory}/")
    end

    # Resolve existing path segments so macOS /var → /private/var matches even for
    # missing leaf paths (broken symlinks, prune targets).
    def normalized_path(path)
      expanded = File.expand_path(path)
      return File.realpath(expanded) if File.exist?(expanded)

      suffix = []
      dirname = expanded
      while dirname != "/" && !File.exist?(dirname)
        suffix.unshift(File.basename(dirname))
        parent = File.dirname(dirname)
        break if parent == dirname

        dirname = parent
      end

      base = File.exist?(dirname) ? File.realpath(dirname) : dirname
      suffix.empty? ? base : File.join(base, *suffix)
    rescue StandardError
      File.expand_path(path)
    end
  end
end
