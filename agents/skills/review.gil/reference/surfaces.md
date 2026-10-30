# Surfaces

Independent review passes folded into the one finish report (`finish.md`). Not lenses, not executions. `quality` does not run them.

Run only for a code diff; skip docs-only and trivial diffs and say so. Use a host-provided review subagent when one exists (general code review; a security review only when the `security` lens is selected), else a second inline pass over the same diff. Let the subagent compute the diff: give it the repo path, the target (`branch changes` or `uncommitted changes`), a base branch only when it is not the repo default, and any user review instructions. If it cannot compute the diff, retry once with a per-file change description. Other failure: retry once, then name the blocker and continue inline.

Fold results into that single finish report. Do not fix, publish, or launch a second review from their output. Return findings in chat.
