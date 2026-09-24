# Perf

Performance lens, language-free except § Ruby. Non-Ruby APIs: verify via `$dev` API-truth against the matching docset. Ruby diffs: verify `Enumerable`, `Enumerator::Lazy`, `Set`, `Hash`, `Array`, `Data.define` semantics against the Ruby docset when they affect the recommendation.

## Method

- Confirm the path is plausibly hot from call sites and data flow; never infer hot paths or API behavior unverified — read more or move to open questions.
- Repeated work: nested loops, repeated regex/parse/allocation/construction/sort, array↔hash↔set conversions; facts computed in one stage and recomputed later.
- Retries/fallbacks/multi-page work: is shared wall-clock (and unlike costs) metered once and honestly?
- Data structures: hidden `O(n^2)` / `O(n*m)` in helpers; reused membership → `Set`/`Hash` (not for tiny, ordered, or duplicate-bearing one-offs); needless copies re-walked or discarded.
- Readability wins ≠ performance wins; don't densify a clear single pass unless it removes work.
- Evidence: use existing benchmarks/specs/profiles; for non-obvious claims propose a minimal benchmark isolating the hot path.

Priority: remove repeated passes → fix data structure → hoist invariants → memoize pure expensive work (stable, cheap keys) → cut intermediate allocations → constant factors last.

## Rearrangements (when they remove real work)

Collect once → derive immutable facts once → rank/select; normalize at the boundary before grouping/membership; carry facts forward; filter before expensive derivation/sort/render; build `Hash`/`Set` indexes before matching; one-pass aggregation instead of `group_by` + traversals.

## Ruby

- `include?`/`find`/`index`/`delete` on arrays inside iteration.
- Repeated string building, symbolization, JSON/time parsing, numeric coercion in inner loops.
- Collapsible chains: `map.compact`, `select.map`, `select.first`, `group_by.values`, `group_by.transform_values`, `flat_map.uniq`, `sort_by.first`, `group_by.values.filter_map.max_by` → `each_with_object` / `filter_map` / `to_h` / `sum` / `tally` / early exit.
- Excess `dup`/`clone`/`merge`/`to_h`/`to_a`/`flatten`/`compact`.
- `Hash.new(0)` / `Set` over scans; `Enumerator::Lazy` only when it avoids meaningful materialization.
- `Data.define` for immutable facts carried across phases instead of ad-hoc hashes/`Struct`/tuples — not when a local or tiny helper suffices.
- Cleaner method boundaries that silently duplicated work.
- Rails: query count, eager loading, repeated relation materialization, per-record Ruby work before micro-opts. Benchmark with `Benchmark.ips` / `bmbm`.

## Output

Severity-ordered, folded into the `finish` report. Per finding: file:line, code evidence, why slow, big-O/constant note, concrete options, short rewrite when straightforward (e.g. "`Array#include?` per row makes this pass `O(n^2)`", not "could be optimized"). Then `Explicit optimization opportunities`, `Open questions or uncertainty`, `Benchmark suggestions`. None found → say so plus low-confidence areas.
