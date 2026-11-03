# Tick

1. `ops-github tick` → Attention Ledger envelope JSON (`status`, `report_md`,
   `auto`, `ask`, `judge`, `budgets`). Exit 0 = quiet, 10 = changes (both OK).
2. Paste `report_md` as the chat report (engine ≤15 lines). Add at most one
   sentence naming what to do first.
3. **Auto:** run each `auto[]` via **act** (engine already caps at `budgets.auto`).
4. **Ask / judge:** one AskQuestion batch for `urgency: urgent` items. Batch wake → one digest line
   ("N new, `/ops-github` to see") unless the user is already in-session.
   After AskQuestion, record `ops-github ledger decide <id> asked|approved|snoozed|deferred|excluded`.
5. **Judge:** for bot-thread items, decide approve / defer / exclude yourself
   only when evidence is clear; else AskQuestion. Record
   `ops-github ledger decide <id> <status>`. Approved → **act**.
6. Arm `ops-github watch` if watcher PID is gone (`doctor` / ledger summary).
   Run it as a background Shell owned by this session (`block_until_ms: 0`,
   full permissions, `notify_on_output` on `OPS_GITHUB_WAKE`, debounce ≥60s) —
   never `nohup … &`, which detaches it and silently drops wakes. Bare
   `/ops-github` is the user's request to monitor.
7. Wake lines: `OPS_GITHUB_WAKE {…}` → this branch again. Urgent → full report +
   AskQuestion; batch → digest only.

Never re-ask items already `asked`/`approved`/`snoozed`/`deferred`/`in_flight`
until the engine resurfaces them (fingerprint change). Enforce the envelope
`budgets` per wake.
