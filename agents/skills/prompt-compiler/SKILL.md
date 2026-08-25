---
name: prompt-compiler
description: >-
  Intermediate compilation layer between raw developer intent and downstream
  coding agents. Translates high-level, unstructured, or ambiguous prompts into
  a persisted IR (invariants + atomic task DAG), then dispatches sequential
  worker sub-agents through `$dev` `implement` with orchestrator-enforced
  verification gates. Use when the user says /prompt-compiler, /prompt-synthesis,
  "compile this prompt", "refine prompt", "structure this prompt", or wants
  intent compiled into isolated executable tasks rather than a free-form agent
  brief.
---

# Prompt Compiler

Intent-domain router. Compiles raw developer intent into a bounded, verifiable IR, then (on approval) dispatches tasks sequentially through `$dev` — the only Build entry. Never mutates code itself.

```
[Raw User Prompt]
       │
       ▼
 ┌──────────────────────┐
 │  1. Ingest & Assess  │ ── (Evaluate Ambiguity & Blast Radius)
 └──────────┬───────────┘
            │
            ├─► [High Ambiguity / Missing Invariants] ──► Invoke `/grill-me` (Halt & Clarify)
            │                                                      │
            │ ◄────────────────────────────────────────────────────┘
            ▼
 ┌──────────────────────┐
 │  2. Compile Spec     │ ── (Persist IR file; plan-pipeline ready)
 └──────────┬───────────┘
            │
            ├─► User approves IR (incl. circuit-breaker policy)
            ▼
 ┌──────────────────────┐
 │  3. Dispatch Tasks   │ ── (Sequential `$dev` workers; clean contexts)
 └──────────┬───────────┘
            │
            ▼
 ┌──────────────────────┐
 │  4. Hard Gate Check  │ ── [Orchestrator re-runs gate + bounds diff]
 └──────────┬───────────┘
            │
            ├─► Pass ──► Git Commit ──► Mark green ──► Next pending
            └─► Fail ──► Retry (Max 2) ──► Circuit Breaker (reset to last green commit)
```

## Pick branch

Never ask the user to pick the branch when signals are clear. Default: **`compile`**.

| Branch    | Use when                                                                               | Job                                                                                            |
| --------- | -------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `compile` | Default; "compile this", "structure this prompt", refine/grill intent, first invoke    | Grill gaps → satisfy plan-pipeline → persist IR file → stop (no code)                          |
| `run`     | User approved a persisted IR; "run the compile", "continue the DAG", resume after halt | Dispatch next `pending` task via `$dev` `implement`; orchestrator gates; resume from IR status |

| Signal                                            | Branch                 |
| ------------------------------------------------- | ---------------------- |
| compile / refine / structure / grill / new IR ask | `compile`              |
| run / dispatch / continue / resume approved IR    | `run`                  |
| "should we build X?" without prior PO gate        | stop — `product-owner` |

## Shared prep

1. **Product before non-trivial scope** — feature / UX / new surface asks load `product-owner` **`gate`** first. Continue only on **Build Now**. Skip for pure bug fix, refactor, infra. (README rule 1.)
2. **Hard bounds on this skill** — `compile` is read-only except writing the IR file. `run` never edits application code itself; workers load `$dev` `implement`. Never invent invariants, `target_files`, or `verification_gate` — ground in the repo or obtain via `/grill-me`.
3. **`/grill-me` on ambiguity** — trigger when structural changes lack non-negotiable invariants, explicit mutation bounds (target vs frozen), or clear breaking-change trade-offs. Load the `grilling` pack when installed; otherwise inline fallback: one targeted question at a time on constraints / scope / acceptance (soft cap 5). Halt until material gaps resolve.
4. **IR is the plan carrier** — `compile` loads [`../dev/reference/plan-pipeline.md`](../dev/reference/plan-pipeline.md) and must satisfy its ready checklist before emitting. The IR is an equivalent syntax of `$dev` `plan`, not a competing format. (README rule 4.)
5. **Circuit-breaker consent** — `run` starts only after the user approves the IR _including_ the circuit-breaker policy (reset to last green task commit on repeated gate failure). That approval is the explicit consent `$dev` Shared prep requires for irreversible git.

## Branch reference

- **`compile`** → [`reference/compile.md`](reference/compile.md) — grill rubric, IR schema + file path, plan-pipeline hook, no-invention rules.
- **`run`** → [`reference/run.md`](reference/run.md) — clean-tree precondition, resume from IR status, `$dev` worker prompt, orchestrator gate + `target_files` diff guard, retry / circuit breaker.

## Handoff

- **`compile` → user** — present the IR path + summary; wait for approval (incl. circuit-breaker policy) before `run`. Do not auto-dispatch.
- **`run` → `$dev`** — each task is a fresh worker sub-agent that loads `$dev` `implement` with only that task's IR slice + `read_context`. `$dev` owns classify, language routing, validation law, and phase-commit format. Orchestrator re-runs the gate and bounds-diff before accepting a commit. (README rule 3.)
- **Full DAG → Assure** — before reporting done, prefer spawning `review.gil` **`findings`** (+ warranted lenses); fallback: fresh in-session pass. If user asked to land and readiness is Yes/Conditional → `pull-request` **`open`**. (README rule 6.)
- Jira entrypoints still use `jira-ticket` (and `product-owner` **`gate`** when scope is non-trivial).

## Completion criteria

| Branch / path   | Done when                                                                                                                               |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| grill (active)  | Halted; `/grill-me` (or inline fallback) pending until invariants / mutation bounds / trade-offs land                                   |
| `compile`       | Plan-pipeline ready checklist satisfied; IR file persisted with invariants + ordered atomic tasks; no application code mutated          |
| `run` (task N)  | Clean tree at start; worker via `$dev`; orchestrator gate exit 0 + only `target_files` changed; commit; task `status: green` in IR file |
| circuit breaker | After `max_retries` failures: reset to last green task commit; mark task `failed`; halt; no further tasks until user re-invokes `run`   |
| full DAG        | All tasks `green`; post-delivery `review.gil` **`findings`** completed before delivery report                                           |
