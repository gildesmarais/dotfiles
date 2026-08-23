---
name: ruby-dev
description: >-
  Always load $dev first; this pack is deltas only. Language-runtime adapter
  loaded by $dev — not the Build entry. Use when $dev routed here or the user
  names this skill with $dev already loaded. Ruby deltas: TDD posture,
  gem/CLI/adapter, RSpec suite hygiene, Rails overlay compose.
---

# Ruby Dev

**Stop:** read `$dev` Shared prep before any delta.

Follow `$dev` for classify, shared stance, API truth / Dash recipe, compat ask, no-destructive git, workflow/plan, validation law, phase commits, and handoff skeleton. This pack adds Ruby deltas only. Craft (modules, types, measured perf) lives in `architecture` — do not inline it here.

## When to use

- Loaded by `$dev` for plain Ruby gems, libraries, CLI, and adapters; load `ruby-on-rails-dev` **with** this skill when the change is Rails-shaped.
- Explicit `@ruby-dev` / `$ruby-dev` compose when `$dev` is already loaded.

## Also earn `design` when

Wrong-owner boundary absorb (serialize/cache/encode bent into a neighbor) / re-ledgering an already-owned aggregate / validate vs runtime expansion diverge / shared deadline or conflated meters across attempts / guard or policy owned in more than one place / published contract vs runtime acceptance drift / specs need private reach to assert behavior / mirrored specs that re-encode the same algorithm across two production adapters (probe dual ownership — co-load architecture `deep-modules`).

## Docsets

- Prefer Dash docsets: **Ruby**; when `ruby-on-rails-dev` is loaded, also **Rails**. Secondary: YARD/RBS/Sorbet only if the repo already uses them.

## Stable-surface hints

- Treat published gem APIs, public service/CLI entrypoints, and versioned HTTP contracts as stable unless the ask or `AGENTS.md` says otherwise.

## Stance deltas

- Prefer TDD for behavior changes: focused failing test first when cheap, then smallest safe fix.
- Prefer simple, forward, clean diffs. LOC reduction and modern idioms (`match?`, `Enumerable`, pattern matching) are fine on the surgical path; do not treat them as a substitute for `architecture` when design is earned.
- Evidence: touched Ruby files, nearby tests, call sites, entrypoints, public contracts; use YARD/RBS/Sorbet only if the repo already relies on them.
- Load thin postures in [`reference.md`](reference.md) when RSpec suite hygiene, SimpleCov/group floors, spec-twin→lib probe, or CLI/config construction homes are in play. Test-quality review judgment stays in `review.gil` `tests` — do not paste it here.

## Ruby 4 baseline

- Read repo `.tool-versions` and `AGENTS.md` when present; default **Ruby 4.0+, no 3.x compat shims or dual-path APIs**.
- Apply syntax + performance checklist from [`reference.md`](reference.md#ruby-4-baseline-harvest) (self-contained — do not assume a gem AGENTS pointer).
- Prefer LOC reduction via dedupe/unify before new files; extract only when a real seam or test surface is earned.
- When the repo has RuboCop, align with `AllCops.TargetRubyVersion: 4.0` and `Style/ItBlockParameter` where enabled.

## Surgical posture

- For behavior-preserving moves without design signals, keep characterization or boundary coverage before moving code.
- Favor small, unified methods over fragmented helper-hell; data-driven constants/maps over repetitive branches when that is the whole ask.
- Local correctness (immutability honesty, adapter honesty, safe handling of untrusted text) stays surgical until dual ownership appears.
- When suite cleanup discovers mirrored specs, classify **spec-only twin** vs **dual-ownership twin** before editing (see [`reference.md`](reference.md)); dual ownership earns `design` + architecture `deep-modules`.
- If the failing path is framework-lifecycle shaped, load `ruby-on-rails-dev` and apply its postures in the same change rather than inventing a language-only clamp.

## Tooling

- Prefer the repository's established entrypoints such as `bin/rspec`, `bundle exec rspec`, `bin/rubocop`, or project wrappers.
- Run targeted tests for the changed behavior first; lint changed Ruby files when the repo has a standard lint command.
- Broader validation when the change crosses boundaries or targeted validation leaves material risk.

## Contracts

- Preserve existing repo conventions for contracts and docs.
- Do not introduce a new global YARD requirement into a repo that does not already use it.
- If a touched public API already has YARD, RBS, Sorbet, or equivalent contract docs, keep them accurate in scope.
- For service objects, jobs, CLI commands, and library-style code, make input/output expectations easy to discover either in code or tests.

## Compose routes

Pointers only — load when present; do not paste their bodies here:

- Rails-shaped work → `ruby-on-rails-dev` (with this skill; via `$dev` route).
- Suite quality / over-mocking review → `review.gil` `tests` (Assure), not a second doctrine log here.
- Spec-twin dual ownership / shared rule kernels → architecture `deep-modules`.

## Handoff deltas

Before handoff (on top of `$dev` skeleton), confirm:

- Targeted tests pass and lint passes for changed files when those commands were in scope.
- Root cause or motivation stated briefly.
- Residual risk, rollback notes, or unverified paths called out when relevant.
