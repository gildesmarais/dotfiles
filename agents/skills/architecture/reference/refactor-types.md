# refactor-types

Primitives and string classifications → domain types with logic on them; wire mapping stays at boundaries ([`axioms.md`](axioms.md)).

## Earn this branch

Primitive obsession across modules, stringly closed sets, magic ints, parallel lookup tables, or a type-driven refactor ask.

## Checklist

1. **Find** string categoricals crossing modules, bare numbers with implicit units/invariants (seconds, Hz, dB, money), parallel index ↔ label tables.
2. **Design** value objects enforcing invariants at construction, closed enums, smart constructors — invalid values unbuildable.
3. **Co-locate** formatting, mappings, predicates, conversions on the type; consumers call methods, not match soup.
4. **Map at edges** inbound/outbound; heavy adapter-contract redesign co-loads `refactor-boundaries`.
5. **Clean consumers** onto the typed API; delete obsolete parsers, fallbacks, lookup tables.

## Anti-patterns

- Validate by structure, not substring bans on identifiers.
- Immutable holders take a defensive handoff the caller cannot mutate.
- Presence is not permission; one bag is not two audiences.
- Durable bags hold serializable primitives; rehydrate domain types at the read seam — methods don't survive a round-trip.
- Domain absence ≠ wire absence — map each layer's legal inhabitant; empty stand-ins and nulls aren't interchangeable.
- Facts needing a peer/catalog set are a different closed set from single-record extracts — don't force membership onto a per-record DTO (cue `deep-modules`).
- Durable-operation results are a typed closed set (committed / rejected / indeterminate), not void plus logs.
- Capture adapters may accept tokens; resolve before domain construction — don't push domain rejection into the capture edge.
- Normalize wire aliases into an app closed set at one edge; don't "helpfully" rename schema fields.

## Done when

Primitive obsession at target cleared or scoped; logic on types; consumers cleaned; boundaries mapped.
