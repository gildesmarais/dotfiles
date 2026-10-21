---
name: swift-dev
description: >-
  Swift deltas: MainActor/@Observable, Apple docsets, Swift Testing, UI overlay.
  Perf recipes in reference.md.
disable-model-invocation: true
---

# Swift Dev

**Stop:** read `$dev` Shared prep before any delta. Craft lives in `architecture`; compose sibling skills by name, never paste them.

## Docsets

Dash: **Swift**, **Objective-C** (IDs if present: `qsucmuuh-swift`, `qsucmuuh-objc`). Secondary: Apple docs.

## Stable surfaces

Apple public APIs and shipped module public interfaces — unless the ask or `AGENTS.md` says otherwise.

## Deltas

- Prefer `@Observable` over Combine when the repo allows; keep MainActor and background-boundary honesty. Project rules stay in `AGENTS.md` / overlays.
- UI-shaped (views, navigation, WidgetKit, AppKit bridges, Transferable, layout) → load `swiftui-dev` in the same change.
- Never nest `#require` inside `#require`; unwrap on separate lines — nested expansion fails to compile.
- Entrypoints: `xcodebuild`, `swift test`, project wrappers, Make targets.
- Apple runtime postures (concurrency/TLS hardening, text storage): [`reference.md`](reference.md).

## Performance & allocation hygiene

Hot path → `$dev` `design` → `architecture` `performance` first; recipes after its stop rules: [`reference.md`](reference.md).

## Compose routes

- UI → `swiftui-dev` (with this pack).
- Swift Testing depth → `swift-testing-pro` when installed.
- On-device AI → `apple-on-device-ai` when present.
- Product overlays (e.g. `prestage-*`) when present in the repo.
