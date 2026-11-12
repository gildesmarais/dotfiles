# Tick

One-shot GitHub pass. No Jira, watcher, or wake handling: `ticket` `intake`
and `$ops` own those.

1. `ops-github tick` → envelope JSON (`status`, `report_md`, `clicks`, `auto`,
   `ask`, `judge`, `board`, `budgets`). Exit 0 quiet, 10 changes; both OK.
2. Paste `report_md` (≤15 lines) + ≤1 sentence on what comes first. Non-empty
   `ask`/`judge` → **digest** before the widget. Prompts repeat id + URL
   (`1a. <class> — <repo#n> — <url>`). In flight: `<pr> — <url>`, never bare id.
3. **Clicks:** report only, never act. `ready-to-merge` → `You merge`,
   `ready-to-approve` → `You approve`; each with `<repo#n> — <url>`. If the
   operator asks to snooze/defer a click: `ledger decide <id> snoozed|deferred`.
4. **Auto:** each `auto[]` via **act** (engine-capped).
5. **Ask:** one AskQuestion (≤4) when invoked interactively standalone, urgent
   then batch (batch on bare `/ops-github` only; overflow waits). Digest those
   rows only. Overflow: `N more waiting`, no links. Record `ledger decide <id>
   asked|approved|snoozed|deferred|excluded`. Under `$ops`, return the rows
   instead; never prompt.
6. **Judge:** bot-thread — approve/defer/exclude on clear evidence, else digest
   + AskQuestion; `ledger decide`; approved → **act**.
7. `issue-assigned` asks: digest only; `$ops` or the operator routes to
   `ticket` `challenge` | `implement`. Skip → `ledger decide <id> deferred`; never → `ledger exclude owner/repo#n`.

Never re-ask decided/`in_flight` items until fingerprint changes. Enforce
`budgets` per tick.

## Digest

Group by shared PR, urgent first. One button per decision. Envelope fields:
`url`, `title`, `class`, `headRefName`, `baseRefName`, `evidence.author`,
`evidence.prs`, `invoke`, `ticket`. Print every URL; clusters list each PR on
its own line.

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
