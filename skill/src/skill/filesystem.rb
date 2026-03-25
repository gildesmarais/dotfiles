# frozen_string_literal: true

require "pathname"

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

    def normalized_path(path)
      expanded = File.expand_path(path)
      File.realpath(expanded)
    rescue StandardError
      parent = File.dirname(expanded)
      begin
        File.join(File.realpath(parent), File.basename(expanded))
      rescue StandardError
        expanded
      end
    end

    def create_symlink(target, link_path)
      link_dir = File.dirname(link_path)
      relative_target = Pathname.new(normalized_path(target)).relative_path_from(Pathname.new(link_dir))
      File.symlink(relative_target.to_s, link_path)
    end
  end
end
