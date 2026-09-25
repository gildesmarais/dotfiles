# frozen_string_literal: true

require "fileutils"
require "find"

module Skill
  class Classifier
    STATUSES = %w[ok drift home-only broken orphan].freeze

    def initialize(paths:)
      @paths = paths
    end

    def status_for(name)
      agent = @paths.agents_skill_path(name)
      store = @paths.store_skill_path(name)

      return "broken" if File.symlink?(agent) && !File.exist?(agent)
      return "drift" if File.directory?(store) && File.directory?(agent) && drift_paths(name).any?
      return "orphan" if orphan_paths(name).any?
      return "home-only" if agent_entry?(agent) && !File.directory?(store)

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

    def orphan_paths(name)
      agent = @paths.agents_skill_path(name)
      return [] unless File.directory?(agent)

      agent_root = File.expand_path(agent)
      store_root = canonical_prefix(@paths.store_dir)

      orphans = []
      Find.find(agent_root) do |path|
        next if path == agent_root
        next unless File.symlink?(path)

        relative = path[(agent_root.length + 1)..]
        next if relative.nil? || relative.empty?
        next if relative.split("/").any? { |part| part.start_with?(".") }

        absolute = File.expand_path(File.readlink(path), File.dirname(path))
        next unless under_store?(absolute, store_root)
        next if File.exist?(absolute)

        orphans << relative
      end

      orphans.sort
    end

    def report_entries
      names = (@paths.store_skill_names | @paths.agents_skill_names).sort
      names.map { |name| [name, status_for(name)] }
    end

    private

    def agent_entry?(path)
      File.directory?(path) || (File.symlink?(path) && File.exist?(path))
    end

    def under_store?(absolute, store_root)
      candidate = canonical_prefix(absolute)
      under_root?(candidate, store_root) || under_root?(File.expand_path(absolute), store_root)
    end

    def under_root?(path, root)
      path == root || path.start_with?(root + File::SEPARATOR)
    end

    # Resolve existing path prefixes so /var vs /private/var comparisons match.
    def canonical_prefix(path)
      expanded = File.expand_path(path)
      probe = expanded
      suffix = []

      until probe.empty? || probe == File::SEPARATOR
        if File.exist?(probe)
          resolved = File.realpath(probe)
          return suffix.empty? ? resolved : File.join(resolved, *suffix)
        end

        suffix.unshift(File.basename(probe))
        parent = File.dirname(probe)
        break if parent == probe

        probe = parent
      end

      expanded
    rescue Errno::ENOENT, Errno::ELOOP
      File.expand_path(path)
    end
  end
end
