# Brief

One board across channels, clustered by ticket, sorted by operator leverage.

## Sweep

Parallel Tier 1 Hands, each returns JSON or ≤12 lines:

- Always: `ops-github tick` (envelope: `clicks`, `auto`, `ask`, `judge`, `board`).
- On start, `/ops brief`, or `urgency: "brief"`: `$ticket` `intake` and
  `$ops-slack` `digest`.

If Slack or Jira fails or needs auth, keep the healthy channels and append one
line: `degraded: <channel> (<reason>)`. Run `auto` via `$ops-github` `act`
within `budgets` first; list them under Auto-Handled.

## Cluster

Join GitHub items (`ticket`), Jira deltas (`key`), and Slack asks naming a key
into clusters headed `[KEY](jira-url) — Summary *(Jira status)*`. Key-less
items go to `Unlinked`.

Sections, in order; omit empty ones:

1. `### Prod Health` — open `#alerts` pages from `$ops-slack`.
2. `### Ready for Your Click` — clusters with `clicks` (`ready-to-merge` →
   **You merge**, `ready-to-approve` → **You approve**) or an unanswered direct
   Slack ask. Sibling blocked PRs of the same ticket sit directly beneath,
   each with its `[n]` handle: the whole finish line in one place. To snooze or
   defer a click when the operator asks: `ops-github ledger decide <id>
   snoozed|deferred`.
3. `### Needs Decision / Hand Dispatch` — clusters with `review-requested`,
   `re-review`, `approved-red`, `red-ci`, `conflicts`, `unresolved-review`,
   `dependabot-triage`, or a Jira delta (new ready ticket, teammate comment,
   status change). Numbered `[1..N]`, exact clickable URL on every row.
4. `### Auto-Handled` — one line per `auto` item run this pass
   (`red-ci-flaky`, `red-ci-base`, `ready-ping`).
5. `### Waiting` — start and `/ops brief` only: one grouped line of
   `board.waiting_review`, `board.behind`, `board.parked_count`.

Handles `[n]` persist in the Brain Ledger until the next brief.

## Periodic wakes

- **Never `AskQuestion`** on a wake: it would freeze the watcher loop while the
  operator is away. End with `Reply 1..N to dispatch Hands.` when anything is
  dispatchable. `AskQuestion` only after the operator engages (confirming an
  outward `COMMENT` review or a Jira post).
- **Quiet rule:** a `brief` wake with zero new deltas on GitHub, Jira, and Slack
  emits one timestamped heartbeat naming each still-open `clicks` item, e.g.
  `ops 12:16: quiet · awaiting your merge on ABC-123 (app#45)`.
- A `changes` wake emits only the changed clusters, same sections.
