# Axioms

Ride-along for every `$dev` `implement` (surgical included). Load this file — not `architecture/SKILL.md` — until `design` is earned. Hold the change against these axioms.

- **Deep Modules:** Small interface surface, substantial private behavior. Avoid shallow pass-through bags.
- **Deletion Test:** Candidate modules must pass the deletion test — removing or swapping a module should not cause cascading rewrites across unrelated consumers.
- **Single Ownership:** One fact, rule, or expansion algorithm has exactly one authoritative owner. Eliminate dual ownership between validate and execute, or between two adapters.
- **Locality over Ceremony:** Introduce seams only where they buy testability or phased migration. Wrong-layer domain surfaces fail locality even if deep internally.
- **Wire vs Domain Boundary:** Domain types enforce invariants at construction; boundary adapters map wire primitives inbound and outbound. Keep application logic out of serialization shells.

When `design` is earned, load `architecture/SKILL.md` (branch pick) and the matched `reference/<branch>.md` files.
