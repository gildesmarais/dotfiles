# frozen_string_literal: true

require "digest"

module OpsGithub
  # Pure rules owner: blocker priority, whitelist, red-CI clustering, thread handled.
  class Classifier
    BOT_AUTHORS = Github::BOT_AUTHORS
    FLAKY_SIGNATURES = [
      /flaky/i,
      /intermittent/i,
      /timed?[\s_]*out/i,
      /network is unreachable/i
    ].freeze
    BASE_CAUSED_CHECKS = %w[bundler_audit dependabot].freeze
    URGENCY_RANK = { "urgent" => 0, "batch" => 1 }.freeze

    def initialize(login:)
      @login = login.to_s
    end

    # +search_rows+: from Github#discover (authored + review-requested)
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

        role = (rows_by_url[url] || {})["role"]
        # "both" (authored + review-requested, e.g. a team request on your own PR)
        # resolves by author so authored rules still apply.
        role = infer_role(state) if role.nil? || role == "both"
        items.concat(items_for_pr(state, role: role))
      end

      items = cluster_red(items)
      items = cluster_dependabot(items)
      items.each do |item|
        item["fingerprint"] = fingerprint(item)
        ledger.upsert_item!(item_stub(item))
      end
      items.reject { |item| ledger.decided?(item) }
    end

    # +in_flight+: ledger items a Hand marked in_flight (classifier items carry no status).
    def render_report(items, in_flight: [])
      needs = items.select { |i| %w[ask judge].include?(i["action"]) }
      lines = ["## Needs you"]
      if needs.empty?
        lines << "(none)"
      else
        ranked = needs.sort_by { |i| URGENCY_RANK.fetch(i["urgency"], 9) }
        ranked.first(8).each do |i|
          lines << "- #{i['urgency']} #{report_label(i)}: #{i['class']}"
        end
      end
      lines << "## In flight"
      if in_flight.empty?
        lines << "(none)"
      else
        in_flight.first(3).each { |i| lines << "- #{i['id']}" }
      end
      lines.first(15).join("\n")
    end

    # +items+: Classifier#classify output (already filtered by Ledger#decided?).
    # +dry+: demote every auto item to ask so nothing outward-facing runs unattended.
    def envelope(items, ledger:, dry: false)
      actionable = items
      actionable = actionable.map { |i| i["action"] == "auto" ? i.merge("action" => "ask") : i } if dry
      auto = actionable.select { |i| i["action"] == "auto" }.first(ledger.budgets["auto"] || 3)
      ask = actionable.select { |i| i["action"] == "ask" }
      judge = actionable.select { |i| i["action"] == "judge" }
      in_flight = ledger.items.values.select { |i| i["status"] == "in_flight" }
      report = render_report(actionable, in_flight: in_flight)
      status = (auto + ask + judge).empty? ? "quiet" : "changes"
      {
        "status" => status,
        "dry" => dry,
        "line" => status_line(ask + judge, auto, in_flight, dry),
        "report_md" => report,
        "auto" => auto.map { |i| slim(i) },
        "ask" => ask.map { |i| slim(i) },
        "judge" => judge.map { |i| slim(i) },
        "budgets" => ledger.budgets
      }
    end

    def thread_handled?(thread)
      return true if thread["isResolved"]

      (thread["last"] || {})["author"].to_s == @login
    end

    private

    def report_label(item)
      prs = (item["evidence"] || {})["prs"]
      prs ? "#{item['repository']} (#{prs.size} PRs)" : item["pr"]
    end

    def status_line(needs, auto, in_flight, dry)
      urgent = needs.count { |i| i["urgency"] == "urgent" }
      segs = []
      segs << "#{needs.size} need you#{" (#{urgent} urgent)" if urgent.positive?}" unless needs.empty?
      segs << "#{auto.size} auto" unless auto.empty?
      segs << "#{in_flight.size} in flight" unless in_flight.empty?
      segs << "quiet" if segs.empty?
      segs << "dry" if dry
      "ops: #{segs.join(' · ')}"
    end

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

      if role == "authored" && (state["mergeable"] == "CONFLICTING" || state["mergeStateStatus"] == "DIRTY")
        out << item(base, "conflicts", "batch", "ask",
                    "/pull-request conflicts #{state['url']}")
      end

      failing = Array(state["failing_checks"])
      unless failing.empty?
        names = failing.map { |c| c["name"] }.compact
        if role == "authored" && base_caused?(names)
          out << item(base, "red-ci-base", "batch", "auto",
                      :act, "checks" => names)
        elsif role == "authored" && flaky?(failing)
          out << item(base, "red-ci-flaky", "batch", "auto", :act, "checks" => names)
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
        if !human_threads.empty? && human_threads.all? { |t| thread_handled?(t) } &&
           pushed_after_review?(state, human_threads)
          reviewers = human_threads.map { |t| (t["first"] || {})["author"] }.compact.uniq
          reviewers.each do |who|
            next if who.to_s.empty? || who == @login || bot_author?(who)

            out << item(base, "ready-ping", "batch", "auto", :act, "reviewer" => who)
          end
        end
      end

      out
    end

    def item(base, klass, urgency, action, invoke, evidence = {}) # rubocop:disable Metrics/ParameterLists
      parts = [base["pr"], klass, evidence["thread_id"], evidence["checks"], evidence["reviewer"]]
      id = Digest::SHA1.hexdigest(parts.flatten.compact.join("|"))[0, 12]
      base.merge(
        "id" => id,
        "class" => klass,
        "urgency" => urgency,
        "action" => action,
        # Auto items route through the act branch, which owns the steps.
        "invoke" => invoke == :act ? "/ops-github act #{id}" : invoke,
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

    # Replying alone is not "ready": the head commit must postdate the review.
    def pushed_after_review?(state, threads)
      pushed = state["headCommittedAt"]
      reviewed = threads.map { |t| (t["first"] || {})["createdAt"] }.compact.max
      !pushed.nil? && !reviewed.nil? && pushed > reviewed
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
        # approved-red stays standalone so its urgency survives.
        if %w[red-ci red-ci-base red-ci-flaky].include?(item["class"])
          checks = Array((item["evidence"] || {})["checks"]).sort
          groups[[item["repository"].to_s, checks.empty? ? [item["class"]] : checks]] << item
        else
          others << item
        end
      end
      groups.each do |(_repo, checks), group|
        if group.size > 1
          prs = group.map { |g| g["pr"] }
          primary = group.first.dup
          primary["id"] = Digest::SHA1.hexdigest((["cluster"] + prs.sort + checks).join("|"))[0, 12]
          primary["class"] = "red-ci-shared"
          primary["pr"] = prs.join(",")
          primary["evidence"] = (primary["evidence"] || {}).merge(
            "checks" => checks,
            "prs" => prs
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
  end
end
