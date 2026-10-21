---
name: product-owner
description: >-
  Admit, defer, or reject product scope; slice Given/When/Then stories; admit
  debt tranches; re-baseline doctrine. Use for feature proposals, scope debates,
  UI/API expansion, UAT that changes scope, or "should we build X?".
---

# Product Owner

Vocabulary: [`../CONTEXT.md`](../CONTEXT.md). Doctrine overrides enthusiasm — see [`reference/gate.md`](reference/gate.md).

## Pick branch

Default **`gate`**. Never ask the user to pick when signals are clear. Unauthored branch name → say so (stay on `gate` when admission applies).

| Branch        | Signals                                                                                                                 |
| ------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `gate`        | should we build, admit/defer, parity, UI/API surface, UAT expansion, debt tranche admission                             |
| `story-slice` | user stories, GWT, UX budgets, AC — only after `gate` Build Now / founder override                                      |
| `rebaseline`  | doctrine feels stale, north star predates shipped product, many founder overrides; step 0 `re-baseline`                 |
| `groom`       | groom backlog, epic cleanup, reparent orphans, board sync after sequencing → [`reference/groom.md`](reference/groom.md) |

Skip: routine surgical bug fix / single-slice cleanup with no user-facing concept or step change; stress-test-only → `grilling`; already one cited AC with no slice ask → no `story-slice`.

**Gate vs overlay** (`gate` only):

- **Gate** (explicit scope ask / admission before product work): always emit the full Decision Output.
- **Overlay** (mid-session UI/scope expansion without an explicit gate ask): full block only for Reject / Build Later / Research Further; quiet Build Now (no block). Step 0 still runs.

## Shared prep

- Cite personas, golden paths, click budgets, mental models, doctrine ledger only from `<project>/.agents/product.md` ([`../CONTEXT.md`](../CONTEXT.md)). Absent → `unknown`. Never invent. Silent → Confidence ≤ Medium; prefer Research Further or one clarifying question.
- No personas section → don't invent a "general user". No step budget → qualitative delta only.

## Branch reference

- `gate`: [`reference/gate.md`](reference/gate.md)
- `story-slice`: [`reference/story-slice.md`](reference/story-slice.md)
- `rebaseline`: [`reference/rebaseline.md`](reference/rebaseline.md)

## Handoff

```text
product-owner gate
  Build Now       → story-slice when stories / multi-slice / UX-mandated AC;
                    else $dev plan. Intent entrypoints may continue; debt → $dev plan
  Build Later     → stop impl; no stories
  Research Further → name smallest missing product artifact; reason `re-baseline` → `rebaseline`
  Reject          → stop; no stories (user override → $dev plan records it)
product-owner story-slice
  ready cards     → $dev plan same turn (writes no code)
  ungated/reject  → stop
product-owner rebaseline
  done            → gate can run again
grilling          → Decide only; this skill keeps doctrine if topic is scope
architecture / dev / *-dev / review.gil → never own "should we build X?"
```

Never treat `architecture` as a parallel Build entry beside `$dev`.

## Completion criteria

Per-branch Done when in the matched reference. Gate/overlay: step 0 + Decision Output rules above.
