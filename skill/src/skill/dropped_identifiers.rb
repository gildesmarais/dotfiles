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

    # current: { rel => text } of the working-tree store; owned_text: all text
    # that may still own an identifier (working tree store + root docs).
    def initialize(store:, ref:, current:, owned_text:)
      @store = store
      @ref = ref
      @current = current
      @owned_text = owned_text
    end

    def findings
      now = @current.values.flat_map { |text| identifiers(text) }
      seen = {}
      ref_files.sort.each do |rel, text|
        identifiers(text).each do |id|
          next if seen.key?(id) || now.include?(id) || @owned_text.include?(id)

          seen[id] = "dropped: #{id} (#{rel})"
        end
      end
      seen.values
    end

    private

    def identifiers(text)
      body = text.gsub(FENCE_RE, "")
      (body.scan(SPAN_RE).flatten + body.scan(LINK_RE).flatten + body.scan(SKILL_REF_RE))
        .map(&:strip).reject(&:empty?).uniq
    end

    def ref_files
      files = []
      git("ls-tree", "-r", @ref).each_line do |line|
        meta, path = line.chomp.split("\t", 2)
        next if path.nil? || meta.start_with?("120000")
        next unless path.end_with?(".md") && File.basename(path) != "README.md"
        next if path.split("/").any? { |part| part.start_with?(".") }

        files << [path, git("show", "#{@ref}:./#{path}")]
      end
      files
    end

    def git(*args)
      output, err, status = Open3.capture3("git", "-C", @store, *args)
      raise ExitError, "git #{args.first} #{@ref} failed: #{err.strip}" unless status.success?

      output
    end
  end
end
