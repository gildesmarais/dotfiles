---
name: ops-chore
description: >-
  Closed-loop service ops review: verify observability, triage queues and
  errors, score APM, admit service fixes to an Ops Ledger. Use for /ops-chore,
  ops chore, weekly or quick ops, post-deploy check, dashboard apply.
disable-model-invocation: true
---

# Ops Chore

Verify observability, triage queues and errors, score APM, and admit service fixes. Evidence in, Ops Ledger out; never application code.

## Pick branch

Presets (bands in [`reference/playbook.md`](reference/playbook.md)); first match wins:

1. `post-deploy` — "post-deploy", "after deploy", "collector check", or a deploy marker in the window. Default window 2h.
2. Explicit words: `quick` ("quick ops", "APM chores", "integrity", default window 3d) · `full` ("weekly ops", "full ops", "deep APM", "dashboard apply" — forces band 7, default window 14d).
3. Unadorned trigger: window ≤ 3d → `quick`, else `full`.

Window: user's → prior Ops Ledger end → now (same service only) → preset default. Ask one question only when the window is ambiguous with no prior ledger or deploy cue.

## Shared prep

1. **Target:** the workspace's monitoring config (service name, error project, telemetry backends, dashboard generator) defines the target; query it through available observability tools ([`../CONTEXT.md`](../CONTEXT.md) Observability cue). None defined → stop and say so.
2. **Constraints:** load [`reference/hard-stops.md`](reference/hard-stops.md) every run.
3. Active outage mid-run → hand off to `triage` now.

## Branch reference

- [`reference/playbook.md`](reference/playbook.md) — preset bands; load only the bands the preset runs (bands 5–7 on `full` or signal).
- [`reference/ledger.md`](reference/ledger.md) — Ops Ledger schema and the admission rule.

## Handoff

Admitted items seed `$dev` `plan` (continue into it only when asked; otherwise stop after the ledger). Product-visible gaps → `product-owner` `gate`.

## Completion criteria

Ledger emitted per `ledger.md` with preset and window; each band done, N/A, or blocked with a reason; every Strong finding admitted or deferred; dashboard apply recorded or N/A; hard stops honored.
