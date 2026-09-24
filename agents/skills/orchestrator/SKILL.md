---
name: orchestrator
description: >-
  Brain for .agents/plan/<slug>.md on one shared worktree: one $dev implement
  hand at a time, file bounds, exit-0 gates, one commit per phase, circuit
  break, one findings pass. Use to execute, run, or resume a plan when Cursor
  multi-agent is not the runner.
---

# Orchestrator

Brain only. It does not specify intent, discover files, or edit application code. It runs a plan the user enqueued. Multi-agent delivery stays in `$dev plan`.

## Pick branch

Single branch **`run`**.

| Signal                                                          | Route                                   |
| --------------------------------------------------------------- | --------------------------------------- |
| execute / run / resume `.agents/plan/<slug>.md` on one worktree | `run`                                   |
| multi-agent delivery when plan already exists                   | delivery offer — do not re-enter `plan` |
| deliver a **new** plan with Cursor multi-agent                  | stop → `$dev` **`plan`**                |
| compile or refine intent                                        | stop → `prompt-compiler` **`compile`**  |
| discover files, gates, or phases (no plan yet)                  | stop → `$dev` **`plan`**                |
| implement one bounded change without a plan                     | stop → `$dev` **`implement`**           |
| "should we build X?"                                            | stop → `product-owner`                  |

## Shared prep

1. Consent and admission already happened in the pipeline batch ([`../CONTEXT.md`](../CONTEXT.md)). Do not ask again.
2. Read repo `AGENTS.md` and the next phase block only.
3. One hand at a time on this worktree. `depends_on` chooses the next phase. Commits are progress.
4. The hand prompt is the plan path and phase id. The brain checks bounds, runs the gate, and commits.
5. Never push. Hard reset only under the approved circuit breaker, only to the last green commit.

## Branch reference

- `run` → [`reference/run.md`](reference/run.md)

## Handoff

Land was in the batch and findings readiness is Yes or Conditional → `pull-request open`. Otherwise stop.

## Completion criteria

- Phase green: bounds match, gate exit 0, planned commit authored.
- Circuit break: reset to the last green commit, halted.
- Run green: all phases committed; one `review.gil findings` pass in `.agents/run/<slug>.md`.
