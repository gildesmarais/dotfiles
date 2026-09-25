---
name: prompt-compiler
description: >-
  Compile raw or ambiguous developer prompts into a persisted intent_spec DTO:
  invariants, allowed blast radius, breaking-change posture. Use for
  /prompt-compiler, "compile this prompt", "refine prompt", or "structure this
  prompt".
---

# Prompt Compiler

When asked to compile: raw language → one `intent_spec` DTO (`.agents/compile/<slug>.yaml`) → `$dev plan` same turn. Not on the default Build path (gate → `$dev plan`). Never executes. DTO fields: [`../CONTEXT.md`](../CONTEXT.md).

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
3. **Owned gaps join the pipeline batch** ([`../CONTEXT.md`](../CONTEXT.md)): invariants, `allowed_domains`, breaking-change posture. One message, then write the DTO. Do not grill one question at a time on this path.
4. **No execution schema:** task DAGs, dependencies, statuses, retries, commands, verification gates, worker prompts are forbidden.

## Branch reference

- `compile` → [`reference/compile.md`](reference/compile.md)

## Handoff

`compile` → `$dev` **`plan`** with the DTO path. Do not stop for a second confirmation. The planning session owns discovery and delivery.

## Completion criteria

- Owned gaps were in the batch or already answered. The DTO is not written while any of the three dimensions is unknown.
- `compile`: valid `intent_spec` v2.0 persisted; no implementation fields or application mutations; `$dev plan` has the DTO path.
