# philosophy

Optimize for reading comprehension; change amplification, cognitive load, and unknown unknowns are defects.

## Earn this branch

Structural design, API contract creation, module decomposition, or structural tech debt.

## Checklist

1. Design it twice: the chosen design plus ≥1 rejected alternative, compared on interface simplicity, generality, and performance before committing.
   - Escalate only when the decision fixes a public contract or a seam with many callers: fan out 3 parallel subagents, each bound to one constraint (minimal entry points / maximal flexibility / trivial common case), then pick or hybridize. Never on `surgical` work.
2. Strategic over tactical: budget ~10–20% of the change for design improvement.
3. General-purpose interfaces; pull complexity down into the module; adjacent layers offer different abstractions.
4. Define errors out of existence before adding handling.
5. One design decision, one module ([`axioms.md`](axioms.md)).

## Anti-patterns (redesign triggers)

Shallow module; pass-through; information leakage; temporal decomposition; conjoined methods; interface docs exposing implementation; vague names (`data`, `result`, `info`).

## Sequencing

Apply at design/plan time (`$dev plan`), before mutating code. Unavoidable tactical debt → `harvest` `debt`.

## Done when

Chosen design plus ≥1 rejected alternative recorded; interfaces simplified; error states structurally minimized; debt addressed or handed to `harvest`.
