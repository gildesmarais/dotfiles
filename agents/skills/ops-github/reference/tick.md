# Tick

1. `ops-github tick` → envelope JSON (`status`, `report_md`, `auto`, `ask`,
   `judge`, `budgets`). Exit 0 quiet, 10 changes; both OK.
2. Paste `report_md` (≤15 lines) + ≤1 sentence on what comes first. Non-empty
   `ask`/`judge` → **digest** before the widget. Prompts repeat id + URL
   (`1a. <class> — <repo#n> — <url>`). In flight: `<pr> — <url>`, never bare id.
3. **Auto:** each `auto[]` via **act** (engine-capped).
4. **Ask:** one AskQuestion (≤4), urgent then batch (batch on bare `/ops-github`
   only, minus `issue-assigned`; overflow waits). Digest those rows only.
   Overflow: `N more waiting`, no links. Record `ledger decide <id>
   asked|approved|snoozed|deferred|excluded`.
5. **Judge:** bot-thread — approve/defer/exclude on clear evidence, else digest
   + AskQuestion; `ledger decide`; approved → **act**.
6. **Tickets** (bare only): `issue-assigned` + Jira keys (Atlassian MCP; JQL
   assigned or new in intake; skip `<state-dir>/jira.txt`). Digest + AskQuestion
   per ticket (`N. <key> — "<title>" — <url>`): challenge / implement / skip.
   Include issue URL. GitHub chosen → **act**; skip → `ledger decide <id>
   deferred`; never → `ledger exclude owner/repo#n`. Jira: append key; Hand →
   `ticket`.
7. Watcher PID gone (`doctor`) → arm `ops-github watch` in a session background
   shell notifying on `OPS_GITHUB_WAKE` (debounce ≥60s); never `nohup … &`.
   Claude Code: `Monitor` (`timeout_ms` 1800000) over `ops-github … watch 2>&1 |
   grep -E --line-buffered 'OPS_GITHUB_WAKE|rror|FAIL'`; re-arm on expiry. Bare
   `/ops-github` = monitor.
8. Wake (`OPS_GITHUB_WAKE`, `urgency`: `changes` | `env`):
   - `changes`: smallest-tier `Task` runs `ops-github tick`, returns `line`,
     `auto` ids, urgent ask/judge (id, pr, url, title, class) ≤12 lines. Print
     `line`, run auto via **act**, ask urgent only; digest those rows.
   - `env`: `ops-github doctor | tail -n 5`, print 1 line, no tick.
   Urgent/batch come from envelope, never wake.

Never re-ask decided/`in_flight` items until fingerprint changes. Enforce
`budgets` per wake.

## Digest

Group by shared PR, urgent first. One button per decision. Envelope fields:
`url`, `title`, `class`, `headRefName`, `baseRefName`, `evidence.author`,
`evidence.prs`, `invoke`. Print every URL; clusters list each PR on its own line.

```text
1. <repo#n>
   <title>
   @<author> · <head> → <base>
   <url>
   <repo#m>
   <url of the other PR, when evidence.prs has one>
   1a <class> — Yes: <what a yes does>. <human step, or none>
   1b <class> — Yes: <what a yes does>. <human step, or none>
```

Widget: `1a. <class> — <repo#n> — <url>`. Review-requested yes is read-only;
operator merges. After verdict or act, repeat `<repo#n> — <url>` with readiness
and human step (`You merge`, or the blocker). See `review.md` and `act.md`.
