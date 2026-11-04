# Tick

1. `ops-github tick` → envelope JSON (`status`, `report_md`, `auto`, `ask`,
   `judge`, `budgets`). Exit 0 quiet, 10 changes; both OK.
2. Paste `report_md` (≤15 lines) + ≤1 sentence on what comes first.
3. **Auto:** each `auto[]` via **act** (engine-capped).
4. **Ask:** one AskQuestion (≤4), urgent then batch (batch on bare `/ops-github`
   only, minus `issue-assigned`; overflow waits). Format prompts for quick
   decisions: `<repo#n> — "<title>" (<class> · @<author>, <head> → <base>)`.
   Record `ledger decide <id> asked|approved|snoozed|deferred|excluded`.
5. **Judge:** bot-thread items — approve/defer/exclude on clear evidence, else
   AskQuestion (`<repo#n> — "<title>"`); record via `ledger decide`; approved →
   **act**.
6. **Tickets** (bare only): `issue-assigned` + Jira keys (Atlassian MCP; JQL
   assigned or new in intake; skip `<state-dir>/jira.txt`). One AskQuestion per
   ticket (`<key> — "<title>"`): challenge / implement / skip. GitHub: chosen →
   **act**; skip → `ledger decide <id> deferred`; never → `ledger exclude
   owner/repo#n`. Jira: append key; Hand → `jira-ticket`.
7. Watcher PID gone (`doctor`) → arm `ops-github watch` in a session background
   shell notifying on `OPS_GITHUB_WAKE` (debounce ≥60s); never `nohup … &`.
   Claude Code: `Monitor` (`timeout_ms` 1800000) over `ops-github … watch 2>&1 |
   grep -E --line-buffered 'OPS_GITHUB_WAKE|rror|FAIL'`; re-arm on expiry. Bare
   `/ops-github` = monitor.
8. Wake (`OPS_GITHUB_WAKE`, `urgency`: `changes` | `env`):
   - `changes`: smallest-tier `Task` runs `ops-github tick`, returns `line`,
     `auto` ids, urgent ask/judge items (id, pr, title, class) in ≤12 lines.
     Print `line`, run auto via **act**, ask urgent items only.
   - `env`: `ops-github doctor | tail -n 5`, print 1 line, no tick.
   Urgent/batch come from envelope, never wake.

Never re-ask decided/`in_flight` items until fingerprint changes. Enforce
`budgets` per wake.
