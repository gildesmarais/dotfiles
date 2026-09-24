---
name: orchestrator
description: >-
  Zero-trust sequential runner for .agents/plan/<slug>.md: spawns isolated $dev
  implement workers, enforces file bounds and exit-0 gates, commits each green
  phase, circuit breaks on repeated failure, runs one DAG-level review.gil
  findings pass. Use to execute, run, or resume an approved plan.
---

# Orchestrator

Owns execution mechanics only — never intent specification, technical discovery, or application implementation.

## Pick branch

Single branch **`run`**.

| Signal                                          | Route                                  |
| ----------------------------------------------- | -------------------------------------- |
| execute / run / resume `.agents/plan/<slug>.md` | `run`                                  |
| compile or refine intent                        | stop → `prompt-compiler` **`compile`** |
| discover files, gates, or phases                | stop → `$dev` **`plan`**               |
| implement one bounded change without a plan DAG | stop → `$dev` **`implement`**          |
| "should we build X?"                            | stop → `product-owner`                 |

## Shared prep

1. Read repo `AGENTS.md` and the full plan.
2. Require a clean starting worktree and explicit circuit-breaker consent.
3. Phases run sequentially in document order; commits are progress state.
4. Fresh `$dev implement` workers with `orchestrated: true`; workers never commit and skip per-phase Assure.
5. Independently enforce exact path bounds and exit-0 gates after every attempt.
6. Never push. Hard reset only under the approved circuit breaker, only to `last_green_commit`.

## Branch reference

- `run` → [`reference/run.md`](reference/run.md)

## Handoff

Per phase: plan block → fresh worker → bounds diff → independent gate → planned Conventional Commit. Full DAG: exactly one cumulative `review.gil findings` pass. Land requests continue to `pull-request open` only after readiness permits.

## Completion criteria

- Phase green: exact bounds pass, independent gate exit 0, phase commit authored.
- Circuit break: reset to `last_green_commit`, halted.
- Full DAG: all phases green; one cumulative `review.gil findings` audit completed.
