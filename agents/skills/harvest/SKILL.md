---
name: harvest
description: >-
  Distill corrections and fixes into preventive mantras for project rules or
  skill references; log architectural debt. Use after Assure/Ship friction, a
  new failure class, or when asked to harvest, distill, or record debt.
disable-model-invocation: true
---

# Harvest

Session friction → durable rules or debt entries. A **Preventive Mantra** is one imperative sentence ("When X, always Y to prevent Z" / "Avoid X; use Y instead because Z"); the **Debt Ledger** (`.agents/debt-ledger.md`) is the architectural-friction backlog, admitted by `product-owner` and executed by `$dev`.

## Pick branch

Default **`distill`**.

| Branch    | Signals                                                                                  |
| --------- | ---------------------------------------------------------------------------------------- |
| `distill` | learn, distill, checklist update, anti-pattern, user correction, failure lesson          |
| `debt`    | debt, architectural friction, tech debt, cleanup candidate, debt ledger, refactor sprint |

Skip: zero corrections, no new failure class, no debt; trivial typo/rename/bump; product admission asks → `product-owner`.

## Shared prep

Never paste raw logs, incident writeups, or transcripts. Fresh-read the target before edit.

## Branch reference

- `distill` → [`reference/distill.md`](reference/distill.md)
- `debt` → [`reference/debt.md`](reference/debt.md)

## Handoff

- `distill` local → `<project>/AGENTS.md` or `<project>/.agents/rules/*.md`; global → `~/.dotfiles/agents/skills/<skill>/reference/`, then the sync steps in `distill.md`.
- `debt` → `<project>/.agents/debt-ledger.md`; admission and Health Capacity Budget: `product-owner` `gate`.

## Completion criteria

Per-branch Done when in the matched reference.
