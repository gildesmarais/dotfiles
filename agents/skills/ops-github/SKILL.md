---
name: ops-github
description: >-
  Daily GitHub PR, issue and Jira operator: setup, tick, whitelist auto-acts,
  PR review, ticket challenge, wrap. Use for /ops-github, "what PRs need me?",
  or periodic PR attention across owners you name.
disable-model-invocation: true
---

# Ops GitHub

Daily GitHub operator over a read-only CLI (discover, classify, day ledger,
watch). This router is the Brain: briefs Hands, never restates engine rules or
edits tracked files. Owners come from setup or the day ledger. Co-load
[`../brain/reference/orchestrate.md`](../brain/reference/orchestrate.md) for
**act** / **review**.

## Pick branch

| Signal | Branch |
| ------ | ------ |
| Bare `/ops-github`, no day ledger; `setup-facts`; `reconfigure` | **setup** |
| Bare `/ops-github`, day ledger exists; or `OPS_GITHUB_WAKE` | **tick** |
| `act <id>` | **act** |
| `review <url>` | **review** |
| `wrap` | **wrap** |

## Shared prep

1. `ops-github` on PATH (`doctor` exit 0). Escalate network for `gh`.
2. Prefer `--state-dir` from ledger / env; never invent owners.
3. After `/compact`, re-read only `ops-github ledger summary` (≤40 lines).
4. `OPS_GITHUB_DRY=1`: all auto becomes ask (first days, new owners).
5. No PR diffs, source, or raw CI here; shell `| tail -n 40`; logs →
   `/tmp/ops-github/<id>.log` (`mkdir -p`; write with `>|`, zsh `noclobber`
   keeps stale files). Mutations and reviews → Hands.

## Branch reference

- **setup** — [`reference/setup.md`](reference/setup.md)
- **tick** — [`reference/tick.md`](reference/tick.md)
- **act** — [`reference/act.md`](reference/act.md)
- **review** — [`reference/review.md`](reference/review.md)
- **wrap** — [`reference/wrap.md`](reference/wrap.md)

## Handoff

- Fix, conflicts, threads on your PR → Hand → `pull-request` resolve | fix-ci | conflicts | reply.
- Others' PR → Hand → `review.gil` `findings` (after per-PR OK).
- Ticket: Jira → Hand → `jira-ticket` `challenge` | `implement`; GitHub issue → `jira-ticket` `challenge` | `$dev`.
- Dependabot fallout → `dependabot` `triage`; multi-repo delivery → `brain` `orchestrate`.

## Completion criteria

Matched branch Done; report ≤15 engine lines + ≤1 sentence; no tracked-file
edits; watch per branch; budgets honored.
