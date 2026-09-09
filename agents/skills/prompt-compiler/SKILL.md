---
name: prompt-compiler
description: >-
  Intent specification compiler. Translates high-level, unstructured, or
  ambiguous developer prompts into a clean persisted intent_spec DTO containing
  invariants, allowed blast radius, breaking-change posture, and circuit-breaker
  consent state. Use for /prompt-compiler, "compile this prompt", "refine prompt",
  or "structure this prompt". Never plans or executes implementation work.
---

# Prompt Compiler

Deep Intent module: raw developer language in, one bounded `intent_spec` DTO out. It owns no technical discovery or execution mechanics.

## Pick branch

Single branch. Default: **`compile`**.

| Signal                                                   | Route                           |
| -------------------------------------------------------- | ------------------------------- |
| compile / refine / structure / grill intent              | `compile`                       |
| write implementation phases / discover files or commands | stop → `$dev` **`plan`**        |
| execute / dispatch / continue / retry                    | stop → `orchestrator` **`run`** |
| implement one bounded phase outside orchestration        | stop → `$dev` **`implement`**   |
| "should we build X?"                                     | stop → `product-owner`          |

`compile` produces `.agents/compile/<slug>.yaml` with an `intent_spec` DTO. It does not produce an executable task graph.

## Shared prep

1. **Product boundary** — non-trivial feature or UX scope requires an admitted product decision before intent compilation. Pure bug fixes, refactors, and infrastructure work do not.
2. **Compiler boundary** — compilation is read-only except for its one DTO file. Never inspect repo mechanics to speculate about files, commands, phases, or tests.
3. **Grill only owned gaps** — resolve invariants, `allowed_domains`, and breaking-change posture. Load `grilling` when available; otherwise ask one targeted question at a time.
4. **No execution schema** — task DAGs, dependencies, statuses, retries, commands, verification gates, and worker prompts are forbidden here.
5. **Consent remains explicit** — emit `circuit_breaker.approved: false`; no compiler inference or automatic approval.

## Branch reference

- **`compile`** → [`reference/compile.md`](reference/compile.md)

## Handoff

`compile` → `$dev` **`plan`** with the emitted DTO path. `$dev plan` performs technical discovery and writes `.agents/plan/<slug>.md`. `orchestrator run` consumes that plan and owns the sequential execution loop. `$dev implement` owns code changes inside a single dispatched phase.

## Completion criteria

| Path         | Done when                                                                                                                     |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| grill active | Halted until invariants, allowed blast radius, and trade-off posture are explicit                                             |
| `compile`    | Valid `intent_spec` v2.0 persisted; no implementation fields or application mutations; halted after clean `$dev plan` handoff |
