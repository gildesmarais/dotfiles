---
name: product-owner
description: >-
  Admit, defer, or reject product scope; slice stories; admit debt tranches; re-
  baseline doctrine. Use for feature proposals, scope debates, UI/API
  expansion, or "should we build X?".
---

# Product Owner

Gate vocabulary and doctrine (overrides enthusiasm): [`reference/gate.md`](reference/gate.md).

## Pick branch

Default **`gate`**.

| Branch        | Signals                                                                                                                 |
| ------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `gate`        | should we build, admit/defer, parity, UI/API surface, UAT expansion, debt tranche admission                             |
| `story-slice` | user stories, GWT, UX budgets, AC — only after `gate` Build Now / founder override                                      |
| `rebaseline`  | doctrine feels stale, north star predates shipped product, many founder overrides; step 0 `re-baseline`                 |
| `groom`       | groom backlog, epic cleanup, reparent orphans, board sync after sequencing |

Skip: surgical bug fix or single-slice cleanup with no user-facing concept or step change; stress-test-only → `grilling`; one cited AC and no slice ask → no `story-slice`.

**Gate vs overlay** (`gate` only):

- **Gate** (explicit scope ask / admission before product work): always emit the full Decision Output.
- **Overlay** (mid-session UI/scope expansion without an explicit gate ask): full block only for Reject / Build Later / Research Further; quiet Build Now (no block). Step 0 still runs.

## Shared prep

Cite personas, golden paths, click budgets, mental models, and the doctrine ledger only from `<project>/.agents/product.md`. Absent → `unknown`, never invent (no "general user"; no step budget → qualitative delta only). Silent → Confidence ≤ Medium; prefer Research Further or one clarifying question.

## Branch reference

- `gate`: [`reference/gate.md`](reference/gate.md)
- `story-slice`: [`reference/story-slice.md`](reference/story-slice.md)
- `rebaseline`: [`reference/rebaseline.md`](reference/rebaseline.md)
- `groom`: [`reference/groom.md`](reference/groom.md)

## Handoff

- `gate` — Build Now → `story-slice` when stories / multi-slice / UX-mandated AC, else `$dev` `plan` (intent entrypoints may continue; debt → `$dev` `plan`). Build Later / Reject → stop, no stories (user override → `$dev` `plan` records it). Research Further → name the smallest missing product artifact (reason `re-baseline` → `rebaseline`).
- `story-slice` — ready cards → `$dev` `plan` same turn (writes no code); ungated or rejected → stop.
- `rebaseline` — done → `gate` can run again.

## Completion criteria

Per-branch Done when in the matched reference. Gate/overlay: step 0 + Decision Output per the rule above.
