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

    # dir: a git work tree directory. names nil: every non-hidden, non-README
    # Markdown file under it (a skill store); names given: those top-level files
    # (root docs). owned_text: all text that may still own an identifier.
    def initialize(dir:, ref:, owned_text:, names: nil)
      @dir = dir
      @ref = ref
      @owned_text = owned_text
      @names = names
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

    # Token match: `dev` is not owned by `devops`, `$dev`, or `dev-tools`.
    def owned?(id)
      @owned_text.match?(/(?<![\w$-])#{Regexp.escape(id)}(?![\w-])/)
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
        next unless markdown_doc?(path)

        files << [path, git("show", "#{@ref}:./#{path}")]
      end
      files
    end

    def listing
      return git("ls-tree", "-z", "-r", @ref) unless @names

      git("ls-tree", "-z", @ref, "--", *@names)
    end

    def markdown_doc?(path)
      return true if @names
      return false unless path.end_with?(".md") && File.basename(path) != "README.md"

      path.split("/").none? { |part| part.start_with?(".") }
    end

    def git(*args)
      output, err, status = Open3.capture3("git", "-C", @dir, *args)
      raise ExitError, "git #{args.first} #{@ref} failed: #{err.strip}" unless status.success?

      output.force_encoding(Encoding::UTF_8)
    end
  end
end
