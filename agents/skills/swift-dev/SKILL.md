---
name: swift-dev
description: >-
  Swift deltas loaded by $dev (load $dev first; not a Build entry):
  MainActor/@Observable, Apple docsets, Swift Testing hygiene, UI overlay
  compose; after a measured-perf handoff, ARC/QoS and Metal / Accelerate / ANE
  recipes.
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
- Never nest `#require` inside `#require` (e.g. `try #require(HTTPURLResponse(url: #require(...)))`); unwrap on separate lines — nested expansion fails to compile.
- Entrypoints: `xcodebuild`, `swift test`, project wrappers, Make targets.
- Apple runtime postures (concurrency/TLS hardening, text storage): [`reference.md`](reference.md).

## Performance & allocation hygiene

Hot path → `$dev` `design` → `architecture` `performance` first; these recipes apply after its stop rules. Depth: [`reference.md`](reference.md).

- Value types / `final` / `@frozen` to cut ARC and witness traffic; `Unsafe*` only on a profiled loop.
- No string formatting, regex, or allocating computed properties inside `==` or other hot equality/diff paths; compare integers, enums, bitmasks, contiguous storage.
- Apple Silicon: design shared-memory stages (CPU ↔ GPU ↔ ANE) before copies; pick Accelerate/AMX vs Metal vs Core ML by workload shape.
- Structured concurrency with correct QoS (compute on performance intent, background I/O on utility/background) — wrong QoS is a throughput bug.
- Verify with Instruments (Time Profiler, Allocations, Metal System Trace): ARC retain/release, P vs E residency, GPU timelines.

## Compose routes

- UI → `swiftui-dev` (with this pack).
- Swift Testing depth → `swift-testing-pro` when installed.
- On-device AI → `apple-on-device-ai` when present.
- Product overlays (e.g. `prestage-*`) when present in the repo.
