# Axioms

Always-on for code changes. Repo structure and `AGENTS.md` win; axioms fill gaps and break ties. **Before** / **After** apply to new files, new modules, or multi-file edits; single-file fixes skip both.

**Before:** read peers and the owning module; state in three lines: code reused or extended; owner module; new abstraction and why (default: none).

Hold the change against:

- **Conform to Peers:** extend existing helpers and patterns first; match neighbors' structure and naming; new behaviour in a shared component is opt-in per caller.
- **Single Ownership:** each fact, rule, or expansion algorithm has one owner. No dual ownership between validate and execute, or between adapters; a rule change moves every consumer onto the owner.
- **Deep Modules:** small interface, substantial private behavior; no shallow pass-through bags.
- **Earn Every Abstraction:** extract on the third real use; seams only for testability or phased migration. Inline test: if complexity vanishes, it was a wrapper.
- **Boundaries:** dependencies point toward the domain; domain types enforce invariants at construction; adapters map wire primitives in and out; no application logic in serialization shells or the wrong layer.

**After:** on `git diff`, list each new file, class, and function. Flag wrappers with one caller or one method; confirm placement matches peers. Fix before reporting.

**Report:** one line: reused / owner / new abstractions (or none).

Dual ownership, shallow modules, boundary mapping, measured perf, or a named pattern → load `architecture`.
