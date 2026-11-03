---
name: ops-github
description: >-
  Daily GitHub attention operator: setup, tick, whitelist auto-acts, review
  briefs, and wrap. Absorbs pr-sweep. Use for /ops-github, "what PRs need me?",
  or periodic PR attention across owners you name.
disable-model-invocation: true
---

# Ops GitHub

Daily GitHub operator. CLI: read-only discovery, classification, day ledger,
watch. Router is the Brain — briefs Hands, no engine-rule restatement, no
tracked-file edits. No org names; owners from setup or day ledger. Co-load
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
4. `OPS_GITHUB_DRY=1` turns all auto into ask (use on first days / new owners).
5. Brain limits: no tracked-file edits; no PR diffs/source/raw CI here; shell
   `| tail -n 40`; logs → `/tmp/ops-github/<id>.log` (`mkdir -p` first; write
   with `>|` — zsh `noclobber` silently keeps a stale file). Mutations/reviews → Hands
   (`Task`, worktree, whitelist, tier, timebox).

## Branch reference

- **setup** — [`reference/setup.md`](reference/setup.md)
- **tick** — [`reference/tick.md`](reference/tick.md)
- **act** — [`reference/act.md`](reference/act.md)
- **review** — [`reference/review.md`](reference/review.md)
- **wrap** — [`reference/wrap.md`](reference/wrap.md)

## Handoff

| Need | Invocation |
| ---- | ---------- |
| Fix / conflicts / threads on your PR | Hand → `pull-request` resolve \| fix-ci \| conflicts \| reply |
| Review someone else's PR | Hand → `review.gil` `findings` (after per-PR OK) |
| Dependabot fallout | `dependabot` `triage` |
| Multi-repo delivery | `brain` `orchestrate` |

## Completion criteria

Matched branch Done; report ≤15 engine lines + ≤1 model sentence; no
tracked-file edits; watch armed/stopped as the branch says; budgets honored.
