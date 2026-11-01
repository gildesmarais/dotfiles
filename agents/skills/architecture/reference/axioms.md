---
description: Architecture axioms for any code change — reuse first, one owner, no shallow wrappers
alwaysApply: true
---

# Axioms

Always-on for any code change; hosts load this file directly. Repo structure and `AGENTS.md` win — axioms fill gaps and break ties. Scope for **Before** / **After**: new files, new modules, or edits spanning files; a single-file fix skips both.

**Before:** read peer files and the owning module, then state in three lines: existing code reused or extended; owner module; new abstraction and why (default: none).

Hold the change against:

- **Conform to Peers:** extend existing helpers and patterns before inventing; match how neighboring code is structured and named.
- **Single Ownership:** each fact, rule, or expansion algorithm has one authoritative owner — no dual ownership between validate and execute, or between two adapters.
- **Deep Modules:** small interface, substantial private behavior; no shallow pass-through bags.
- **Earn Every Abstraction:** extract on the third real use, not the first; seams only where they buy testability or phased migration. Inline it: if the complexity vanishes, it was a wrapper; if it reappears across many callers, it earns its place.
- **Boundaries:** dependencies point toward the domain; domain types enforce invariants at construction; adapters map wire primitives in and out; no application logic in serialization shells or the wrong layer.

**After:** on `git diff`, list each new file, class, and function. Apply the inline test; flag any wrapper with one caller or one method; confirm placement matches peers. Fix before reporting.

**Report:** one line — reused / owner / new abstractions (or none).

Dual ownership, shallow modules, boundary mapping, measured perf, or a named pattern → load `architecture`.
