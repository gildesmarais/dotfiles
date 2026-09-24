# Axioms

Ride-along for every `$dev` `implement` (surgical included). Load this file — not `architecture/SKILL.md` — until `design` is earned; then load `architecture/SKILL.md` and matched `reference/<branch>.md`. Hold the change against:

- **Deep Modules:** small interface, substantial private behavior; no shallow pass-through bags.
- **Deletion Test:** removing or swapping a module must not cascade rewrites across unrelated consumers.
- **Single Ownership:** each fact, rule, or expansion algorithm has one authoritative owner — no dual ownership between validate and execute, or between two adapters.
- **Locality over Ceremony:** seams only where they buy testability or phased migration; wrong-layer domain surfaces fail locality even if deep.
- **Wire vs Domain Boundary:** domain types enforce invariants at construction; boundary adapters map wire primitives in and out; no application logic in serialization shells.
