---
name: swift-dev
description: >-
  Swift deltas: MainActor/@Observable, Apple docsets, Swift Testing, UI overlay.
  Perf recipes in reference.md.
disable-model-invocation: true
---

# Swift Dev

**Stop:** apply `$dev` Shared prep first; skip if already read. Craft lives in `architecture`; compose sibling skills by name, never paste them.

## Docsets

Dash: **Swift**, **Objective-C**, Apple API Reference as installed. Secondary: Apple docs.

## Stable surfaces

Apple public APIs and shipped module public interfaces — unless the ask or `AGENTS.md` says otherwise.

## Deltas

- `@Observable` over Combine; Swift 6 mode with strict concurrency unless the repo pins otherwise; honest MainActor/background boundaries.
- UI-shaped (views, navigation, WidgetKit, AppKit bridges, Transferable, layout) → load `swiftui-dev` in the same change.
- Never nest `#require` inside `#require`; unwrap on separate lines — nested expansion fails to compile.
- Entrypoints: `xcodebuild`, `swift test`, project wrappers, Make targets.
- Foreign-exception / TLS / text-storage hardening: [`reference.md`](reference.md).

## Performance & allocation hygiene

Hot path → `$dev` `design` → `architecture` `performance` first; recipes after its stop rules: [`reference.md`](reference.md).

## Compose routes

- UI → `swiftui-dev` (with this pack).
- Swift Testing depth → `swift-testing-pro` when installed.
- On-device AI → `apple-on-device-ai` when present.
- Repo product overlays (e.g. `prestage-*`) when present.
