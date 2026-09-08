# philosophy

System complexity is incremental. Adopt a zero-tolerance mindset for change amplification, cognitive load, and unknown unknowns. Optimize strictly for reading comprehension over write speed.

## Earn this branch

The task involves structural design, API contract creation, module decomposition, or reviewing accumulated structural tech debt.

## Core Axioms

1. **Strategic over Tactical:** Invest 10-20% of development time in design improvements. Working code is a byproduct; the primary increments of software development are robust abstractions.
2. **Design it Twice:** Force the consideration of at least one alternative design (comparing interface simplicity, generality, and performance) before committing to an approach.
3. **General-Purpose Interfaces:** Build the most general-purpose interface possible to cleanly separate from special-purpose implementation code.
4. **Different Layers, Different Abstractions:** Ensure adjacent layers offer entirely different abstractions. A pass-through method signals flawed responsibility splitting.
5. **Pull Complexity Downward:** The module must absorb unavoidable complexity internally rather than pushing hard decisions or configurations to callers.
6. **Define Errors Out of Existence:** Redefine semantics, mask exceptions, or aggregate handling to make error states structurally impossible.
7. **Information Hiding:** Encapsulate design decisions. When the same design decision is reflected in multiple modules, information has leaked.

## Red Flags Matrix

Trigger a failure or redesign when encountering these signals during code review or planning:

| Signal                     | Meaning                                                                                                   |
| -------------------------- | --------------------------------------------------------------------------------------------------------- |
| **Shallow Module**         | Interface is as complex as its implementation.                                                            |
| **Information Leakage**    | The same design decision is reflected in multiple modules.                                                |
| **Temporal Decomposition** | Modules are split by execution order, not by encapsulated knowledge.                                      |
| **Pass-Through Method**    | A layer simply forwards arguments without providing a new abstraction.                                    |
| **Conjoined Methods**      | Understanding one method requires reading the implementation of another.                                  |
| **Impl Contamination**     | Interface documentation exposes internal implementation details.                                          |
| **Comment Repeats Code**   | A comment is just an English translation of the code rather than explaining the _why_ or constraints.     |
| **Vague Naming**           | A name is too generic (`data`, `result`, `info`) or hard to pick, indicating the design itself is flawed. |

## Sequencing

Apply these axioms during the design and planning phase (via `$dev plan`) before code is mutated. If tactical programming is unavoidable due to external constraints, the resulting tech debt must be captured via the `harvest` skill into the `.agents/debt-ledger.md`.
