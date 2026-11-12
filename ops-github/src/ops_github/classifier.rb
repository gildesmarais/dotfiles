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
    # The one class an assigned issue yields; ranks after PR items of equal urgency.
    ISSUE_CLASS = "issue-assigned"
    # An authored PR with one of these labels (case-insensitive) is parked like a draft.
    PARKED_LABELS = %w[on-hold do-not-merge parked].freeze
    # Ticket keys: uppercase PROJECT-123; these prefixes are standards and hashes, not projects.
    TICKET_KEY = /(?<![A-Za-z0-9])([A-Z][A-Z0-9]+)-\d+(?!\d)/.freeze
    NOT_TICKET_PREFIXES = %w[UTF SHA ISO HTTP CVE RFC PEP].freeze
    STANDING_REVIEW_STATES = %w[APPROVED CHANGES_REQUESTED DISMISSED].freeze

    # First ticket key in the title, else in the head branch name; nil when none.
    def self.ticket_key(record)
      [record["title"], record["headRefName"]].each do |text|
        text.to_s.scan(TICKET_KEY) do |(prefix)|
          return Regexp.last_match(0) unless NOT_TICKET_PREFIXES.include?(prefix)
        end
      end
      nil
    end

    def initialize(login:, parked_labels: PARKED_LABELS)
      @login = login.to_s
      @parked_labels = Array(parked_labels).map { |l| l.to_s.downcase }
    end

    # +search_rows+: from Github#discover (authored + review-requested)
    # +states+: map url => pr_state hash
    # +ledger+: Ledger
    def classify(search_rows:, states:, ledger:)
      items = []
      rows_by_url = {}
      Array(search_rows).each { |r| rows_by_url[r["url"]] = r }
      summaries = {}

      Array(states).each do |state|
        url = state["url"]
        next if url.nil?

        pr_key = Github.pr_key(state)
        next if ledger.exclusions.include?(pr_key)
        next items << issue_item(state) if state["kind"] == "issue"

        role = (rows_by_url[url] || {})["role"]
        # "both" (authored + review-requested, e.g. a team request on your own PR)
        # resolves by author so authored rules still apply.
        role = infer_role(state) if role.nil? || role == "both"
        summaries[pr_key] = pr_summary(state, role)
        items.concat(items_for_pr(state, role: role))
      end
      ledger.cache_prs!(summaries)

      items = cluster_red(items)
      items = cluster_dependabot(items)
      items.each do |item|
        item["pr_keys"] = Array((item["evidence"] || {})["prs"] || item["pr"])
        item["fingerprint"] = fingerprint(item)
        ledger.upsert_item!(item_stub(item))
      end
      items.reject { |item| ledger.decided?(item) }
    end

    # +in_flight+: ledger items a Hand marked in_flight (classifier items carry no status).
    def render_report(items, in_flight: [])
      needs = items.select { |i| %w[ask judge click].include?(i["action"]) }
      lines = ["## Needs you"]
      if needs.empty?
        lines << "(none)"
      else
        # Index keeps the order stable; issues trail PRs so they never crowd them out.
        ranked = needs.each_with_index.sort_by do |i, index|
          [URGENCY_RANK.fetch(i["urgency"], 9), i["class"] == ISSUE_CLASS ? 1 : 0, index]
        end
        ranked.map(&:first).first(8).each do |i|
          lines << "- #{i['action'] == 'click' ? 'click' : i['urgency']} #{report_label(i)}: #{i['class']}"
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
      clicks = actionable.select { |i| i["action"] == "click" }
      in_flight = ledger.items.values.select { |i| i["status"] == "in_flight" }
      report = render_report(actionable, in_flight: in_flight)
      status = (auto + ask + judge + clicks).empty? ? "quiet" : "changes"
      {
        "status" => status,
        "dry" => dry,
        "line" => status_line(ask + judge, auto, clicks, in_flight, dry),
        "report_md" => report,
        "auto" => auto.map { |i| slim(i) },
        "ask" => ask.map { |i| slim(i) },
        "judge" => judge.map { |i| slim(i) },
        "clicks" => clicks.map { |i| slim(i) },
        "board" => board(ledger.prs),
        "budgets" => ledger.budgets
      }
    end

    # Standing view of the authored PRs, from the summaries Ledger#cache_prs! holds
    # (kept current across ticks without refetching unchanged PRs).
    def board(prs)
      mine = prs.values.select { |s| s["authored"] }
      active = mine.reject { |s| s["parked"] }.reject { |s| s["failing"] }
      {
        "behind" => active.select { |s| s["mergeStateStatus"] == "BEHIND" }
                          .map { |s| s.slice("pr", "url", "title", "ticket", "reviewDecision") },
        "waiting_review" => active.select { |s| waiting_review?(s) }
                                  .map { |s| s.slice("pr", "url", "title", "ticket", "rollup_state") },
        "parked_count" => mine.count { |s| s["parked"] }
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

    def status_line(needs, auto, clicks, in_flight, dry)
      urgent = needs.count { |i| i["urgency"] == "urgent" }
      segs = []
      segs << "#{needs.size} need you#{" (#{urgent} urgent)" if urgent.positive?}" unless needs.empty?
      segs << "#{clicks.size} click#{'s' unless clicks.size == 1}" unless clicks.empty?
      segs << "#{auto.size} auto" unless auto.empty?
      segs << "#{in_flight.size} in flight" unless in_flight.empty?
      segs << "quiet" if segs.empty?
      segs << "dry" if dry
      "ops: #{segs.join(' · ')}"
    end

    # Compact per-PR record the board is computed from; the only thing Ledger#prs stores.
    def pr_summary(state, role)
      {
        "pr" => Github.pr_key(state),
        "url" => state["url"],
        "title" => state["title"],
        "ticket" => Classifier.ticket_key(state),
        "authored" => role == "authored",
        "parked" => parked?(state),
        "failing" => !Array(state["failing_checks"]).empty?,
        "mergeStateStatus" => state["mergeStateStatus"],
        "mergeable" => state["mergeable"],
        "reviewDecision" => state["reviewDecision"],
        "rollup_state" => state["rollup_state"].to_s
      }
    end

    def waiting_review?(summary)
      summary["reviewDecision"] == "REVIEW_REQUIRED" &&
        summary["mergeStateStatus"] != "BEHIND" &&
        summary["mergeStateStatus"] != "DIRTY" && summary["mergeable"] != "CONFLICTING"
    end

    def infer_role(state)
      state["author"].to_s == @login ? "authored" : "review-requested"
    end

    # Draft or parked label: the author's own PR is not ready, so its blockers wait.
    def parked?(state)
      return true if state["isDraft"]

      (Array(state["labels"]).map { |l| l.to_s.downcase } & @parked_labels).any?
    end

    def bot_author?(login)
      name = login.to_s.sub(%r{\Aapp/}, "")
      BOT_AUTHORS.include?(name)
    end

    # Assigned issue: one ask routed through the act branch. Evidence stays stable so
    # a decision holds until the issue closes, whatever bumps its updatedAt.
    def issue_item(state)
      base = {
        "pr" => Github.pr_key(state),
        "url" => state["url"],
        "title" => state["title"],
        "repository" => state["repository"],
        "number" => state["number"],
        "ticket" => Classifier.ticket_key(state)
      }
      item(base, ISSUE_CLASS, "batch", "ask", :act, "author" => state["author"])
    end

    def items_for_pr(state, role:)
      out = []
      pr = Github.pr_key(state)
      base = {
        "pr" => pr,
        "url" => state["url"],
        "title" => state["title"],
        "repository" => state["repository"],
        "number" => state["number"],
        "baseRefName" => state["baseRefName"],
        "headRefName" => state["headRefName"],
        "headRefOid" => state["headRefOid"],
        "ticket" => Classifier.ticket_key(state)
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

      return out if role == "authored" && parked?(state)

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

      out.concat(merge_items(base, state)) if role == "authored"
      out.concat(reviewed_items(base, state)) if role == "reviewed" && state["author"].to_s != @login
      out
    end

    # The operator's one click: approved, up to date, green, nothing blocking.
    def merge_items(base, state)
      return [] unless state["reviewDecision"] == "APPROVED" && state["mergeStateStatus"] == "CLEAN"
      return [] unless Array(state["failing_checks"]).empty? && state["rollup_state"] != "PENDING"
      return [] unless Array(state["threads"]).reject { |t| t["isResolved"] || t["bot"] }.empty?

      [item(base, "ready-to-merge", "urgent", "click", "merge #{state['url']}", "head_oid" => state["headRefOid"])]
    end

    # PRs you reviewed (no live request): re-review once the author moved, else approve when settled.
    def reviewed_items(base, state)
      mine = my_review(state)
      return [] if mine.nil? || my_standing_review(state)&.fetch("state") == "APPROVED"

      evidence = re_review_evidence(state, mine)
      unless evidence.empty?
        return [item(base, "re-review", "urgent", "ask", "/ops-github review #{state['url']}", evidence)]
      end
      return [] unless approvable?(state)

      [item(base, "ready-to-approve", "urgent", "click", "approve #{state['url']}", "head_oid" => state["headRefOid"])]
    end

    def my_review(state)
      Array(state["reviews"]).select { |r| r["author"] == @login && r["submittedAt"] }.max_by { |r| r["submittedAt"] }
    end

    # Latest APPROVED / CHANGES_REQUESTED / DISMISSED review of mine: a thread reply's
    # COMMENTED review must not cancel an approval.
    def my_standing_review(state)
      mine = Array(state["reviews"]).select do |r|
        r["author"] == @login && r["submittedAt"] && STANDING_REVIEW_STATES.include?(r["state"])
      end
      mine.max_by { |r| r["submittedAt"] }
    end

    # Empty when the author has not moved since +mine+. A push changes since/head oid,
    # a new reply changes comment_id, so each moves the fingerprint.
    def re_review_evidence(state, mine)
      evidence = {}
      if mine["commit_oid"] && state["headRefOid"] != mine["commit_oid"]
        evidence.merge!("since_oid" => mine["commit_oid"], "head_oid" => state["headRefOid"])
      end
      reply = latest_reply(state, mine)
      evidence["comment_id"] = reply["databaseId"] if reply
      evidence
    end

    # Newest unresolved human reply after +mine+ in a thread you started or the author answered.
    def latest_reply(state, mine)
      replies = Array(state["threads"]).reject { |t| t["isResolved"] || t["bot"] }.map do |thread|
        last = thread["last"]
        next if last.nil? || last["author"] == @login || bot_author?(last["author"])
        next unless last["createdAt"].to_s > mine["submittedAt"].to_s
        next unless (thread["first"] || {})["author"] == @login || last["author"] == state["author"]

        last
      end
      replies.compact.max_by { |c| c["createdAt"].to_s }
    end

    def approvable?(state)
      state["reviewDecision"] != "APPROVED" &&
        Array(state["threads"]).reject { |t| t["isResolved"] || t["bot"] }.empty? &&
        Array(state["failing_checks"]).empty? && state["rollup_state"] == "SUCCESS"
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
        "pr_keys" => item["pr_keys"],
        "url" => item["url"],
        "title" => item["title"],
        "ticket" => item["ticket"],
        "repository" => item["repository"],
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
        "title" => item["title"],
        "ticket" => item["ticket"],
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
          primary["ticket"] = nil
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
        primary["ticket"] = nil
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
