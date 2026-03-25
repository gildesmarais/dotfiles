# frozen_string_literal: true

require_relative "filesystem"

module Skill
  class State
    def initialize(paths:)
      @paths = paths
    end

    def inspect_skill(name)
      store_path = @paths.store_skill_path(name)

      @paths.project_skills_dirs.map do |dir|
        inspect_destination_skill(dir, name, store_path)
      end
    end

    def inspect_destination_entries(dir)
      @paths.project_entries(dir).map do |name|
        store_path = @paths.store_skill_path(name)
        store_path = nil unless File.directory?(store_path)
        inspect_destination_skill(dir, name, store_path)
      end
    end

    def inspect_destination_skill(dir, name, store_path = nil)
      path = File.join(dir, name)
      result = inspect_path(path, store_path)
      result[:destination] = dir
      result[:name] = name
      result
    end

    def inspect_path(path, store_path = nil)
      if File.symlink?(path)
        target = File.readlink(path)
        resolved_target = Filesystem.symlink_target_path(path)
        normalized_store_path = Filesystem.normalized_path(store_path) unless store_path.nil?

        if !File.exist?(path)
          { path: path, kind: :broken_symlink, resolved_target: resolved_target, target: target }
        elsif !normalized_store_path.nil? && resolved_target == normalized_store_path
          { path: path, kind: :symlink_to_store, resolved_target: resolved_target, target: target }
        else
          { path: path, kind: :symlink_elsewhere, resolved_target: resolved_target, target: target }
        end
      elsif File.directory?(path)
        { path: path, kind: :local_directory }
      elsif File.exist?(path)
        { path: path, kind: :foreign_file }
      else
        { path: path, kind: :missing }
      end
    end
  end
end
