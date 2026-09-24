---
name: dev
description: >-
  Build-domain router for implementation plans and code changes: classify, route
  language packs and overlays, phase commits, validation, API truth. Use for
  implement, fix, feature, change the code, implementation plan, Cursor plan
  mode, phased plan, surgical or design-shaped coding; also optimize, hot path,
  throughput, latency, allocate, profile, benchmark, Apple Silicon / SIMD as
  coding work.
---

# Dev

Single Build entry. Load packs/overlays by name; never paste their bodies. Craft lives in `architecture`; product scope in `product-owner`. Repo `AGENTS.md` overrides the defaults here.

## Pick branch

Never ask the user to pick when signals are clear.

| Signal                                             | Branch                                                                                                        |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| implementation plan, plan mode, phased plan        | `plan` — load [`reference/plan-pipeline.md`](reference/plan-pipeline.md); the planning session writes no code |
| implement, fix, feature, change the code (default) | `implement`                                                                                                   |
| "should we build X?"                               | stop → `product-owner`                                                                                        |
| assure / findings / tests review / merge prep      | stop → `review.gil`                                                                                           |
| open / slice / comment a PR                        | stop → `pull-request`                                                                                         |

## Shared prep

1. Read `AGENTS.md`. Label survey claims Strong / Worth / Speculative.
2. **Observability cue:** APM / trace / error-tracking / log links or IDs → discover and use the matching observability MCP; fold findings into evidence before coding. No vendor hardcode or vendor recipes here. If none is available, say so and continue from ask + code.
3. **Security cue:** authn/authz, tenancy, PII/PHI, secrets, exports, webhooks, raw SQL, privileged ops → `review.gil` `security` on Assure; co-load during implement when clearly needed. The Rails matrix stays in the overlay / `AGENTS.md`.
4. **Classify:** `surgical` | `design` | `review-hand-off`.
   - Load [`architecture/reference/axioms.md`](../architecture/reference/axioms.md) on **every** `implement`, surgical included. Load `architecture` `SKILL.md` + matched references only when `design` is earned.
   - Earn `design` on the core six: dual ownership / shallow modules / primitive obsession across boundaries / structural cleanup ask / measured perf / type-driven refactor; also named GoF / which-pattern asks (`design-patterns`). Ambiguous → prefer `design`.
   - **Approved-plan inheritance:** executing from `.agents/plan/<slug>.md` that records a completed architecture pass or declares `orchestrated: true` → inherit its decisions; don't re-run an interactive pass; axioms stay active.
   - **Gated:** `design` earned without inheritance → invoke `architecture` and document seam decisions in the plan or milestone ledger **before** writing code.
   - Packs may only append "also earn when…" lists.
   - `review-hand-off` → stop → `review.gil`.
5. **Route by touched files** (not repo-wide presence); multi-load OK; validate per surface; clarify only when signals are absent or contradictory.

   | Touched                                                                   | Load                                |
   | ------------------------------------------------------------------------- | ----------------------------------- |
   | `.rb` / gem / plain Ruby                                                  | `ruby-dev` (+ `reference.md`)       |
   | Rails-shaped (controllers, policies, serializers, workers, migrations, …) | `ruby-dev` + `ruby-on-rails-dev`    |
   | `.rs`                                                                     | `rust-dev` (+ `reference.md`)       |
   | `.swift` (non-UI)                                                         | `swift-dev`                         |
   | SwiftUI / WidgetKit / AppKit UI                                           | `swift-dev` + `swiftui-dev`         |
   | `.ts` / `.tsx` / `.js` / `.jsx`                                           | `typescript-dev` (+ `reference.md`) |

6. **Surgical laws:**
   - Test flight height: pure unit for domain/math, focused fakes for components, real I/O for integration; frontend: real DOM/a11y via `modern-web-guidance` and `chrome-devtools` over mocks. Decompose suites by layer. No ad-hoc sleep polling — bounded condition waits. Test friction diagnoses a seam defect.
   - Introducing or widening a dual delivery path for one derived fact → discriminating parity (or failure-matrix) test before cutover.
   - Acceptance names observable outcomes, not internal field inventories.
   - One-surface incident rule: drive-by edits on a second surface travel with the revert.
