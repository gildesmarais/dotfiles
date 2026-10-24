---
name: ops-chore
description: >-
  Closed-loop service ops chore: verify observability, triage queues and errors,
  score APM, and admit service fixes. Use for /ops-chore, ops chore, run ops,
  weekly ops, full ops, quick ops, APM chores, post-deploy, datadog, or apply dashboard.
---

# Ops Chore

Closed-loop service ops review: verify observability, triage queues and errors, score APM, and admit service fixes to the Ops Ledger. Does not implement application code.

## Pick branch

Resolve preset from trigger or lookback:
- `quick`: "quick ops", "APM chores", "integrity", or unadorned trigger with lookback ≤ 3d.
- `post-deploy`: "post-deploy", "after deploy", "collector check", or deploy marker in lookback. Default lookback 2h.
- `full`: "weekly ops", "full ops", "deep APM", "datadog", "apply dashboard" (forces dashboard apply), or default lookback > 3d (default 14d).

Lookback: user window → prior ledger `Window.end` → now (same service) → default. Ask at most 1 question only if lookback is ambiguous without prior ledger or deploy cue. Details: [`reference/presets.md`](reference/presets.md).

## Shared prep

1. **Target**: Resolve from current workspace (monitoring config, OTEL service name, Sentry project, Datadog/OpenObserve targets, dashboard generator). Query telemetry via available Datadog or OpenObserve MCP tools / CLIs. If workspace defines no observability target, stop. Never query another repo's streams, org, or boards.
2. **Hard stops**: Load [`reference/hard-stops.md`](reference/hard-stops.md). Read-only by default; write allowed only for live dashboard apply on an owned board. Never implement app code, open PRs, drain jobs, or raise limits.
3. **Admit service fixes**: Every Strong reliability/APM finding must admit a concrete code/config change with target files and rejected alternative, or explicitly state deferral reason.
4. **Incidents**: Active outage or incident mid-run → immediately hand off to `$triage`.

## Branch reference

- Presets & scope: [`reference/presets.md`](reference/presets.md)
- Playbook execution (bands 1–8): [`reference/playbook.md`](reference/playbook.md)
- Hard stops & mutation boundary: [`reference/hard-stops.md`](reference/hard-stops.md)
- Ops Ledger DTO schema: [`reference/ledger.md`](reference/ledger.md)

## Handoff

| Signal | Next |
| --- | --- |
| Active incident | `$triage` |
| Admitted items (user requested plan) | `$dev` `plan` with admitted items |
| Admitted items (no plan request) | Stop after ledger; items seed future `$dev` plan |
| Product / journey ambiguity | `product-owner` `gate` |

## Completion criteria

- Ops Ledger emitted matching schema in [`reference/ledger.md`](reference/ledger.md).
- Selected preset and lookback recorded on ledger.
- All preset bands completed or marked blocked/NA with explicit reason.
- Every Strong reliability/APM finding has an admitted `$dev` plan item or explicit deferral.
- Dashboard applied with id/hash or marked N/A with reason.
- Hard stops honored; zero direct application code or worktree modifications.
