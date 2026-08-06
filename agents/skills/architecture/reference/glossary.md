# Glossary

Operational defs shared by every architecture branch and survey mode.

| Term                | Meaning here                                                                                                        |
| ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **module**          | A coherent unit of ownership (crate/module/package or clear boundary) with one job.                                 |
| **interface**       | The narrow contract callers depend on: types, functions, errors — not private guts.                                 |
| **depth**           | How much useful behavior hides behind a small interface. Deep is good when the interface stays narrow.              |
| **seam**            | A deliberate cut where you can swap, test, or phase work without rewriting everything.                              |
| **adapter**         | Thin translation at a boundary (IO, FFI, wire, DB) that must not own domain rules.                                  |
| **leverage**        | Change that unlocks many call sites or clears a whole class of bugs — not LOC churn.                                |
| **locality**        | Related facts and decisions live together; one fact has one home.                                                   |
| **deletion test**   | If you delete the module/type and nothing meaningful breaks for callers, it was a passthrough — remove or merge it. |
| **canonical shape** | Agreed peer layout for modules of one kind (repo law + majority practice; law wins on conflict).                    |
| **snowflake**       | Peer that breaks canonical placement/shape for the same job without an owned exception.                             |
| **promote**         | Move a surface up only when it is truly shared and domain-free; otherwise push domain down.                         |
| **relocate**        | Move a unit to its owning module/layer (wrong home → right home).                                                   |
| **fold**            | Absorb a micro-module into one consumer home when it fails the deletion test or has a single owner.                 |
