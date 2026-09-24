---
name: triage
description: >-
  Intent intake for incidents and fuzzy ops asks: gather evidence, classify
  product vs eng scope, emit a Triage Ledger, hand off to product-owner gate or
  $dev plan. Use for Sentry/errors/timeouts, scrape failures, fail-closed UX
  after outages, /triage, /intake, or when the next step is unclear between
  admit-scope and implementation plan.
---

# Triage

Incident/ops signals → evidence → Triage Ledger → exactly one next skill. Does not implement code, open PRs, or answer "should we build X?".

## Pick branch

Default and only branch: **`intake`**. Never ask the user to pick.

Playbook (load after intake.md on signal; not a peer branch): Botasaurus, scrape-api, `challenge_block`, `timeout/work`, fail-closed scrape UX → [`reference/scrape-incident.md`](reference/scrape-incident.md).

Skip: approved plan / explicit go → `$dev` `implement`; Jira key/URL → `jira-ticket`; pure intent compilation → `prompt-compiler`; stress-test → `grilling`; morning PR attention → `pr-sweep`.

## Shared prep

1. Prefer repo law (`AGENTS.md` / `CONTEXT.md`).
2. **Observability cue:** APM / error / log links or IDs → matching MCP when available; missing → say so, continue with ask text + codebase.
3. Reproduce locally when cheap (health, control URL, failing URL). Label claims **Strong** / **Worth** / **Speculative**.
4. Never implement, open PRs, raise timeouts, or invent golden paths / click budgets.
5. Max **2** clarifying questions, only if the route is blocked; else playbook/table defaults. Never re-grill locks an active playbook states.

## Branch reference

- `intake` → [`reference/intake.md`](reference/intake.md) — evidence checklist, route table, Triage Ledger schema.

## Handoff

Emit the Triage Ledger, then load exactly one next skill:

```text
triage intake
  product | both     → product-owner gate
                         Build Now → $dev plan
                         Build Later | Research Further | Reject → stop
  eng only           → $dev plan
  should-we-build    → product-owner only
  approved plan / go → stop triage; $dev implement
```

**Continue policy:** user already said go / Shot 2 / "plan then implement" → after Build Now continue into `$dev` `plan` (`implement` only when explicitly approved). Shot 1 alone → stop after ledger + next skill loaded (or after PO + plan when class `both` and gate is Build Now).

Non-trivial scope gets `product-owner` `gate` before `$dev`; `$dev` never answers "should we build X?". Triage never owns Assure/Ship. Hand off only — never paste `product-owner` doctrine or `$dev` plan-pipeline bodies.

## Completion criteria

- `intake` (+ playbook): evidence listed; Triage Ledger emitted; route chosen with rationale; next skill loaded or explicit stop.
- Handoff PO: gate runs (or prior gate summarized); no application code.
- Handoff `$dev` plan: product stance noted (`Build Now` / `skip`+why / pending).
- Stop: approved plan present, PO not Build Now, or should-we-build-only resolved.
