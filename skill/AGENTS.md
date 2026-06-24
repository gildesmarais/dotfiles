# Skill CLI Agent Guide

## Purpose

`skill/` owns the implementation and tests for the `skill` command used to manage the dotfiles skill store (`~/.dotfiles/skills`).

Install skills into agents with [`npx skills`](https://github.com/vercel-labs/skills). This CLI handles store hygiene only: `promote` and `rename`.

## Key Decision

The CLI implementation lives in [`src/cli.rb`](/Users/gil/.dotfiles/skill/src/cli.rb) and the executable entrypoint stays thin in [`../scripts/skill`](/Users/gil/.dotfiles/scripts/skill).

Reason:

- keep command logic testable without shell-heavy fixtures
- preserve a stable executable path for users
- keep filesystem behavior centralized in one Ruby file

Do not move business logic back into the shell wrapper unless there is a hard portability reason.

## Vision

This tool should remain a small, dependable local utility for dotfiles skill store management.

Optimize for:

- predictable filesystem behavior
- safe refusal on ambiguous or destructive states
- compatibility with a bare macOS machine
- low maintenance cost

Do not optimize for:

- plugin architecture
- external services
- non-stdlib Ruby dependencies
- broad cross-platform abstractions unless they are required by an actual use case
- symlink-based agent install management (use `npx skills` instead)

## Operating Constraints

- Ruby must stay compatible with macOS system Ruby 2.6.
- Prefer stdlib only.
- `scripts/skill` must remain a tiny launcher.
- Hidden directories in the store are not user skills and must stay excluded from `list` and related workflows.
- The tool manages local directories in the dotfiles store; it should fail closed rather than overwrite unexpected paths.
- Behavior should remain understandable from CLI output alone. Errors should be explicit and actionable.
- Do not create project symlinks. Print `npx skills add gildesmarais/dotfiles` hints after promote.

## Canonical Paths

- Store: `skills/` at the dotfiles root
- Project promote source: `<project>/.agents/skills/` only (`.codex/skills/` is deprecated and rejected)
- Main implementation: `skill/src/cli.rb`
- Tests: `skill/test/cli_test.rb`
- Lint config: `skill/.rubocop.yml`
- User guide: `skills/README.md`

## Change Rules

- When changing command behavior, update tests in `skill/test/cli_test.rb`.
- Preserve current command names and semantics unless the user explicitly requests a CLI contract change.
- Keep direct execution of `ruby skill/src/cli.rb ...` working.
- Prefer targeted helper methods over introducing new layers or frameworks.
- Document any intentional behavior change in `skill/README.md`.

## Validation

Run:

```sh
make lint test
```

Quality gate: `make lint test` must pass before handoff.

`make test` is the compatibility gate because it uses macOS system Ruby 2.6.

## Review Focus

When reviewing changes here, prioritize:

- accidental overwrites or unsafe path handling
- hidden-file handling regressions
- argument parsing regressions
- drift between README, tests, and executable behavior
- accidental reintroduction of symlink or `.codex/skills` workflows
