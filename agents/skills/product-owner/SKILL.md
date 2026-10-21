---
name: product-owner
description: >-
  Product domain router: admit, defer, or reject scope against cited golden
  paths, click budgets, and mental models. Use before feature proposals, scope
  debates, UI/API expansion, UAT that changes scope, or "should we build X?";
  to slice into Given/When/Then stories before $dev plan; admit debt tranches;
  or re-baseline stale doctrine.
---

# Product Owner

Features must earn their existence; doctrine overrides enthusiasm, founder bias, and technical elegance. Vocabulary: [`../CONTEXT.md`](../CONTEXT.md).

## Pick branch

Default **`gate`**. Never ask the user to pick when signals are clear.

| Branch        | Status | Signals                                                                                                                 |
| ------------- | ------ | ----------------------------------------------------------------------------------------------------------------------- |
| `gate`        | active | should we build, admit/defer, parity, UI/API surface, UAT expansion, debt tranche admission                             |
| `story-slice` | active | user stories, GWT, UX budgets, AC — only after `gate` Build Now / founder override                                      |
| `rebaseline`  | active | doctrine feels stale, north star predates shipped product, many founder overrides; step 0 `re-baseline`                 |
| `groom`       | active | groom backlog, epic cleanup, reparent orphans, board sync after sequencing → [`reference/groom.md`](reference/groom.md) |
| `prioritize`  | stub   | backlog ranking                                                                                                         |
| `experiment`  | stub   | experiment / analytics design                                                                                           |

Stubs are not authored — never invent their content. Signals only at a stub: stay on `gate` when admission applies, else say the branch is not authored.

Skip: routine surgical bug fix / single-slice cleanup with no user-facing concept or step change; stress-test-only → `grilling`; already one cited AC with no slice ask → no `story-slice`.

**Gate vs overlay** (`gate` only):

- **Gate** (explicit scope ask / admission before product work): always emit the full Decision Output.
- **Overlay** (mid-session UI/scope expansion without an explicit gate ask): full block only for Reject / Build Later / Research Further; quiet Build Now (no block). Step 0 still runs.

## Shared prep

- Cite personas, golden paths, click budgets, mental models, and the doctrine ledger only from `<project>/.agents/product.md` ([`../CONTEXT.md`](../CONTEXT.md)). Uncited or absent section → `unknown`. Never invent. Silent → Confidence ≤ Medium; prefer Research Further or one clarifying question.
- No personas section → don't use a "general user"; add that section from local history. No step budget → qualitative delta (`adds friction` / `removes friction` / `unclear`).

## Branch reference

- `gate`: [`reference/gate.md`](reference/gate.md) — staleness step 0, doctrine, Doctrine Check, Decision Output.
- `story-slice`: [`reference/story-slice.md`](reference/story-slice.md) — Story Card, Quality Gate Matrix.
- `rebaseline`: [`reference/rebaseline.md`](reference/rebaseline.md) — never evaluates a feature.

## Handoff

```text
product-owner gate
  Build Now       → story-slice when stories / multi-slice / UX-mandated AC;
                    else $dev plan. Intent entrypoints (e.g. jira-ticket) may
                    continue; debt tranches → $dev plan
  Build Later     → stop impl; no stories; optional communication/status
  Research Further → name smallest missing product artifact; do not invent strategy;
                    reason `re-baseline` → branch `rebaseline`
  Reject          → stop; no stories (unless user overrides — then $dev plan records it)
product-owner story-slice
  ready cards     → $dev plan in the same turn (planning session writes no code)
  ungated/reject  → stop; do not invent stories
  Plan mode       → explicit /product-owner; product stance in `$dev` `plan`
product-owner rebaseline
  done            → gate can run again against the new basis
grilling          → Decide only; this skill keeps doctrine + evidence rules if topic is scope
architecture / dev / *-dev / review.gil → never own "should we build X?"
```

Never treat `architecture` as a parallel Build entry beside `$dev`. This skill does not teach how to build.

## Completion criteria

- **Gate**: step 0; Doctrine Check; Forced Challenge; full Decision Output incl. Doctrine delta; Evidence lists paths or gaps.
- **Overlay**: step 0; full Decision Output only for Reject / Build Later / Research Further.
- **story-slice**: prerequisite cited; contraband stripped; one Story Card per slice; Quality Gate Matrix filled; ready for `$dev` `plan`.
- **rebaseline**: [`reference/rebaseline.md`](reference/rebaseline.md) completion criteria met, incl. falsification clause.
