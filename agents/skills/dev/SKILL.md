---
name: dev
description: >-
  Build-domain router for implementation plans and code changes: classify, route
  language packs and overlays, phase commits, validation, API truth. Use for
  implement, fix, feature, change the code, implementation plan, phased plan,
  surgical or design-shaped coding; also optimize, hot path, profile, benchmark.
---

# Dev

Single Build entry. Load packs/overlays by name; never paste their bodies. Craft lives in `architecture`; product scope in `product-owner`. Repo `AGENTS.md` overrides the defaults here. Vocabulary: [`../CONTEXT.md`](../CONTEXT.md).

## Pick branch

Never ask the user to pick when signals are clear.

| Signal                                             | Branch                                                      |
| -------------------------------------------------- | ----------------------------------------------------------- |
| implementation plan, plan mode, phased plan        | `plan` — the planning session writes no code                |
| implement, fix, feature, change the code (default) | `implement`                                                 |
| "should we build X?"                               | stop → `product-owner`                                      |
| assure / findings / tests review / merge prep      | stop → `review.gil`                                         |
| open / slice / comment a PR                        | stop → `pull-request`                                       |

## Shared prep

1. **AGENTS.md load** / observability / security cues: [`../CONTEXT.md`](../CONTEXT.md). Co-load the security lens during implement when clearly needed. Rails matrix stays in the overlay / `AGENTS.md`.
2. **Classify:** `surgical` | `design` | `review-hand-off`.
   - Load [`architecture/reference/axioms.md`](../architecture/reference/axioms.md) on **every** `implement`. Load `architecture` `SKILL.md` + matched references only when `design` is earned.
   - Earn `design` on: dual ownership / shallow modules / primitive obsession across boundaries / structural cleanup ask / measured perf / type-driven refactor; also named GoF / which-pattern asks. Ambiguous → prefer `design`.
   - **Plan inheritance:** prompt names a plan path and phase id → inherit its classification and architecture decisions; no second pass; axioms stay active.
   - **Gated:** `design` earned without inheritance → invoke `architecture` and document seam decisions in the plan or milestone ledger **before** writing code.
   - Packs may only append "also earn when…" lists. `review-hand-off` → stop → `review.gil`.
3. **Route by touched files** (not repo-wide presence); multi-load OK; validate per surface; clarify only when signals are absent or contradictory.

   | Touched                                                                   | Load                                |
   | ------------------------------------------------------------------------- | ----------------------------------- |
   | `.rb` / gem / plain Ruby                                                  | `ruby-dev` (+ `reference.md`)       |
   | Rails-shaped (controllers, policies, serializers, workers, migrations, …) | `ruby-dev` + `ruby-on-rails-dev`    |
   | `.rs`                                                                     | `rust-dev` (+ `reference.md`)       |
   | `.swift` (non-UI)                                                         | `swift-dev`                         |
   | SwiftUI / WidgetKit / AppKit UI                                           | `swift-dev` + `swiftui-dev`         |
   | `.ts` / `.tsx` / `.js` / `.jsx`                                           | `typescript-dev` (+ `reference.md`) |

4. Tests / dual paths / acceptance → load [`reference/surgical-laws.md`](reference/surgical-laws.md).
5. **Compat ask:** classify internal vs stable public. Possibly-breaking change to a stable surface with unclear permission → ask first. No silent shims, no silent breaks. Packs only name what counts as stable.
6. **No destructive git:** never `push --force`, hard reset, or other irreversible git unless explicitly asked.
7. Material API claim → load [`reference/api-truth.md`](reference/api-truth.md).
8. **Validation:** repo-native entrypoints, narrow → broad, per phase. Never claim green without an observed exit 0 for each cited command.
9. Committing → load [`reference/phase-commits.md`](reference/phase-commits.md).

## Branch reference

- **`plan`** — writes no code. Each todo names its exact repo-relative files, one gate copied from repo evidence (`AGENTS.md`, `Makefile`, CI; none trustworthy → halt and name the missing contract, never invent), and its Conventional Commit message. Embed [`../review.gil/reference/plan-checklists.md`](../review.gil/reference/plan-checklists.md) where signaled. Execute: [`reference/phase-commits.md`](reference/phase-commits.md).
- **`implement`** — Shared prep → classify (axioms; `architecture` if design) → load routed `{lang}-dev` (+ overlay, reference) → execute → post-delivery Assure → handoff.

## Handoff

Path: `$dev` ⇄ `architecture` → `review.gil` → `pull-request`; never reverse. Emit the **Delivery Ledger** at delivery and pass it to `review.gil`; state phase commits made or deferred.

**Delivery Ledger** (handoff DTO; `$dev` → `review.gil` → `pull-request` / `harvest`):

- `Classification / Branches`: `surgical` | `design` and active branches
- `Target Files`: exact paths matchable against `git diff --name-only <task_baseline>`
- `Verification`: command executed + exit 0 observed
- `Phase Commits`: hashes & rationale (or explicit deferral on default branch)
- `Active Lenses`: `security`, `tests`, `perf`, `legacy`
- `Readiness`: `Yes` | `No` | `Conditional`
- `Residuals / Debt`: deferred items or N/A

- `design` → `architecture` (branch pick inside), then continue implement here.
- **Post-delivery Assure** (every `implement` delivery), before reporting delivery:
  - Prefer a subagent running `review.gil` `findings` (+ warranted lenses; `security` when the cue matched) with the Delivery Ledger; reload in-session if no subagent (implementer self-check is not the review).
  - Trivial diff (docs-only, comment/typo, single-line config) may skip — state skip + reason; never silent.
  - `quality` only on explicit merge-prep / boy-scout ask or already-authorized P0/P1 fixes; never from bare "review".
  - Report delivery only after the pass returns. Land ask + readiness Yes/Conditional → `pull-request` `open`.
- Harvest → `harvest` (`distill` | `debt`) when pain repeats, a fix was non-obvious, or the user asked.
- Forward doc (post-Assure, Yes/Conditional): capture non-obvious maintenance in repo `AGENTS.md`; skip if self-documenting and say so.

## Completion criteria

| Branch      | Done when                                                                                                                                                                                                                                             |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `plan`      | Each todo names exact files, one discovered gate, and a Conventional Commit message; planning session wrote no code                                                                                                                                   |
| `implement` | Classification stated with axioms loaded (+ `architecture` decisions documented if design); compat decided or asked; pack/overlay handoff fields; exit-0 honesty; commits made or deferred; Assure done or trivial skip stated before delivery report |
