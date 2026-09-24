# philosophy

Optimize for reading comprehension; treat change amplification, cognitive load, and unknown unknowns as defects.

## Earn this branch

Structural design, API contract creation, module decomposition, or accumulated structural tech debt.

## Checklist

1. Design it twice: compare ≥1 alternative on interface simplicity, generality, and performance before committing.
2. Strategic over tactical: budget ~10–20% of the change for design improvement.
3. Prefer general-purpose interfaces over special-purpose ones; pull complexity down into the module instead of pushing decisions or config to callers.
4. Adjacent layers offer different abstractions.
5. Define errors out of existence (redefine semantics, mask, aggregate) before adding handling.
6. One design decision lives in one module (see [`axioms.md`](axioms.md)).

## Anti-patterns (redesign triggers)

- Shallow module; pass-through method; information leakage (one decision in many modules).
- Temporal decomposition (split by execution order, not knowledge).
- Conjoined methods (one is unreadable without the other's implementation).
- Interface docs exposing implementation; comments restating code instead of constraints.
- Vague or hard-to-pick names (`data`, `result`, `info`) — the design is unclear.

## Sequencing

Apply at design/plan time (`$dev plan`) before mutating code. Unavoidable tactical debt is captured via `harvest` `debt` into `.agents/debt-ledger.md`.

## Done when

At least two alternative designs considered; interfaces simplified; error states structurally minimized; cognitive load and tech debt explicitly addressed.
