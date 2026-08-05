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

### 2026-08-04 — fix/harden harvest (scarce reverts)

Consult when preventing dual ownership of validate/runtime, deadlines, guards, meters, or published contracts. Signal is forward harden / review-follow-up loops, not rollbacks.

11. **Validate the same expanded inputs the runtime uses.** A validator that inspects raw templates while execution expands first greenlights configs that fail later — one expansion path, shared by validate and run. _(deep-modules, refactor-boundaries)_
12. **Share one remaining wall-clock across fallbacks and pagination.** Per-attempt static timeouts under multi-strategy or multi-page work recreate deadline bugs; own remaining time once and pass it down. _(deep-modules, performance)_
13. **Run a body/policy guard at exactly one lifecycle point.** Checking the same surface in more than one place duplicates work and can disagree; pick a single owner and keep adapters returning raw payload. _(deep-modules)_
14. **Split accounting axes that only look alike.** Primary quota and secondary work must not share one meter, or secondary work steals primary capacity. _(deep-modules, refactor-types)_
15. **Promote a public collaborator instead of reaching private surface.** Specs that assert through private reach are a missing seam; extract the unit under test to a narrow public interface. _(deep-modules)_
16. **Keep published contract and runtime acceptance on one closed set.** Options accepted at runtime but absent from the published contract (or the reverse) are dual ownership of the contract. _(deep-modules, refactor-boundaries)_
17. **Validate by structure, not by substring ban.** Character-level rejects on identifiers over-block valid forms and under-specify which components are unsafe. _(refactor-types)_
18. **Treat streaming, decoding, and empty-body recovery as one adapter concern.** Stream limits without decoding — or success with an empty streamed body — produce false-success responses. _(deep-modules)_
19. **Resolve relative references against the current document base.** Multi-page work that always uses the first location as base is dual ownership of “document base”; pass the current page’s location into resolution. _(deep-modules)_
20. **Immutable holders must not remain mutable by the caller.** Accepting external collections without a defensive handoff the caller cannot mutate voids the immutability contract the type claims. _(refactor-types)_

### 2026-08-05 — fix/revert year harvest

Corpus: structural lessons from a year of fix and revert commits. Signal is revert-and-harden classes, not feature dumps.

21. **Own the seam that failed.** Absorbing a serialize, cache, or encode failure into a neighboring layer invites revert; put format and encoding where the boundary already lives. _(deep-modules, refactor-boundaries)_
22. **Invisible contracts fail closed in production.** Assumed return shapes, forgotten reload dependencies, and incomplete cache identity skip silently until users feel them—name every dependency the path relies on. _(deep-modules, performance)_
23. **Cut over only after the replacement seam exists.** Removing a queryable or enforceable path before its successor is live is an incomplete migration. _(deep-modules)_
24. **Presence is not permission, and one bag is not two audiences.** Existence without an active set, and self-only fields on shared payloads, are the same disclosure class. _(refactor-types, deep-modules)_
25. **A surgical fix stays on one surface.** Drive-by edits on a second surface travel with the revert when the primary fix is wrong. _(deep-modules)_
26. **Derive; do not re-ledger.** When components already own the truth, a second full pass is dual ownership of the same fact. _(deep-modules, performance)_

### 2026-08-05 — measured-perf commits harvest

Corpus: structural lessons from encoder/hot-path performance commits (stage benches, portable-vs-accelerated seams, baseline republish). Signal is measured-perf failure classes — not SIMD/allocator recipes.

27. **Refresh published baselines only through a harness that actually updates them.** A broken publish path leaves stale numbers that look like evidence. _(performance)_
28. **Instrument the stage you intend to change before tuning it.** End-to-end alone hides which stage moved and invites drive-by micro-tweaks elsewhere. _(performance)_
29. **Default the portable path; accelerate behind an explicit opt-in and compare both.** Unstable acceleration as the ship-default conflates buildability with speed claims. _(performance)_
30. **Republish the baseline when the host or harness changes.** Cross-machine or cross-harness deltas are not wins. _(performance)_
31. **Keep one algorithm surface over swappable acceleration backends.** Forked scalar and accelerated copies are dual ownership of the hot path. _(deep-modules, performance)_
32. **Keep telemetry off the critical path you measure.** Observability on the hot path both slows and contaminates the baseline. _(performance)_
33. **Separate exploratory slower algorithms from the production speed path.** Exploration and ship-default must not share one gate. _(performance, deep-modules)_
34. **Decouple input feeding from hot-path accumulators.** Shared bags for source context and working frames couple unrelated lifetimes and block layout changes. _(deep-modules, performance)_
35. **Match iteration nesting to storage order on the measured stage.** Wrong nesting burns bandwidth without changing the algorithm. _(performance)_
