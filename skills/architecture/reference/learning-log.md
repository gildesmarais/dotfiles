# Learning log

Macro-level rules for an expert agent. No product nouns, paths, schemas, or worked examples. One imperative sentence + branch tags. Grow only via the harvest protocol in `SKILL.md`.

### 2026-08-04 — deepen harvest (ported)

1. **Mirroring into a third bag is dual ownership.** If A owns a fact and a later consumer only sees it because A copied into B, delete the copy and consume A; stale B fields must fail a characterization test. _(deep-modules)_
2. **Kitchen-sink accumulators fail the deletion test.** Typed stage inputs/outputs only; keep the outbound wire contract stable while internal bags stay narrow and composable. _(deep-modules, refactor-types)_
3. **Seams must buy lifecycle or testability.** A facade that inverts real call order—or is a shallow multi-call husk—fails the deletion test. _(deep-modules)_
4. **One fact, one decision site.** Dual semantics for one derived value will fork; decide once at the owning stage and pass the result down. _(deep-modules)_
5. **Assembly is a field map; domains own behavior.** Composition/serialization shells must not own algorithms or policy; move logic and its tests into the owning module; drop compatibility re-exports when breaks are allowed. _(deep-modules, refactor-boundaries)_
6. **Orchestrators are linear glue over owned stage outcomes.** Narrow each stage to the config/result it actually reads; move large buffers across stages — do not clone by default. _(deep-modules, performance)_
7. **Forked IO policies share one write core via intent.** Encode policy variants as a closed set over a single path; named constructors beat silent default-drift on knobs that must not inherit. _(refactor-types, deep-modules)_
8. **Policy lives with enforcement.** Gates belong next to the writer; dual writers share insert helpers so allow-sets cannot diverge — assert producer keys ⊆ policy. _(deep-modules)_
9. **Guards that hide root causes are cover-ups.** Typed errors over clamps that paper over load/IO failures; unit mismatches on bare scalars get distinct types at the edge, not comments. _(refactor-types, deep-modules)_
10. **Accidental public surface and early boundary context are debt.** Drop unused public surface; inject host/render/write context at the adapter boundary — not into early domain bags. _(deep-modules, refactor-boundaries)_
