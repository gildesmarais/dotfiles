---
name: ruby-dev
description: >-
  Language-runtime adapter loaded by $dev. Not the Build entry. Use when $dev
  routed here or the user names this skill with $dev already loaded. Ruby
  deltas: TDD-oriented fixes, gem/CLI/adapter posture, Rails overlay compose.
---

# Ruby Dev

Follow `$dev` for classify, shared stance, API truth / Dash recipe, workflow/plan, validation law, phase commits, and handoff skeleton. This pack adds Ruby deltas only. Craft (modules, types, measured perf) lives in `architecture` — do not inline it here.

## When to use

- Loaded by `$dev` for plain Ruby gems, libraries, CLI, and adapters; load `ruby-on-rails-dev` **with** this skill when the change is Rails-shaped.
- Explicit `@ruby-dev` / `$ruby-dev` compose when `$dev` is already loaded.

## Also earn `design` when

Wrong-owner boundary absorb (serialize/cache/encode bent into a neighbor) / re-ledgering an already-owned aggregate / validate vs runtime expansion diverge / shared deadline or conflated meters across attempts / guard or policy owned in more than one place / published contract vs runtime acceptance drift / specs need private reach to assert behavior.

## Docsets

- Prefer Dash docsets: **Ruby**; when `ruby-on-rails-dev` is loaded, also **Rails**. Secondary: YARD/RBS/Sorbet only if the repo already uses them.

## Stance deltas

- Prefer TDD for behavior changes: focused failing test first when cheap, then smallest safe fix.
- Prefer simple, forward, clean diffs. LOC reduction and modern idioms (`match?`, `Enumerable`, pattern matching) are fine on the surgical path; do not treat them as a substitute for `architecture` when design is earned.
- Evidence: touched Ruby files, nearby tests, call sites, entrypoints, public contracts; use YARD/RBS/Sorbet only if the repo already relies on them.

## Surgical posture

- For behavior-preserving moves without design signals, keep characterization or boundary coverage before moving code.
- Favor small, unified methods over fragmented helper-hell; data-driven constants/maps over repetitive branches when that is the whole ask.
- Local correctness (immutability honesty, adapter honesty, safe handling of untrusted text) stays surgical until dual ownership appears.
- If the failing path is framework-lifecycle shaped, load `ruby-on-rails-dev` and apply its postures in the same change rather than inventing a language-only clamp.

## Tooling

- Prefer the repository's established entrypoints such as `bin/rspec`, `bundle exec rspec`, `bin/rubocop`, or project wrappers.
- Run targeted tests for the changed behavior first; lint changed Ruby files when the repo has a standard lint command.
- Broader validation when the change crosses boundaries or targeted validation leaves material risk.

## Contracts

- Avoid destructive git operations unless explicitly requested.
- Preserve existing repo conventions for contracts and docs.
- Do not introduce a new global YARD requirement into a repo that does not already use it.
- If a touched public API already has YARD, RBS, Sorbet, or equivalent contract docs, keep them accurate in scope.
- For service objects, jobs, CLI commands, and library-style code, make input/output expectations easy to discover either in code or tests.

## Handoff deltas

Before handoff (on top of `$dev` skeleton), confirm:

- Targeted tests pass and lint passes for changed files when those commands were in scope.
- Root cause or motivation stated briefly.
- Residual risk, rollback notes, or unverified paths called out when relevant.
