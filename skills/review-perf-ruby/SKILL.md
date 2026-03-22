---
name: review-perf-ruby
description: Review Ruby code, branches, or PRs for performance risks and optimization opportunities. Use when the user asks for a performance review, wants explicit big-O analysis, requests fewer iterations or fewer allocations, asks whether Set/Hash/Array are the right data structures, wants better Enumerable usage, or wants architectural rearrangements for hot paths in Ruby code.
---

# Review Ruby Performance

Review the actual changed code before making recommendations. Prefer diff-first review against the default branch when the request is about a branch or PR.

Focus on findings, not generic advice. For each finding, cite file and line, explain the performance impact, and give concrete improvement options.

When checking Ruby core APIs or standard-library behavior, verify them instead of relying on memory alone. Use Dash MCP lookups against the installed Ruby docset first, then Context7 if needed, and only then official API docs or primary sources. Prioritize verifying `Enumerable`, `Enumerator::Lazy`, `Set`, `Hash`, `Array`, and `Data.define` semantics when they materially affect the recommendation.

## Review Workflow

1. Establish scope.

- Identify the target diff or files under review.
- Distinguish committed branch changes from unrelated local edits.
- Read the relevant code before forming conclusions. Gather enough local context to understand call sites, surrounding helpers, data flow, and whether the path is plausibly hot.
- If the user asked for a review, do not start editing unless they explicitly ask for fixes.

2. Find hot paths and repeated work.

- Look for nested loops, repeated regex scans, repeated parsing, repeated allocations, repeated object construction, repeated sorting, and repeated conversions between arrays/hashes/sets.
- Trace the same data through the pipeline. Flag cases where one stage computes facts and a later stage recomputes them.
- Prefer architectural rearrangements when they remove entire passes, repeated normalization, or repeated derivation of the same facts.

3. Analyze data structures and big-O.

- Check membership tests, deduplication, grouping, set operations, lookup tables, queue/stack behavior, and accidental quadratic scans hidden inside helpers.
- Prefer `Set` or `Hash` over repeated `Array#include?`, `Array#any?`, or linear scans when the collection is reused.
- Call out big-O explicitly when it matters, especially `O(n^2)` or hidden `O(n*m)` patterns.
- Check assignment patterns that duplicate memory without need: extra `dup`, `clone`, `to_a`, `transform_values`, `merge`, `flatten`, `compact`, `sort`, or `group_by` results that are immediately re-walked or partially discarded.
- In modern Ruby, treat `Set` as a strong default for repeated membership and dedupe work; do not recommend it when order, duplicates, or tiny one-off collections make arrays simpler and cheaper.

4. Analyze Enumerable usage.

- Prefer single-pass transforms with `each_with_object`, `filter_map`, `to_h`, `sum`, `tally`, or a targeted accumulator over long pipelines that materialize multiple intermediate arrays.
- Avoid replacing a clear single pass with a denser chain unless it actually removes work.
- Flag `map.select`, `select.first`, `group_by.values`, `flat_map.uniq`, `sort_by.first`, and similar chains when a single accumulator or early-exit loop would do less work.
- Check whether laziness or streaming would help, but do not recommend `Enumerator::Lazy` unless it avoids real materialization costs on a meaningful path.
- Distinguish readability wins from real performance wins.

5. Consider object-model changes.

- Look for ad-hoc hashes, positional arrays, or multi-value tuples that force repeated recomputation, repeated unpacking, or unclear contracts.
- Consider `Data.define` as the primary immutable-holder recommendation when a hot path repeatedly passes around derived facts.
- Good candidates: normalized strings, tokenized values, parsed numeric facts, scoring inputs, grouped aggregates, memo payloads passed between phases.
- Do not recommend `Data.define` if a plain local variable, block local, or tiny private helper is sufficient.

6. Validate with evidence.

- If local benchmarks, focused specs, or profiling output exist, use them.
- Do not report assumptions or unverified findings. If a concern depends on missing context, read more code until the claim is supportable or move it to open questions.
- If no evidence exists and the optimization is non-obvious, recommend a minimal benchmark or profiling shape.
- Prefer validation that isolates the suspected hot path: `Benchmark.ips` or `Benchmark.bmbm` for CPU-bound code, allocation-sensitive checks for memory churn, and request/query inspection when a Rails path is involved.

## Performance Heuristics

Prioritize findings in this order:

1. Remove repeated passes over the same data.
2. Replace the wrong data structure.
3. Hoist invariant work out of loops.
4. Cache or memoize expensive pure computations.
5. Reduce allocation churn from intermediate arrays/strings/hashes.
6. Improve constant factors only after the above.

## Ruby-Specific Review Points

- Check for accidental `O(n^2)` loops from repeated `include?`, `find`, `detect`, `index`, or `delete` against arrays inside iteration.
- Check for repeated string building, slicing, interpolation, symbolization, JSON parsing, time parsing, and numeric coercion in inner loops.
- Check for `map { ... }.compact`, `select { ... }.map`, `group_by { ... }.transform_values`, `sort_by { ... }.first`, and similar pipelines that can collapse into one pass or early exit.
- Check for repeated `dup`, `clone`, `merge`, `to_h`, `to_a`, or `flatten` that inflate memory assignment and allocation pressure.
- Check whether `Hash.new(0)`, `Hash` lookup tables, or `Set` membership would replace repeated scans more cheaply.
- Check whether `Data.define` would let the code compute immutable facts once and carry them across phases instead of recomputing or repeatedly unpacking hashes.
- Check for `group_by.values.filter_map.max_by` style pipelines that can become one accumulator pass.
- Check whether `Enumerable` chains allocate arrays where lazy or single-pass accumulation would be better.
- Check whether `Struct` or ad-hoc hashes are being used for immutable facts that would read more clearly as `Data.define`.
- Check whether memoization keys are stable and cheaper than recomputing.
- Check whether a branch introduced cleaner method boundaries but accidentally duplicated work across methods or classes.
- For Rails code, briefly check query count, eager-loading boundaries, repeated relation materialization, and per-record Ruby work before focusing on micro-optimizations.

## Architectural Rearrangement Patterns

Use these when they materially reduce work:

- Candidate/facts/ranking pipeline:
  collect items once, derive immutable facts once, rank/select from those facts.
- Normalize once at the boundary:
  normalize strings, parse tokens, coerce numbers/times, and derive lookup keys once before grouping or membership checks.
- Carry facts forward:
  pass precomputed facts into downstream phases instead of rediscovering them.
- Replace broad cleanup with earlier filtering:
  suppress bad candidates before expensive derivation, sorting, or rendering.
- Build indexes before matching:
  precompute `Hash` or `Set` indexes once, then resolve relationships or membership checks against them.
- Collapse multi-pass aggregation:
  accumulate counts, best candidates, or grouped results in one pass instead of `group_by` followed by several traversals.

## Output Format

Start with findings ordered by severity.

For each finding include:

- severity
- file and line
- evidence and supporting context from the code
- why it is slow or risky
- explicit big-O or constant-factor note when useful
- concrete improvement options
- short suggested rewrite when the optimization is straightforward

Then include:

- `Explicit optimization opportunities`
- `Open questions or uncertainty`
- `Benchmark suggestions`

## Review Style

- Be specific and direct.
- Do the reading needed to support each claim. Do not infer hot paths, repeated work, or API behavior without verifying them from the code and, when relevant, the docs.
- Prefer "this loop does an `Array#include?` lookup for every row, turning the pass into `O(n^2)`" over "could be optimized."
- Do not praise code unless it clarifies a tradeoff.
- If no material issues are found, say so explicitly and list residual low-confidence areas.
