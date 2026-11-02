# Act

Run one envelope item (`auto` or user-approved `ask`). Mark `in_flight` before;
`done` / `blocked` after via `ops-github ledger decide <id> <status>`.

Hand brief, Merge-main, Tiers, Verify:
[`../../brain/reference/orchestrate.md`](../../brain/reference/orchestrate.md)
— do not restate. Cap tool output; logs → `/tmp/ops-github/<id>.log`; Hand
returns ≤12 lines.

## Resolve invoke

| `class` / hint | Steps |
| -------------- | ----- |
| `red-ci-flaky` | Brain fast: `gh run rerun <id> --failed` (discover via capped `gh pr checks`) |
| `ready-ping` | Brain fast: `gh pr comment <url> --body "@<who> ready for another look"` |
| `red-ci-base` | Small/low Hand, Merge-main, ≤8 turns: merge `origin/<baseRefName>`; Brain verifies file set vs pre-merge, pushes |
| bot-thread / unresolved-review / conflicts / red-ci / approved-red | Mid Hand (`strongest` on retry/security), ≤15 turns, worktree: `pull-request` resolve \| conflicts \| fix-ci; Verify + push; max 1 retry/wake |
| `red-ci-shared` / `dependabot-triage` | Ask once with cluster; never auto |

## Workspace rules

- Hands own checkouts; Brain edits no tracked files.
- Fast: reruns, pings. Mid: fixes/conflicts/CI. Frontier: retries, security, reviews.
- Budgets: 3 auto, 1 retry/wake. On block: `ledger decide <id> blocked`.
