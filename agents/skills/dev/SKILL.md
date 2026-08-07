---
name: dev
description: >
  Build-domain router for implementation plans and code changes — classify,
  language/overlay route, phase commits, validation honesty. Use when the ask
  is implement, fix, feature, implementation plan, surgical, or design-shaped
  coding work. Routes to {lang}-dev / overlays; design → architecture;
  assure/ship → review.gil / pull-request. Never answers "should we build X?".
---

# Dev

Single Build entry (and Solution-touch for implementation plans). Language packs and overlays stay dedicated — load them; do not paste their bodies. Craft lives in `architecture`. Product scope stays in `product-owner`.

## Pick branch

Never ask the user to pick the branch when signals are clear.

| Branch      | When                                                                              | Job                                                                                                                                                                     |
| ----------- | --------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `plan`      | Writing / refining an implementation plan (Cursor plan mode or explicit plan ask) | Classify; route runtime + overlay; name architecture branches if `design`; emit phased plan with validate→commit per phase — no code unless user already approved build |
| `implement` | Default when coding                                                               | Shared prep → load routed `{lang}-dev` (+ overlay) → surgical or post-architecture execute → handoff                                                                    |

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
3. **Classify:** `surgical` | `design` | `review-hand-off`.
   - Earn `design` when any of the **core six**: dual ownership / shallow modules / primitive obsession across boundaries / structural cleanup ask / measured perf / type-driven refactor.
   - Language packs may append a short “also earn when…” list only — do not restate the core six there as a second SoT.
   - `review-hand-off` → stop and continue with `review.gil` (do not implement under this skill).
4. **Route runtime** (load the dedicated skill; do not paste its body):

| Signal                          | Load                                         |
| ------------------------------- | -------------------------------------------- |
| Ruby (non-Rails)                | `ruby-dev`                                   |
| Rails-shaped                    | `ruby-dev` + `ruby-on-rails-dev`             |
| Rust                            | `rust-dev`                                   |
| Swift (non-UI)                  | `swift-dev`                                  |
| SwiftUI / WidgetKit / AppKit UI | `swift-dev` + `swiftui-dev`                  |
| TypeScript / JavaScript         | `typescript-dev`                             |
| Mixed / unclear                 | one clarifying question, or repo `AGENTS.md` |

5. Shared surgical laws: smallest safe change; preserve behavior unless intentional break; focused test when cheap; **one-surface** incident rule (drive-by edits on a second surface travel with the revert); no silent craft inline — when `design` is earned, load `architecture`.
6. **API truth (all runtimes):** Do not invent stdlib/framework/crate APIs from memory when the claim is material. Ladder: repo docs + in-tree usage → **Dash MCP** `user-dash-api` → language secondary from the routed pack → say unknown. Recipe: discover tools on `user-dash-api` → `search_documentation` (query + docset) → take `load_url` → `load_documentation_page`. Prefer human docset names from the routed pack; use listed IDs only if present. If MCP errors, say so and fall back — do not hedge packs with “when available”.
7. Validation law: repo-native entrypoints → narrow→broad → exit-0 honesty → validate per phase. Never claim green without observing exit status 0 for commands you cite.
8. **Phase commits:** after each plan phase or surgical milestone, validate → ≥1 Conventional Commit with rationale/intent body before the next phase. Format: [`CONTEXT.md`](../CONTEXT.md). Inspect `git log` / `git show` when needed. `release` **`notes`** consumes history later — do not defer authoring to notes. Overlays never duplicate this carrier.
9. Review routing: prefer `review.gil` **`tests`** / **`finish`** when that is the ask; Rails security matrix stays in the overlay / `AGENTS.md`.

## Branch reference

- **`plan`** — Shared prep through route + classify; emit ordered phases each ending validate→commit (cite [`CONTEXT.md`](../CONTEXT.md)); list validation entrypoints from the routed lang pack; residual risk. No code unless build already approved.
- **`implement`** — Shared prep → load routed `{lang}-dev` (+ overlay) → execute surgical or post-`architecture` decisions with language validation → handoff.

## Handoff

- `design` → `architecture` (branch pick inside); then continue implement via this skill → routed `{lang}-dev` / overlay.
- Assure / ship → `review.gil` / `pull-request` — never reverse.
- Product scope → `product-owner`. Never answer “should we build X?” here.
- Harvest note: stage → promote/drop per `architecture/reference/growth.md` (or lang `reference.md` for language-only) — not an append-forever log.

## Completion criteria

| Branch      | Done when                                                                                                                                                  |
| ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `plan`      | Classification stated; runtime (+ overlay) named; architecture branches named or N/A; ordered phases each ending validate→commit; residual risk called out |
| `implement` | Classification stated; routed lang pack (+ overlay) handoff fields satisfied; commands + exit honesty; harvest note (stage→promote/drop)                   |
