# Act

Run one envelope item (`auto` or user-approved `ask`). Push one branch per
command. Mark `in_flight` before; `done` / `blocked` after.

## Resolve invoke

| `class` / hint | Steps |
| -------------- | ----- |
| `red-ci-base` | `wt` → merge `baseRefName` → `verify-merge` vs PR base + prior files → push iff OK |
| `red-ci-flaky` | Re-run failing checks once via `gh`; no local edits |
| `ready-ping` | `ops-github post issue-comment` once; read-back must match |
| `bot-thread` (approved) | Hand replies/resolves after a commit addresses it; `post reply` |
| conflicts / red-ci / unresolved-review / approved-red | Hand → `pull-request` conflicts \| fix-ci \| resolve (mid; frontier on retry) |
| `red-ci-shared` | Ask once with clustered PRs; never auto |

## Workspace rules

- `ops-github wt owner/repo branch` — ff-only; claimed trees block auto.
- `verify-merge PATH --base REF --before-files LIST` must pass before any push
  this session owns.
- Fast: merges, re-runs, ff, bot replies. Mid: thread fixes, judgement
  conflicts. Frontier: retries, security-matrix hits.
- Hand brief: fixed prefix per `brain` orchestrate; ≤12 lines back; logs →
  `/tmp/ops-github/<id>.log`.
- Budgets: 3 auto, 1 retry/wake. On block: `ledger decide <id> blocked`.
