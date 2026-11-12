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

A small, dependable local utility for multi-owner PR and issue attention.

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
- `OpsGithub::Github` is the only module that invokes `gh`, and it is read-only (`setup_facts`, `discover`, `states`, `pr_states`); inject a runner for tests.
- Discovery has two phases. `Github#discover` (probe and tick) runs one cheap `gh api graphql` search per page, with the authored, review-requested, assigned-issue and reviewed aliases in one query and owners ORed as `user:<owner>` qualifiers. Each row carries `id`, `kind` (`pr`|`issue`), `role` (`authored`|`review-requested`|`both`|`reviewed`|`assigned`; `Github#merge_role` owns merging: authored + review-requested = `both`, a live review request beats `reviewed`, authored beats `reviewed`) and the change `signature` (updatedAt|rollup state for PRs; a constant for issues, so comments and labels never wake the watcher — only a new assignment, an unseen key, does), built only in `Github`. Issues are complete after phase 1: `Github#states(rows)` passes them through as their own state, and `Classifier` turns each into one `issue-assigned` ask. `Github#states` sends changed PR ids to `Github#pr_states(ids)` (tick only), which fetches full state through `nodes(ids:)` in `STATE_CHUNK` batches. A failed chunk is bisected down to single ids: a single id that fails with NOT_FOUND ("Could not resolve to a node") is dropped (its row is still stamped seen), any other error fails the tick; nodes whose `state` is not `OPEN` are skipped. `Github.pr_key` owns the `owner/repo#n` key string. `Ledger` stores and compares the signature opaquely, and `Classifier` stamps each item's `pr_keys` (the only key source); `Ledger#retire_stale!` drops `new` items of PRs changed this tick that were not reclassified, and `Ledger#undecided` re-surfaces `new` items whose `pr_keys` are all open and unchanged. `Ledger#cluster_siblings` widens the changed set to the still-open members of any multi-PR item touching a changed key (one pass), so a cluster is reclassified whole. Items written before `pr_keys` existed stay hidden until their PR changes (same day only).
- `reviewed` rows are open PRs you reviewed (`reviewed-by:@me -author:@me`) whose review request is gone. State adds `reviews(last:20)` (`reviews`: author, state, submittedAt, `commit_oid`) and `rollup_state` (`SUCCESS|PENDING|FAILURE|` or `""` without checks).
- `Classifier` also owns the human `clicks`: `action: "click"` items never run unattended, never block on a question, and appear as `clicks` in the envelope, as `N click(s)` in `line`/`status.txt`, and as `- click <pr>: <class>` in `report_md`; they make `status` `changes` (tick/probe exit 10) until decided. `ready-to-merge` (authored, not parked, `APPROVED`, `CLEAN`, no failing checks, rollup not `PENDING`, no unresolved human thread; invoke `merge <url>`) and `ready-to-approve` (reviewed, your latest `APPROVED`/`CHANGES_REQUESTED`/`DISMISSED` review not `APPROVED` — a later `COMMENTED` reply review does not cancel an approval, no `re-review`, no human unresolved thread, green rollup `SUCCESS`; invoke `approve <url>`). `re-review` is an urgent `ask` for reviewed PRs when the head moved past your latest review's `commit_oid` or a human replied in an unresolved thread after it; `since_oid`/`head_oid`/`comment_id` evidence moves the fingerprint on each new push or reply.
- Every item and board entry carries `ticket` (`Classifier.ticket_key`: first uppercase `PROJECT-123` in the title, else the head branch; `UTF|SHA|ISO|HTTP|CVE|RFC|PEP` prefixes ignored; nil when none; nil on cluster items).
- `Ledger#prs` (`ledger.data["prs"]`) caches a compact `pr_summary` per open PR, written by `Classifier#classify` whenever a state is fetched and pruned to the open keys every tick (`Ledger#retain_prs!`). The envelope `board` (`behind`, `waiting_review`, `parked_count`; authored PRs only, failing/parked PRs excluded from the lists) is computed from the cached `ledger.prs` summaries, so every tick is complete without refetching unchanged PRs; base-branch-only `BEHIND` drift without a PR `updatedAt`/rollup change therefore refreshes on the first tick of each day (same signature constraint as below). An open PR missing from the cache (ledger written before it existed) is fetched once as if changed.
- `watch [--max-ticks N] [--brief-every SECONDS]`: with `--brief-every` a positive value, `Watch` also emits `OPS_GITHUB_WAKE {"prompt":"/ops brief","urgency":"brief"}` every SECONDS on a monotonic clock (injectable `clock_fn`), splitting a probe pause instead of lengthening or shortening it; 0 or omitted keeps the old behavior. The default wake `prompt` for `"changes"` and `"env"` is `/ops` (`$ops` owns `OPS_GITHUB_WAKE`); `"brief"` carries `/ops brief`.
- The signature does not see base-moved conflicts or a change in which check fails; the first tick of each day refreshes all PRs.
- Keep `mergeable`/`mergeStateStatus`, check contexts and threads out of the search query. Computing merge state across about 75 PRs pushes a search past GitHub's ~10s gateway timeout (HTTP 502). `STATE_CHUNK = 10` measured about 3.7s live; a chunk of 20 took about 8.5s.
- `tick` writes `<state-dir>/status.txt` (`line · HH:MM`) atomically for a zero-token statusline.
- `OPS_GITHUB_DRY` (non-empty, not `0|false|no`, case-insensitive) makes `tick` demote every auto item to ask.
- Fail closed rather than overwrite unexpected paths.
- `Ledger.previous` (newest `YYYY-MM-DD.json` before today, across gaps) is the only carry source: a new day inherits its owners (unless `--owners` is passed), exclusions, carried items and watcher PID. `setup-facts` owners seed only the very first ledger. Exclusions persist until `ledger include PR`, `ledger exclude --clear`, or the first tick of a day, which prunes exclusions and carried items of PRs the search no longer returns (`Ledger#prune_closed!`; items without `pr_keys` stay).
- `Classifier#parked?` treats an authored PR as not ready when it is a draft or carries a parked label (`Classifier::PARKED_LABELS`, case-insensitive; `OPS_GITHUB_PARKED_LABELS=a,b` replaces the set). Review requests on others' PRs are never parked. Labels come from the phase-2 state query; adding a label bumps `updatedAt` (observed live), so the signature sees it.
- Exclude this tree from rcup via path-prefixed globs in `rcrc` (`ops-github/src`, `ops-github/test`, …) — never a bare `ops-github` basename, which would also skip `agents/skills/ops-github` and `scripts/ops-github`.
