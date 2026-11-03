# frozen_string_literal: true

require "fileutils"
require "json"
require "optparse"
require "stringio"

require_relative "ops_github/error"
require_relative "ops_github/github"
require_relative "ops_github/ledger"
require_relative "ops_github/classifier"
require_relative "ops_github/watch"

module OpsGithub
  class CLI
    PROBE_QUIET = 0
    PROBE_DELTA = 10

    COMMANDS = {
      "setup-facts" => :run_setup_facts,
      "probe" => :run_probe,
      "tick" => :run_tick,
      "ledger" => :run_ledger,
      "watch" => :run_watch,
      "doctor" => :run_doctor,
      "help" => :run_help
    }.freeze

    def self.run(argv = ARGV)
      new(argv).run
    end

    def initialize(argv, github: nil, stdout: $stdout, stderr: $stderr)
      @argv = argv.dup
      @github = github
      @stdout = stdout
      @stderr = stderr
      @state_dir = nil
      @owners = nil
    end

    def run
      command, args = parse_args(@argv)
      if args.any? { |a| %w[-h --help].include?(a) }
        usage
        raise ExitError.new(status: 0)
      end

      handler = COMMANDS[command]
      raise ExitError, "unknown command: #{command}" unless handler

      send(handler, args)
    rescue ExitError => e
      @stderr.write("ops-github: #{e.message}\n") unless e.message.nil? || e.message.empty?
      exit(e.status)
    end

    private

    def parse_args(argv)
      parser = OptionParser.new do |opts|
        opts.on("--state-dir DIR") { |d| @state_dir = d }
        opts.on("--owners LIST") { |list| @owners = list.split(",").map(&:strip).reject(&:empty?) }
      end
      # order! stops at the subcommand so flags like watch --max-ticks stay intact.
      rest = parser.order(argv)
      command = rest.shift
      raise ExitError, "missing command" if command.nil? || command.empty?

      [command, rest]
    end

    def github
      @github ||= Github.new
    end

    def state_dir
      return @state_dir if @state_dir && !@state_dir.empty?

      env = ENV["OPS_GITHUB_STATE_DIR"]
      return env if env && !env.empty?

      xdg = ENV["XDG_STATE_HOME"]
      base = xdg && !xdg.empty? ? xdg : File.join(Dir.home, ".local", "state")
      File.join(base, "ops-github")
    end

    def run_setup_facts(_args)
      facts = github.setup_facts
      emit(facts)
    end

    def run_probe(_args)
      ledger = ensure_ledger
      rows = github.discover(ledger.owners)
      delta = rows.any? do |row|
        key = Github.pr_key(row)
        !ledger.exclusions.include?(key) && ledger.changed_since_seen?(key, signature: row["signature"])
      end
      if delta
        emit("status" => "changes", "count" => rows.size)
        raise ExitError.new(status: PROBE_DELTA)
      end

      emit("status" => "quiet", "count" => rows.size)
      raise ExitError.new(status: PROBE_QUIET)
    end

    def run_tick(_args)
      ledger = ensure_ledger
      rows = github.discover(ledger.owners)
      first_tick = ledger.seen.empty?
      changed_ids = []
      changed_keys = []
      open_keys = []
      rows.each do |row|
        key = Github.pr_key(row)
        next if ledger.exclusions.include?(key)

        open_keys << key
        next unless first_tick || ledger.changed_since_seen?(key, signature: row["signature"])

        changed_ids << row["id"]
        changed_keys << key
      end
      states = github.pr_states(changed_ids)
      # Stamp only after full state fetched, so a failed tick re-sees the change.
      rows.each do |row|
        key = Github.pr_key(row)
        ledger.mark_seen!(key, signature: row["signature"]) unless ledger.exclusions.include?(key)
      end

      login = github.login
      login = github.setup_facts["login"] if login.nil? || login.empty?
      classifier = Classifier.new(login: login)
      items = classifier.classify(search_rows: rows, states: states, ledger: ledger)
      # Undecided items of unchanged open PRs stay visible; a changed PR is reclassified.
      fresh_ids = items.map { |i| i["id"] }
      items += ledger.undecided(open_keys - changed_keys).reject { |i| fresh_ids.include?(i["id"]) }
      env = classifier.envelope(items, ledger: ledger, dry: dry_run?)
      emit(env)
      write_status(env)
      code = env["status"] == "quiet" ? PROBE_QUIET : PROBE_DELTA
      raise ExitError.new(status: code)
    end

    def dry_run?
      v = ENV["OPS_GITHUB_DRY"].to_s.strip.downcase
      !v.empty? && !%w[0 false no].include?(v)
    end

    # Zero-token statusline source; atomic so a reader never sees a partial line.
    def write_status(env)
      FileUtils.mkdir_p(state_dir)
      path = File.join(state_dir, "status.txt")
      tmp = "#{path}.tmp.#{Process.pid}"
      File.write(tmp, "#{env['line']} · #{Time.now.strftime('%H:%M')}\n")
      File.rename(tmp, path)
    end

    def run_ledger(args)
      sub = args.shift
      raise ExitError, "ledger requires summary|decide|exclude" if sub.nil?

      ledger = ensure_ledger
      case sub
      when "summary"
        @stdout.write("#{ledger.summary}\n")
      when "decide"
        id = args.shift
        status = args.shift
        raise ExitError, "usage: ledger decide <id> <status>" if id.nil? || status.nil?

        emit(ledger.decide!(id, status))
      when "exclude"
        pr = args.shift
        raise ExitError, "usage: ledger exclude owner/repo#n" if pr.nil?

        ledger.exclude!(pr)
        emit("exclusions" => ledger.exclusions)
      else
        raise ExitError, "unknown ledger subcommand: #{sub}"
      end
    end

    def run_watch(args)
      max_ticks = nil
      OptionParser.new { |opts| opts.on("--max-ticks N") { |n| max_ticks = n.to_i } }.parse!(args)
      ledger = ensure_ledger
      if ledger.watcher_alive?
        emit("status" => "already-running", "pid" => ledger.watcher_pid)
        return
      end

      ledger.watcher_pid = Process.pid
      probe = lambda do
        out = StringIO.new
        err = StringIO.new
        begin
          self.class.new(
            ["--state-dir", state_dir, "--owners", ledger.owners.join(","), "probe"],
            github: github,
            stdout: out,
            stderr: err
          ).run
          PROBE_QUIET
        rescue SystemExit => e
          e.status
        rescue StandardError => e
          # Any probe crash surfaces as an env wake instead of killing watch.
          @stderr.write("ops-github: probe: #{e.class}: #{e.message}\n")
          1
        end
      end
      Watch.new(probe: probe, stdout: @stdout).run(max_ticks: max_ticks)
    end

    def run_doctor(_args)
      checks = {
        "ruby" => RUBY_VERSION,
        "state_dir" => state_dir,
        "state_dir_writable" => writable_dir?(state_dir),
        "cli" => File.expand_path(__FILE__)
      }
      begin
        facts = github.setup_facts
        checks["auth_ok"] = facts["auth_ok"]
        checks["login"] = facts["login"]
      rescue ExitError => e
        checks["auth_ok"] = false
        checks["auth_error"] = e.message
      end
      path = Ledger.day_path(state_dir)
      if File.file?(path)
        ledger = Ledger.load(path)
        checks["watcher_pid"] = ledger.watcher_pid
        checks["watcher_alive"] = ledger.watcher_alive?
      else
        checks["watcher_pid"] = nil
        checks["watcher_alive"] = false
      end
      emit(checks)
      ok = checks["state_dir_writable"] && checks["auth_ok"]
      raise ExitError.new("doctor failed", status: 1) unless ok
    end

    def run_help(_args)
      usage
    end

    def ensure_ledger
      owners = @owners
      if owners.nil? || owners.empty?
        path = Ledger.day_path(state_dir)
        return Ledger.load(path) if File.file?(path)

        facts = github.setup_facts
        owners = facts["owners"]
      end
      Ledger.init(state_dir, owners: owners)
    end

    def writable_dir?(dir)
      FileUtils.mkdir_p(dir)
      test = File.join(dir, ".write-test.#{Process.pid}")
      File.write(test, "ok")
      File.delete(test)
      true
    rescue StandardError
      false
    end

    def emit(obj)
      @stdout.write(JSON.pretty_generate(obj))
      @stdout.write("\n")
    end

    def usage
      @stdout.write(<<~USAGE)
        Usage: ops-github [--state-dir DIR] [--owners a,b] <command> [args]

        Commands:
          setup-facts          Owners + login from gh (no org names hardcoded)
          probe                Exit 0 quiet / 10 delta vs day ledger
          tick                 Attention Ledger envelope (JSON); writes <state>/status.txt
                               OPS_GITHUB_DRY=1 demotes all auto to ask (0|false|no = off)
          ledger summary       Compact day summary
          ledger decide ID ST  Record decision (asked|approved|snoozed|done|…)
          ledger exclude PR    Exclude owner/repo#n for the day
          watch [--max-ticks N]
          doctor               Self-check
          help
      USAGE
    end
  end
end

OpsGithub::CLI.run(ARGV) if $PROGRAM_NAME == __FILE__
