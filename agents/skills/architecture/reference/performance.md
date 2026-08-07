# performance

Measure → baseline → optimize. Language-free stop rules only. No SIMD, allocator, or framework recipes here.

## Earn this branch

User asks for speed/allocations, a clear hot path exists, or measured evidence shows a bottleneck. Do not co-load on speculation alone.

## Checklist

1. **Measure first.** No “make it faster” without a baseline, profile, or an identified hot path from evidence.
2. **Isolate the bottleneck.** Prefer the narrowest reproduction (one path, one stage) before changing shared layout.
3. **Prefer leverage over micro-tweaks.** Algorithm, data layout, and allocation cuts before low-level tricks.
4. **Keep changes local** to the measured bottleneck unless a co-loaded `deep-modules` move already requires a layout change.
5. **Fidelity over reckless approximation** on correctness-sensitive paths.
6. **Stop when:** the measured goal is met; further gains need language/runtime recipes (hand off to `$dev` → `{lang}-dev` / overlay, project `AGENTS.md`, or optional third-party packs — do not paste those recipes into this file); or evidence does not support the change.

## Anti-patterns

- Optimizing without a baseline.
- Inventing language-specific recipe dumps in this skill.
- Expanding scope to “while we’re here” cleanups that are not on the measured path (route those to other branches or surgical `$dev` work).
- Refreshing published baselines outside a harness that actually updates them.
- Shipping unstable acceleration as the default — keep the portable path default; accelerate behind explicit opt-in and compare both.
- Forking scalar and accelerated copies of one hot-path algorithm (cue `deep-modules`).
- Telemetry on the critical path you measure.
- Gating identity refresh or capture visibility behind sync/work throttles (cue `deep-modules`: freshness ≠ sync).
