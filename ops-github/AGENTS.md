# Ops-GitHub CLI Agent Guide

## Purpose

`ops-github/` owns the implementation and tests for the `ops-github` command: a daily GitHub attention engine (probe, tick, ledger, worktrees, post, watch). The agent skill router at `agents/skills/ops-github/` calls these verbs; it never reimplements them.

## Key Decision

Logic lives in [`src/cli.rb`](src/cli.rb) and `src/ops_github/`; the executable stays thin in [`../scripts/ops-github`](../scripts/ops-github).

Reason:

- keep command logic testable without shell-heavy fixtures
- preserve a stable PATH entry via rcm (`~/.scripts/ops-github`)
- keep GitHub wire and classification rules out of skill Markdown (token cost)

Do not move business logic into the shell wrapper.

## Vision

A small, dependable local utility for multi-owner PR attention.

Optimize for:

- predictable filesystem and ledger behavior
- safe refusal on ambiguous or destructive states
- compatibility with a bare macOS machine (system Ruby 2.6, stdlib only)
- low maintenance cost

Do not optimize for:

- plugin architecture
- non-stdlib Ruby dependencies
- encoding org names in the tool or skill

## Operating Constraints

- Ruby must stay compatible with macOS system Ruby 2.6.
- Prefer stdlib only.
- `scripts/ops-github` must remain a tiny launcher. Keep `require_relative` so the rcm `~/.scripts/ops-github` symlink still loads `src/cli.rb`.
- `OpsGithub::Classifier` owns blocker priority, whitelist, red-CI clustering, and thread-handled rules; other modules must not reimplement those.
- `OpsGithub::Github` is the only module that invokes `gh`; inject a runner for tests.
- Fail closed rather than overwrite unexpected paths.
- Exclude this tree from rcup (`ops-github ops-github/*` in `rcrc`) so tests are never installed into agent skill dirs.
