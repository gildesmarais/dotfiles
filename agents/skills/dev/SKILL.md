---
name: dev
description: >
  Build-domain router for implementation plans and code changes — classify,
  language/overlay route, phase commits, validation honesty, API truth.
  Use when the ask is implement, fix, feature, implementation plan, Cursor plan
  mode, surgical, or design-shaped coding work. Routes to {lang}-dev / overlays
  (multi-load from touched-file evidence); design → architecture; plan mode →
  reference/plan-pipeline.md quality gates; assure/ship → review.gil /
  pull-request. Never answers "should we build X?".
---

# Dev

Single Build entry (and Solution-touch for implementation plans). Language packs and overlays stay dedicated — load them; do not paste their bodies. Craft lives in `architecture`. Product scope stays in `product-owner`.

## Pick branch

Never ask the user to pick the branch when signals are clear.

| Branch      | When                                                                              | Job                                                                                                                                 |
| ----------- | --------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `plan`      | Writing / refining an implementation plan (Cursor plan mode or explicit plan ask) | Phase 0 Gate: `view_file` on [`reference/plan-pipeline.md`](reference/plan-pipeline.md) — **no code** until user approves           |
| `implement` | Default when coding                                                               | Shared prep → Classify (Shift-Left `architecture` if design) → load routed `{lang}-dev` (+ overlay & reference) → execute → handoff |

| Signal                                      | Branch                 |
| ------------------------------------------- | ---------------------- |
| implementation plan, plan mode, phased plan | `plan`                 |
| implement, fix, feature, change the code    | `implement`            |
| “should we build X?”                        | stop — `product-owner` |
| assure / finish / tests review / merge prep | stop — `review.gil`    |
| open / slice / comment a PR                 | stop — `pull-request`  |

## Shared prep

1. Read `AGENTS.md` when present; prefer repo law over defaults here.
2. Evidence before claims: `rg`, file reads, in-tree call sites. Label Strong / Worth / Speculative when surveying.
3. **Observability cue:** if the ask cites **APM / traces, error tracking, or logging** links/IDs (or equivalent incident signals), discover and use the **matching observability MCP** when available; fold findings into evidence before coding. Do not hardcode a vendor. Do not invent a full observability skill. If no observability MCP is available, say so and continue with ask text + codebase evidence. Vendor-specific tool recipes stay out of `$dev`.
4. **Security cue:** when the ask/change touches authn/authz, tenancy, PII/PHI, secrets, exports, webhooks, raw SQL, or privileged ops, prefer `review.gil` **`security`** on the post-delivery Assure pass (and co-load during implement when clearly needed). Dense Rails Security Trigger Matrix stays in the overlay / `AGENTS.md` — this cue is light only.
5. **Classify (Shift-Left Architecture Enforcement):** `surgical` | `design` | `review-hand-off`.
   - Earn `design` when any of the **core six**: dual ownership / shallow modules / primitive obsession across boundaries / structural cleanup ask / measured perf / type-driven refactor.
   - **Gated Rule:** When `design` is earned, DO NOT edit code immediately. You MUST invoke `architecture` (load its axioms and matched references) and document the structural/seam decisions in the plan or milestone ledger before writing code.
   - Language packs may append a short “also earn when…” list only — do not restate the core six there as a second SoT.
   - `review-hand-off` → stop and continue with `review.gil` (do not implement under this skill).
6. **Route runtime** (load dedicated skill(s) + references; do not paste bodies). Prefer **files the ask/change actually touches** — not repo-wide extension presence.

| Touched evidence                                                          | Load                                  |
| ------------------------------------------------------------------------- | ------------------------------------- |
| `.rb` / Ruby gem or plain Ruby                                            | `ruby-dev` (and `reference.md`)       |
| Rails-shaped (controllers, policies, serializers, workers, migrations, …) | `ruby-dev` + `ruby-on-rails-dev`      |
| `.rs`                                                                     | `rust-dev` (and `reference.md`)       |
| `.swift` (non-UI)                                                         | `swift-dev`                           |
| SwiftUI / WidgetKit / AppKit UI                                           | `swift-dev` + `swiftui-dev`           |
| `.ts` / `.tsx` / `.js` / `.jsx`                                           | `typescript-dev` (and `reference.md`) |

**Multi-load OK** when touched files span multiple rows — one phase plan may name several runtimes; validate per surface. Clarify only when file signals are absent or contradictory (or follow repo `AGENTS.md`).

