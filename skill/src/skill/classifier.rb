# frozen_string_literal: true

require "fileutils"
require "find"

module Skill
  class Classifier
    # Per-skill statuses, plus "overlap" for an install root that overlaps the
    # store (see #overlaps_store?).
    STATUSES = %w[ok drift home-only broken orphan overlap].freeze

    def initialize(paths:)
      @paths = paths
    end

    def status_for(name, root: "agents")
      agent = File.join(@paths.install_dir(root), name)
      store = @paths.store_skill_path(name)

      return "broken" if File.symlink?(agent) && !File.exist?(agent)
      return "drift" if File.directory?(store) && File.directory?(agent) && drift_paths(name, root: root).any?
      return "orphan" if orphan_paths(name, root: root).any?
      return "home-only" if agent_entry?(agent) && !File.directory?(store)

      "ok"
    end

    def drift_paths(name, root: "agents")
      store = @paths.store_skill_path(name)
      agent = File.join(@paths.install_dir(root), name)
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

    # Links under ~/.<root>/skills/<name>/ that dangle and whose target, as the
    # OS resolves it, lies inside the dotfiles store (agents/skills or
    # claude/skills).
    # An install root that overlaps the store is never scanned: its dangling
    # links belong to the store, not to an rcup install.
    def orphan_paths(name, root: "agents")
      agent = File.join(@paths.install_dir(root), name)
      return [] unless File.directory?(agent)
      return [] if overlaps_store?(root)

      agent_root = File.expand_path(agent)

      orphans = []
      Find.find(agent_root) do |path|
        next if path == agent_root
        next unless File.symlink?(path)

        relative = path[(agent_root.length + 1)..]
        next if relative.nil? || relative.empty?
        next if relative.split("/").any? { |part| part.start_with?(".") }

        next if File.exist?(path)

        # Resolve relative targets from the link's real directory, as the OS
        # does, so a symlinked install root cannot misplace them.
        target = File.expand_path(File.readlink(path), File.realpath(File.dirname(path)))
        next unless under_store?(target, store_roots)

        orphans << relative
      end

      orphans.sort
    end

    # True when ~/.<root>/skills, resolved, lies inside the dotfiles store
    # (agents/skills or claude/skills) or contains it, e.g.
    # ~/.agents/skills -> ~/.dotfiles/agents/skills or ~/.claude/skills -> ~/.dotfiles.
    def overlaps_store?(root)
      install = canonical_prefix(@paths.install_dir(root))
      store_roots.any? { |store| under_root?(install, store) || under_root?(store, install) }
    end

    # [name, status] rows for one install root. The agents root lists every
    # store skill too; other roots list only what is installed there.
    def report_entries(root: "agents")
      installed = @paths.install_skill_names(root)
      names = root == "agents" ? (@paths.store_skill_names | installed).sort : installed
      names.map { |name| [name, status_for(name, root: root)] }
    end

    private

    def agent_entry?(path)
      File.directory?(path) || (File.symlink?(path) && File.exist?(path))
    end

    def store_roots
      [@paths.store_dir, @paths.claude_dir].map { |dir| canonical_prefix(dir) }
    end

    def under_store?(target, store_roots)
      canonical = canonical_prefix(target)
      store_roots.any? { |root| under_root?(canonical, root) }
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
