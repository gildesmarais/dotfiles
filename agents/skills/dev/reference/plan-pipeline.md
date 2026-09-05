# Dev plan pipeline

Quality gates for **`$dev` `plan`** (Cursor plan mode, prepare/refine plan, implementation plan asks). Product admission: **`product-owner`** explicit invoke only — no auto-run in plan mode.

## Sequence

1. Product stance (thread or AskQuestion if unstated)
2. Shared prep + classify (`surgical` | `design` | `review-hand-off`)
3. Route runtime (`{lang}-dev` + overlays from touched evidence)
4. Architecture pass if `design` OR new subsystem → findings table
5. Conditional sections (signal matrix)
6. Observability (≥2 phases)
7. Delivery runbook (≥2 phases)
8. Pre-ship checklists embed ([`review.gil/reference/plan-checklists.md`](../../review.gil/reference/plan-checklists.md) — not full findings)
9. Plan ready — no code until user approves execute

Execute approved → `$dev` `implement` → validate → commit per phase → post-delivery **`review.gil` findings** → forward doc (below) → if user asked to land, **`pull-request` `open`**.

**Forward doc (post-Assure, readiness Yes/Conditional):** update repo maint docs (`AGENTS.md` or nested equivalent) with non-obvious upkeep only — canonical paths, validation commands, change rules. Skip when delivery is small or already self-documenting; state skip in handoff.

## Product stance

Fields: Recommendation (Build Now / Build Later / Research Further / Reject / Unstated), Source, SSOT impact.

| Situation                        | Action                                         |
| -------------------------------- | ---------------------------------------------- |
| Prior PO gate in thread          | Summarize + cite eval path                     |
| Overruled after Reject           | Record override; Phase 1 may flip product SSOT |
| Reject in thread, plan continues | AskQuestion once: override / defer / stop      |
| No PO gate                       | Unstated → AskQuestion before plan ready       |

Never invent Build Now without evidence or explicit override.

## Architecture pass

**When:** `design` OR new subsystem / deep module / cross-process bridge.
**Load:** `architecture`; co-load branches from signals.
**Artifact:** Architecture review findings table (Severity | Finding | Plan fix). When earned: ownership map, boundary contract map, deletion test cuts. Craft: [`architecture/SKILL.md`](../../architecture/SKILL.md).

## Signal matrix

Add section when signal matches; N/A with evidence if skipped.

| Section                     | Signals                                                                                |
| --------------------------- | -------------------------------------------------------------------------------------- |
| Module architecture         | `design`; new subsystem; dual ownership risk                                           |
| Boundary contract map       | Wire/API/JS bridge; adapter; serialize edge                                            |
| Test pyramid & seam design  | Test refactor/audit ask; coverage remediation; monolithic suite split; flight smearing; dual delivery paths for one derived fact; durable mutation failure matrix |
| Performance budgets         | Hot path; debounce/async; large payload; latency ask                                   |
| Sandbox / platform          | Sandbox; WebKit/XPC/JS; file URLs; network; entitlements                               |
| Observability               | ≥2 phases                                                                              |
| Autonomous delivery runbook | ≥2 phases                                                                              |
| Pre-ship checklists         | Plans that will be implemented                                                         |

When **Test pyramid & seam design** matches: require characterization before cutover (parity across delivery modes and/or failure-injection matrix). Acceptance criteria must name observable outcomes or queries — not internal field inventories. Diagnose test friction as production seam defects (`$dev` Shared prep).

## Observability + runbook (≥2 phases)

- One log category per new subsystem; level map; no secrets/full user content in logs
- Cross-process bridge: error forward path if applicable
- Branch: repo `AGENTS.md` / Makefile; if silent AskQuestion once (main vs feature), lock session
- One Conventional Commit per phase; validate exit 0 before next phase; never push unless asked
- Document parallel vs serial phases; entry/exit + resume criteria per phase

## Plan ready checklist

- [ ] Product stance filled or override recorded
- [ ] Classification + runtime route stated
- [ ] Architecture findings (if triggered) or N/A with evidence
- [ ] Target file bounds explicit (`target_files` declared vs frozen surfaces)
- [ ] Flight height evaluated by default (pure unit base, fakes for component, real I/O for integration; test friction diagnosed as production defects)
- [ ] Dual delivery / durable-mutation scope: characterization parity or failure-matrix planned before cutover; acceptance names outcomes/queries, not field inventories
- [ ] Conditional sections or N/A with evidence
- [ ] Observability + runbook if ≥2 phases
- [ ] Pre-ship checklists embedded
- [ ] Phases: validate (exit 0) → Conventional Commit (or deferral on default branch)
- [ ] Rollback boundary / circuit breaker stated on repeated phase verification failure
- [ ] Residual risks named
- [ ] No code unless user asked to execute
