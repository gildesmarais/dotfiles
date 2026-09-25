---
name: architecture
description: >-
  Language-free solution craft: module depth and seams, type-driven refactors,
  wire/adapter boundaries, measured performance, GoF pattern selection, and
  structural tree surveys. Use when $dev classifies design, or for deepen
  modules, shallow modules, dual ownership, replace primitives with domain
  types, optimize with a baseline, bottleneck class, zero-copy / heterogeneous
  placement, measured hot-path work, which GoF pattern fits, directory/tree
  survey, peer-folder conformity, snowflake placement, promote/relocate/fold
  modules.
---

# Architecture

Structure, types, boundaries, measured perf — not whether to build, not language validation. Not a Build entry alone: coding enters via `$dev`. [`reference/axioms.md`](reference/axioms.md) is the axioms SoT and rides along on every `$dev` `implement`; this router loads only when `design` is earned or a signal below matches.

## Pick branch

Never ask the user to pick when signals are clear; multi-load when signals combine.

| Branch                | Signals                                                                                                                            |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `philosophy`          | tactical programming, cognitive load, tech debt, complex interface, obscure logic, information leakage, exception bloat            |
| `deep-modules`        | deepen, shallow modules, seams, locality, dual ownership                                                                           |
| `refactor-types`      | primitive obsession, stringly enums, logic-on-types                                                                                |
| `refactor-boundaries` | wire/API maps, adapter contract shape, boundary serialize                                                                          |
| `performance`         | slow, hot path, allocate, profile, benchmark                                                                                       |
| `design-patterns`     | pattern names, "which pattern", decouple sender/receiver, pluggable strategies, undo/redo, creation flexibility                    |
| `structure-survey`    | tree/directory/layout audit, peer conformity, snowflake, promote/relocate/fold/nest ownership moves, layer-wide layout unification |

`structure-survey` is a discovery mode, not a craft branch: load it, then multi-load craft branches from its findings.

| Ask                                                     | Route instead                                                                                                                                                           |
| ------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| "review code", `/review.gil`, PR review, findings       | `review.gil` — co-load only when tree / layout / snowflake is also asked; then survey first → craft handoff, `findings` schema only if a findings report is also wanted |
| Surgical language work only                             | `$dev` (routes `{lang}-dev` / overlay)                                                                                                                                  |
| "should we build X?"                                    | `product-owner` ([`../CONTEXT.md`](../CONTEXT.md))                                                                                                                      |
| "promote" (release/product) / "unify" (UX copy, tokens) | `release` / product / design skills                                                                                                                                     |
| Surgical deepen of one named module in hand             | `deep-modules` (+ siblings) — skip survey                                                                                                                               |

Bare "promote" / "unify" → one clarifying question, or stay on the skill in play.

## Shared prep

1. Evidence labels when surveying: Strong / Worth / Speculative.
2. Craft stays language-free; recipes live in `{lang}-dev`, overlays, third-party packs, or project `AGENTS.md` (via `$dev`).
3. Structural signals → survey before or with craft.
4. Phase → validate → commit: Solution craft phase commits follow [`../CONTEXT.md`](../CONTEXT.md). During an implementation run, dirty-tree git interactions and default-branch commit prompts are owned exclusively by `$dev`.
5. **Blocking:** before designing, refactoring, or restructuring, read each matched branch reference (+ [`reference/glossary.md`](reference/glossary.md) for terms).

## Branch reference

[`philosophy`](reference/philosophy.md) · [`deep-modules`](reference/deep-modules.md) · [`refactor-types`](reference/refactor-types.md) · [`refactor-boundaries`](reference/refactor-boundaries.md) · [`performance`](reference/performance.md) · [`design-patterns`](reference/design-patterns.md) · [`structure-survey`](reference/structure-survey.md) (mode). Adding branches / harvest only: [`reference/growth.md`](reference/growth.md) + [`reference/learning-log.md`](reference/learning-log.md).

## Handoff

Return one ledger (required before coding continues via `$dev`) in **Delivery Ledger** shape ([`../CONTEXT.md`](../CONTEXT.md)) plus craft deltas: branches loaded; craft decisions (structural / type / boundary / perf), each with the rejected alternative, implement must honor; residuals incl. dual ownership; commits made or deferred.

- Craft touched code → re-route through `$dev` → `{lang}-dev` / overlay for validation before Assure / Ship.
- Then `review.gil` / `pull-request` — never reverse; never skip `$dev` validation when code changed.
- Survey → ranked ledger + craft-branch names; load them, or hand to `$dev` if craft is decided.
- Product scope → `product-owner`; changelog from merged history → `release` `notes`.

## Completion criteria

Each loaded reference's **Done when** met or explicitly N/A with reason; one combined handoff for multi-load.
