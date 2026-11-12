---
name: ops
description: >-
  Daily attention loop over GitHub, Jira and Slack: setup, brief, watch, act,
  wrap. Ticket-clustered boards, periodic wakes, Hands dispatch. Use for /ops,
  "what needs me today?", or "keep watching".
disable-model-invocation: true
---

# Ops

Brain plus a periodic multi-channel attention loop over `$ops-github`,
`$ops-slack`, and `$ticket` `intake`. Co-load
[`../brain/reference/orchestrate.md`](../brain/reference/orchestrate.md);
`$brain` hard limits apply from turn 1.

- Parent holds the macro picture only: config banner, ticket-clustered briefs,
  Brain Ledger `~/.local/state/brain/ops-<profile>.md`.
- Tier 1 Fast Hands run leaf sweeps: `ops-github tick`, `$ops-slack` `digest`,
  `$ticket` `intake`.
- Tier 2/3 Hands run `$ops-github` `act` / `review`, `$pull-request`,
  `$ticket` `challenge` | `implement`.

## Pick branch

| Signal | Branch |
| ------ | ------ |
| Bare `/ops`, no profile config; `/ops reconfigure` | **setup** |
| Bare `/ops` with profile config; `/ops start` | **start**: brief (full board), then arm watch |
| `/ops brief` | **brief** |
| `OPS_GITHUB_WAKE` (`changes` \| `brief` \| `env`) | **wake** |
| Handle (`1`, `2`, `all`) or an explicit task | **act** |
| `/ops wrap` | **wrap** |

## Shared prep

1. `ops-github doctor` exit 0; escalate network for `gh`. Profile config
   `~/.local/state/ops/<profile>/config.json` (see setup).
2. Print the Active Config Banner on start, after setup, and after `/compact`.
3. After `/compact`, re-read only the Brain Ledger and `ops-github ledger summary`.
4. Leaf failures degrade one channel; never block the others.

## Branch reference

- **setup** — [`reference/setup.md`](reference/setup.md)
- **brief**, **start** — [`reference/brief.md`](reference/brief.md); start also arms [`reference/watch.md`](reference/watch.md)
- **wake**, **wrap** — [`reference/watch.md`](reference/watch.md)
- **act** — handle → item `invoke`: `$ops-github` `act` | `review`; ticket →
  `$ticket` `challenge` | `implement`; delivery tranche → `$brain` `orchestrate`.
  Mark in the Brain Ledger before and after.

## Handoff

- Fix, conflicts, threads on your PR → Hand → `pull-request`.
- Others' PR → Hand → `review.gil` `findings` via `$ops-github` `review`.
- Live outage → `triage`; monitor retune → `trustworthy-alerts`.

## Completion criteria

Branch Done; banner shown on start/setup; brief ticket-clustered with every
URL; no `AskQuestion` on a wake; ledgers updated; no tracked-file edits.
