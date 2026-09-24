---
name: ruby-dev
description: >-
  Ruby deltas loaded by $dev (load $dev first; not a Build entry): TDD posture,
  Ruby 4 baseline, gem/CLI/adapter work, RSpec suite hygiene, Rails overlay
  compose.
---

# Ruby Dev

**Stop:** read `$dev` Shared prep before any delta. Craft lives in `architecture`; compose sibling skills by name, never paste them.

## Also earn `design` when

Wrong-owner boundary absorb (serialize/cache/encode bent into a neighbor) / re-ledgering an already-owned aggregate / validate vs runtime expansion diverge / shared deadline or conflated meters across attempts / guard or policy owned in more than one place / published contract vs runtime acceptance drift / specs need private reach to assert behavior / mirrored specs re-encoding one algorithm across two production adapters (dual ownership → architecture `deep-modules`).

## Docsets

Dash: **Ruby**; with `ruby-on-rails-dev`, also **Rails**. YARD/RBS/Sorbet only if the repo already uses them — then keep touched contract docs accurate; never introduce a global YARD requirement.

## Stable surfaces

Published gem APIs, public service/CLI entrypoints, versioned HTTP contracts — unless the ask or `AGENTS.md` says otherwise.

## Ruby 4 baseline

- Read `.tool-versions` / `AGENTS.md`; default **Ruby 4.0+, no 3.x compat shims or dual-path APIs**.
- Apply the checklist in [`reference.md`](reference.md#ruby-4-baseline-harvest) (self-contained).
- RuboCop present → `AllCops.TargetRubyVersion: 4.0`, `Style/ItBlockParameter` where enabled.

## Deltas

- TDD for behavior changes: focused failing test first.
- Modern idioms and LOC reduction (dedupe/unify before new files) are fine on the surgical path; never a substitute for `design`.
- Behavior-preserving moves: characterization or boundary coverage before moving code.
- Small unified methods over helper-hell; data-driven maps over repetitive branches when that is the whole ask.
- Immutability/adapter honesty and untrusted-text handling stay surgical until dual ownership appears.
- Mirrored specs: classify **spec-only twin** vs **dual-ownership twin** before editing ([`reference.md`](reference.md)); dual ownership earns `design` + `deep-modules`.
- Framework-lifecycle-shaped failure → load `ruby-on-rails-dev` in the same change.
- Service objects, jobs, CLI, library code: make input/output expectations discoverable in code or tests.
- Load [`reference.md`](reference.md) for RSpec hygiene, SimpleCov floors, spec-twin probe, CLI/config construction homes. Test-quality judgment → `review.gil` `tests`.
- Entrypoints: `bin/rspec`, `bundle exec rspec`, `bin/rubocop`, or project wrappers; lint changed files.

## Compose routes

- Rails-shaped → `ruby-on-rails-dev` (with this pack).
- Suite quality / over-mocking → `review.gil` `tests`.
- Spec-twin dual ownership / shared rule kernels → architecture `deep-modules`.

## Handoff deltas

Root cause or motivation stated briefly.
