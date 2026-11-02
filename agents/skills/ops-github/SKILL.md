---
name: ops-github
description: >-
  Daily GitHub attention operator: setup, tick, whitelist auto-acts, review
  briefs, and wrap. Absorbs pr-sweep. Use for /ops-github, "what PRs need me?",
  or periodic PR attention across owners you name.
disable-model-invocation: true
---

# Ops GitHub

Daily GitHub operator. The `ops-github` CLI owns GitHub calls, classification,
whitelist, ledger, worktrees, post, and watch. This router runs the workflow and
briefs Hands; it never restates engine rules. Brain hard limits: edit no tracked
files. No org names; owners come from setup or the day ledger.

## Pick branch

| Signal | Branch |
| ------ | ------ |
| Bare `/ops-github`, no day ledger | **setup** |
| Bare `/ops-github`, day ledger exists; or `OPS_GITHUB_WAKE` | **tick** |
| `act <id>` | **act** |
| `review <url>` | **review** |
| `reconfigure` | **setup** |
| `wrap` | **wrap** |

## Shared prep

1. Require `ops-github` on PATH (`doctor` exit 0). Escalate network for `gh`.
2. Prefer `--state-dir` from the day ledger / env; never invent owners.
3. After `/compact`, re-read only `ops-github ledger summary` (≤40 lines).

## Branch reference

- **setup** — [`reference/setup.md`](reference/setup.md)
- **tick** — [`reference/tick.md`](reference/tick.md)
- **act** — [`reference/act.md`](reference/act.md)
- **review** — [`reference/review.md`](reference/review.md)
- **wrap** — [`reference/wrap.md`](reference/wrap.md)

## Handoff

| Need | Invocation |
| ---- | ---------- |
| Code fix / conflicts / threads on your PR | Hand → `pull-request` resolve \| fix-ci \| conflicts \| reply |
| Review someone else's PR | Hand → `review.gil` `findings` (publish only after per-PR OK) |
| Dependabot fallout on one PR | `dependabot` `triage` |
| Multi-repo / multi-tranche delivery | `brain` `orchestrate` |

## Completion criteria

Matched branch Done; report ≤15 engine lines + ≤1 model sentence; no
tracked-file edits; watch armed or stopped as the branch says.
