---
name: ruby-dev
description: "Ruby workflow for bug fixes, refactors, incidents, and targeted code review. Use when work needs disciplined Ruby investigation, small safe changes, repo-native validation, TDD-oriented fixes, and clear routing to test review or finish-review when the request is narrower or later-stage."
---

# Ruby Dev

## When to use

- Use for Ruby implementation work: bug fixes, refactors, incidents, and small feature adjustments.
- Read `AGENTS.md` first when present and follow repo-specific conventions over defaults here.
- Prefer `review-tests` when the user mainly wants test/spec review quality.
- Prefer `finish-review` when the user wants end-of-branch production-readiness review.

## Workflow

1. Classify the task: `bug fix`, `refactor`, `incident`, `feature adjustment`, or `review`.
2. Gather context before proposing changes:
   - Read the touched Ruby files and nearby tests.
   - Inspect call sites, entrypoints, and public contracts.
   - Use YARD, RBS, Sorbet, or inline docs if the repo already relies on them.
3. Reproduce the bug or current behavior when possible. If reproduction is not possible, state what was checked instead.
4. For behavior changes, prefer TDD:
   - Add or update a focused failing test first when the failure can be expressed cheaply.
   - Then implement the smallest safe fix.
5. For refactors, preserve behavior with characterization or boundary coverage before moving code.
6. Validate with the repo's native commands, starting with the narrowest relevant scope and broadening when practical.
7. Handoff with the commands run, result, residual risk, and any follow-up that remains intentionally out of scope.

## Validation Defaults

- Prefer the repository's established entrypoints such as `bin/rspec`, `bundle exec rspec`, `bin/rubocop`, or project wrappers.
- Run targeted tests for the changed behavior first.
- Run lint for changed Ruby files when the repo has a standard lint command.
- Run broader validation when the change crosses boundaries or when targeted validation leaves material risk.
- Do not claim broader validation passed unless the command exit status was actually zero.

## Contracts and Documentation

- Avoid destructive git operations unless explicitly requested.
- Preserve existing repo conventions for contracts and docs.
- Do not introduce a new global YARD requirement into a repo that does not already use it.
- If a touched public API already has YARD, RBS, Sorbet, or equivalent contract docs, keep them accurate in scope.
- For service objects, jobs, CLI commands, and library-style code, make input/output expectations easy to discover either in code or tests.

## Review Focus

- Prioritize correctness, failure modes, boundary handling, and maintainability.
- For review-style requests, report findings first with file references and concrete bug risk.
- If the diff is test-heavy, use `review-tests` for the test-quality pass instead of duplicating that guidance here.
- If no critical implementation defects are found, say `No critical implementation defects detected` and note residual risks or validation gaps.

## Handoff Checklist

Before handoff, confirm:

- Targeted tests pass and lint passes for changed files.
- Commands run are listed with scope and pass/fail.
- Root cause or motivation for the change is stated briefly.
- Residual risk, rollback notes, or unverified paths are called out when relevant.
