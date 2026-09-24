---
name: swiftui-dev
description: >-
  SwiftUI overlay loaded by $dev with swift-dev (deltas only): views,
  navigation, WidgetKit, and AppKit bridges.
---

# SwiftUI Dev

**Stop:** read `$dev` Shared prep before any delta. Loaded with `swift-dev`; design or private-seam cases → `$dev` → `architecture`.

Scope: views, navigation, layout, WidgetKit, AppKit bridges, Transferable, presentation/chrome. Optional packs by name when installed (never inline their checklists): `swiftui-pro` (review depth), `swiftui-design-principles` (spacing, typography, materials); testing depth → `swift-testing-pro` via `swift-dev`.

## Implementation deltas

- System controls, materials, semantic colors over custom chrome; native navigation (`NavigationStack` / `NavigationSplitView`) over bespoke shells.
- Stay in SwiftUI until AppKit/UIKit is earned by a concrete gap. Ask before adding third-party UI kits.
- Thin view bodies: local presentation state; domain logic and orchestration outside views.
- Interactive surfaces ship focus, labels, and keyboard shortcuts with the interaction.
- `NSViewRepresentable`/`UIViewRepresentable`: track focus via coordinator `lastFocusedField`; never spoof prior focus from native first-responder state.
- Outbound data mirroring stays unidirectional: no `.onChange` on properties updated by outbound text flushes.
- Model persistence through one non-reentrant trigger, not stacked parallel `.onChange` modifiers.

## Handoff deltas

UI-layer impact, AppKit bridge touch, optional-pack invocation status, validation gaps.
