---
name: product-owner
description: >-
  Product domain router: admit, defer, or reject scope against cited golden
  paths, click budgets, cognitive load, and mental models. Use before feature
  proposals, scope debates, UI/API surface expansion, product evaluations, idea
  / user feedback / UAT that changes scope, or any "should we build X?"; to
  slice admitted scope into Given/When/Then user stories with interaction
  budgets before $dev plan; to admit debt tranches; or to re-baseline stale
  doctrine (north star predates what shipped, founder overrides piled up).
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

Skip: routine surgical bugfix / single-slice cleanup with no user-facing concept or step change; stress-test-only → `grilling`; already one cited AC with no slice ask → no `story-slice`.

**Gate vs overlay** (`gate` only):

- **Gate** (explicit scope ask / admission before product work): always emit the full Decision Output.
- **Overlay** (mid-session UI/scope expansion without an explicit gate ask): full block only for Reject / Build Later / Research Further; quiet Build Now (no block). Step 0 still runs.

## Shared prep

Evidence rules (all branches):

- Discover golden paths, click budgets, personas, mental models only from existing repo docs (`AGENTS.md`, `ROADMAP.md`, `CONTEXT.md`, `docs/personas.md`, repo-local product-owner wrapper, or equivalents). Cite the path for every such claim; uncited → `unknown`.
- Never invent golden paths, step counts, budgets, SLAs, personas, or preserved/prohibited models. Docs silent → Confidence ≤ Medium; prefer Research Further or one clarifying question.
- No documented personas → don't evaluate against a "general user"; prompt to set up `docs/personas.md` with concrete candidates synthesized from local history (ADRs, git log, README, evaluations, stories).
- No documented step budget → report deltas qualitatively (`adds friction` / `removes friction` / `unclear`).

## Branch reference

- `gate`: [`reference/gate.md`](reference/gate.md) — staleness step 0, doctrine, Doctrine Check, Decision Output.
- `story-slice`: [`reference/story-slice.md`](reference/story-slice.md) — Story Card, Quality Gate Matrix.
- `rebaseline`: [`reference/rebaseline.md`](reference/rebaseline.md) — never evaluates a feature.
- Promote / refine a repo-local wrapper: [`skill/authoring/product-owner-promote.md`](../../../skill/authoring/product-owner-promote.md).

## Handoff

```text
product-owner gate
  Build Now       → story-slice when the ask is stories / multi-slice /
                    UX-mandated AC; else $dev only (classifies; loads
                    architecture when design; routes {lang}-dev / overlay);
                    Intent entrypoints (e.g. jira-ticket) may continue;
                    debt tranches from .agents/debt-ledger.md route to $dev
  Build Later     → stop impl; no stories; optional communication/status
  Research Further → name smallest missing product artifact; do not invent strategy;
                    reason `re-baseline` → branch `rebaseline` (do not evaluate the feature)
  Reject          → stop; no stories (unless user explicitly overrides — then $dev plan records override)
product-owner story-slice
  ready cards     → $dev plan (not implement until plan ready)
  ungated/reject  → stop; do not invent stories
  Plan mode       → explicit /product-owner; product stance in dev/reference/plan-pipeline.md
product-owner rebaseline
  done            → gate can run again against the new basis
grilling          → Decide only (stress-test interview); this skill keeps doctrine + evidence rules if topic is scope
architecture / dev / *-dev / review.gil → never own "should we build X?"
```

Never treat `architecture` as a parallel Build entry beside `$dev`. This skill does not teach how to build.

## Completion criteria

- **Gate**: step 0 ran; Doctrine Check answered; Forced Challenge stated; full Decision Output incl. Doctrine delta; Evidence lists paths or gaps.
- **Overlay**: step 0 ran; full Decision Output only for Reject / Build Later / Research Further.
- **story-slice**: prerequisite gate/override cited; contraband stripped; one Story Card per slice; Quality Gate Matrix filled; ready for `$dev` `plan`.
- **rebaseline**: [`reference/rebaseline.md`](reference/rebaseline.md) completion criteria met, incl. the falsification clause.
