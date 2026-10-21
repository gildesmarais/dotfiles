# Perf

Performance lens, language-free except § Ruby. Non-Ruby APIs: verify via `$dev` API-truth. Ruby diffs: verify `Enumerable`, `Enumerator::Lazy`, `Set`, `Hash`, `Array`, `Data.define` semantics against the Ruby docset when they affect the recommendation.

## Method

- Confirm the path is plausibly hot from call sites and data flow; never infer hot paths unverified.
- Repeated work: nested loops, repeated regex/parse/allocation/construction/sort, array↔hash↔set conversions; facts computed in one stage and recomputed later.
- Retries/fallbacks/multi-page work: is shared wall-clock metered once and honestly?
- Data structures: hidden `O(n^2)` / `O(n*m)`; reused membership → `Set`/`Hash`; needless copies re-walked or discarded.
- Readability wins ≠ performance wins; don't densify a clear single pass unless it removes work.
- Evidence: use existing benchmarks/specs/profiles; for non-obvious claims propose a minimal benchmark isolating the hot path.

Priority: remove repeated passes → fix data structure → hoist invariants → memoize pure expensive work → cut intermediate allocations → constant factors last.

## Rearrangements (when they remove real work)

Collect once → derive immutable facts once → rank/select; normalize at the boundary before grouping; carry facts forward; filter before expensive derivation/sort; build indexes before matching; one-pass aggregation instead of `group_by` + traversals.

## Ruby

- `include?`/`find`/`index`/`delete` on arrays inside iteration.
- Repeated string building, symbolization, JSON/time parsing, numeric coercion in inner loops.
- Collapsible chains: `map.compact`, `select.map`, `select.first`, `group_by.values`, `flat_map.uniq`, `sort_by.first` → `each_with_object` / `filter_map` / `to_h` / `sum` / `tally` / early exit.
- Excess `dup`/`clone`/`merge`/`to_h`/`to_a`/`flatten`/`compact`.
- `Hash.new(0)` / `Set` over scans; `Enumerator::Lazy` only when it avoids meaningful materialization.
- `Data.define` for immutable facts carried across phases — not when a local helper suffices.
- Rails: query count, eager loading, repeated relation materialization, per-record Ruby work before micro-opts. Benchmark with `Benchmark.ips` / `bmbm`.

## Output

Severity-ordered, folded into the `finish` report. Per finding: file:line, code evidence, why slow, big-O/constant note, concrete options, short rewrite when straightforward. Then `Explicit optimization opportunities`, `Open questions or uncertainty`, `Benchmark suggestions`. None found → say so plus low-confidence areas.
