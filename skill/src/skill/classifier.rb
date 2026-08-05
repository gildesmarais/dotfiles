# frozen_string_literal: true

require "fileutils"
require "find"

module Skill
  class Classifier
    STATUSES = %w[ok drift home-only broken].freeze

    def initialize(paths:)
      @paths = paths
    end

    def status_for(name)
      agent = @paths.agents_skill_path(name)
      store = @paths.store_skill_path(name)

      return "broken" if File.symlink?(agent) && !File.exist?(agent)
      return "home-only" if agent_entry?(agent) && !File.directory?(store)
      return "drift" if File.directory?(store) && File.directory?(agent) && drift_paths(name).any?

      "ok"
    end

    def drift_paths(name)
      store = @paths.store_skill_path(name)
      agent = @paths.agents_skill_path(name)
      return [] unless File.directory?(store) && File.directory?(agent)

      agent_root = File.expand_path(agent)
      drifted = []

      Find.find(agent_root) do |path|
        next if path == agent_root
        next if File.directory?(path) || File.symlink?(path)
        next unless File.file?(path)

        relative = path[(agent_root.length + 1)..]
        next if relative.nil? || relative.empty?
        next if relative.split("/").any? { |part| part.start_with?(".") }

        store_file = File.join(store, relative)
        next if File.file?(store_file) && FileUtils.compare_file(path, store_file)

        drifted << relative
      end

      drifted.sort
    end

    def report_entries
      names = (@paths.store_skill_names | @paths.agents_skill_names).sort
      names.map { |name| [name, status_for(name)] }
    end

    private

    def agent_entry?(path)
      File.directory?(path) || (File.symlink?(path) && File.exist?(path))
    end
  end
end
