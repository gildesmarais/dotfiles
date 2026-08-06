---
name: architecture
description: >
  Language-free solution craft for module depth, type-driven refactors, and
  measured performance. Use when design or structural cleanup is earned, when
  a *-dev skill classifies design, or when the user asks to deepen modules,
  replace primitives with domain types, or optimize with a baseline. Also use
  for structural tree / directory surveys: peer-folder conformity, snowflake
  placement, and module promote/relocate/fold ranking — not for generic code
  review (use review.gil).
---

# Architecture

Change how the codebase is structured, typed, or measured for performance — not whether to build a feature, and not language-runtime validation.

## Pick branch

Never ask the user to pick a template when signals are clear. Load one or more when signals combine.

| Branch                | Job                                                                | Status |
| --------------------- | ------------------------------------------------------------------ | ------ |
| `deep-modules`        | Module/interface/depth/seam/adapter/locality/deletion test         | active |
| `refactor-types`      | Primitives/strings → domain types; logic on types; type hygiene    | active |
| `refactor-boundaries` | Wire/API/adapter contract maps; keep domain out of boundary shells | active |
| `performance`         | Measure → baseline → optimize; language-free stop rules            | active |

| Signal                                                                                         | Load                                               |
| ---------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| deepen, shallow modules, seams, locality, dual ownership                                       | `deep-modules`                                     |
| primitive obsession, stringly enums, logic-on-types                                            | `refactor-types`                                   |
| wire/API maps, adapter contract shape, boundary serialize                                      | `refactor-boundaries`                              |
| slow, hot path, allocate, profile, benchmark                                                   | `performance`                                      |
| tree / directory / layout audit; peer conformity; snowflake / same job different homes; promote / relocate / fold / nest as ownership moves; whole-layer module-layout unification | `structure-survey` (survey mode) → craft as needed |

**Survey mode** is discovery only: load [`reference/structure-survey.md`](reference/structure-survey.md), then multi-load craft branches from findings. It is not a fifth craft branch.

| Ask                                                       | Route instead                                                                 |
| --------------------------------------------------------- | ----------------------------------------------------------------------------- |
| “review code”, `/review.gil`, PR review, finish readiness | `review.gil` — co-load only when the ask also needs tree / layout / snowflake |
| “promote” in a product / release sense                    | `release` / product                                                           |
| “unify” UX copy, visual grammar, design tokens            | designer / screen-grammar skills                                              |
| Surgical deepen of one named module already in hand       | `deep-modules` (and siblings) — skip whole-tree survey                        |
| “should we build X?”                                      | `product-owner`                                                               |
| Surgical language work only                               | stay in the relevant `*-dev` skill                                            |

Bare “promote” / “unify” alone → one clarifying question, or stay on the skill already in play.

**Co-load with review:** default stays split. When the ask combines both (e.g. review structure via the tree for promote/relocate): survey first → craft-branch handoff; review finish format only if they also want a findings report.

## Shared prep

1. Read `AGENTS.md` when present; prefer repo law over defaults here.
2. Evidence before claims: call sites, ownership, existing tests. Label Strong / Worth / Speculative when surveying.
3. Always load [`reference/glossary.md`](reference/glossary.md) with any branch or survey mode.
4. Multi-load OK when signals combine; one handoff covering everything loaded.
5. Keep craft language-free. Language recipes belong in `*-dev`, overlays, third-party packs, or project `AGENTS.md`.
6. **Phase → validate → commit:** after each craft phase (architecture phase, surgical milestone, or user-named plan step), validate, then create ≥1 Conventional Commit with a rationale/intent body before the next phase. Format and phase law: [`CONTEXT.md`](../CONTEXT.md).
7. Structural signals → run survey **before or with** craft deepening.

Branch expansion and harvest protocol live in [`reference/growth.md`](reference/growth.md) — load only when adding a branch or harvesting lessons.

## Branch reference

Load progressively — glossary plus each selected branch or mode. Do not preload every reference.

- Glossary → [`reference/glossary.md`](reference/glossary.md)
- Survey mode → [`reference/structure-survey.md`](reference/structure-survey.md)
- `deep-modules` → [`reference/deep-modules.md`](reference/deep-modules.md)
- `refactor-types` → [`reference/refactor-types.md`](reference/refactor-types.md)
- `refactor-boundaries` → [`reference/refactor-boundaries.md`](reference/refactor-boundaries.md)
- `performance` → [`reference/performance.md`](reference/performance.md)
- Harvest only → [`reference/growth.md`](reference/growth.md) + [`reference/learning-log.md`](reference/learning-log.md)

## Handoff

- Implementation and language validation continue in the relevant `*-dev` / overlay after craft decisions are clear.
- Assure / ship continues with `review` / `pull-request` — never reverse.
- Product scope questions go to `product-owner`.
- Changelog from merged history → `release` **`notes`** (consumer only).
- Structure survey → ranked ledger + craft-branch names; then load those branches (or hand off to `*-dev` if craft is already decided).

## Completion criteria

| Branch / mode         | Done when                                                                                                                                 |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `structure-survey`    | Canonical shape stated; anomalies ranked with evidence; craft-branch handoff named; residual dual ownership called out — no code required |
| `deep-modules`        | Deletion test / ownership / seams addressed; phases validated; residual dual ownership called out                                         |
| `refactor-types`      | Primitive obsession at target cleared or scoped; logic on types; consumers cleaned; boundaries mapped                                     |
| `refactor-boundaries` | Contract map for targeted edges; domain out of shells; serialize ownership clear; phases committed per Shared prep                        |
| `performance`         | Baseline or hot path identified before changes; stop rules applied; no language-specific recipe invented here                             |
| multi-load            | Each loaded branch’s done-when met or explicitly N/A with reason; one combined handoff                                                    |
