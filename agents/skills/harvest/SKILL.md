---
name: harvest
description: >-
  Distill corrections and fixes into preventive mantras for project rules or
  skill references; log architectural debt. Use after Assure/Ship friction, a
  new failure class, or when asked to harvest, distill, or record debt.
disable-model-invocation: true
---

# Harvest

Session friction → durable rules or debt entries, never raw noise. A **Preventive Mantra** is one imperative sentence ("When X, always Y to prevent Z" / "Avoid X; use Y instead because Z"); the **Debt Ledger** (`.agents/debt-ledger.md`) is the architectural-friction backlog, admitted by `product-owner` and executed by `$dev`.

## Pick branch

Default **`distill`**.

| Branch    | Signals                                                                                  |
| --------- | ---------------------------------------------------------------------------------------- |
| `distill` | learn, distill, checklist update, anti-pattern, user correction, failure lesson          |
| `debt`    | debt, architectural friction, tech debt, cleanup candidate, debt ledger, refactor sprint |

Skip: zero corrections, no new failure class, no debt; trivial typo/rename/bump; product admission asks → `product-owner`; raw incident writeups/transcript dumps are rejected.

## Shared prep

Scope destinations and procedure: [`reference/distill.md`](reference/distill.md) / [`reference/debt.md`](reference/debt.md). Never paste raw logs. Fresh-read target before edit. Distillation test: the Preventive Mantra form.

## Branch reference

- `distill` → [`reference/distill.md`](reference/distill.md)
- `debt` → [`reference/debt.md`](reference/debt.md)

## Handoff

- `distill` local → `<project>/AGENTS.md` or `<project>/.agents/rules/*.md`; global → `~/.dotfiles/agents/skills/<skill>/reference/`, then `skill doctor` and `rcup` (drift → `skill backfill <name>` → `rcup`).
- `debt` → `<project>/.agents/debt-ledger.md` (Health Capacity: CONTEXT; admission: `product-owner`).

## Completion criteria

Per-branch Done when in the matched reference.
