---
name: orchestrator
description: >-
  Zero-trust sequential execution runner. Consumes implementation phases from
  .agents/plan/<slug>.md, spawns isolated $dev implement workers, independently
  enforces file bounds and verification gates, commits each green phase, circuit
  breaks on repeated failure, and runs one DAG-level review.gil findings pass.
---

# Orchestrator

Executes approved implementation plans. It owns execution mechanics and never owns intent specification, technical discovery, or application implementation.

## Pick branch

Single branch. Default: **`run`**.

| Signal                                          | Route                                  |
| ----------------------------------------------- | -------------------------------------- |
| execute / run / resume `.agents/plan/<slug>.md` | `run`                                  |
| compile or refine intent                        | stop → `prompt-compiler` **`compile`** |
| discover files, gates, or phases                | stop → `$dev` **`plan`**               |
| implement one bounded change without a plan DAG | stop → `$dev` **`implement`**          |
| "should we build X?"                            | stop → `product-owner`                 |

## Shared prep

1. Read repository `AGENTS.md` and the complete plan carrier.
2. Require a clean starting worktree and explicit circuit-breaker consent.
3. Execute phases sequentially in document order; commits are progress state.
4. Dispatch fresh `$dev implement` workers. Workers never commit and skip per-phase Assure.
5. Independently enforce exact path bounds and exit-0 gates after every attempt.
6. Never push. Hard reset is legal only for the approved circuit breaker and only to `last_green_commit`.

## Branch reference

- **`run`** → [`reference/run.md`](reference/run.md)

## Handoff

Per phase: plan block → fresh `$dev implement` worker → bounds diff → independent gate → planned Conventional Commit. Full DAG: exactly one cumulative `review.gil findings` pass. Land requests continue to `pull-request open` only after readiness permits.

## Completion criteria

| Path          | Done when                                                                 |
| ------------- | ------------------------------------------------------------------------- |
| phase green   | Exact bounds pass, independent verification exit 0, phase commit authored |
| circuit break | Reset to last green commit and halt after retries are exhausted           |
| full DAG      | All phases green and one cumulative `review.gil findings` audit completed |
