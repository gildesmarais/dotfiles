---
name: architecture
description: >
  Language-free solution craft for module depth, type-driven refactors,
  measured performance, and GoF design-pattern selection. Use when $dev
  classifies design, when design or structural cleanup is earned, or when
  the user asks to deepen modules, replace primitives with domain types,
  optimize with a baseline, name a bottleneck class, zero-copy /
  heterogeneous placement, measured hot-path work, or which GoF pattern
  fits — not a Build entry alone (enter via $dev for coding). Also use for
  structural tree / directory surveys: peer-folder conformity, snowflake
  placement, and module promote/relocate/fold ranking — not for generic
  code review (use review.gil).
---

# Architecture

Change how the codebase is structured, typed, or measured for performance — not whether to build a feature, and not language-runtime validation.

**Axioms SoT:** [`reference/axioms.md`](reference/axioms.md) — ride-along load for `$dev` `implement`. This `SKILL.md` (branch pick, Phase 0, references) loads when `design` is earned or a branch signal matches.

## Pick branch

Never ask the user to pick a template when signals are clear. Load one or more when signals combine.

| Branch                | Signals                                                                                                                                                 | Job                                                                |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| `philosophy`          | tactical programming, cognitive load, tech debt, complex interface, obscure logic, information leakage, exception-handling bloat                        | design axioms; evaluate cognitive load and module depth            |
| `deep-modules`        | deepen, shallow modules, seams, locality, dual ownership                                                                                                | Module/interface/depth/seam/adapter/locality/deletion test         |
| `refactor-types`      | primitive obsession, stringly enums, logic-on-types                                                                                                     | Primitives/strings → domain types; logic on types; type hygiene    |
| `refactor-boundaries` | wire/API maps, adapter contract shape, boundary serialize                                                                                               | Wire/API/adapter contract maps; keep domain out of boundary shells |
| `performance`         | slow, hot path, allocate, profile, benchmark                                                                                                            | Measure → baseline → optimize; language-free stop rules            |
| `design-patterns`     | pattern names, "which pattern", decouple sender/receiver, pluggable strategies, undo/redo, object-creation flexibility                                  | GoF pattern vocabulary; earn a pattern from forces; map to craft   |
| `structure-survey`    | tree / directory / layout audit; peer conformity; snowflake; promote / relocate / fold / nest as ownership moves; whole-layer module-layout unification | survey mode → craft as needed                                      |

**Survey mode** is discovery only: execute `view_file` on [`reference/structure-survey.md`](reference/structure-survey.md), then multi-load craft branches from findings. It is not a craft branch.

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
5. **Phase → validate → commit:** Solution craft phase commits follow [`CONTEXT.md`](../CONTEXT.md). Build carrier phase commits belong to `$dev` Shared prep. When `architecture` is loaded during an implementation run, dirty-tree git interactions and phase-commit prompts on the default branch are owned exclusively by `$dev`.
6. Structural signals → run survey **before or with** craft deepening.

## Phase 0: Mandatory Context Pre-Flight (Blocking)

Before authoring architectural designs, refactoring code, or restructuring boundaries: `view_file` the matched `reference/<branch>.md` (and [`reference/glossary.md`](reference/glossary.md) for terms). Branch expansion and harvest protocol live in [`reference/growth.md`](reference/growth.md) + [`reference/learning-log.md`](reference/learning-log.md) (harvest only).

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

Done when each loaded reference's **Done when** is met or explicitly N/A with reason; one combined handoff for multi-load.
