# Docs — `architecture`

ADRs, design notes, diagrams, system overviews, boundary and integration-flow docs. Goal: a reader can see boundaries, reason about data/control flow, identify constraints, and change the system without breaking critical behavior.

## Evidence ladder

1. live runtime behavior and observable system effects
2. executable entrypoints and boundary handlers
3. enforced interfaces (schemas, API contracts, storage models, event definitions)
4. tests exercising real integration paths
5. configuration, scripts, generated artifacts
6. existing architecture documents (only to detect contradiction)

Live runtime impractical → continue down the ladder and report the tier reached.

## Procedure

1. Name the decisions the doc supports and the behavior a reader must not break.
2. Trace key flows from real entrypoints through boundaries and enforced interfaces.
3. Record constraints, failure modes, propagation, and fallback/recovery.
4. Cut: history unless it explains a current constraint, removed components, speculative architecture, diagrams that don't match behavior. Never remove constraints that affect correctness.
5. Rewrite: **System overview** · **Components and boundaries** · **Data and control flow** · **Constraints and invariants** · **Failure modes**. Diagrams only when they match reality.
6. Validate: flows match execution paths; constraints enforced; interfaces exist and match implementation.

## Stopping rule

- Core flows and boundaries verified → rewrite verified sections; isolate unknowns explicitly.
- Core flows unverifiable → do not rewrite the main narrative as settled; produce a constrained gap report naming the next sources to inspect.

## Handoff additions

- verification tier reached for the main claims
- key constraints and flows clarified
- outdated assumptions removed
