# Tick

1. `ops-github tick` → Attention Ledger envelope JSON (`status`, `report_md`,
   `auto`, `ask`, `judge`, `budgets`). Exit 0 = quiet, 10 = changes (both OK).
2. Paste `report_md` as the chat report (engine ≤15 lines). Add at most one
   sentence naming what to do first.
3. **Auto:** run each `auto[]` via **act** (engine already caps at `budgets.auto`).
4. **Ask / judge:** one AskQuestion batch for `urgency: urgent` items.
   After AskQuestion, record `ops-github ledger decide <id> asked|approved|snoozed|deferred|excluded`.
5. **Judge:** for bot-thread items, decide approve / defer / exclude yourself
   only when evidence is clear; else AskQuestion. Record
   `ops-github ledger decide <id> <status>`. Approved → **act**.
6. Arm `ops-github watch` if watcher PID is gone (`doctor` / ledger summary).
   Run it as a background Shell owned by this session (`block_until_ms: 0`,
   full permissions, `notify_on_output` on `OPS_GITHUB_WAKE`, debounce ≥60s) —
   never `nohup … &`, which detaches it and silently drops wakes. In Claude Code
   that is `Monitor` (`timeout_ms` 1800000, the max) over
   `ops-github … watch 2>&1 | grep -E --line-buffered 'OPS_GITHUB_WAKE|rror|FAIL'`;
   it expires after 30m and kills the watch, so re-arm on every expiry. Bare
   `/ops-github` is the user's request to monitor.
7. Wake (`OPS_GITHUB_WAKE`, `urgency` is `changes` or `env`):
   - `changes`: spawn a smallest-tier, low-effort `Task` that runs `ops-github tick`
     and returns `line`, all `auto` ids, and the urgent ask/judge items (id, pr,
     class), ≤12 lines. The Brain prints `line` as its one chat line, runs auto via
     **act**, and asks about urgent items in one AskQuestion. Batch items stay in
     the envelope for the next bare `/ops-github`.
   - `env`: run `ops-github doctor | tail -n 5`, print one line, no tick.
   Urgent/batch come from envelope items, never from the wake.

Never re-ask items already `asked`/`approved`/`snoozed`/`deferred`/`in_flight`
until the engine resurfaces them (fingerprint change). Enforce the envelope
`budgets` per wake.
