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

Incident/ops signals → evidence → Triage Ledger → exactly one next skill. Does not implement, open PRs, or own product admission. The **Triage Ledger** is the incident/ops evidence DTO.

## Pick branch

Default and only branch: **`intake`**.

Playbook (load after intake.md on signal; not a peer branch): Botasaurus, scrape-api, `challenge_block`, `timeout/work`, fail-closed scrape UX → [`reference/scrape-incident.md`](reference/scrape-incident.md).

Skip: approved plan / explicit go → `$dev` `implement`; Jira key/URL → `jira-ticket`; stress-test → `grilling`; morning PR attention → `pr-sweep`.

## Shared prep

Observability cue: [`../CONTEXT.md`](../CONTEXT.md). Reproduce when cheap; label Strong / Worth / Speculative (see [`reference/intake.md`](reference/intake.md)). Never implement, open PRs, raise timeouts, or invent golden paths. Max **2** clarifying questions when route blocked. Never re-grill playbook locks.

## Branch reference

- `intake` → [`reference/intake.md`](reference/intake.md)

## Handoff

Emit the Triage Ledger, then load exactly one next skill (route table in `intake.md`): product or both → `product-owner` `gate` (Build Now → `$dev` `plan`, else stop); eng only → `$dev` `plan`; should-we-build → `product-owner` only; approved plan / go → stop triage, `$dev` `implement`.

**Continue policy:** go / Shot 2 / "plan then implement" → after Build Now continue `$dev` `plan` (`implement` only when explicitly approved). Shot 1 alone → stop after ledger + next skill. Hand off only — never paste doctrine or `$dev` plan bodies.

## Completion criteria

Triage Ledger emitted; route chosen; next skill loaded or explicit stop. Never owns Assure/Ship or application code.
