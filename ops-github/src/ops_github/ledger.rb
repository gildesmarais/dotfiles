# frozen_string_literal: true

require "date"
require "fileutils"
require "json"
require "time"

module OpsGithub
  # Day state with atomic writes. Item lifecycle and decided-suppression live here;
  # classification rules live in Classifier.
  class Ledger
    DECIDED_STATUSES = %w[asked approved snoozed deferred excluded in_flight blocked done].freeze
    VALID_STATUSES = (%w[new] + DECIDED_STATUSES).freeze
    CARRY_STATUSES = %w[approved snoozed deferred excluded in_flight blocked].freeze

    attr_reader :path, :data

    def self.day_path(state_dir, date = Date.today)
      File.join(state_dir, date.strftime("%Y-%m-%d.json"))
    end

    def self.init(state_dir, owners:, exclusions: [], date: Date.today)
      FileUtils.mkdir_p(state_dir)
      path = day_path(state_dir, date)
      if File.file?(path)
        ledger = load(path)
        ledger.owners = owners if owners && !owners.empty? && ledger.owners != Array(owners)
        return ledger
      end

      yesterday = day_path(state_dir, date - 1)
      carry = {}
      carry_exclusions = exclusions.dup
      watcher_pid = nil
      if File.file?(yesterday)
        prev = load(yesterday)
        (prev.data["items"] || {}).each do |id, item|
          next unless CARRY_STATUSES.include?(item["status"])

          carry[id] = item
        end
        carry_exclusions |= Array(prev.data["exclusions"])
        # A watch started yesterday keeps running past midnight.
        watcher_pid = prev.watcher_pid
      end

      ledger = new(
        path,
        "date" => date.strftime("%Y-%m-%d"),
        "owners" => owners,
        "exclusions" => carry_exclusions.uniq,
        "watcher_pid" => watcher_pid,
        "seen" => {},
        "items" => carry,
        "budgets" => { "auto" => 3, "review" => 4, "retry" => 1 }
      )
      ledger.save!
      ledger
    end

    def self.load(path)
      raw = JSON.parse(File.read(path))
      new(path, raw)
    end

    def initialize(path, data)
      @path = path
      @data = data
    end

    def owners
      Array(@data["owners"])
    end

    def owners=(list)
      @data["owners"] = Array(list)
      save!
    end

    def exclusions
      Array(@data["exclusions"])
    end

    def exclude!(pr_key)
      @data["exclusions"] = (exclusions + [pr_key]).uniq
      save!
    end

    def watcher_pid
      @data["watcher_pid"]
    end

    def watcher_pid=(pid)
      @data["watcher_pid"] = pid
      save!
    end

    def watcher_alive?
      pid = watcher_pid
      return false if pid.nil?

      Process.kill(0, Integer(pid))
      true
    rescue Errno::ESRCH, Errno::EPERM, ArgumentError, TypeError
      false
    end

    def budgets
      @data["budgets"] || { "auto" => 3, "review" => 4, "retry" => 1 }
    end

    def seen
      @data["seen"] ||= {}
    end

    def items
      @data["items"] ||= {}
    end

    # +signature+: opaque change string built by Github (updatedAt + CI rollup +
    # mergeable + reviewDecision); the ledger only compares it.
    def mark_seen!(pr_key, signature:)
      seen[pr_key] = signature
      save!
    end

    def changed_since_seen?(pr_key, signature:)
      seen[pr_key] != signature
    end

    def decide!(id, status, meta = {})
      raise ExitError, "unknown status: #{status}" unless VALID_STATUSES.include?(status)

      item = items[id] || { "id" => id }
      item["status"] = status
      item["updated_at"] = Time.now.utc.iso8601
      meta.each { |k, v| item[k.to_s] = v }
      items[id] = item
      save!
      item
    end

    # A decision holds until the item's fingerprint changes.
    def decided?(item)
      existing = items[item["id"]]
      !existing.nil? && DECIDED_STATUSES.include?(existing["status"]) &&
        existing["fingerprint"] == item["fingerprint"]
    end

    def upsert_item!(item)
      existing = items[item["id"]]
      return existing if decided?(item)

      merged = (existing || {}).merge(item)
      merged["status"] ||= "new"
      items[item["id"]] = merged
      save!
      merged
    end

    def summary(limit: 40)
      lines = []
      lines << "date: #{@data['date']}"
      lines << "owners: #{owners.join(', ')}"
      lines << "exclusions: #{exclusions.size}"
      lines << "watcher_pid: #{watcher_pid.inspect} alive=#{watcher_alive?}"
      by_status = Hash.new { |h, k| h[k] = 0 }
      items.each_value { |i| by_status[i["status"]] += 1 }
      lines << "items: #{by_status.map { |k, v| "#{k}=#{v}" }.join(' ')}"
      open = items.values.select { |i| %w[new asked approved in_flight blocked].include?(i["status"]) }
      open.first(10).each do |i|
        lines << "- #{i['status']} #{i['id']} #{i['class']}"
      end
      lines.first(limit).join("\n")
    end

    def save!
      dir = File.dirname(@path)
      FileUtils.mkdir_p(dir)
      tmp = "#{@path}.tmp.#{Process.pid}"
      File.write(tmp, JSON.pretty_generate(@data))
      File.rename(tmp, @path)
      md = @path.sub(/\.json\z/, ".md")
      File.write(md, "#{summary}\n")
      self
    end
  end
end
