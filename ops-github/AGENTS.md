# Ops-GitHub CLI Agent Guide

## Purpose

`ops-github/` owns the implementation and tests for the `ops-github` command: a daily GitHub attention engine (probe, tick, ledger, watch). The agent skill router at `agents/skills/ops-github/` calls these verbs; it never reimplements them. GitHub mutations and worktrees belong to Hands (`pull-request`, `gh`, Task worktree isolation).

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
- local worktree mirrors or GitHub write wrappers (Hands own those)

## Operating Constraints

- Ruby must stay compatible with macOS system Ruby 2.6.
- Prefer stdlib only.
- `scripts/ops-github` must remain a tiny launcher. Keep `require_relative` so the rcm `~/.scripts/ops-github` symlink still loads `src/cli.rb`.
- `OpsGithub::Classifier` owns blocker priority, whitelist, red-CI clustering, and thread-handled rules; other modules must not reimplement those.
- `OpsGithub::Github` is the only module that invokes `gh`, and it is read-only (`setup_facts`, `discover`, `pr_states`); inject a runner for tests.
- Discovery has two phases. `Github#discover` (probe and tick) runs one cheap `gh api graphql` search per page, with the authored and review-requested aliases in one query and owners ORed as `user:<owner>` qualifiers. Each row carries `id`, `role` and the change `signature` (updatedAt|rollup state), which is built only in `Github`. `Github#pr_states(ids)` (tick only, changed PRs only) fetches full state through `nodes(ids:)` in `STATE_CHUNK` batches. A failed chunk is bisected down to single ids: a single id that fails with NOT_FOUND ("Could not resolve to a node") is dropped (its row is still stamped seen), any other error fails the tick; nodes whose `state` is not `OPEN` are skipped. `Github.pr_key` owns the `owner/repo#n` key string. `Ledger` stores and compares the signature opaquely, and `Classifier` stamps each item's `pr_keys` (the only key source); `Ledger#retire_stale!` drops `new` items of PRs changed this tick that were not reclassified, and `Ledger#undecided` re-surfaces `new` items whose `pr_keys` are all open and unchanged. `Ledger#cluster_siblings` widens the changed set to the still-open members of any multi-PR item touching a changed key (one pass), so a cluster is reclassified whole. Items written before `pr_keys` existed stay hidden until their PR changes (same day only).
- The signature does not see base-moved conflicts or a change in which check fails; the first tick of each day refreshes all PRs.
- Keep `mergeable`/`mergeStateStatus`, check contexts and threads out of the search query. Computing merge state across about 75 PRs pushes a search past GitHub's ~10s gateway timeout (HTTP 502). `STATE_CHUNK = 10` measured about 3.7s live; a chunk of 20 took about 8.5s.
- `tick` writes `<state-dir>/status.txt` (`line · HH:MM`) atomically for a zero-token statusline.
- `OPS_GITHUB_DRY` (non-empty, not `0|false|no`, case-insensitive) makes `tick` demote every auto item to ask.
- Fail closed rather than overwrite unexpected paths.
- Exclude this tree from rcup via path-prefixed globs in `rcrc` (`ops-github/src`, `ops-github/test`, …) — never a bare `ops-github` basename, which would also skip `agents/skills/ops-github` and `scripts/ops-github`.
