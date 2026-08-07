---
name: swift-dev
description: >-
  Always load $dev first; this pack is deltas only. Language-runtime adapter
  loaded by $dev — not the Build entry. Use when $dev routed here or the user
  names this skill with $dev already loaded. Swift deltas: MainActor/@Observable,
  Apple docset cues, UI overlay compose.
---

# Swift Dev

**Stop:** read `$dev` Shared prep before any delta.

Follow `$dev` for classify, shared stance, API truth / Dash recipe, compat ask, no-destructive git, workflow/plan, validation law, phase commits, and handoff skeleton. This pack adds Swift deltas only. Craft (modules, types, measured perf) lives in `architecture` — do not inline it here.

## When to use

- Loaded by `$dev` for Swift packages, libraries, CLI, and app targets; load `swiftui-dev` **with** this skill when the change is UI-shaped (views, navigation, WidgetKit, AppKit bridges, Transferable, layout).
- Explicit `@swift-dev` / `$swift-dev` compose when `$dev` is already loaded.
- Compose sibling guideline or domain skills when they apply; never paste their contents into this workflow.

## Docsets

- Prefer Dash docsets: **Swift**, **Objective-C** (optional IDs if present: `qsucmuuh-swift`, `qsucmuuh-objc`). Secondary: Apple docs.

## Stable-surface hints

- Treat Apple public APIs and shipped module public interfaces as stable unless the ask or `AGENTS.md` says otherwise.

## Stance deltas

- Observation / concurrency: prefer `@Observable` over Combine when the repo allows it; keep MainActor and background-boundary honesty. Project rules live in `AGENTS.md` and local overlays — compose them; do not paste them here.
- Evidence: touched modules, public contracts, real call sites, existing tests, compat posture (ask via `$dev` if unclear).

## Surgical posture

- Preserve behavior unless the ask is an intentional break and compat allows it.
- Add or tighten a focused test when the failure can be expressed cheaply.
- Validate with the narrowest repo-native command that covers the change.
- If the failing path is UI-shaped, load `swiftui-dev` and apply its deltas in the same change rather than inventing a language-only clamp.

## Tooling

- Use repo-native entrypoints (`xcodebuild`, `swift test`, project wrappers, Make targets). Prefer a ready, documented target over inventing one-off commands.
- Start narrow (touched target/module/tests), then broaden when the change crosses seams.

## Contracts

- Preserve existing repo conventions for contracts and docs.
- Do not invent a new global docs regime.
- If a touched public API already has docs or contract comments, keep them accurate in scope.

## Compose routes

Pointers only — load when present; do not paste their bodies here:

- UI-shaped work → `swiftui-dev` (with this skill; via `$dev` route).
- Swift Testing depth → `swift-testing-pro` when installed.
- On-device AI → `apple-on-device-ai` when that pack exists.
- Product overlays (e.g. `prestage-*`) when present in the repo.

## Handoff deltas

Before handoff (on top of `$dev` skeleton), confirm:

- Residual risk, unverified paths, and intentional out-of-scope work called out.
