# Tick

1. `ops-github tick` → Attention Ledger envelope JSON (`status`, `report_md`,
   `auto`, `ask`, `judge`, `budgets`). Exit 0 quiet, 10 changes; both OK.
2. Paste `report_md` (≤15 lines) plus ≤1 sentence on what comes first.
3. **Auto:** each `auto[]` via **act** (engine caps it).
4. **Ask:** one AskQuestion batch for `urgency: urgent` items; record
   `ops-github ledger decide <id> asked|approved|snoozed|deferred|excluded`.
5. **Judge:** bot-thread items — approve/defer/exclude only on clear evidence,
   else AskQuestion; record via `ledger decide`; approved → **act**.
6. **Jira** (bare `/ops-github` only, Atlassian MCP connected): JQL for tickets
   assigned to the user or new in their intake, skipping keys in
   `<state-dir>/jira.txt`. One AskQuestion: challenge / implement / skip per key;
   append decided keys. Challenge → Hand → `jira-ticket` `challenge`, returns
   verdict + gaps + draft in ≤12 lines; the Brain asks before posting.
7. Watcher PID gone (`doctor`) → arm `ops-github watch` as a session-owned
   background shell notifying on `OPS_GITHUB_WAKE` (debounce ≥60s); never
   `nohup … &`, which drops wakes. Claude Code: `Monitor` (`timeout_ms`
   1800000) over `ops-github … watch 2>&1 | grep -E --line-buffered
   'OPS_GITHUB_WAKE|rror|FAIL'`; re-arm on every expiry. Bare `/ops-github`
   means monitor.
8. Wake (`OPS_GITHUB_WAKE`, `urgency` is `changes` or `env`):
   - `changes`: smallest-tier `Task` runs `ops-github tick`, returns `line`,
     `auto` ids, urgent ask/judge items (id, pr, class) in ≤12 lines. Print
     `line`, run auto via **act**, ask urgent items in one AskQuestion; batch
     items wait for the next bare `/ops-github`.
   - `env`: run `ops-github doctor | tail -n 5`, print one line, no tick.
   Urgent/batch come from envelope items, never from the wake.

Never re-ask a decided or `in_flight` item until the engine resurfaces it
(fingerprint change). Enforce envelope `budgets` per wake.
