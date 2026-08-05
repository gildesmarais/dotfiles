# Glossary

Operational defs shared by every architecture branch.

| Term              | Meaning here                                                                                                        |
| ----------------- | ------------------------------------------------------------------------------------------------------------------- |
| **module**        | A coherent unit of ownership (crate/module/package or clear boundary) with one job.                                 |
| **interface**     | The narrow contract callers depend on: types, functions, errors — not private guts.                                 |
| **depth**         | How much useful behavior hides behind a small interface. Deep is good when the interface stays narrow.              |
| **seam**          | A deliberate cut where you can swap, test, or phase work without rewriting everything.                              |
| **adapter**       | Thin translation at a boundary (IO, FFI, wire, DB) that must not own domain rules.                                  |
| **leverage**      | Change that unlocks many call sites or clears a whole class of bugs — not LOC churn.                                |
| **locality**      | Related facts and decisions live together; one fact has one home.                                                   |
| **deletion test** | If you delete the module/type and nothing meaningful breaks for callers, it was a passthrough — remove or merge it. |

Orientation pointers (not required reading):

| Glossary term          | Related ideas                                                                                                      |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------ |
| **module** / **depth** | Information hiding; deep modules = small interface + substantial private behavior.                                 |
| **interface**          | What callers must know. Shrink accidental surface; contracts live at module edges.                                 |
| **seam**               | Cuts that buy phased moves or testability — not ceremony.                                                          |
| **adapter**            | Boundary translation. Domain rules stay out.                                                                       |
| **leverage**           | Structural change that removes a class of mistakes or unlocks many call sites.                                     |
| **locality**           | One fact, one home; decisions co-located with enforcement.                                                         |
| **deletion test**      | If deleting the unit changes nothing meaningful for callers, it was a passthrough. Practical check, not a theorem. |
