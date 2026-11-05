# frozen_string_literal: true

require "open3"

require_relative "error"

module Skill
  # Identifiers (backticked spans, Markdown link targets, `$skill` refs) present
  # in the store's Markdown at a git ref but gone from the working tree and
  # owned nowhere else.
  class DroppedIdentifiers
    LINK_RE = /\[[^\]]*\]\(([^)\s]+)\)/.freeze
    SPAN_RE = /`([^`\n]+)`/.freeze
    SKILL_REF_RE = /(?<![\w$])\$[a-z][a-z0-9_-]*/.freeze
    FENCE_RE = /^```.*?^```/m.freeze

    # The tree subpath that `path` names at ref, following git symlink entries
    # (the path itself or a parent) to their in-dir targets; nil when it is
    # absent, not a tree, or its target leaves dir.
    def self.tree_at_ref(dir, ref, path, depth = 0)
      return nil if depth > 8

      parts = path.split("/")
      mode = type = nil
      parts.each_index do |i|
        cur = parts[0..i].join("/")
        mode, type = git_in(dir, ref, "ls-tree", "-z", ref, "--", cur).split(/[ \t]/, 3).first(2)
        return nil if mode.nil?
        next unless mode == "120000"

        target = normalize(File.join(File.dirname(cur), git_in(dir, ref, "show", "#{ref}:./#{cur}")))
        return target && tree_at_ref(dir, ref, [target, *parts[(i + 1)..]].join("/"), depth + 1)
      end
      type == "tree" ? path : nil
    end

    def self.normalize(joined)
      parts = []
      joined.split("/").each do |part|
        next if part.empty? || part == "."
        return nil if part == ".." && parts.empty?

        part == ".." ? parts.pop : parts << part
      end
      parts.empty? ? nil : parts.join("/")
    end

    def self.git_in(dir, ref, *args)
      output, err, status = Open3.capture3("git", "-C", dir, *args)
      raise ExitError, "git #{args.first} #{ref} failed: #{err.strip}" unless status.success?

      output.force_encoding(Encoding::UTF_8)
    end

    # dir: a git work tree directory. names nil: every non-hidden, non-README
    # Markdown file under it (a skill store), or under its subpath when given
    # (a store at REF whatever the working tree holds there; reported relative
    # to it); names given: those top-level files (root docs). owned_text: all
    # text that may still own an identifier.
    def initialize(dir:, ref:, owned_text:, names: nil, subpath: nil)
      @dir = dir
      @ref = ref
      @owned_text = owned_text
      @names = names
      @subpath = subpath
    end

    def findings
      seen = {}
      ref_files.sort.each do |rel, text|
        identifiers(text).each do |id|
          next if seen.key?(id) || owned?(id)

          seen[id] = "dropped: #{id} (#{rel})"
        end
      end
      seen.values
    end

    private

    # Token match: `dev` is not owned by `devops`, `$dev`, or `dev-tools`. A
    # boundary applies only where the id's edge is a word-like character, so
    # `agents/skills/` is owned by `agents/skills/x.md` and `.md` by `SKILL.md`.
    def owned?(id)
      before = id.match?(/\A[\w$-]/) ? '(?<![\w$-])' : ""
      after = id.match?(/[\w-]\z/) ? '(?![\w-])' : ""
      @owned_text.match?(/#{before}#{Regexp.escape(id)}#{after}/)
    end

    def identifiers(text)
      body = text.gsub(FENCE_RE, "")
      (body.scan(SPAN_RE).flatten + body.scan(LINK_RE).flatten + body.scan(SKILL_REF_RE))
        .map(&:strip).reject(&:empty?).uniq
    end

    def ref_files
      files = []
      listing.split("\0").each do |entry|
        meta, path = entry.split("\t", 2)
        next if path.nil? || meta.start_with?("120000")

        rel = @subpath ? path.sub(%r{\A#{Regexp.escape(@subpath)}/}, "") : path
        next unless markdown_doc?(rel)

        files << [rel, git("show", "#{@ref}:./#{path}")]
      end
      files
    end

    def listing
      return git("ls-tree", "-z", "-r", @ref, *(@subpath ? ["--", @subpath] : [])) unless @names

      git("ls-tree", "-z", @ref, "--", *@names)
    end

    def markdown_doc?(path)
      return true if @names
      return false unless path.end_with?(".md") && File.basename(path) != "README.md"

      path.split("/").none? { |part| part.start_with?(".") }
    end

    def git(*args)
      self.class.git_in(@dir, @ref, *args)
    end
  end
end
