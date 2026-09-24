---
name: harvest
description: >-
  Distill session corrections, review findings, and tricky fixes into imperative
  preventive mantras for project rules or store skill references, and log
  architectural debt to .agents/debt-ledger.md. Use after Assure or Ship with
  friction, when a new failure class appears, or when asked to harvest, distill,
  capture lessons, or record debt.
---

# Harvest

Session friction → durable rules or debt entries, never raw noise. Vocabulary (Preventive Mantra, Debt Ledger): [`../CONTEXT.md`](../CONTEXT.md).

## Pick branch

Default **`distill`**.

| Branch    | Signals                                                                                  |
| --------- | ---------------------------------------------------------------------------------------- |
| `distill` | learn, distill, checklist update, anti-pattern, user correction, failure lesson          |
| `debt`    | debt, architectural friction, tech debt, cleanup candidate, debt ledger, refactor sprint |

Skip: zero corrections, no new failure class, no debt; trivial typo/rename/bump; product admission asks → `product-owner` ([`../CONTEXT.md`](../CONTEXT.md)); raw incident writeups/transcript dumps are rejected.

## Shared prep

1. **Never raw logs:** strip transcripts, stack traces, conversational prose, temporary workarounds.
2. **Fresh read** the target file immediately before editing (concurrent state).
3. **Scope:** project-local (repo commands, domain models, build quirks) → `<project>/AGENTS.md` or `<project>/.agents/rules/*.md`; global (language idioms, universal architecture, review heuristics) → `~/.dotfiles/agents/skills/<skill>/reference/<branch>.md`.
4. **Distillation test:** must be a Preventive Mantra (checklist item or anti-pattern) an expert recalls before repeating the mistake.
5. **Dedupe:** search the target; drop duplicates, near-clones, platitudes, weak candidates.

## Branch reference

- `distill` → [`reference/distill.md`](reference/distill.md)
- `debt` → [`reference/debt.md`](reference/debt.md)

## Handoff

```text
harvest distill
  local  → <project>/AGENTS.md or <project>/.agents/rules/*.md
  global → ~/.dotfiles/agents/skills/<skill>/reference/
           → `skill doctor`, then `rcup` (drift → `skill backfill <name>` → `rcup`)
harvest debt
  → <project>/.agents/debt-ledger.md
  → feeds orchestrator / triage and product-owner Health Capacity Budget
```

## Completion criteria

- `distill`: mantras distilled; repo nouns stripped if global; target read fresh; deduplicated; placed in the right section; store synced if global.
- `debt`: category + concrete blast radius + evidence cited; entry added to `.agents/debt-ledger.md`; no raw diff blobs.
