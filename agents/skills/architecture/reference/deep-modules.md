# deep-modules

Module depth is the spine for structural design work. Prefer deep modules: small interface, substantial private behavior.

## Earn this branch

Dual ownership of one fact, passthrough bags, shallow multi-call husks, or the user asks for structural cleanup / deepen.

## Checklist

- Apply the deletion test to candidate modules and thin re-export bags.
- Prefer deep modules: small interface, substantial private behavior.
- Kill passthrough bags and dual ownership of the same fact.
- Narrow stage and dependency interfaces; one fact, one home.
- Introduce seams only where they buy phased moves or testability — not for ceremony.
- Share one expansion path between validate and run — dual ownership of expansion greenlights configs that fail later.
- Own one remaining wall-clock across fallbacks and pagination; pass it down.
- Name every dependency the path relies on — invisible contracts fail closed in production.
- Cut over only after the replacement seam exists; incomplete migrations invite revert.
- Anti-patterns: dump modules of unrelated helpers; twin structs that must stay in sync; adapters that grow domain branches.

## Sequencing

Work in small phases. Validate after each phase before the next. Prefer co-loading `refactor-types` when closed sets or primitive obsession sit on the same seams; co-load `performance` only when a measured bottleneck drives a layout move.
