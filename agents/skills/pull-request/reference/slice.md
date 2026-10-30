# Slice

Rebuild an oversized branch into focused PRs optimized for final reviewable intent, not history.

## Plan

1. **Freeze** — record source + default branch; create a backup branch before rewriting; source becomes read-only reference. Prefer one worktree per PR branch.
2. **Group the final diff** (source vs default branch, not intermediate commits) into intent stories. Ambiguous grouping → confirm the PR set with the user.
   - One primary story per PR; ignore original order unless asked.
   - Fold later hardening into the feature PR; drop prep that doesn't help the target PR.
   - Docs-only separate unless required to explain a new public interface.
3. **Ledger** per PR (update after every push, PR create, merge, branch switch): branch, worktree path, title, files/hunks included, source commits/hunks, excluded items, validation result, last verified pushed commit, PR URL (or explicit `deferred`), merge status.

## Execute (per PR, sequentially)

- **Locus check** before any validate/commit/push/PR command: `pwd`, `git branch --show-current`, `git worktree list`. Never commit or validate from the backup/source branch when the PR has its own worktree.
- Branch from the latest default branch after the previous PR merged; no stacked dependent branches unless asked. Cherry-pick whole commits only when they match the story; else `git cherry-pick -n` / hunk copy and curate. Editor-safe: `GIT_EDITOR=true git cherry-pick --continue` / `GIT_EDITOR=true git rebase --continue`.
- Validate touched behavior + full gate when practical; pass only on exit 0; separate new regressions from baseline failures. Moved fixtures must still match real upstream formats.
- `git push`, then verify and record the remote head.
- `gh pr view --json number,url,state,headRefName,baseRefName`: existing PR → `gh pr edit`; none → `gh pr create --web --title … --body …` without extra confirmation. Say "open" only after `gh pr view` confirms.
- Once a PR exists, review fixes go to its worktree, not the source branch.
- Loop: PR N → wait for user review + merge → fetch default → rebuild PR N+1. After the last slice, ask before removing worktrees and running `git worktree prune`.

## Premature-completion shield

No **open** or **resolve** for a slice until its ledger row has branch, commits, validation result; push is verified on remote; and (sequential plans) the prior slice is merged. Deferred/not-ready → report that state.
