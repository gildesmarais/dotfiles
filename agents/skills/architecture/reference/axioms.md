# Axioms

Always-on for any code change; hosts load this file directly. Repo structure and `AGENTS.md` win — axioms fill gaps and break ties. Scope for **Before** / **After**: new files, new modules, or edits spanning files; a single-file fix skips both.

**Before:** read peer files and the owning module, then state in three lines: existing code reused or extended; owner module; new abstraction and why (default: none).

Hold the change against:

- **Deep Modules:** small interface, substantial private behavior; no shallow pass-through bags.
- **Deletion Test:** removing or swapping a module must not cascade rewrites across unrelated consumers.
- **Single Ownership:** each fact, rule, or expansion algorithm has one authoritative owner — no dual ownership between validate and execute, or between two adapters.
- **Locality over Ceremony:** seams only where they buy testability or phased migration; wrong-layer domain surfaces fail locality even if deep.
- **Wire vs Domain Boundary:** domain types enforce invariants at construction; boundary adapters map wire primitives in and out; no application logic in serialization shells.

**After:** on `git diff`, list each new file, class, and function. Apply the deletion test; flag any wrapper with one caller or one method; confirm placement matches peers. Fix before reporting.

**Report:** one line — reused / owner / new abstractions (or none).

Dual ownership, shallow modules, boundary mapping, measured perf, or a named pattern → load `architecture`.
