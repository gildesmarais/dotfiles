# Perf

Performance lens, language-free. Non-Ruby APIs: verify via `$dev` API-truth. Ruby diffs → `ruby-dev` (+ rails overlay) after these checks.

## Method

- Confirm the path is hot from call sites and data flow; never assume.
- Repeated work: nested loops, repeated parse/allocation/construction/sort, needless conversions, facts recomputed across stages.
- Retries/fallbacks/multi-page work: is shared wall-clock metered once and honestly?
- Evidence: existing benchmarks/specs/profiles; for non-obvious claims propose a minimal benchmark isolating the hot path.

Priority: remove repeated passes → fix data structure → hoist invariants → cut intermediate allocations → constant factors last.

## Output

Severity-ordered, folded into `finish`. Per finding: file:line, code evidence, why slow, big-O/constant note, concrete options. Then `Explicit optimization opportunities`, `Open questions or uncertainty`, `Benchmark suggestions`. None found → say so plus low-confidence areas.
