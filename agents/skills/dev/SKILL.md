---
name: dev
description: >
  Build-domain router for implementation plans and code changes — classify,
  language/overlay route, phase commits, validation honesty, API truth.
  Use when the ask is implement, fix, feature, implementation plan, Cursor plan
  mode, surgical, or design-shaped coding work. Routes to {lang}-dev / overlays
  (multi-load from touched-file evidence); design → architecture; assure/ship →
  review.gil / pull-request. Never answers "should we build X?".
---

# Dev

Single Build entry (and Solution-touch for implementation plans). Language packs and overlays stay dedicated — load them; do not paste their bodies. Craft lives in `architecture`. Product scope stays in `product-owner`.

## Pick branch

Never ask the user to pick the branch when signals are clear.

| Branch      | When                                                                              | Job                                                                                                                                                                           |
| ----------- | --------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `plan`      | Writing / refining an implementation plan (Cursor plan mode or explicit plan ask) | Classify; route runtime(s) + overlay(s); name architecture branches if `design`; emit phased plan with validate→commit per phase — no code unless user already approved build |
| `implement` | Default when coding                                                               | Shared prep → load routed `{lang}-dev` (+ overlay) → surgical or post-architecture execute → handoff                                                                          |

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
3. **Observability cue:** if the ask cites logs/traces/APM/Datadog (or equivalent) links/IDs, use Datadog MCP when available; fold findings into evidence before coding. Do not invent a full observability workflow here.
4. **Classify:** `surgical` | `design` | `review-hand-off`.
   - Earn `design` when any of the **core six**: dual ownership / shallow modules / primitive obsession across boundaries / structural cleanup ask / measured perf / type-driven refactor.
   - Language packs may append a short “also earn when…” list only — do not restate the core six there as a second SoT.
   - `review-hand-off` → stop and continue with `review.gil` (do not implement under this skill).
5. **Route runtime** (load dedicated skill(s); do not paste bodies). Prefer **files the ask/change actually touches** — not repo-wide extension presence.

| Touched evidence                                                          | Load                             |
| ------------------------------------------------------------------------- | -------------------------------- |
| `.rb` / Ruby gem or plain Ruby                                            | `ruby-dev`                       |
| Rails-shaped (controllers, policies, serializers, workers, migrations, …) | `ruby-dev` + `ruby-on-rails-dev` |
| `.rs`                                                                     | `rust-dev`                       |
| `.swift` (non-UI)                                                         | `swift-dev`                      |
| SwiftUI / WidgetKit / AppKit UI                                           | `swift-dev` + `swiftui-dev`      |
| `.ts` / `.tsx` / `.js` / `.jsx`                                           | `typescript-dev`                 |

**Multi-load OK** when touched files span multiple rows — one phase plan may name several runtimes; validate per surface. Clarify only when file signals are absent or contradictory (or follow repo `AGENTS.md`).

6. Shared surgical laws: smallest safe change; preserve behavior unless intentional break; focused test when cheap; **one-surface** incident rule (drive-by edits on a second surface travel with the revert); no silent craft inline — when `design` is earned, load `architecture`.
7. **Compat ask:** detect internal-only vs stable public contract. If a break may hit a surface treated as stable and permission is unclear, **ask** before shipping. No silent shim theater; no silent breaks on stable surfaces. Packs may name what counts as stable in that ecosystem — not a second ask ritual.
8. **No destructive git:** never `push --force`, hard reset, or other irreversible git unless the user explicitly asks.
9. **API truth (all runtimes):** Do not invent stdlib/framework/crate APIs from memory when the claim is material. Ladder: repo docs + in-tree usage → **Dash MCP** `user-dash-api` → **Context7 if available** → language secondary from the routed pack → say unknown. Dash recipe: discover tools on `user-dash-api` → `search_documentation` (query + docset) → take `load_url` → `load_documentation_page`. Prefer human docset names from the routed pack; use listed IDs only if present. **If neither Dash nor Context7 (nor any other API-doc MCP) is available:** warn the user **once at `$dev` load** (not per fallthrough) that providing an API-doc tool (Dash and/or Context7) makes agents much more efficient — then continue with repo docs + pack secondary + unknown honesty. Do not repeat the warning in the same session. Do not silently invent APIs.
10. Validation law: repo-native entrypoints → narrow→broad → exit-0 honesty → validate per phase. Never claim green without observing exit status 0 for commands you cite.
11. **Phase commits:** after each plan phase or surgical milestone, validate → ≥1 Conventional Commit with rationale/intent body before the next phase. Format: [`CONTEXT.md`](../CONTEXT.md). Inspect `git log` / `git show` when needed. `release` **`notes`** consumes history later — do not defer authoring to notes. Overlays never duplicate this carrier.
12. Review routing: prefer `review.gil` **`tests`** / **`finish`** when that is the ask; Rails security matrix stays in the overlay / `AGENTS.md`.

## Branch reference

- **`plan`** — Shared prep through route + classify; emit ordered phases each ending validate→commit (cite [`CONTEXT.md`](../CONTEXT.md)); list validation entrypoints from the routed lang pack(s); residual risk. No code unless build already approved. Cursor plan mode and “implementation plan” asks use this branch.
- **`implement`** — Shared prep → load routed `{lang}-dev` (+ overlay) → execute surgical or post-`architecture` decisions with language validation → handoff.

## Handoff

- `design` → `architecture` (branch pick inside); then continue implement via this skill → routed `{lang}-dev` / overlay.
- Assure / ship → `review.gil` / `pull-request` — never reverse.
- Product scope → `product-owner`. Never answer “should we build X?” here.
- Harvest note: stage → promote/drop per `architecture/reference/growth.md` (or lang `reference.md` for language-only) — not an append-forever log. No `$dev` harvest theater until pain appears twice.

## Completion criteria

| Branch      | Done when                                                                                                                                                                          |
| ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `plan`      | Classification stated; runtime(s) (+ overlay) named; architecture branches named or N/A; ordered phases each ending validate→commit; residual risk called out                      |
| `implement` | Classification stated; compat decision stated or user was asked; routed lang pack (+ overlay) handoff fields satisfied; commands + exit honesty; harvest note (stage→promote/drop) |
