# frozen_string_literal: true

require "fileutils"
require "json"
require "optparse"
require "stringio"

require_relative "ops_github/error"
require_relative "ops_github/github"
require_relative "ops_github/ledger"
require_relative "ops_github/classifier"
require_relative "ops_github/workspace"
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
      "wt" => :run_wt,
      "verify-merge" => :run_verify_merge,
      "post" => :run_post,
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

    def run_probe(args)
      ledger = ensure_ledger(args)
      rows = discover(ledger.owners)
      delta = false
      rows.each do |row|
        key = "#{row['repository']}##{row['number']}"
        next if ledger.exclusions.include?(key)

        if ledger.changed_since_seen?(key, updated_at: row["updatedAt"])
          delta = true
          break
        end
      end
      if delta
        emit("status" => "changes", "count" => rows.size)
        raise ExitError.new(status: PROBE_DELTA)
      end

      emit("status" => "quiet", "count" => rows.size)
      raise ExitError.new(status: PROBE_QUIET)
    end

    def run_tick(args)
      ledger = ensure_ledger(args)
      rows = discover(ledger.owners)
      changed_urls = []
      rows.each do |row|
        key = "#{row['repository']}##{row['number']}"
        next if ledger.exclusions.include?(key)

        changed_urls << row["url"] if ledger.changed_since_seen?(key, updated_at: row["updatedAt"])
      end

      # First tick (empty seen): fetch all non-excluded.
      if ledger.seen.empty?
        changed_urls = rows.reject { |r| ledger.exclusions.include?("#{r['repository']}##{r['number']}") }
                           .map { |r| r["url"] }
      end

      states = github.pr_states(changed_urls.uniq)
      states_by_url = {}
      states.each { |state| states_by_url[state["url"]] = state }
      # Always stamp search rows so probe can quiet even when a view fails.
      rows.each do |row|
        key = "#{row['repository']}##{row['number']}"
        next if ledger.exclusions.include?(key)

        state = states_by_url[row["url"]]
        if state
          ledger.mark_seen!(key, updated_at: state["updatedAt"], head_sha: state["headRefOid"])
        else
          ledger.mark_seen!(key, updated_at: row["updatedAt"], head_sha: nil)
        end
      end

      login = github.login
      login = github.setup_facts["login"] if login.nil? || login.empty?
      classifier = Classifier.new(login: login)
      items = classifier.classify(search_rows: rows, states: states, ledger: ledger, claimed: {})
      env = classifier.envelope(items, ledger: ledger)
      emit(env)
      code = env["status"] == "quiet" ? PROBE_QUIET : PROBE_DELTA
      raise ExitError.new(status: code)
    end

    def run_ledger(args)
      sub = args.shift
      raise ExitError, "ledger requires summary|decide|exclude" if sub.nil?

      ledger = ensure_ledger([])
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

    def run_wt(args)
      owner_repo = args.shift
      branch = args.shift
      raise ExitError, "usage: wt owner/repo branch" if owner_repo.nil? || branch.nil?

      emit(workspace.ensure(owner_repo, branch))
    end

    def run_verify_merge(args)
      path = args.shift
      base = nil
      before_file = nil
      OptionParser.new do |opts|
        opts.on("--base REF") { |r| base = r }
        opts.on("--before-files PATH") { |p| before_file = p }
      end.parse!(args)
      if path.nil? || base.nil? || before_file.nil?
        raise ExitError,
              "usage: verify-merge PATH --base REF --before-files LIST"
      end

      before = File.readlines(before_file).map(&:strip)
      emit(workspace.verify_merge(path, base_ref: base, before_files: before))
    end

    def run_post(args)
      kind = args.shift
      raise ExitError, "usage: post issue-comment|reply …" if kind.nil?

      case kind
      when "issue-comment"
        owner, repo, number, body = args
        raise ExitError, "usage: post issue-comment owner repo number body" if [owner, repo, number, body].any?(&:nil?)

        result = github.post_issue_comment(owner, repo, number, body)
        ensure_ledger([]).record_echo!(comment_ids: [result["id"]].compact)
        emit(result)
      when "reply"
        owner, repo, comment_id, body = args
        raise ExitError, "usage: post reply owner repo comment_id body" if [owner, repo, comment_id, body].any?(&:nil?)

        result = github.post_reply(owner, repo, comment_id, body)
        ensure_ledger([]).record_echo!(comment_ids: [result["id"]].compact)
        emit(result)
      else
        raise ExitError, "unknown post kind: #{kind}"
      end
    end

    def run_watch(args)
      max_ticks = nil
      OptionParser.new { |opts| opts.on("--max-ticks N") { |n| max_ticks = n.to_i } }.parse!(args)
      ledger = ensure_ledger([])
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
        end
      end
      Watch.new(probe: probe, stdout: @stdout).run(max_ticks: max_ticks)
    end

    def run_doctor(_args)
      checks = {
        "ruby" => RUBY_VERSION,
        "state_dir" => state_dir,
        "state_dir_writable" => writable_dir?(state_dir),
        "cache_dir" => cache_dir,
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
      emit(checks)
      raise ExitError.new("doctor failed", status: 1) unless checks["state_dir_writable"]
    end

    def run_help(_args)
      usage
    end

    def workspace
      @workspace ||= Workspace.new(cache_dir: cache_dir)
    end

    def cache_dir
      File.join(state_dir, "cache")
    end

    def ensure_ledger(_args)
      owners = @owners
      if owners.nil? || owners.empty?
        path = Ledger.day_path(state_dir)
        return Ledger.load(path) if File.file?(path)

        facts = github.setup_facts
        owners = facts["owners"]
      end
      Ledger.init(state_dir, owners: owners)
    end

    def discover(owners)
      authored = github.search_prs(owners, "authored")
      requested = github.search_prs(owners, "review-requested")
      by_url = {}
      authored.each { |r| by_url[r["url"]] = r }
      requested.each do |r|
        if by_url[r["url"]]
          by_url[r["url"]]["role"] = "both"
        else
          by_url[r["url"]] = r
        end
      end
      by_url.values
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
          tick                 Attention Ledger envelope (JSON)
          ledger summary       Compact day summary
          ledger decide ID ST  Record decision (asked|approved|snoozed|…)
          ledger exclude PR    Exclude owner/repo#n for the day
          wt owner/repo branch Ensure (or ff) a local worktree
          verify-merge PATH --base REF --before-files LIST
          post issue-comment|reply …
          watch [--max-ticks N]
          doctor               Self-check
          help
      USAGE
    end
  end
end

OpsGithub::CLI.run(ARGV) if $PROGRAM_NAME == __FILE__
