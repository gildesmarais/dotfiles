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
- Anti-patterns: dump modules of unrelated helpers; twin structs that must stay in sync; adapters that grow domain branches.

## Sequencing

Work in small phases. Validate after each phase before the next. Prefer co-loading `refactor-types` when closed sets or primitive obsession sit on the same seams; co-load `performance` only when a measured bottleneck drives a layout move.
