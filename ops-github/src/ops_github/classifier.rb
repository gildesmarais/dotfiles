# frozen_string_literal: true

require "digest"

module OpsGithub
  # Pure rules owner: blocker priority, whitelist, red-CI clustering, thread handled.
  class Classifier
    BOT_AUTHORS = Github::BOT_AUTHORS
    FLAKY_SIGNATURES = [
      /flaky/i,
      /intermittent/i,
      /timed?\s*out/i,
      /network is unreachable/i
    ].freeze
    BASE_CAUSED_CHECKS = %w[bundler_audit dependabot].freeze
    URGENCY_RANK = { "urgent" => 0, "batch" => 1 }.freeze

    def initialize(login:)
      @login = login.to_s
    end

    # +search_rows+: from Github#search_prs (authored + review-requested)
    # +states+: map url => pr_state hash
    # +ledger+: Ledger
    def classify(search_rows:, states:, ledger:)
      items = []
      rows_by_url = {}
      Array(search_rows).each { |r| rows_by_url[r["url"]] = r }

      Array(states).each do |state|
        url = state["url"]
        next if url.nil?

        pr_key = pr_key_for(state)
        next if ledger.exclusions.include?(pr_key)

        role = (rows_by_url[url] || {})["role"] || infer_role(state)
        items.concat(items_for_pr(state, role: role))
      end

      items = cluster_red(items)
      items = cluster_dependabot(items)
      items.each do |item|
        item["fingerprint"] = fingerprint(item)
        ledger.upsert_item!(item_stub(item))
      end
      suppress_decided(items, ledger)
    end

    def report_sections(items)
      needs = items.select { |i| %w[ask judge].include?(i["action"]) }
      auto = items.select { |i| i["action"] == "auto" }
      info = items.select { |i| i["action"] == "info" }
      {
        "needs" => needs,
        "auto" => auto,
        "info" => info,
        "waiting" => info.size
      }
    end

    def render_report(items, auto_done: [])
      sections = report_sections(items)
      lines = []
      lines << "## Needs you"
      if sections["needs"].empty?
        lines << "(none)"
      else
        ranked = sections["needs"].sort_by { |i| URGENCY_RANK.fetch(i["urgency"], 9) }
        ranked.first(8).each do |i|
          lines << "- #{i['urgency']} #{i['pr']}: #{i['class']} → #{i['invoke']}"
        end
      end
      lines << "## Auto-done"
      if auto_done.empty?
        lines << "(none)"
      else
        auto_done.first(5).each { |line| lines << "- #{line}" }
      end
      lines << "## In flight"
      inflight = items.select { |i| i["status"] == "in_flight" }
      lines << (inflight.empty? ? "(none)" : inflight.map { |i| "- #{i['id']}" }.join("\n"))
      lines << "## Waiting on others"
      lines << sections["waiting"].to_s
      lines = lines.first(15)
      lines.join("\n")
    end

    def envelope(items, ledger:, auto_done: [])
      actionable = suppress_decided(items, ledger)
      auto = actionable.select { |i| i["action"] == "auto" }.first(ledger.budgets["auto"] || 3)
      ask = actionable.select { |i| i["action"] == "ask" }
      judge = actionable.select { |i| i["action"] == "judge" }
      report = render_report(actionable, auto_done: auto_done)
      status = (auto + ask + judge).empty? ? "quiet" : "changes"
      {
        "status" => status,
        "report_md" => report,
        "auto" => auto.map { |i| slim(i) },
        "ask" => ask.map { |i| slim(i) },
        "judge" => judge.map { |i| slim(i) },
        "budgets" => ledger.budgets
      }
    end

    def thread_handled?(thread, head_pushed_at: nil)
      return true if thread["isResolved"]

      last = thread["last"]
      return false if last.nil?
      return false unless last["author"].to_s == @login
      return true if head_pushed_at.nil? || last["createdAt"].nil?

      last["createdAt"] >= head_pushed_at
    end

    private

    def infer_role(state)
      state["author"].to_s == @login ? "authored" : "review-requested"
    end

    def pr_key_for(state)
      "#{state['repository']}##{state['number']}"
    end

    def bot_author?(login)
      name = login.to_s.sub(%r{\Aapp/}, "")
      BOT_AUTHORS.include?(name)
    end

    def items_for_pr(state, role:)
      out = []
      pr = pr_key_for(state)
      base = {
        "pr" => pr,
        "url" => state["url"],
        "title" => state["title"],
        "repository" => state["repository"],
        "number" => state["number"],
        "baseRefName" => state["baseRefName"],
        "headRefName" => state["headRefName"],
        "headRefOid" => state["headRefOid"]
      }

      if role == "review-requested" && state["author"].to_s != @login
        klass, urgency, invoke = if bot_author?(state["author"])
                                   ["dependabot-review", "batch",
                                    "/dependabot triage #{state['repository']}"]
                                 else
                                   ["review-requested", "urgent",
                                    "/ops-github review #{state['url']}"]
                                 end
        out << item(base, klass, urgency, "ask", invoke, "author" => state["author"])
      end

      return out if state["isDraft"] && role == "authored"

      if state["mergeable"] == "CONFLICTING" || state["mergeStateStatus"] == "DIRTY"
        out << item(base, "conflicts", "batch", "ask",
                    "/pull-request conflicts #{state['url']}")
      end

      failing = Array(state["failing_checks"])
      unless failing.empty?
        names = failing.map { |c| c["name"] }.compact
        if role == "authored" && base_caused?(names)
          out << item(base, "red-ci-base", "batch", "auto",
                      "/ops-github act #{pr} merge-main",
                      "checks" => names)
        elsif role == "authored" && flaky?(failing)
          out << item(base, "red-ci-flaky", "batch", "auto",
                      "gh run rerun --failed",
                      "checks" => names)
        elsif role == "authored" && state["reviewDecision"] == "APPROVED"
          out << item(base, "approved-red", "urgent", "ask",
                      "/pull-request fix-ci #{state['url']}",
                      "checks" => names)
        elsif role == "authored"
          out << item(base, "red-ci", "batch", "ask",
                      "/pull-request fix-ci #{state['url']}",
                      "checks" => names)
        end
      end

      unresolved = Array(state["threads"]).reject { |t| t["isResolved"] }
      unresolved.each do |thread|
        next if thread_handled?(thread)

        if thread["bot"] && role == "authored"
          out << item(base, "bot-thread", "batch", "judge",
                      "/pull-request resolve #{state['url']}",
                      "thread_id" => thread["id"],
                      "comment_id" => (thread["last"] || {})["databaseId"],
                      "path" => thread["path"],
                      "body" => (thread["first"] || {})["body"])
        elsif role == "authored" && thread["last"] && thread["last"]["author"] != @login
          urgency = human_reply?(thread) ? "urgent" : "batch"
          out << item(base, "unresolved-review", urgency, "ask",
                      "/pull-request resolve #{state['url']}",
                      "thread_id" => thread["id"],
                      "comment_id" => (thread["last"] || {})["databaseId"],
                      "author" => (thread["last"] || {})["author"],
                      "body" => (thread["last"] || {})["body"])
        end
      end

      if role == "authored" && state["reviewDecision"] == "CHANGES_REQUESTED"
        human_threads = unresolved.reject { |t| t["bot"] }
        if !human_threads.empty? && human_threads.all? { |t| thread_handled?(t) }
          reviewers = human_threads.map { |t| (t["first"] || {})["author"] }.compact.uniq
          reviewers.each do |who|
            next if who.to_s.empty? || who == @login || bot_author?(who)

            out << item(base, "ready-ping", "batch", "auto",
                        "gh pr comment #{state['url']} --body \"@#{who} ready for another look\"",
                        "reviewer" => who)
          end
        end
      end

      out
    end

    def item(base, klass, urgency, action, invoke, evidence = {}) # rubocop:disable Metrics/ParameterLists
      parts = [base["pr"], klass, evidence["thread_id"], evidence["checks"]]
      id = Digest::SHA1.hexdigest(parts.flatten.compact.join("|"))[0, 12]
      base.merge(
        "id" => id,
        "class" => klass,
        "urgency" => urgency,
        "action" => action,
        "invoke" => invoke,
        "evidence" => evidence
      )
    end

    def item_stub(item)
      {
        "id" => item["id"],
        "pr" => item["pr"],
        "url" => item["url"],
        "class" => item["class"],
        "action" => item["action"],
        "urgency" => item["urgency"],
        "invoke" => item["invoke"],
        "fingerprint" => item["fingerprint"],
        "baseRefName" => item["baseRefName"],
        "headRefName" => item["headRefName"],
        "headRefOid" => item["headRefOid"],
        "evidence" => item["evidence"],
        "status" => "new"
      }
    end

    def fingerprint(item)
      Digest::SHA1.hexdigest([item["pr"], item["class"], item["evidence"]].inspect)[0, 16]
    end

    def slim(item)
      {
        "id" => item["id"],
        "pr" => item["pr"],
        "url" => item["url"],
        "class" => item["class"],
        "urgency" => item["urgency"],
        "action" => item["action"],
        "invoke" => item["invoke"],
        "baseRefName" => item["baseRefName"],
        "headRefName" => item["headRefName"],
        "headRefOid" => item["headRefOid"],
        "evidence" => item["evidence"]
      }
    end

    def base_caused?(names)
      names.any? { |n| BASE_CAUSED_CHECKS.any? { |b| n.to_s.downcase.include?(b) } }
    end

    def flaky?(checks)
      checks.any? do |c|
        text = [c["name"], c["state"]].join(" ")
        FLAKY_SIGNATURES.any? { |re| re.match?(text) }
      end
    end

    def human_reply?(thread)
      last = thread["last"]
      first = thread["first"]
      return false if last.nil? || first.nil?
      return false if BOT_AUTHORS.include?(last["author"].to_s)
      return false if last["author"] == @login

      last["author"] != first["author"] || last["databaseId"] != first["databaseId"]
    end

    def cluster_red(items)
      groups = Hash.new { |h, k| h[k] = [] }
      reds = []
      others = []
      items.each do |item|
        if %w[red-ci red-ci-base red-ci-flaky approved-red].include?(item["class"])
          key = Array((item["evidence"] || {})["checks"]).sort.join(",")
          key = item["class"] if key.empty?
          groups[key] << item
        else
          others << item
        end
      end
      groups.each do |key, group|
        if group.size > 1
          primary = group.first.dup
          primary["id"] = Digest::SHA1.hexdigest("cluster|#{key}")[0, 12]
          primary["class"] = "red-ci-shared"
          primary["pr"] = group.map { |g| g["pr"] }.join(",")
          primary["evidence"] = (primary["evidence"] || {}).merge(
            "checks" => key.split(","),
            "prs" => group.map { |g| g["pr"] }
          )
          primary["invoke"] = "/pull-request fix-ci #{group.first['url']}"
          primary["action"] = "ask"
          primary["urgency"] = "batch"
          reds << primary
        else
          reds.concat(group)
        end
      end
      others + reds
    end

    def cluster_dependabot(items)
      groups = Hash.new { |h, k| h[k] = [] }
      others = []
      items.each do |item|
        if item["class"] == "dependabot-review"
          repo = item["repository"].to_s
          groups[repo] << item
        else
          others << item
        end
      end
      clustered = groups.map do |repo, group|
        next group.first if group.size == 1

        primary = group.first.dup
        primary["id"] = Digest::SHA1.hexdigest("dependabot|#{repo}")[0, 12]
        primary["class"] = "dependabot-triage"
        primary["pr"] = group.map { |g| g["pr"] }.join(",")
        primary["evidence"] = (primary["evidence"] || {}).merge(
          "prs" => group.map { |g| g["pr"] },
          "count" => group.size
        )
        primary["invoke"] = "/dependabot triage #{repo}"
        primary["action"] = "ask"
        primary["urgency"] = "batch"
        primary
      end
      others + clustered
    end

    def suppress_decided(items, ledger)
      items.reject do |item|
        existing = ledger.items[item["id"]]
        next false if existing.nil?
        next true if %w[snoozed deferred excluded done].include?(existing["status"])
        next true if %w[asked approved in_flight blocked].include?(existing["status"]) &&
                     existing["fingerprint"] == item["fingerprint"]

        false
      end
    end
  end
end
