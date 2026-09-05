---
name: harvest
description: >
  Synthesize and capture continuous learnings and architectural debt into the Skills OS.
  Distills session corrections, review findings, and tricky fixes into imperative preventive
  mantras (anti-patterns and checklist items) for local rules or global skill references,
  and logs systemic friction to .agents/debt-ledger.md. Use when a session uncovers new
  failure classes, after Assure or Ship, or when asked to harvest, distill, or record debt.
---

# Harvest

Continuous learning and debt capture router. Turn session friction, user corrections, and review findings into durable system wisdom without polluting skills with raw noise.

## When to use / skip

| Use when                                                                                   | Skip when                                                                    |
| ------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------- |
| Post-delivery handoff from `review.gil` (Assure) or `pull-request` (Ship) with friction    | Routine execution with zero corrections, no new failure class, and zero debt |
| User explicitly asked to capture, learn, or harvest lessons from the session               | User asks "should we build X?" → load `product-owner`                       |
| A tricky bug, subtle failure class, or non-obvious work-around was resolved                | Trivial typo, variable rename, or pure mechanical bump                       |
| Unresolved architectural debt, leaky boundary, or performance trap deferred for later      | Raw incident writeup / transcript dump (harvest rejects raw logs)            |

## Pick branch

Map the harvest ask to one branch. Default: **`distill`**.

| Branch    | Status     | Use when                                                                                           |
| --------- | ---------- | -------------------------------------------------------------------------------------------------- |
| `distill` | **active** | Extract preventive mantras; update project-local rules or global skill checklists / anti-patterns |
| `debt`    | **active** | Log architectural friction, boundary rot, or debt tranches into `.agents/debt-ledger.md`           |

| Signal                                                                              | Branch    |
| ----------------------------------------------------------------------------------- | --------- |
| learn, distill, checklist update, anti-pattern, user correction, failure lesson     | `distill` |
| debt, architectural friction, tech debt, cleanup candidate, debt ledger, refactor sprint | `debt`    |

## Shared prep

Before authoring any updates:

1. **Never raw logs:** Strip transcripts, stack traces, conversational prose, and temporary workarounds.
2. **Fresh read:** Always read the target file immediately before editing. Staging and reference files are concurrent state.
3. **Classify scope:**
   - **Project-local:** repo-specific commands, local domain models, custom build quirks → `<project>/AGENTS.md` or `<project>/.agents/rules/*.md`.
   - **Global store:** language idioms, universal architecture rules, review heuristics → `agents/skills/<skill>/reference/<branch>.md`.
4. **Distillation test:** Candidate must be an imperative preventive mantra (checklist item or anti-pattern) an expert recalls before repeating the mistake.
5. **Deduplication:** Search target file. Reject duplicates, near-clones, and generic platitudes ("write clean code"). Drop weak candidates.

## Branch reference

Load only the reference for the active branch:

- **`distill`:** Follow [`reference/distill.md`](reference/distill.md).
- **`debt`:** Follow [`reference/debt.md`](reference/debt.md).

## Handoff

```text
harvest distill
  Local rule update  → written to <project>/AGENTS.md or .agents/rules/*.md
  Global store update → written to ~/.dotfiles/agents/skills/<skill>/reference/
                       → run `skill doctor`; on drift run `rcup`
harvest debt
  Logged debt tranche → written to <project>/.agents/debt-ledger.md
                       → feeds Intent (orchestrator / triage) and Product (product-owner)
```

- When global store files in `~/.dotfiles/agents/skills/` are updated, run `skill doctor` and run `rcup` so live installs in `~/.agents/skills/` update immediately.
- Admitted debt in `.agents/debt-ledger.md` feeds `product-owner` under its Health Capacity Budget.

## Completion criteria

| Branch    | Done when                                                                                                                                                                          |
| --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `distill` | Signals distilled to imperative mantras; domain noise stripped (if global); target read fresh; deduplicated against existing items; placed in correct section; store synced if global |
| `debt`    | Friction classified (boundary/types/perf/legacy); concrete blast radius and evidence cited; added to `.agents/debt-ledger.md`; no raw diff blobs                                    |
