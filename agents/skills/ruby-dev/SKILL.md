---
name: ruby-dev
description: >-
  Ruby workflow for surgical fixes and design handoffs. Use when work needs
  disciplined Ruby investigation, small safe changes, repo-native validation,
  TDD-oriented fixes, and clear routing to architecture on design or to review
  on assure/ship asks.
---

# Ruby Dev

Language-runtime adapter for Ruby. Craft (modules, types, measured perf) lives in `architecture` — do not inline it here.

## When to use

- Default for plain Ruby gems, libraries, CLI, and adapters; load `ruby-on-rails-dev` **with** this skill when the change is Rails-shaped.
- Use for Ruby implementation work: surgical fixes, incidents, and small feature adjustments.
- Read `AGENTS.md` first when present and follow repo-specific conventions over defaults here.
- Prefer `review.gil` **`tests`** when the user mainly wants test/spec review quality.
- Prefer `review.gil` **`finish`** when the user wants end-of-branch production-readiness review.
- Prefer `architecture` when design/structure/types/measured perf is the job (or when classification is `design`).
- Use with `ruby-on-rails-dev` when the change is Rails-shaped (controllers, policies, serializers, workers, mailers/jobs, migrations, framework config loaders, cache-key composition, encryption cutovers). Do not invent Rails recipes in this skill.

## Classify

| Class             | Action                                                        |
| ----------------- | ------------------------------------------------------------- |
| `surgical`        | Stay here; smallest safe change; language validation          |
| `design`          | Load `architecture`; do not inline craft advice in this skill |
| `review-hand-off` | Route to `review.gil`                                         |

Earn `design` when any of: dual ownership / shallow modules / primitive obsession across boundaries / user asks for structural cleanup / measured perf work / type-driven refactor / wrong-owner boundary absorb (serialize/cache/encode bent into a neighbor) / re-ledgering an already-owned aggregate / validate vs runtime expansion diverge / shared deadline or conflated meters across attempts / guard or policy owned in more than one place / published contract vs runtime acceptance drift / specs need private reach to assert behavior.

## Stance

- Evidence before claims. Prefer `rg`, file reads, and in-tree call sites over guesswork.
- Reproduce the bug or current behavior when possible. If reproduction is not possible, state what was checked instead.
- Prefer TDD for behavior changes: focused failing test first when cheap, then smallest safe fix.
- Prefer simple, forward, clean diffs. Default to surgical unless design is earned.
- LOC reduction and modern idioms (`match?`, `Enumerable`, pattern matching) are fine on the surgical path; do not treat them as a substitute for `architecture` when design is earned.

## Workflow

1. Classify: `surgical` | `design` | `review-hand-off`.
2. Evidence first: touched Ruby files, nearby tests, call sites, entrypoints, public contracts; use YARD/RBS/Sorbet only if the repo already relies on them.
3. Branch:
   - **Surgical:** smallest safe change (TDD when behavior changes) → validate → handoff.
   - **Design:** load `architecture` (branch pick inside) → implement decisions here with Ruby validation → handoff.
   - **Review-hand-off:** stop and continue with `review.gil`.
4. Handoff: commands run, residual risk, whether architecture harvest should stage → promote or drop (per `architecture/reference/growth.md` — no append-forever log).

## Surgical path

- Change only what the bug or ask requires.
- Preserve behavior unless the ask is an intentional break.
- For behavior-preserving moves without design signals, keep characterization or boundary coverage before moving code.
- Favor small, unified methods over fragmented helper-hell; data-driven constants/maps over repetitive branches when that is the whole ask.
- Keep the incident diff on **one surface**; drive-by edits on a second surface travel with the revert when the primary fix is wrong.
- Local correctness (immutability honesty, adapter honesty, safe handling of untrusted text) stays surgical until dual ownership appears.
- If the failing path is framework-lifecycle shaped, load `ruby-on-rails-dev` and apply its postures in the same change rather than inventing a language-only clamp.

## Validation Defaults

- Prefer the repository's established entrypoints such as `bin/rspec`, `bundle exec rspec`, `bin/rubocop`, or project wrappers.
- Run targeted tests for the changed behavior first.
- Run lint for changed Ruby files when the repo has a standard lint command.
- Run broader validation when the change crosses boundaries or when targeted validation leaves material risk.
- Do not claim broader validation passed unless the command exit status was actually zero.
- For design phases: validate after each phase before starting the next.

## Contracts and Documentation

- Avoid destructive git operations unless explicitly requested.
- Preserve existing repo conventions for contracts and docs.
- Do not introduce a new global YARD requirement into a repo that does not already use it.
- If a touched public API already has YARD, RBS, Sorbet, or equivalent contract docs, keep them accurate in scope.
- For service objects, jobs, CLI commands, and library-style code, make input/output expectations easy to discover either in code or tests.
- **Phase commits:** after each plan phase or surgical milestone, validate → ≥1 Conventional Commit with rationale/intent body before the next phase. Format: [`CONTEXT.md`](../CONTEXT.md). Inspect `git log` / `git show` when needed. `release` **`notes`** consumes history later — do not defer authoring to notes.

## Handoff Checklist

Before handoff, confirm:

- Classification stated (`surgical` / `design` / `review-hand-off`).
- For `design`: which `architecture` branches were loaded.
- Targeted tests pass and lint passes for changed files when those commands were in scope.
- Commands run listed with scope and pass/fail.
- Root cause or motivation stated briefly.
- Residual risk, rollback notes, or unverified paths called out when relevant.
