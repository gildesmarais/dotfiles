# performance

Measure → baseline → optimize. Language-free stop rules only. No SIMD, allocator, or framework recipes here.

## Earn this branch

User asks for speed/allocations, a clear hot path exists, or measured evidence shows a bottleneck. Do not co-load on speculation alone.

## Checklist

1. **Measure first.** No “make it faster” without a baseline, profile, or an identified hot path from evidence.
2. **Isolate the bottleneck.** Prefer the narrowest reproduction (one path, one stage) before changing shared layout.
3. **Name the bottleneck class before the accelerator.** Classify the scarce resource: algorithm, data layout, allocation/ownership traffic, memory bandwidth & cache, syscall & I/O wait, compute-offload setup & transfer, or scheduler / core-class misfit. Do not pick SIMD, ring buffers, GPU, NPU, or similar until the class is evidenced.
4. **Prefer leverage over micro-tweaks.** Algorithm, data layout, and allocation cuts before low-level tricks.
5. **Treat hardware affinity as layout + seam work.** Zero-copy and unified-memory wins need one buffer ownership and contiguous lifetime across producers/consumers. Co-load `deep-modules` when CPU and an accelerator would each own a copy or a forked algorithm.
6. **Offload only when work ≫ setup.** Measure end-to-end including map, submit, sync, and readback. Tiny stages that lose to setup stay on the portable CPU path.
7. **Keep changes local** to the measured bottleneck unless a co-loaded `deep-modules` move already requires a layout change.
8. **Fidelity over reckless approximation** on correctness-sensitive paths.
9. **Verify two layers.** (a) Evidence the intended path ran (vectorized loop, shared buffer, correct core class). (b) End-to-end budget vs baseline. Naming an accelerator is neither layer.
10. **Stop when:** the measured goal is met; further gains need language/runtime recipes (hand off to `$dev` → `{lang}-dev` / overlay, project `AGENTS.md`, or optional third-party packs — do not paste those recipes into this file); or evidence does not support the change. Keep the portable path default; accelerate behind explicit opt-in and compare both (adapters, not domain).

## Anti-patterns

- Optimizing without a baseline.
- Starting from a platform capability checklist instead of a measured bottleneck class.
- Inventing language-specific recipe dumps in this skill.
- Expanding scope to “while we’re here” cleanups that are not on the measured path (route those to other branches or surgical `$dev` work).
- Refreshing published baselines outside a harness that actually updates them.
- Shipping unstable acceleration as the default — keep the portable path default; accelerate behind explicit opt-in and compare both.
- Forking scalar and accelerated copies of one hot-path algorithm (cue `deep-modules`).
- Counting “zero-copy” when a hidden serialize, format convert, or retain storm still crosses the seam.
- Optimizing for peak FLOPS while bandwidth-, alloc-, or scheduler-bound.
- Telemetry on the critical path you measure.
- Gating identity refresh or capture visibility behind sync/work throttles (cue `deep-modules`: freshness ≠ sync).