7. Shared surgical laws: smallest safe change; preserve behavior unless intentional break; focused test when cheap; **one-surface** incident rule (drive-by edits on a second surface travel with the revert); no silent craft inline — when `design` is earned, load `architecture`.
8. **Compat ask:** detect internal-only vs stable public contract. If a break may hit a surface treated as stable and permission is unclear, **ask** before shipping. No silent shim theater; no silent breaks on stable surfaces. Packs may name what counts as stable in that ecosystem — not a second ask ritual.
9. **No destructive git:** never `push --force`, hard reset, or other irreversible git unless the user explicitly asks.
10. **API truth (all runtimes):** Do not invent stdlib/framework/crate APIs from memory when the claim is material. Ladder: repo docs + in-tree usage → **Dash MCP** `user-dash-api` → **Context7 if available** → language secondary from the routed pack → say unknown. **Dash recipe:** discover tools on `user-dash-api` first; if discovery fails, treat Dash as unavailable and continue the ladder — do not assume tool names. When tools are present: `search_documentation` (query + docset) → take `load_url` → `load_documentation_page`. Prefer human docset names from the routed pack; use listed IDs only if present. **Context7:** discover-if-present (same fallthrough honesty). **Warn once on the first material API fallthrough** in the session (when a material claim cannot be verified via repo docs, Dash, Context7, or another API-doc MCP) that providing an API-doc tool (Dash and/or Context7) makes agents much more efficient — then continue with repo docs + pack secondary + unknown honesty. Do **not** warn at `$dev` load. Do not repeat the warning in the same session. Do not silently invent APIs.
11. Validation law: repo-native entrypoints → narrow→broad → exit-0 honesty → validate per phase. Never claim green without observing exit status 0 for commands you cite.
12. **Phase commits:** detect the default branch early (from `AGENTS.md` / remote HEAD). **Not on the default branch:** after each plan phase or surgical milestone, validate → ≥1 Conventional Commit with rationale/intent body before the next phase (cite [`CONTEXT.md`](../CONTEXT.md)). **On the default branch:** ask the user early whether to author phase commits here or defer; do not silently commit on main/master. Format: [`CONTEXT.md`](../CONTEXT.md). Inspect `git log` / `git show` when needed. `release` **`notes`** consumes history later — do not defer authoring to notes. Overlays never duplicate this carrier. Handoff must state commits made or deferred.
13. Review routing: prefer `review.gil` **`tests`** / **`finish`** when that is the ask; Rails security matrix stays in the overlay / `AGENTS.md`.

## Branch reference

- **`plan`** — Phase 0 Gate: Execute `view_file` on [`reference/plan-pipeline.md`](reference/plan-pipeline.md) first; satisfy its ready checklist before any code is generated.
- **`implement`** — Shared prep → Classify (Shift-Left `architecture` if design) → load routed `{lang}-dev` (+ overlay & reference) → execute surgical or post-`architecture` decisions with language validation → post-delivery Assure → handoff.

## Handoff

- `design` → `architecture` (branch pick inside); then continue implement via this skill → routed `{lang}-dev` / overlay.
- **Post-delivery Assure** (plan-driven `implement`, or work that followed `$dev` `plan`): before reporting delivery to the user, prefer spawning a **new agent** that runs `review.gil` (default: **`findings`** / finish + warranted lenses; include **`security`** when the Shared prep security cue matched). Invoke **`quality`** when in scope: explicit merge-prep / boy-scout ask, or findings show clear fixable P0/P1 the user already authorized to change — never infer `quality` from bare “review.” **Fallback:** if Task/subagent is unavailable, run `review.gil` as a fresh in-session pass (reload skill; do not treat implementer self-check as the review). Report delivery only after that pass returns. Do not claim ship-ready without it.
- Assure / ship → `review.gil` / `pull-request` — never reverse.
- Product scope → `product-owner`. Never answer “should we build X?” here.
- Harvest: only when pain appears twice or the user asked — stage → promote/drop per `architecture/reference/growth.md` (or lang `reference.md` for language-only). Not an append-forever log. No `$dev` harvest theater on every implement.
- Phase commits: state commits made or deferred (especially when work started on the default branch).

## Completion criteria

| Branch      | Done when                                                                                                                                                                                                                                                                                                                                                  |
| ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `plan`      | [`reference/plan-pipeline.md`](reference/plan-pipeline.md) ready checklist satisfied; no code written before plan approval                                                                                                                                                                                                                                 |
| `implement` | Classification stated; shift-left architecture documented if design earned; compat decision stated or user was asked; routed lang pack (+ overlay) handoff fields satisfied; commands + exit honesty; phase commits made or deferred stated; post-delivery Assure (`review.gil`) completed (spawn preferred, else fresh in-session) before delivery report |
