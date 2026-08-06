# refactor-types

Replace raw primitives and string classifications with domain types; move logic onto those types; keep wire mapping at boundaries.

## Earn this branch

Primitive obsession across modules, stringly closed sets, magic ints, parallel lookup tables, or an explicit type-driven refactor ask.

## Checklist

1. **Identify primitive obsession**
   - String categoricals passed across modules (`"swung"`, status labels, mode names).
   - Implicit units/invariants on bare numbers (seconds, Hz, dB, money).
   - Parallel static arrays or manual conditionals translating index ↔ label.

2. **Design domain types**
   - Value objects wrap primitives and enforce invariants at construction.
   - Domain enums (or equivalent closed sets) for limited categoricals.
   - Smart constructors / factories so invalid values cannot be built silently.

3. **Co-locate logic on types**
   - Move formatting, mappings, predicates, and conversions onto the type.
   - Consumers call queries/methods — not distant match soup on primitives.

4. **Boundary mapping**
   - Map raw wire/DB/CSV into domain types at the edge (inbound).
   - Serialize domain types back to primitives outbound.
   - Keep application logic out of serialization shells.
   - Heavy adapter-contract redesign co-loads `refactor-boundaries`; keep maps thin and local when only types move.

5. **Clean consumers**
   - Rewrite call sites to the typed API.
   - Delete obsolete parsers, fallbacks, and parallel lookup tables.

## Anti-patterns

- Validate by structure, not by substring ban on identifiers.
- Immutable holders take a defensive handoff the caller cannot mutate.
- Presence is not permission; one bag is not two audiences.
- Durable bags hold serializable primitives; rehydrate domain types at the read seam — methods do not survive a round-trip.
- Domain absence and wire absence are different closed sets — map each layer’s legal inhabitant; empty stand-ins and nulls are not interchangeable.
- Capture adapters may accept tokens; resolve before domain construction — do not push domain rejection into the capture edge.
- Wire vocabulary stays at the wire — normalize aliases into an app closed set at one edge; do not “helpful rename” schema fields.

## Thin examples (illustrative only)

Value object shape (any language): wrap a scalar; reject out-of-range in the constructor; expose a read accessor.

Closed set shape: finite variants; predicates on the type (`has_vocals?` / `has_vocals`); map to/from wire strings only at the boundary.

Do not dump language-specific serde/ORM recipes here.
