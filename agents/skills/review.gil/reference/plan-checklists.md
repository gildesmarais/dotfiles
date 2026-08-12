# Plan-mode checklists (embed only)

Checklists for **`$dev` `plan`** — not a findings report. Post-implement: full **`review.gil` findings**. SoT: [`dev/reference/plan-pipeline.md`](../../dev/reference/plan-pipeline.md).

## finish (always)

- [ ] One home per fact; golden-path invariants (cite `AGENTS.md` if present)
- [ ] Non-goals + residual risks with mitigations

## tests (behavior changes)

- [ ] In-process over UI/E2E unless repo requires otherwise; no sleep-based async

## perf (performance section)

- [ ] Budgets + measure method; hot path isolated; optimize only measured breaches

## security (sandbox/boundary)

- [ ] Capabilities justified; boundaries validated; no secrets/PII in logs

## observability (≥2 phases)

- [ ] Log category per subsystem; levels + privacy; bridge error path if applicable
