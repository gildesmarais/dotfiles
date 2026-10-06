# frozen_string_literal: true

require "find"
require "yaml"

require_relative "error"

module Skill
  class Linter
    BUDGETS_FILE = ".budgets.yml"
    DEFAULT_DESCRIPTION_MAX_WORDS = 80
    DEFAULT_LEARNING_LOG_MAX_LINES = 20
    DEFAULT_LINE_CAP = 100
    DUPLICATE_MIN_WORDS = 12
    ROUTER_HEADERS = [
      "Pick branch",
      "Shared prep",
      "Branch reference",
      "Handoff",
      "Completion criteria"
    ].freeze
    MD_LINK_RE = /\[(?:[^\]]*)\]\(([^)]+)\)/.freeze
    FRONTMATTER_RE = /\A---\r?\n(.*?)\r?\n---\r?\n/m.freeze

    def initialize(paths:)
      @paths = paths
      @errors = []
    end

    def run
      @paths.ensure_store!
      @store = @paths.store_dir
      @budgets = load_budgets
      @files = installed_markdown_files
      @contents = {}
      @files.each { |rel| @contents[rel] = File.read(File.join(@store, rel)) }

      check_line_caps
      check_word_ratchet
      check_descriptions
      check_router_shapes
      check_links_resolve
      check_link_graph
      check_duplicate_lines
      check_learning_logs

      @errors
    end

    private

    def load_budgets
      path = File.join(@store, BUDGETS_FILE)
      raise ExitError, "missing budgets file: #{path}" unless File.file?(path)

      data = yaml_load(File.read(path))
      raise ExitError, "budgets file must be a mapping: #{path}" unless data.is_a?(Hash)

      data
    end

    def installed_markdown_files
      files = []
      Find.find(@store) do |path|
        next if path == @store

        rel = path[(@store.length + 1)..]
        next if rel.nil? || rel.empty?

        parts = rel.split("/")
        Find.prune if parts.any? { |part| part.start_with?(".") }
        next unless File.file?(path)
        next unless rel.end_with?(".md")
        next if File.basename(rel) == "README.md"

        files << rel
      end
      files.sort
    end

    def check_line_caps
      cap = integer_budget("line_cap", DEFAULT_LINE_CAP)
      @files.each do |rel|
        lines = @contents[rel].lines.size
        next if lines <= cap

        error("#{rel}: #{lines} lines exceeds hard cap of #{cap}")
      end
    end

    def check_word_ratchet
      words = @budgets["words"]
      unless words.is_a?(Hash)
        error("budgets: missing words map")
        return
      end

      @files.each do |rel|
        count = word_count(@contents[rel])
        max = words[rel]
        if max.nil?
          error("#{rel}: missing words budget entry (count=#{count})")
          next
        end
        max_i = Integer(max)
        next if count <= max_i

        error("#{rel}: #{count} words exceeds budget #{max_i}")
      end
    end

    def check_descriptions
      max = integer_budget("description_max_words", DEFAULT_DESCRIPTION_MAX_WORDS)
      @files.select { |rel| File.basename(rel) == "SKILL.md" }.each do |rel|
        desc = frontmatter_description(@contents[rel])
        next if desc.nil?

        count = word_count(desc)
        next if count <= max

        error("#{rel}: description has #{count} words (max #{max})")
      end
    end

    def check_router_shapes
      pinned = @budgets["pinned_headers"]
      pinned = {} unless pinned.is_a?(Hash)

      @files.select { |rel| File.basename(rel) == "SKILL.md" }.each do |rel|
        skill_name = File.dirname(rel)
        skill_name = File.basename(rel, ".md") if skill_name == "."
        headers = markdown_h2_headers(@contents[rel])
        expected = pinned[skill_name]
        if expected.is_a?(Array)
          next if headers == expected.map(&:to_s)

          error("#{rel}: headers #{headers.inspect} != pinned #{expected.inspect}")
          next
        end

        next if router_headers?(headers)

        error("#{rel}: router headers must be #{ROUTER_HEADERS.inspect} " \
              "(Shared prep optional); got #{headers.inspect}")
      end
    end

    def router_headers?(headers)
      return false if headers.empty?
      return false unless headers.first == "Pick branch"
      return false unless headers.include?("Branch reference")
      return false unless headers.include?("Handoff")
      return false unless headers.include?("Completion criteria")

      expected = ["Pick branch"]
      expected << "Shared prep" if headers.include?("Shared prep")
      expected << "Branch reference"
      expected << "Handoff"
      expected << "Completion criteria"
      headers == expected
    end

    def check_links_resolve
      each_relative_md_link do |rel, _line_no, target, _raw|
        dest = resolve_link(rel, target)
        next if dest && File.file?(File.join(@store, dest))

        error("#{rel}: broken link -> #{target}")
      end
    end

    def check_link_graph
      graph = Hash.new { |h, k| h[k] = [] }
      each_relative_md_link do |rel, _line_no, target, _raw|
        dest = resolve_link(rel, target)
        next if dest.nil?

        graph[rel] << dest unless graph[rel].include?(dest)
      end

      roots = @files.select { |rel| File.basename(rel) == "SKILL.md" }
      roots.each do |root|
        walk_graph(root, graph, [root], 0)
      end
    end

    def walk_graph(node, graph, chain, depth)
      graph.fetch(node, []).each do |dest|
        if skill_md?(dest) && skill_md?(node) && File.dirname(dest) != File.dirname(node)
          error("#{node}: router-to-router link -> #{dest}")
        elsif skill_md?(dest) && !skill_md?(node)
          # reference → foreign SKILL.md also banned
          error("#{node}: link to skill router -> #{dest}")
        end

        if chain.include?(dest)
          error("cycle: #{(chain + [dest]).join(' -> ')}")
          next
        end

        next_depth = depth + 1
        if next_depth > 2
          error("#{chain.first}: path exceeds 2 hops: #{(chain + [dest]).join(' -> ')}")
          next
        end

        walk_graph(dest, graph, chain + [dest], next_depth)
      end
    end

    def check_duplicate_lines
      owners = duplicate_owner_map
      locations = Hash.new { |h, k| h[k] = [] }

      @files.each do |rel|
        @contents[rel].each_line.with_index(1) do |line, line_no|
          norm = normalize_line(line)
          next if norm.empty?
          next if word_count(norm) < DUPLICATE_MIN_WORDS

          locations[norm] << [rel, line_no]
        end
      end

      locations.each do |norm, locs|
        files = locs.map(&:first).uniq
        next if files.size <= 1
        next if owners.key?(norm)

        error("duplicate line in #{files.join(', ')}: #{truncate(norm)}")
      end
    end

    def check_learning_logs
      max = integer_budget("learning_log_max_lines", DEFAULT_LEARNING_LOG_MAX_LINES)
      @files.select { |rel| File.basename(rel) == "learning-log.md" }.each do |rel|
        lines = @contents[rel].lines.size
        next if lines <= max

        error("#{rel}: #{lines} lines exceeds learning-log cap of #{max}")
      end
    end

    def each_relative_md_link
      @files.each do |rel|
        @contents[rel].each_line.with_index(1) do |line, line_no|
          line.scan(MD_LINK_RE) do |match|
            raw = match.first.to_s
            next if raw.empty? || raw.start_with?("#")
            next if raw =~ /\A[a-z][a-z0-9+.-]*:/i

            target = raw.split("#", 2).first
            next if target.nil? || target.empty?
            next unless target.end_with?(".md")

            yield(rel, line_no, target, raw)
          end
        end
      end
    end

    def resolve_link(from_rel, target)
      base_dir = File.dirname(from_rel)
      base_dir = "" if base_dir == "."
      joined = base_dir.empty? ? target : File.join(base_dir, target)
      parts = []
      joined.split("/").each do |part|
        next if part.empty? || part == "."

        if part == ".."
          return nil if parts.empty?

          parts.pop
        else
          parts << part
        end
      end
      parts.join("/")
    end

    def skill_md?(rel)
      File.basename(rel) == "SKILL.md"
    end

    def markdown_h2_headers(text)
      text.each_line.map { |line| line[/\A## (.+?)\s*\z/, 1] }.compact.map(&:strip)
    end

    def frontmatter_description(text)
      match = FRONTMATTER_RE.match(text)
      return nil unless match

      fm = match[1]
      return Regexp.last_match(1).gsub(/^[ \t]+/, "").strip if fm =~ /^description:\s*>-?\s*\n((?:[ \t]+.*\n)*)/
      return Regexp.last_match(1).strip if fm =~ /^description:\s*(.+)$/

      nil
    end

    def word_count(text)
      text.to_s.split(/\s+/).reject(&:empty?).size
    end

    def normalize_line(line)
      line.to_s.strip.downcase.gsub(/\s+/, " ")
    end

    def duplicate_owner_map
      entries = @budgets["duplicate_owners"]
      return {} unless entries.is_a?(Array)

      map = {}
      entries.each do |entry|
        next unless entry.is_a?(Hash)

        text = entry["text"] || entry[:text]
        owner = entry["owner"] || entry[:owner]
        next if text.nil? || owner.nil?

        map[normalize_line(text)] = owner.to_s
      end
      map
    end

    def integer_budget(key, default)
      value = @budgets[key]
      return default if value.nil?

      Integer(value)
    end

    def truncate(text, max = 90)
      return text if text.length <= max

      "#{text[0, max - 3]}..."
    end

    def error(message)
      @errors << message
    end

    def yaml_load(text)
      YAML.safe_load(text)
    rescue StandardError => e
      raise ExitError, "budgets YAML error: #{e.message}"
    end
  end
end
