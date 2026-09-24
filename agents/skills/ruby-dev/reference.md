# ruby-dev reference

Ruby/RSpec execution postures only; craft → `architecture`, test-quality judgment → `review.gil` `tests`. Grow only with Ruby-specific lessons (≤~10 bullets per harvest).

## Spec twins → lib probe

1. **Classify before collapsing.** Mirrored `describe` blocks / option-forwarding matrices are **spec-only** (production already single-path → shared_examples / table-drive / thin the extra layer) or **dual-ownership** (two production homes encode the same rules → shared kernel + thin adapters, shared fixtures). Don't invent a production fold when the lib is single-owner.
2. **Shared rule kernel, not a mega-class.** Pure field rules in one module; adapters only traverse and call; one fixture corpus asserted by both (see architecture `deep-modules`).
3. **Raise flight before adding doubles.** Fixture/HTML/JSON → observable outcomes over `have_received(:new)` skip-graphs and `instance_variable_get` / `send` pins.

## RSpec suite hygiene

4. Matrices (option-forwarding, routing URL contracts, twin asserts) → table rows or `it_behaves_like`, not copy-paste contexts.
5. Same scenario across layers: one authoritative unit (or pipeline) plus at most one higher smoke (facade/exe/VCR); delete the third.
6. RuboCop `ExampleLength` / `MultipleExpectations` on a discriminating multi-assert → tag `:aggregate_failures`; don't split.
7. `Dir.glob` loader for a missing `spec/support/shared_examples` → add real examples or remove the loader.

## Coverage (SimpleCov and peers)

8. Floors already pass → no micro-units for defensive branches; add fixture-driven product edges only.
9. No branch-coverage minimum unless user or repo policy asks.
10. Groups pointing at stale directories → repoint at real `lib/` trees or delete.

## Construction homes (gem/CLI)

11. CLI and public API shortcuts building the same controls object with differing "explicit" semantics → one builder on the config/type (`from_shortcut` / `from_cli_options`); Thor/option parsing stays thin.

## Ruby 4 baseline (harvest)

Default **4.0+, no 3.x compat** when `.tool-versions` / `AGENTS.md` are silent.

| Check | Prefer | Avoid |
| --- | --- | --- |
| Frozen strings | `# frozen_string_literal: true` on every `.rb` | Per-file mutable string churn |
| Block params | `it` for single-arg blocks | `{ \|x\| … }` when one arg only |
| Condition wraps | Leading `&&` / `\|\|` at line start | Trailing operators on wrapped lines |
| Shape dispatch | Pattern matching (`case … in`) | Deep `if/elsif` on structure |
| Collections | Core `Set`, `filter_map`, `index_by` | `require 'set'`, verbose `map`/`compact` |
| Structs | `Data.define` | OpenStruct / hand-rolled structs |
| Regex | `match?` | `=~` for boolean checks |
| Hot paths | Memoize pure/`ENV.fetch` work; one helper owner | Duplicated helpers split for metrics |
| Specs | Table-drive; `:aggregate_failures` for discriminating multi-assert | `send(...)` to pin private behavior |
| Extraction | Dedupe/unify before new files | Metric-driven micro-methods or files |
