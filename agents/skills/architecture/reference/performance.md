# performance

Measure → baseline → optimize. Language-free stop rules; no SIMD, allocator, or framework recipes here.

## Earn this branch

Speed/allocation ask, an evidenced hot path, or a measured bottleneck. Never co-load on speculation.

## Checklist

1. Baseline, profile, or evidenced hot path before any change; narrowest reproduction (one path, one stage) before touching shared layout.
2. Name the bottleneck class before the accelerator: algorithm, data layout, alloc/ownership traffic, bandwidth & cache, syscall & I/O wait, offload setup & transfer, scheduler / core-class misfit. No SIMD, ring buffers, GPU, NPU until the class is evidenced; algorithm/layout/alloc cuts before low-level tricks.
3. Hardware affinity is layout + seam work: zero-copy / unified memory needs one buffer owner and contiguous lifetime. Co-load `deep-modules` when CPU and accelerator would each own a copy or a forked algorithm.
4. Offload only when work ≫ setup, measured end-to-end (map, submit, sync, readback).
5. Stay local to the measured bottleneck unless a co-loaded `deep-modules` move requires layout change; no "while we're here" cleanups.
6. Fidelity over approximation on correctness-sensitive paths. Never meet an SLA by omitting semantic fields from a fast path claiming parity — change scheduling or placement, never meaning (cue `deep-modules` when delivery modes forked the schema).
7. Verify two layers: (a) evidence the intended path ran (vectorized loop, shared buffer, core class); (b) end-to-end budget vs baseline.
8. Stop when the goal is met, evidence doesn't support the change, or gains need language/runtime recipes → `$dev` → `{lang}-dev` / overlay / `AGENTS.md` (never paste recipes here). Portable path stays default; acceleration behind explicit opt-in, compared against it.

## Anti-patterns

- Starting from a platform capability checklist instead of a measured bottleneck class; peak-FLOPS work while bandwidth-, alloc-, or scheduler-bound.
- Refreshing published baselines outside the harness that owns them.
- Forking scalar and accelerated copies of one algorithm (cue `deep-modules`).
- Claiming zero-copy while a hidden serialize, format convert, or retain storm crosses the seam.
- Telemetry on the measured critical path.
- Gating identity refresh or capture visibility behind sync throttles (cue `deep-modules`: freshness ≠ sync).

## Done when

Baseline or hot path identified before changes; stop rules applied; no language-specific recipe invented here.
