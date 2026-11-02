# Tick

1. `ops-github tick` → Attention Ledger envelope JSON (`status`, `report_md`,
   `auto`, `ask`, `judge`, `budgets`). Exit 0 = quiet, 10 = changes (both OK).
2. Paste `report_md` as the chat report (engine ≤15 lines). Add at most one
   sentence naming what to do first.
3. **Auto:** run each `auto[]` via **act** up to `budgets.auto` (default 3).
   Overflow carries.
4. **Ask / judge:** one AskQuestion batch for urgent items (review-requested,
   human reply, approved-red). Batch wake → one digest line
   ("N new, `/ops-github` to see") unless the user is already in-session.
5. **Judge:** for bot-thread items, decide approve / defer / exclude yourself
   only when evidence is clear; else AskQuestion. Record
   `ops-github ledger decide <id> <status>`.
6. Arm `ops-github watch` if watcher PID is gone (ledger / doctor).
7. Wake lines: `OPS_GITHUB_WAKE {…}` → this branch again. Urgent → full report +
   AskQuestion; batch → digest only.

Never re-ask items already `asked`/`approved`/`snoozed`/`deferred`/`in_flight`
until the engine resurfaces them (fingerprint change).
