---
name: swift-dev
description: >-
  Swift workflow for surgical fixes and design handoffs. Use when Swift work needs
  evidence-first investigation, repo-native validation, and clear routing to
  architecture on design or to review on assure/ship asks.
---

# Swift Dev

Language-runtime adapter for Swift. Craft (modules, types, measured perf) lives in `architecture` — do not inline it here.

## When to use

- Default for Swift packages, libraries, CLI, and app targets; load `swiftui-dev` **with** this skill when the change is UI-shaped (views, navigation, WidgetKit, AppKit bridges, Transferable, layout).
- Use for Swift implementation work: surgical fixes and small feature adjustments.
- Read `AGENTS.md` first when present. Compose sibling guideline or domain skills when they apply; never paste their contents into this workflow.
- Prefer `review` **`tests`** when the user mainly wants test/spec review quality.
- Prefer `review` **`finish`** when the user wants end-of-branch production-readiness review.
- Prefer `architecture` when design/structure/types/measured perf is the job (or when classification is `design`).

## Classify

| Class             | Action                                                        |
| ----------------- | ------------------------------------------------------------- |
| `surgical`        | Stay here; smallest safe change; language validation          |
| `design`          | Load `architecture`; do not inline craft advice in this skill |
| `review-hand-off` | Route to `review`                                             |

Earn `design` when any of: dual ownership / shallow modules / primitive obsession across boundaries / user asks for structural cleanup / measured perf work / type-driven refactor.

## Stance

- Evidence before claims. Prefer `rg`, file reads, and in-tree call sites over guesswork. When surveying, label findings Strong / Worth / Speculative.
- API truth: prefer Dash MCP (`user-dash-api`) and Apple docs over memory. Say when unknown; do not invent Apple APIs.
  - Docsets: Swift `qsucmuuh-swift`; Objective-C `qsucmuuh-objc`.
  - Lookup: `search_documentation` (query + docset) → take `load_url` → `load_documentation_page`.
- Observation / concurrency: prefer `@Observable` over Combine when the repo allows it; keep MainActor and background-boundary honesty. Project rules live in `AGENTS.md` and local overlays — compose them; do not paste them here.
- Prefer simple, forward, clean diffs. Default to surgical unless design is earned.

## Workflow

1. Classify: `surgical` | `design` | `review-hand-off`.
2. Evidence first: touched modules, public contracts, real call sites, existing tests, compat posture (ask if unclear).
3. Branch:
   - **Surgical:** smallest safe change → validate → handoff.
   - **Design:** load `architecture` (branch pick inside) → implement decisions here with Swift validation → handoff.
   - **Review-hand-off:** stop and continue with `review`.
4. Handoff: commands run, residual risk, whether architecture harvest should run (stage → promote/drop per architecture protocol — not a permanent learning-log store).

## Surgical path

- Change only what the bug or ask requires.
- Preserve behavior unless the ask is an intentional break and compat allows it.
- Add or tighten a focused test when the failure can be expressed cheaply.
- Validate with the narrowest repo-native command that covers the change.
- If the failing path is UI-shaped, load `swiftui-dev` and apply its deltas in the same change rather than inventing a language-only clamp.

## Validation Defaults

- Use repo-native entrypoints (`xcodebuild`, `swift test`, project wrappers, Make targets). Prefer a ready, documented target over inventing one-off commands.
- Start narrow (touched target/module/tests), then broaden when the change crosses seams.
- Never claim green without observing exit status 0 for the commands you cite.
- For design phases: validate after each phase before starting the next.

## Contracts and Documentation

- Preserve existing repo conventions for contracts and docs.
- Do not invent a new global docs regime.
- If a touched public API already has docs or contract comments, keep them accurate in scope.
- **Phase commits:** after each plan phase or surgical milestone, validate → ≥1 Conventional Commit with rationale/intent body before the next phase. Format: [`CONTEXT.md`](../CONTEXT.md). Inspect `git log` / `git show` when needed. `release` **`notes`** consumes history later — do not defer authoring to notes.

## Compose routes

Pointers only — load when present; do not paste their bodies here:

- UI-shaped work → `swiftui-dev` (with this skill).
- Swift Testing depth → `swift-testing-pro` when installed; otherwise the repo’s Testing pack name (e.g. `swift-testing-expert`).
- On-device AI → `apple-on-device-ai` when that pack exists.
- Product overlays (e.g. `prestage-*`) when present in the repo.

## Handoff Checklist

Before handoff, confirm:

- Classification stated (`surgical` / `design` / `review-hand-off`).
- For `design`: which `architecture` branches were loaded.
- Commands run listed with scope and pass/fail (exit 0 only when claiming pass).
- Compat decision stated, or that the user was asked.
- Residual risk, unverified paths, and intentional out-of-scope work called out.
