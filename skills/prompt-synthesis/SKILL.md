---
name: prompt-synthesis
description: >-
  Transforms rough notes or vague task ideas into a dense, paste-ready agent
  brief (Goal, Context, Success, Constraints, Verify). Grills material gaps
  with code-backed recommendations before emitting. Use when the user says
  /prompt-synthesis, "refine prompt", "structure this prompt", or wants a
  paste-ready agent prompt without executing the task.
---

# Prompt Synthesis

Turn fragmented intent into one paste-ready agent brief. **Do not execute the task.**

## Pick branch

Map the user prompt to exactly one branch, or stay on Shared prep only:

| Branch         | Use when                                                          |
| -------------- | ----------------------------------------------------------------- |
| _(default)_    | Vague intent, mixed signals, or no clear class — Shared prep only |
| `code`         | Impl, refactor, bugfix, tests, verification of a code change      |
| `architecture` | Structure, seams, types, performance craft, system design         |
| `product`      | Scope, UX/mental model, admit/defer feature shape                 |

Routing signals:

| User says                                              | Branch         |
| ------------------------------------------------------ | -------------- |
| "fix", "implement", "refactor this file", "add tests"  | `code`         |
| "deepen", "seams", "module boundary", "perf design"    | `architecture` |
| "should we build", "golden path", "user flow", "scope" | `product`      |

When signals are unclear, do not ask the user to pick a branch — stay on Shared prep and grill for load-bearing gaps.

## Shared prep

Every path:

1. **Hard bounds** — Grill and emit only. Read-only tools. Never Write, Edit, Delete, Shell-mutate, commit, push, install, or run the described work. Never invent APIs, paths, constraints, or stakes.
2. **Intent parse** — Extract candidate Goal, current state, success signal, and material gaps. Do not fill gaps with assumptions.
3. **Ground (cheap + pointers)** — If a workspace root is available, skim high-signal guideline files when present (`AGENTS.md`, `CLAUDE.md`, relevant nested `AGENTS.md`). Put real non-negotiables into Context or Constraints. Otherwise leave path/query pointers. Broaden reads only when a grill recommendation must be code-proven.
4. **Grill** — Ask **one question at a time** until material-complete:
   - **Decision/tradeoff:** 2–3 options; put `(Recommended)` on the best default first; cite evidence (file path, snippet, or internal skill consult — do not name skills in the eventual brief).
   - **Fact** (API, name, path, owner): one open question — no fake multiple choice.
   - Soft cap **5** questions; user saying “keep grilling” extends the cap.
   - After the cap with gaps still open: **halt** — do not emit until answers land or the user explicitly allows emit-with-unknowns.
5. **Emit** — Only when material-complete, or on explicit emit-with-unknowns. Output **only** the brief in one fenced markdown block. No narration, preamble, tool dump, or `<SynthesisLog>`.

### Brief schema

```markdown
## Goal

[Single primary outcome]

## Context

[Current state + grounded invariants or pointers]

## Success

[Observable done-when]

## Constraints

[Non-negotiables and exclusions — omit this entire section if empty]

## Verify

[How to prove Success: commands, tests, checks]
```

- **Success** = destination (observable outcome). **Verify** = proof steps. No overlap.
- On emit-with-unknowns, list each gap under Constraints as `Unknown: … — verify before acting; do not invent.`

### Anti-fluff

Never include: Role/persona, “you are an expert…”, empty sections, motivational filler, restating the obvious for strong models, fake precision, or invented constraints. Soft target: usually ≤ ~40–60 lines unless Context must carry grounded quotes.

While synthesizing, local skills may be consulted for better grill recommendations. The **emitted brief never names** skills or OS handoffs.

## Branch reference

When a class branch was selected, load exactly one disclosed reference and fold its checklist into Context / Constraints / Verify — still emit only the five-field brief:

- **`code`** → [`reference/code.md`](reference/code.md)
- **`architecture`** → [`reference/architecture.md`](reference/architecture.md)
- **`product`** → [`reference/product.md`](reference/product.md)

Default (no branch): skip reference files; Shared prep alone.

## Handoff

This skill stops at the paste-ready brief. It does not hand off into Build, Assure, or Ship. Downstream agents receive the brief as ordinary user input.

## Completion criteria

| Path           | Done when                                                                                                      |
| -------------- | -------------------------------------------------------------------------------------------------------------- |
| any            | Material gaps resolved, or user explicitly allowed emit-with-unknowns                                          |
| emit           | One fenced brief matching schema + anti-fluff; Constraints omitted iff empty; Success ≠ Verify; no skill names |
| grill (active) | Exactly one pending question; no brief yet                                                                     |
| halt at N      | No brief; waiting for answers or explicit escape                                                               |
