# Plan-mode checklists (embed only)

Checklists for **`$dev` `plan`** — not a findings report. Post-implement: full **`review.gil` findings**. SoT: [`dev/reference/plan-pipeline.md`](../../dev/reference/plan-pipeline.md).

## finish (always)

- [ ] One home per fact; golden-path invariants (cite `AGENTS.md` if present)
- [ ] Non-goals + residual risks with mitigations

## tests (behavior changes)

- [ ] Flight height evaluated by default: pure unit base for domain/math, focused fakes for component, real I/O for integration; in-process over heavy UI harness; no sleep-based async; test friction diagnosed as production seam defects.

## perf (performance section)

- [ ] Budgets + measure method; hot path isolated; optimize only measured breaches

## security (sandbox/boundary)

- [ ] Capabilities justified; boundaries validated; no secrets/PII in logs

## observability (≥2 phases)

- [ ] Log category per subsystem; levels + privacy; bridge error path if applicable
