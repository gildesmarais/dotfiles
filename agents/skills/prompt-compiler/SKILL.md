---
name: prompt-compiler
description: >-
  Compile raw or ambiguous developer prompts into a persisted intent_spec DTO:
  invariants, allowed blast radius, breaking-change posture, circuit-breaker
  consent. Use for /prompt-compiler, "compile this prompt", "refine prompt", or
  "structure this prompt".
---

# Prompt Compiler

Raw developer language in, one `intent_spec` DTO (`.agents/compile/<slug>.yaml`) out, then stop. Never plans or executes implementation work; no executable task graph. DTO fields: [`../CONTEXT.md`](../CONTEXT.md) (Intent DTO fields).

## Pick branch

Single branch **`compile`**.

| Signal                                                   | Route                           |
| -------------------------------------------------------- | ------------------------------- |
| compile / refine / structure / grill intent              | `compile`                       |
| write implementation phases / discover files or commands | stop → `$dev` **`plan`**        |
| execute / dispatch / continue / retry                    | stop → `orchestrator` **`run`** |
| implement one bounded phase outside orchestration        | stop → `$dev` **`implement`**   |
| "should we build X?"                                     | stop → `product-owner`          |

## Shared prep

1. **Product boundary:** non-trivial feature/UX scope needs an admitted product decision first; bug fixes, refactors, infra don't.
2. **Read-only** except the one DTO file. Never inspect repo mechanics to speculate about files, commands, phases, or tests.
3. **Grill only owned gaps** (invariants, `allowed_domains`, breaking-change posture): load `grilling` when available, else one targeted question at a time.
4. **No execution schema:** task DAGs, dependencies, statuses, retries, commands, verification gates, worker prompts are forbidden.
5. **Consent explicit:** always emit `circuit_breaker.approved: false`; never infer approval.

## Branch reference

- `compile` → [`reference/compile.md`](reference/compile.md)

## Handoff

`compile` → `$dev` **`plan`** with the DTO path (it does discovery and writes `.agents/plan/<slug>.md`) → `orchestrator run` → `$dev implement` per dispatched phase.

## Completion criteria

- Grill active: halted until invariants, blast radius, and trade-off posture are explicit.
- `compile`: valid `intent_spec` v2.0 persisted; no implementation fields or application mutations; halted after `$dev plan` handoff.
