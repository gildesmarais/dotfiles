---
name: triage
description: >
  Intent intake for incidents and fuzzy ops asks: gather evidence (observability
  MCP, local reproduce, AGENTS.md), classify product vs eng scope, emit a Triage
  Ledger, then hand off to product-owner gate or $dev plan. Use for Sentry/errors/
  timeouts, scrape failures, fail-closed UX after outages, /triage, /intake, or when
  the next step is unclear between admit-scope and implementation plan. Does not
  implement code, open PRs, or answer "should we build X?".
---

# Triage

Intent-domain router. Turn messy incident/ops signals into a single next skill.
Evidence first; one handoff; no Build.

## When to use / skip

| Use when                                                           | Skip when                                                             |
| ------------------------------------------------------------------ | --------------------------------------------------------------------- |
| Prod errors, Sentry/APM, scrape/timeouts, "investigate then what?" | Clear "implement this plan" / approved plan → `$dev` `implement`      |
| Need route: product admit vs eng plan                              | Jira key/URL as entry → prefer `jira-ticket`                          |
| `/triage`, `/intake`, incident without ticket or IR                | Pure compile-to-IR → `prompt-compiler`; stress-test only → `grilling` |

## Pick branch

Never ask the user to pick when signals are clear. Default: **`intake`**.

| Branch   | Status     | Use when                                               |
| -------- | ---------- | ------------------------------------------------------ |
| `intake` | **active** | Default incident/fuzzy ops → evidence → ledger → route |

**Playbooks** (progressive load under `reference/`, not peer branches):

| Signal                                                                       | Load                                                           |
| ---------------------------------------------------------------------------- | -------------------------------------------------------------- |
| Botasaurus, scrape-api, challenge_block, timeout/work, fail-closed scrape UX | [`reference/scrape-incident.md`](reference/scrape-incident.md) |

## Shared prep

1. Read repo `AGENTS.md` / `CONTEXT.md` when present; prefer repo law.
2. **Observability cue:** if APM / error tracking / logging links or IDs appear, use the matching MCP when available; fold findings into evidence. If MCP is missing, say so and continue with ask text + codebase.
3. Reproduce locally when cheap (health, control URL, failing URL). Label claims **Strong** / **Worth** / **Speculative**.
4. Do **not** implement, open PRs, raise timeouts, or invent golden paths / click budgets.
5. Max **2** clarifying questions only if the route is blocked; prefer playbook defaults.
6. If a playbook is active, do **not** re-grill locks already stated there.

## Branch reference

- **`intake`** → [`reference/intake.md`](reference/intake.md) — evidence checklist, route table, Triage Ledger schema.
- Playbooks (when signaled) → load after intake.md; apply locks; same handoff contract.

## Handoff

Emit the **Triage Ledger** (see intake.md), then load exactly one next skill:

```text
triage intake
  product | both     → product-owner gate
                         Build Now → $dev plan
                         Build Later | Research Further | Reject → stop
  eng only           → $dev plan
  should-we-build    → product-owner only
  approved plan / go → stop triage; $dev implement
```

**Continue policy:** If the user already said go / Shot 2 / “plan then implement”, after **Build Now** continue into `$dev` `plan` (and `implement` only when explicitly approved). Shot 1 alone → stop after ledger + next skill loaded (or after PO+plan if class is `both` and gate is Build Now).

Compose: Product before non-trivial scope (store README rule 1). `$dev` never answers “should we build X?”. Triage never owns Assure/Ship. Do not paste `product-owner` doctrine or `$dev` plan-pipeline bodies—handoff only.

## Completion criteria

| Path                  | Done when                                                                                               |
| --------------------- | ------------------------------------------------------------------------------------------------------- |
| `intake` (+ playbook) | Evidence listed; Triage Ledger emitted; route chosen with rationale; next skill loaded or explicit stop |
| Handoff PO            | Gate runs (or prior gate summarized); no application code                                               |
| Handoff `$dev` plan   | Product stance noted (`Build Now` / `skip`+why / pending); plan-pipeline owned by `$dev`                |
| Stop                  | Approved plan already present, or PO not Build Now, or should-we-build-only resolved                    |
