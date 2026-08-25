# ruby-dev reference

Language-only postures (Ruby / RSpec / gem tooling). Architecture craft lives on `architecture` branch refs — never duplicate it here as a parallel doctrine log. Test-quality review judgment lives in `review.gil` `tests` — this file holds Ruby/RSpec execution postures for `$dev` implement.

Grow this file only for Ruby-specific lessons that cannot be stated language-free. Cap ~10 new bullets per harvest unless the user asks for more. Routine surgical fixes do not grow this file.

## Spec twins → lib probe (Ruby execute)

1. **Classify before collapsing.** Mirrored `describe` blocks or option-forwarding matrices are either **spec-only** (production already shares one path → shared_examples / table-drive / thin the extra layer) or **dual-ownership** (two production homes encode the same rules → extract a shared kernel + thin adapters, then share fixtures). Do not invent a second production fold when the lib is already single-owner.
2. **Shared rule kernel, not a mega-class.** When two DOM/API adapters reimplement the same field rules, put pure rules in one module; adapters only traverse and call. Keep one shared fixture corpus both adapters (or rule specs + thin adapter specs) assert against — see architecture `deep-modules`.
3. **Raise flight before adding doubles.** Prefer fixture/HTML/JSON → observable article/feed/CLI outcomes over `have_received(:new)` skip-graphs and `instance_variable_get` / `send` pins (many repos ban `send` in specs via `AGENTS.md`).

## RSpec suite hygiene

4. **Table-drive and shared_examples for matrices.** Option-forwarding, routing URL contracts, and audio/video twin asserts belong in rows or `it_behaves_like`, not copy-paste contexts.
5. **Multi-layer same scenario.** Keep one authoritative unit (or pipeline) SoT plus at most one higher smoke (facade/exe/VCR); delete the third copy.
6. **`:aggregate_failures` over hollow splits.** When RuboCop `ExampleLength` / `MultipleExpectations` trip on a discriminating multi-assert outcome, tag the example — do not split into examples that lose the failure story.
7. **Populate or drop shared_examples loaders.** A `Dir.glob` for `spec/support/shared_examples` with a missing directory is dead hygiene; either add real shared examples or remove the loader.

## Coverage tooling (SimpleCov and peers)

8. **Trust floors, not vanity %.** When overall/by-file floors already pass, do not chase remaining defensive/coercion branches with micro-units; add fixture-driven product edges only.
9. **No silent branch gates.** Do not add a branch coverage minimum unless the user or repo policy asks; line floors are enough unless stated otherwise.
10. **Group paths must resolve.** Empty SimpleCov (or peer) groups that point at stale directories are hygiene debt — point them at real `lib/` trees or delete them.

## Construction homes (gem/CLI)

11. **One builder for explicit-key provenance.** When CLI and public API shortcuts both assemble the same controls object with slightly different “explicit” semantics, own construction on the config/type (`from_shortcut` / `from_cli_options`); keep Thor/option parsing thin at the edge.

## Ruby 4 baseline (harvest)

Default **4.0+, no 3.x compat**. Read repo `.tool-versions` / `AGENTS.md` first; when absent, apply this checklist.

| Check           | Prefer                                                                      | Avoid                                    |
| --------------- | --------------------------------------------------------------------------- | ---------------------------------------- |
| Frozen strings  | `# frozen_string_literal: true` on every `.rb`                              | Per-file mutable string churn            |
| Block params    | `it` for single-arg blocks                                                  | `{ \|x\| … }` when one arg only          |
| Condition wraps | Leading `&&` / `\|\|` at line start                                         | Trailing operators on wrapped lines      |
| Shape dispatch  | Pattern matching (`case … in`)                                              | Deep `if/elsif` on structure             |
| Collections     | Core `Set`, `filter_map`, `index_by`                                        | `require 'set'`, verbose `map`/`compact` |
| Structs         | `Data.define`                                                               | OpenStruct / hand-rolled structs         |
| Regex           | `match?`                                                                    | `=~` for boolean checks                  |
| Hot paths       | Memoize pure/`ENV.fetch` work; one helper owner                             | Duplicated helpers split for metrics     |
| Specs           | Table-drive matrices; `:aggregate_failures` for discriminating multi-assert | `send(...)` to pin private behavior      |
| Extraction      | Dedupe/unify before new files                                               | Metric-driven micro-methods or files     |

**Anti-patterns:** Ruby 3.x guards or dual-path APIs; `send` in specs to reach private APIs; trailing wrapped `&&`/`||`; duplicated helpers across files; `require 'set'` on Ruby 4; OpenStruct for value objects; metric-only extractions that buy no seam.
