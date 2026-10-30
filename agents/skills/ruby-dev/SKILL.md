---
name: ruby-dev
description: >-
  Ruby deltas: Ruby 4 baseline, gem/CLI/adapter work, RSpec suite hygiene, spec
  twins, Rails overlay.
disable-model-invocation: true
---

# Ruby Dev

**Stop:** apply `$dev` Shared prep first; skip if already read. Craft lives in `architecture`; compose sibling skills by name, never paste them.

## Also earn `design` when

Specs need private reach to assert behavior / mirrored specs re-encoding one algorithm across two production adapters (dual ownership → architecture `deep-modules`) / validate vs runtime expansion diverge.

## Docsets

Dash: **Ruby**; with `ruby-on-rails-dev`, also **Rails**. YARD/RBS/Sorbet only if the repo already uses them; keep touched contract docs accurate.

## Stable surfaces

Published gem APIs, public service/CLI entrypoints, versioned HTTP contracts — unless the ask or `AGENTS.md` says otherwise.

## Ruby 4 baseline

Read `.tool-versions` / `AGENTS.md`; default **Ruby 4.0+, no 3.x shims or dual-path APIs**. RuboCop present → `TargetRubyVersion: 4.0`.

- `# frozen_string_literal: true` on every `.rb`; `it` for single-arg blocks; leading `&&` / `||` on wrapped conditions; `case … in` over structural `if/elsif`.
- Core `Set` (no `require 'set'`); `Data.define` over OpenStruct.
- Dedupe before new files; no metric-driven micro-methods.

## Deltas

- Behavior-preserving moves: characterization or boundary coverage first.
- Framework-lifecycle-shaped failure → load `ruby-on-rails-dev` in the same change.
- [`reference.md`](reference.md): spec twins, RSpec hygiene, SimpleCov floors, CLI/config homes. Test-quality → `review.gil` `tests`.
- Entrypoints: `bin/rspec`, `bundle exec rspec`, `bin/rubocop`, or project wrappers.

## Compose routes

- Rails-shaped → `ruby-on-rails-dev` (with this pack).
- Suite quality / over-mocking → `review.gil` `tests`.
- Spec-twin dual ownership / shared rule kernels → architecture `deep-modules`.

## Handoff deltas

Root cause or motivation stated briefly.
