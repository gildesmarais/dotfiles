---
name: architecture
description: >-
  Language-free solution craft: module depth, type-driven refactors, wire
  boundaries, measured perf, GoF, tree surveys. Use when $dev classifies design,
  or for deepen/shallow, dual ownership, hot-path, which-pattern, promote/fold.
disable-model-invocation: true
---

# Architecture

Structure, types, boundaries, measured perf — not whether to build, not language validation. Not a Build entry: coding enters via `$dev`. [`reference/axioms.md`](reference/axioms.md) is the axioms SoT and rides along on every `$dev` `implement`; this router loads only when `design` is earned or a signal below matches.

## Pick branch

Multi-load when signals combine.

| Branch                | Signals                                                                                                                            |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `philosophy`          | tactical programming, cognitive load, tech debt, complex interface, obscure logic, information leakage, exception bloat            |
| `deep-modules`        | deepen, shallow modules, seams, locality, dual ownership                                                                           |
| `refactor-types`      | primitive obsession, stringly enums, logic-on-types                                                                                |
| `refactor-boundaries` | wire/API maps, adapter contract shape, boundary serialize                                                                          |
| `performance`         | slow, hot path, allocate, profile, benchmark                                                                                       |
| `design-patterns`     | pattern names, "which pattern", decouple sender/receiver, pluggable strategies, undo/redo, creation flexibility                    |
| `structure-survey`    | tree/directory/layout audit, peer conformity, snowflake, promote/relocate/fold/nest ownership moves, layer-wide layout unification |

`structure-survey` is discovery: load it, then multi-load craft branches from its findings. Surgical deepen of one named module → `deep-modules` (+ siblings), no survey.

Route instead: "review/findings" → `review.gil` (co-load survey only when tree/snowflake also asked); surgical language-only → `$dev`; "should we build X?" → `product-owner`; "promote" (release) / "unify" (UX) → `release` / product skills. Bare "promote"/"unify" → one clarifying question.

## Shared prep

1. Craft stays language-free; recipes live in `{lang}-dev`, overlays, or project `AGENTS.md` (via `$dev`).
2. Structural signals → survey before or with craft; evidence labels Strong / Worth / Speculative ([`reference/structure-survey.md`](reference/structure-survey.md)).
3. Phase → validate → commit: [`../dev/reference/plan.md`](../dev/reference/plan.md); `$dev` owns dirty-tree and default-branch commit prompts.
4. **Blocking:** before designing/refactoring, read each matched branch reference (+ [`reference/glossary.md`](reference/glossary.md) for terms).

## Branch reference

[`philosophy`](reference/philosophy.md) · [`deep-modules`](reference/deep-modules.md) · [`refactor-types`](reference/refactor-types.md) · [`refactor-boundaries`](reference/refactor-boundaries.md) · [`performance`](reference/performance.md) · [`design-patterns`](reference/design-patterns.md) · [`structure-survey`](reference/structure-survey.md). Adding branches only: [`reference/growth.md`](reference/growth.md).

## Handoff

Return one ledger (required before coding continues via `$dev`) in **Delivery Ledger** shape ([`../CONTEXT.md`](../CONTEXT.md)) plus: branches loaded; craft decisions (structural / type / boundary / perf), each with its rejected alternative, which implement must honor; residuals incl. dual ownership; commits made or deferred.

- Code changed → `$dev` → `{lang}-dev` / overlay validation, then `review.gil` / `pull-request`; never reverse.
- Survey → ranked ledger + craft-branch names; load them, or hand to `$dev` if craft is decided.
- Product scope → `product-owner`; changelog from merged history → `release` `notes`.

## Completion criteria

Each loaded reference's **Done when** met or explicitly N/A with reason; one combined handoff for multi-load.
