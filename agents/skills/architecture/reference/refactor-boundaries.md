# refactor-boundaries

Map wire/API/adapter contracts at boundary shells; keep domain out of them. Wire vs domain axiom: [`axioms.md`](axioms.md).

## Earn this branch

Wire/API contract redesign, adapter shells that grew domain branches, dual serialize/deserialize ownership, or a boundary-map ask.

## Checklist

1. **Contract map** — list inbound/outbound edges (HTTP/RPC, CLI, DB/ORM, queue/event codecs, file/CSV); per edge: raw in → domain at the shell → reverse outbound; one named map owner per edge (no twin mappers). Published contract and runtime acceptance are one closed set — options accepted but unpublished (or the reverse) are dual ownership.
2. **Domain out of shells** — shells parse, shape-validate, map, forward; no rules, policy branches, or workflows. Extract existing domain logic before widening the contract. Adapters wrapping foreign/legacy/system event loops contain and normalize unwinding faults at the boundary; foreign unwinding never bypasses concurrency state machines, task runners, or cleanup.
3. **Serialize ownership** — one serializer home per wire shape. Derived-cache freshness binds content identity, not size/time heuristics. A derived export outside the primary transaction still may not drop on error: if the vendor didn't accept/journal it, retain and retry with coalescing (cue `deep-modules` for outbox ownership).
4. **Compat** — breaking wire changes name versioning or explicit migration, never silent permanent shims. When compat is waived, delete superseded hydrate, deprecation shims, and alias constants — no parallel old-shape path.
5. **Edges** — envelope variance (flat vs wrapped) is one parse concern: explicit modes, characterize both, permissive first parse hardened inward. Alias tables at the edge beat renaming wire fields to app vocabulary.

## Sequencing

One edge (or owned map) per phase; validate → ≥1 Conventional Commit ([`../../CONTEXT.md`](../../CONTEXT.md)) before the next. Co-load `refactor-types` when maps pass primitives deep; `deep-modules` for passthrough adapters or behavior dual ownership; `performance` only with a baseline.

## Done when

Contract map for targeted edges; domain out of shells; serialize ownership clear; phases committed per Shared prep.
