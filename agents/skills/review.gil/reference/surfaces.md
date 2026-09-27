# Surfaces

Cursor subagents folded into the one finish report ([`finish.md`](finish.md)). Not lenses, not executions. `quality` does not launch them.

Launch only for a code diff. Skip docs-only and trivial diffs (comment, typo, single-line config) and say so.

The subagent computes the diff. Do not compute it first. Path is the workspace or repo root. If the target branch or PR head is not checked out, switch first; stash only after the user confirms. One of each, `run_in_background: false`. Diff is `branch changes` for a branch or PR, `uncommitted changes` for a dirty tree only. Omit `Base Branch` unless that compare target is not the repo default.

## Bugbot

`subagent_type: bugbot`, `description: "Bugbot"`.

```text
Full Repository Path: <absolute repository path>
Diff: <one of: "branch changes", "uncommitted changes", "natural language">
Base Branch: <only include this line when reviewing branch changes against a known specific base branch>
Change Description: <required only when Diff is "natural language"; list each changed file and what changed in it>
Custom Instructions: <only include this line when the user gave specific review instructions>
```

If it cannot compute the diff, retry once with `Diff: natural language`, no `Base Branch`, and a `Change Description`: one `<path> (added|modified|deleted|renamed)` block per file, plus what changed. Any other failure: retry once, then stop and name the blocker.

## Security Review

Only when the `security` lens is already selected. `subagent_type: security-review`, `description: "Security Review"`.

```text
Full Repository Path: <absolute repository path>
Diff: <one of: "branch changes", "uncommitted changes">
Base Branch: <only include this line when reviewing branch changes against a known specific base branch>
Custom Instructions: <only include this line when the user gave specific review instructions>
```

Wrong invocation or other failure: retry once, then stop and name the blocker.

## Fold

Fold both into that single finish report. Do not fix, publish, or launch a second review from their output. Orchestrated runs append the same report to `.agents/run/<slug>.md`.