7. **Compat ask:** classify internal vs stable public. Possibly-breaking change to a stable surface with unclear permission → ask first. No silent shims, no silent breaks. Packs only name what counts as stable.
8. **No destructive git:** never `push --force`, hard reset, or other irreversible git unless explicitly asked.
9. **API truth** (material claims): repo docs + in-tree usage → Dash → Context7 → routed pack secondary → say unknown.
   - Dash: discover tools on `dash-api` / `user-dash-api` first; discovery fails → Dash unavailable, continue. Recipe: `search_documentation` (query + docset) → take `load_url` → `load_documentation_page`. Prefer the pack's human docset names; listed IDs only if present.
   - Context7: discover-if-present, same fallthrough honesty.
   - On the **first** material fallthrough in the session, warn once that an API-doc tool (Dash and/or Context7) makes agents much more efficient. Not at load; never repeated.
10. **Validation:** repo-native entrypoints, narrow → broad, per phase. Never claim green without an observed exit 0 for each cited command.
11. **Phase commits:** detect the default branch early (`AGENTS.md` / remote HEAD).
    - Off default: after each plan phase or surgical milestone, validate → ≥1 Conventional Commit with a rationale body before the next. Format: [`CONTEXT.md`](../CONTEXT.md) (absent → conventionalcommits.org v1.0.0).
    - On default: commit only when the pipeline batch already said so. The batch has not run → ask once there, not mid-phase. Never silently commit on main/master.
    - `release` `notes` consumes history later — don't defer authoring. Overlays never restate this.

## Branch reference

- **`plan`** — load [`reference/plan-pipeline.md`](reference/plan-pipeline.md) first; satisfy its ready checklist before any code.
- **`implement`** — Shared prep → classify (axioms; `architecture` if design) → load routed `{lang}-dev` (+ overlay, reference) → execute → post-delivery Assure → handoff.

## Handoff

Path: `$dev` ⇄ `architecture` → `review.gil` → `pull-request`; never reverse. Emit the **Delivery Ledger** ([`CONTEXT.md`](../CONTEXT.md)) at delivery and pass it to `review.gil`; state phase commits made or deferred.

- `design` → `architecture` (branch pick inside), then continue implement here.
- **Post-delivery Assure** (every `implement` delivery, plan-driven or surgical), before reporting delivery:
  - Prefer spawning a new agent running `review.gil` `findings` (+ warranted lenses; `security` when the cue matched) with the Delivery Ledger.
  - Small single-surface surgical → fresh in-session pass OK; spawn preferred for plan-driven, multi-phase, or security-cue work.
  - Trivial diff (docs-only, comment/typo, single-line config) may skip — state skip + reason; never silent.
  - `orchestrated: true` → emit the ledger, skip `findings` (orchestrator runs one DAG-level pass).
  - `quality` only on explicit merge-prep / boy-scout ask or already-authorized P0/P1 fixes; never from bare "review".
  - No subagent → fresh in-session pass (reload the skill; implementer self-check is not the review).
  - Report delivery only after the pass returns; no ship-ready claim without it. Land ask + readiness Yes/Conditional → `pull-request` `open`.
- Harvest → `harvest` (`distill` mantras | `debt` → `.agents/debt-ledger.md`) when pain repeats, a fix was non-obvious, or the user asked — not on every implement.
- Forward doc (post-Assure, Yes/Conditional): capture non-obvious maintenance in repo `AGENTS.md`; skip if self-documenting and say so.

## Completion criteria

| Branch      | Done when                                                                                                                                                                                                                                             |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `plan`      | Ready checklist satisfied; planning session wrote no code; delivery offer shown, or skipped because the runner was already named                                                                                                                      |
| `implement` | Classification stated with axioms loaded (+ `architecture` decisions documented if design); compat decided or asked; pack/overlay handoff fields; exit-0 honesty; commits made or deferred; Assure done or trivial skip stated before delivery report |
