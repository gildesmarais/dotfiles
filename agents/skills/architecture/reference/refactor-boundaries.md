# refactor-boundaries

Map wire/API/adapter contracts at boundary shells. Keep domain logic out of those shells; serialize and deserialize at the edge.

## Earn this branch

Wire/API contract redesign, adapter shells that grew domain branches, dual ownership of serialize/deserialize, or an explicit boundary-map ask.

## Checklist

1. **Contract map**
   - List inbound and outbound edges: HTTP/RPC handlers, CLI parsers, DB/ORM mappers, queue/event codecs, file/CSV readers.
   - For each edge: raw shape in → domain types at the shell → domain work inward; reverse outbound.
   - Name the owner of each map (one module or type family per edge — no twin mappers).
   - Keep published contract and runtime acceptance on one closed set — options accepted at runtime but absent from the published contract (or the reverse) are dual ownership of the contract.

2. **Domain out of shells**
   - Boundary shells parse, validate shape, map to/from domain types, and forward.
   - No business rules, policy branches, or multi-step workflows inside adapters.
   - If a shell already owns domain logic, extract before widening the contract.

3. **Serialize ownership**
   - One fact, one serializer home. Kill parallel encode/decode paths for the same wire shape.

- Prefer thin maps; do not invent a second abstraction layer for ceremony.
- Breaking wire changes: call out versioning or explicit migration — do not silent-shim forever.
- When compat is waived, delete the superseded hydrate, deprecation shims, and backward-compatibility alias constants — do not leave parallel old-shape paths beside the current path.
- Envelope variance (flat vs wrapped) is one parse concern — explicit modes, characterize both; keep the first parse permissive and harden inward.
- Alias tables at the edge beat renaming wire fields to match app vocabulary.

4. **Overlap routing**
   - Module depth / dual ownership of behavior → co-load `deep-modules`.
   - Primitive obsession / closed sets on the same seams → co-load `refactor-types`.
   - Measured hot path on a boundary → co-load `performance` only with a baseline.

## Sequencing

Work one edge (or one owned map) per phase. Validate after each phase → ≥1 Conventional Commit (format and phase law: [`CONTEXT.md`](../../CONTEXT.md)) before the next edge. Prefer co-loading `refactor-types` when maps still pass primitives deep; co-load `deep-modules` when adapters are shallow passthrough bags.

## Thin examples (illustrative only)

Inbound: handler receives raw JSON/params → constructs domain types → calls application code with types only.

Outbound: application returns domain values → shell maps to wire DTO/primitives → no domain predicates in the encoder.

Do not dump language-specific serde/ORM recipes here.
