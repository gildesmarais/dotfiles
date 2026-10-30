---
name: triage
description: >-
  Intent intake for incidents and fuzzy ops asks: gather evidence, classify
  product vs eng scope, emit a Triage Ledger. Use for Sentry/errors/timeouts,
  scrape failures, fail-closed UX, /triage, /intake, or unclear admit-scope vs
  plan.
disable-model-invocation: true
---

# Triage

Incident/ops signals → evidence → Triage Ledger (the evidence DTO, schema in `intake.md`) → one next skill, chained per the route. Never implements, opens PRs, raises timeouts, invents golden paths, or owns product admission.

## Pick branch

Default and only branch: **`intake`**.

Playbook (load after `intake.md` on signal; not a peer branch): Botasaurus, scrape-api, `challenge_block`, `timeout/work`, fail-closed scrape UX → [`reference/scrape-incident.md`](reference/scrape-incident.md).

Skip: approved plan / explicit go → `$dev` `implement`; Jira key/URL → `jira-ticket`; stress-test → `grilling`; morning PR attention → `pr-sweep`; periodic or post-deploy service review → `ops-chore`.

## Shared prep

Observability cue: [`../CONTEXT.md`](../CONTEXT.md). Reproduce when cheap. No observability tool available → say so and label the evidence Speculative. Max **2** clarifying questions when the route is blocked; never re-grill playbook locks.

## Branch reference

- `intake` → [`reference/intake.md`](reference/intake.md)

## Handoff

Emit the Triage Ledger, then load the next skill (route table in `intake.md`): product or both → `product-owner` `gate` (Build Now → `$dev` `plan`, else stop); eng only → `$dev` `plan`; should-we-build → `product-owner` only; approved plan / go → stop triage, `$dev` `implement`.

**Continue policy:** go / approval ("Shot 2") / "plan then implement" → after Build Now continue `$dev` `plan` (`implement` only when explicitly approved). Report-only ("Shot 1") → stop after ledger + next skill. Hand off only — never paste doctrine or `$dev` plan bodies.

## Completion criteria

Triage Ledger emitted; route chosen; next skill loaded or explicit stop.
