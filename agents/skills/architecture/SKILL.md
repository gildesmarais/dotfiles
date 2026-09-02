---
name: architecture
description: >
  Language-free solution craft for module depth, type-driven refactors, and
  measured performance. Use when $dev classifies design, when design or
  structural cleanup is earned, or when the user asks to deepen modules,
  replace primitives with domain types, optimize with a baseline, name a
  bottleneck class, zero-copy / heterogeneous placement, or measured hot-path
  work — not a Build entry alone (enter via $dev for coding). Also use for
  structural tree / directory surveys: peer-folder conformity, snowflake
  placement, and module promote/relocate/fold ranking — not for generic code
  review (use review.gil).
---

# Architecture

Change how the codebase is structured, typed, or measured for performance — not whether to build a feature, and not language-runtime validation.

## Core Architectural Axioms (Always Active)

- **Deep Modules:** Small interface surface, substantial private behavior. Avoid shallow pass-through bags.
- **Deletion Test:** Candidate modules must pass the deletion test — removing or swapping a module should not cause cascading rewrites across unrelated consumers.
- **Single Ownership:** One fact, rule, or expansion algorithm has exactly one authoritative owner. Eliminate dual ownership between validate and execute, or between two adapters.
- **Locality over Ceremony:** Introduce seams only where they buy testability or phased migration. Wrong-layer domain surfaces fail locality even if deep internally.
- **Wire vs Domain Boundary:** Domain types enforce invariants at construction; boundary adapters map wire primitives inbound and outbound. Keep application logic out of serialization shells.

**Ride-along contract:** `$dev` loads this `SKILL.md` on every `implement` (surgical included) so the axioms are always active during Build. That default load is axioms-only — branch pick, Phase 0 pre-flight, and reference files engage when `design` is earned or a branch signal matches.

## Pick branch

Never ask the user to pick a template when signals are clear. Load one or more when signals combine.

| Branch                | Job                                                                | Status |
| --------------------- | ------------------------------------------------------------------ | ------ |
| `deep-modules`        | Module/interface/depth/seam/adapter/locality/deletion test         | active |
| `refactor-types`      | Primitives/strings → domain types; logic on types; type hygiene    | active |
| `refactor-boundaries` | Wire/API/adapter contract maps; keep domain out of boundary shells | active |
| `performance`         | Measure → baseline → optimize; language-free stop rules            | active |

| Signal                                                                                                                                                                             | Load                                               |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| deepen, shallow modules, seams, locality, dual ownership                                                                                                                           | `deep-modules`                                     |
| primitive obsession, stringly enums, logic-on-types                                                                                                                                | `refactor-types`                                   |
| wire/API maps, adapter contract shape, boundary serialize                                                                                                                          | `refactor-boundaries`                              |
| slow, hot path, allocate, profile, benchmark                                                                                                                                       | `performance`                                      |
| tree / directory / layout audit; peer conformity; snowflake / same job different homes; promote / relocate / fold / nest as ownership moves; whole-layer module-layout unification | `structure-survey` (survey mode) → craft as needed |

**Survey mode** is discovery only: execute `view_file` on [`reference/structure-survey.md`](reference/structure-survey.md), then multi-load craft branches from findings. It is not a fifth craft branch.

| Ask                                                     | Route instead                                                                 |
| ------------------------------------------------------- | ----------------------------------------------------------------------------- |
| “review code”, `/review.gil`, PR review, findings-ready | `review.gil` — co-load only when the ask also needs tree / layout / snowflake |
| “promote” in a product / release sense                  | `release` / product                                                           |
| “unify” UX copy, visual grammar, design tokens          | designer / screen-grammar skills                                              |
| Surgical deepen of one named module already in hand     | `deep-modules` (and siblings) — skip whole-tree survey                        |
| “should we build X?”                                    | `product-owner`                                                               |
| Surgical language work only                             | `$dev` (routes to `{lang}-dev` / overlay)                                     |

Bare “promote” / “unify” alone → one clarifying question, or stay on the skill already in play.

**Co-load with review.gil:** default stays split. When the ask combines both (e.g. review structure via the tree for promote/relocate): survey first → craft-branch handoff; `findings` Required Output Schema only if they also want a findings report.

## Shared prep

1. Read `AGENTS.md` when present; prefer repo law over defaults here.
2. Evidence before claims: call sites, ownership, existing tests. Label Strong / Worth / Speculative when surveying.
3. Multi-load OK when signals combine; one handoff covering everything loaded.
4. Keep craft language-free. Language recipes belong in `{lang}-dev`, overlays, third-party packs, or project `AGENTS.md` (loaded via `$dev`).
5. **Phase → validate → commit:** after each craft phase (architecture phase, surgical milestone, or user-named plan step), validate, then create ≥1 Conventional Commit with a rationale/intent body before the next phase. Format and phase law: [`CONTEXT.md`](../CONTEXT.md). Build-side phase commits also live on `$dev`.
6. Structural signals → run survey **before or with** craft deepening.

## Phase 0: Mandatory Context Pre-Flight (Blocking)

Before authoring architectural designs, refactoring code, or restructuring boundaries, execute `view_file` on the matching reference files:

1. **`deep-modules`:** You MUST view [`reference/deep-modules.md`](reference/deep-modules.md).
2. **`refactor-types`:** You MUST view [`reference/refactor-types.md`](reference/refactor-types.md).
3. **`refactor-boundaries`:** You MUST view [`reference/refactor-boundaries.md`](reference/refactor-boundaries.md).
4. **`performance`:** You MUST view [`reference/performance.md`](reference/performance.md).
5. **`structure-survey`:** You MUST view [`reference/structure-survey.md`](reference/structure-survey.md).
6. **Detailed Terms & Definitions:** View [`reference/glossary.md`](reference/glossary.md).

Branch expansion and harvest protocol live in [`reference/growth.md`](reference/growth.md) + [`reference/learning-log.md`](reference/learning-log.md) (harvest only).

## Handoff

Return ledger (required before coding continues via `$dev`) — **Delivery Ledger** shape in [`CONTEXT.md`](../CONTEXT.md):

- Branches loaded
- Craft decisions (structural / type / boundary / perf) — what implement must honor
- Residuals / N/A (including dual ownership)
- Commits made or deferred
- If craft touched code: re-route through `$dev` → `{lang}-dev` / overlay for language validation before Assure / Ship

Then:

- Implementation and language validation continue via `$dev` → routed `{lang}-dev` / overlay after craft decisions are clear.
- Assure / ship continues with `review.gil` / `pull-request` — never reverse; never skip `$dev` validation when code changed.
- Product scope questions go to `product-owner`.
- Changelog from merged history → `release` **`notes`** (consumer only).
- Structure survey → ranked ledger + craft-branch names; then load those branches (or hand off to `$dev` if craft is already decided).

## Completion criteria

| Branch / mode         | Done when                                                                                                                                 |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `structure-survey`    | Canonical shape stated; anomalies ranked with evidence; craft-branch handoff named; residual dual ownership called out — no code required |
| `deep-modules`        | Deletion test / ownership / seams addressed; phases validated; residual dual ownership called out                                         |
| `refactor-types`      | Primitive obsession at target cleared or scoped; logic on types; consumers cleaned; boundaries mapped                                     |
| `refactor-boundaries` | Contract map for targeted edges; domain out of shells; serialize ownership clear; phases committed per Shared prep                        |
| `performance`         | Baseline or hot path identified before changes; stop rules applied; no language-specific recipe invented here                             |
| multi-load            | Each loaded branch’s done-when met or explicitly N/A with reason; one combined handoff                                                    |
