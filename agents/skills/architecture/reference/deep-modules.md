# deep-modules

Module depth is the spine for structural design work. Prefer deep modules: small interface, substantial private behavior.

## Earn this branch

Dual ownership of one fact, passthrough bags, shallow multi-call husks, or the user asks for structural cleanup / deepen.

## Checklist

- Apply the deletion test to candidate modules and thin re-export bags.
- Prefer deep modules: small interface, substantial private behavior.
- Kill passthrough bags and dual ownership of the same fact.
- One public name per schema or type — delete aliases that keep both live.
- Shared kernels import the owning type module, not a duplicate re-export.
- Prefer ownership and seam failure signals when surveying deepen work; ignore metric smell counts that do not name dual ownership, passthrough, or deletion-test failure.
- When surveying many peers, infer canonical shape before proposing seams (survey mode when structural signals match).
- Wrong-layer domain surfaces fail locality even if deep internally — relocate before deepening in place.
- Narrow stage and dependency interfaces; one fact, one home.
- Introduce seams only where they buy phased moves or testability — not for ceremony.
- Share one expansion path between validate and run — dual ownership of expansion greenlights configs that fail later.
- Own one remaining wall-clock across fallbacks and pagination; pass it down.
- Give shared meters and policies one construction home; require them explicit at the pipeline boundary and prove omission fails with a discriminating test.
- Name every dependency the path relies on — invisible contracts fail closed in production.
- Cut over only after the replacement owns the implementation one-way — reverse calls into the old home are still dual ownership.
- When relocating a predicate's ownership, verify each touched call site's argument shape still matches what the predicate inspects.
- Fold detect-and-persist into one critical section — check-then-act across suspension points is dual ownership of uniqueness.
- Keep freshness and sync as different jobs — do not gate identity reload or capture visibility behind work throttles meant for sync.
- Quarantine permanent validation failures on one unit so sequential siblings still proceed.
- Committed primary survives failed enrichment — nest enrichment status on the success value; retry enrichment on the already-committed resource; do not unwind the primary.
- On conflict, revert to last-known-good — do not invent a new identity and retry.
- Route key stale unless live state matches — if navigation names an entity the live result does not hold, fall back to create/list shell; never render a mismatched result.
- When two runtimes encode the same closed decision, share one fixture corpus both assert against.
- Spec twins that re-encode the same algorithm: probe production for dual ownership before collapsing to shared examples only; if two adapters share rules, extract one kernel and keep thin adapters — do not invent a second production home when the lib path is already single-owner.
- Anti-patterns: dump modules of unrelated helpers; twin structs that must stay in sync; adapters that grow domain branches.

## Sequencing

Work in small phases. Validate after each phase before the next. Prefer co-loading `refactor-types` when closed sets or primitive obsession sit on the same seams; co-load `performance` only when a measured bottleneck drives a layout move.
