---
name: swiftui-dev
description: >-
  Always load $dev first (with $swift-dev); this overlay is deltas only. SwiftUI
  overlay for views, navigation, WidgetKit, and AppKit bridges — native
  UI-shaped Swift work.
---

# SwiftUI Dev

**Stop:** read `$dev` Shared prep before any delta.

## Purpose and Routing

- Overlay loaded via `$dev` with `$swift-dev`; keep Swift-general workflow in `$swift-dev` and shared classify / one-surface / design / API truth / compat / git safety in `$dev`.
- Apply to views, navigation, layout, WidgetKit, AppKit bridges, Transferable, and presentation/chrome.
- Follow `AGENTS.md` routing and precedence.
- Design or private-seam cases → `$dev` → `$swift-dev` → `architecture`. Do not invent adapter craft here.
- For review or design depth, compose optional packs by **name** when installed (do not inline their checklists):
  - `swiftui-pro` — SwiftUI review depth
  - `swiftui-design-principles` — spacing, typography, materials
- Testing depth stays on `$swift-dev` (`swift-testing-pro`).

## Implementation Deltas

- Prefer system controls, materials, and semantic colors over custom chrome.
- Stay in SwiftUI until AppKit (or UIKit) is earned by a concrete gap.
- Do not add third-party UI kits without asking.
- Keep view bodies thin: own presentation state locally; push domain logic and orchestration out of views.
- Prefer native navigation (`NavigationStack` / `NavigationSplitView`) and platform idioms over bespoke shells.
- For interactive surfaces, ship focus, labels, and keyboard shortcuts with the interaction.

## Tooling and Completion

- Validate with the repo-native UI/target commands already preferred by `$swift-dev` (documented Make / `xcodebuild` / previews).
- In handoff, include: UI-layer impact, any AppKit bridge touch, optional-pack invocation status, and validation gaps.
