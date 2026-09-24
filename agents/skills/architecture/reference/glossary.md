# Glossary

Craft terms for every architecture branch and survey mode. Store vocabulary: [`../../CONTEXT.md`](../../CONTEXT.md).

- **module**: one coherent unit of ownership with one job.
- **interface**: the narrow contract callers depend on (types, functions, errors).
- **depth**: behavior hidden behind a small interface.
- **seam**: a deliberate cut to swap, test, or phase work.
- **adapter**: thin translation at a boundary (IO, FFI, wire, DB); owns no domain rules.
- **leverage**: unlocks many call sites or clears a bug class — not LOC churn.
- **locality**: related facts live together; one fact, one home.
- **deletion test**: delete/swap the unit; if callers lose nothing meaningful it was a passthrough — remove or merge.
- **canonical shape**: agreed peer layout for one kind (repo law + majority; law wins).
- **snowflake**: peer breaking canonical shape for the same job without an owned exception.
- **promote** / **relocate** / **fold**: move up only when truly shared and domain-free (else push domain down) / move to the owning layer / absorb a micro-module into its single consumer.
- **bottleneck class**: the scarce resource on the hot path (layout, alloc, bandwidth, syscalls, offload transfer, scheduler) — not the first fancy API.
- **heterogeneous placement**: which execution unit owns a stage given shared vs copied memory; a seam decision, not a micro-opt.
- **zero-copy boundary**: producer and consumer see the same bytes with no intermediate owned buffer; proven, not asserted.
