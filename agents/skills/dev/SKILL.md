---
name: dev
description: >-
  Build router: classify, route language packs/overlays, phase commits, API
  truth. Use for implement, fix, feature, change the code, implementation plan,
  phased plan, surgical or design coding; also optimize, hot path, profile.
---

# Dev

Single Build entry. Load packs/overlays by name; never paste their bodies. Craft lives in `architecture`; product scope in `product-owner`. Repo `AGENTS.md` overrides these defaults. Vocabulary: [`../CONTEXT.md`](../CONTEXT.md).

## Pick branch

| Signal                                             | Branch                  |
| -------------------------------------------------- | ----------------------- |
| implementation plan, plan mode, phased plan        | `plan`                  |
| implement, fix, feature, change the code (default) | `implement`             |
| "should we build X?"                               | stop → `product-owner`  |
| assure / findings / tests review / merge prep      | stop → `review.gil`     |
| open / slice / comment a PR                        | stop → `pull-request`   |

## Shared prep

1. **Classify:** `surgical` | `design` | `review-hand-off` (→ stop → `review.gil`).
   - Load [`architecture/reference/axioms.md`](../architecture/reference/axioms.md) on **every** `implement`; `architecture` `SKILL.md` + matched references only when `design` is earned.
   - Earn `design` on: dual ownership, shallow modules, primitive obsession across boundaries, structural cleanup, measured perf, type-driven refactor, named patterns. Ambiguous → `design`. Packs may only append "also earn when…" signals.
   - A prompt naming a plan path and phase id inherits that classification and its architecture decisions; no second pass.
   - `design` earned without inheritance → invoke `architecture` and record seam decisions in the plan or milestone ledger **before** writing code.
2. **Route by touched files** (not repo-wide presence); multi-load OK; validate per surface; clarify only when signals are absent or contradictory.

   | Touched                                                                   | Load                                |
   | ------------------------------------------------------------------------- | ----------------------------------- |
   | `.rb` / gem / plain Ruby                                                  | `ruby-dev` (+ `reference.md`)       |
   | Rails-shaped (controllers, policies, serializers, workers, migrations, …) | `ruby-dev` + `ruby-on-rails-dev`    |
   | `.rs`                                                                     | `rust-dev` (+ `reference.md`)       |
   | `.swift` (non-UI)                                                         | `swift-dev`                         |
   | SwiftUI / WidgetKit / AppKit UI                                           | `swift-dev` + `swiftui-dev`         |
   | `.ts` / `.tsx` / `.js` / `.jsx`                                           | `typescript-dev` (+ `reference.md`) |

3. **On signal:** tests / dual paths / acceptance → [`reference/surgical-laws.md`](reference/surgical-laws.md); material API claim → [`reference/api-truth.md`](reference/api-truth.md); committing or executing a plan → [`reference/plan.md`](reference/plan.md). **AGENTS.md load**, security and observability cues: [`../CONTEXT.md`](../CONTEXT.md); co-load the security lens when clearly needed.
4. **Compat:** classify internal vs stable public. Possibly-breaking change to a stable surface with unclear permission → ask first. No silent shims, no silent breaks.
5. **No destructive git** (`push --force`, hard reset, …) unless explicitly asked.
6. **Validation:** repo-native entrypoints, narrow → broad, per phase. Never claim green without an observed exit 0 for each cited command.

## Branch reference

- **`plan`** — writes no code; contract and checklists in [`reference/plan.md`](reference/plan.md).
- **`implement`** — Shared prep → classify → routed `{lang}-dev` (+ overlay, reference) → execute → post-delivery Assure → Handoff.

## Handoff

Path: `$dev` ⇄ `architecture` → `review.gil` → `pull-request`; never reverse. Emit the **Delivery Ledger** ([`../CONTEXT.md`](../CONTEXT.md)) at delivery → `review.gil`.

- **Post-delivery Assure** (every `implement`, before the delivery report): prefer a subagent running `review.gil` `findings` (+ warranted lenses) with the Ledger; else reload in-session. Trivial diffs may skip (state why). `quality` only on explicit merge-prep / boy-scout / authorized P0/P1. Land ask + Yes/Conditional → `pull-request` `open`.
- `harvest` when pain repeats, a fix was non-obvious, or asked.
- Forward doc (post-Assure, Yes/Conditional): non-obvious maintenance → repo `AGENTS.md`; skip if self-documenting.

## Completion criteria

- **`plan`**: every todo names files, one discovered gate, a Conventional Commit message; no code written.
- **`implement`**: classification + axioms (+ architecture decisions if design); compat decided; exit-0 honesty; commits made/deferred; Assure done or trivial skip stated.
