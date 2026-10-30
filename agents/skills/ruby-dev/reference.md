# ruby-dev reference

Ruby/RSpec postures; craft → `architecture`, test-quality judgment → `review.gil` `tests`.

## Spec twins → lib probe

1. **Classify before collapsing.** Mirrored `describe` blocks are **spec-only twins** (production already single-path → shared_examples / table-drive) or **dual-ownership twins** (two production homes → shared kernel + thin adapters, shared fixtures; earns `design` + `deep-modules`). Never invent a production fold for a single-owner lib.
2. **Shared rule kernel, not a mega-class.** Pure field rules in one module; adapters only traverse and call; one fixture corpus asserted by both.
3. **Raise flight before adding doubles.** Fixture/HTML/JSON → observable outcomes over `have_received(:new)` skip-graphs and `instance_variable_get` / `send` pins.

## RSpec suite hygiene

4. Matrices → table rows or `it_behaves_like`, not copy-paste contexts.
5. Same scenario across layers: one authoritative unit plus at most one higher smoke.
6. RuboCop `ExampleLength` / `MultipleExpectations` on a discriminating multi-assert → `:aggregate_failures`; don't split.
7. `Dir.glob` loader for a missing `spec/support/shared_examples` → add real examples or remove the loader.

## Coverage (SimpleCov and peers)

8. Floors already pass → no micro-units for defensive branches; add fixture-driven product edges only. No branch-coverage minimum unless user or repo policy asks.
9. Groups pointing at stale directories → repoint at real `lib/` trees or delete.

## Construction homes (gem/CLI)

10. CLI and public API shortcuts building the same controls object with differing "explicit" semantics → one builder on the config/type; Thor/option parsing stays thin.
