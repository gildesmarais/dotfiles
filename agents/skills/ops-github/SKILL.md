---
name: ops-github
description: >-
  One-shot GitHub PR and issue attention leaf: setup, tick, act, review. Use
  for /ops-github or "what PRs or issues need me?". Continuous monitoring and
  multi-channel briefs live in `$ops`.
disable-model-invocation: true
---

# Ops GitHub

Brain over a read-only CLI (discover, classify, day ledger): briefs Hands,
never restates engine rules. One-shot only: no watcher, no wake loop. Watching
and multi-channel briefs → `$ops`. Co-load
[`../brain/reference/orchestrate.md`](../brain/reference/orchestrate.md) for
**act** / **review**.

## Pick branch

| Signal | Branch |
| ------ | ------ |
| Bare `/ops-github`, no day ledger; `setup-facts`; `reconfigure` | **setup** |
| Bare `/ops-github`, day ledger exists | **tick** |
| `act <id>` | **act** |
| `review <url>` | **review** |

## Shared prep

1. `ops-github` on PATH (`doctor` exit 0). Escalate network for `gh`.
2. `--state-dir` from ledger / env; owners only from setup or the day ledger.
3. After `/compact`, re-read only `ops-github ledger summary` (≤40 lines).
4. `OPS_GITHUB_DRY=1`: all auto becomes ask (first days, new owners).
5. No PR diffs, source, or raw CI here; shell `| tail -n 40`; logs →
   `/tmp/ops-github/<id>.log` (`mkdir -p`; write with `>|`, zsh `noclobber`
   keeps stale files). Mutations and reviews → Hands.

## Branch reference

- **setup** — [`reference/setup.md`](reference/setup.md)
- **tick** — [`reference/tick.md`](reference/tick.md); `clicks`
  (`ready-to-merge`, `ready-to-approve`) and `re-review` come from the envelope
- **act** — [`reference/act.md`](reference/act.md)
- **review** — [`reference/review.md`](reference/review.md)

## Handoff

- Fix, conflicts, threads on your PR → Hand → `pull-request` resolve | fix-ci | conflicts | reply.
- Others' PR → Hand → `review.gil` `findings` (after per-PR OK).
- Ticket (Jira or GitHub issue) → Hand → `ticket` `challenge` | `implement`.
- Jira sweep → `ticket` `intake`; watcher, wake, wrap → `$ops`.
- Dependabot fallout → `dependabot` `triage`; multi-repo delivery → `brain` `orchestrate`.

## Completion criteria

Matched branch Done; report ≤15 engine lines + ≤1 sentence; no tracked-file
edits; budgets honored.
