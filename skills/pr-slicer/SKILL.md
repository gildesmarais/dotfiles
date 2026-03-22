---
name: pr-slicer
description: Rebuild a large, messy git branch into small reviewable PRs by mapping the current diff into final intent-based commits and recreating branches from the default branch. Use when a user wants to split one branch into multiple PRs, drop preparatory or unrelated changes, replace development chronology with cleaner history, or run a sequential branch-to-PR-to-merge workflow.
---

# PR Slicer

## Overview

Use this skill to turn an oversized branch into a sequence of focused PRs with clean history. Optimize for final reviewable intent, not for preserving how the work was originally developed.

## Workflow

### 1. Freeze the source branch

- Record the source branch and default branch.
- Create a backup branch before rewriting or rebuilding anything.
- Prefer a dedicated worktree for each PR branch.
- Treat the source branch as reference material once slicing begins.

### 2. Build the slice plan from the final diff

- Diff the source branch against the default branch, not against intermediate commits.
- Group the final diff into review stories.
- Ask the user to confirm the target PR set when the grouping is ambiguous.
- Favor intent-based groupings such as `docs`, `schema dedup`, `request boundary`, `CLI cleanup`, `feature X`.

### 3. Use these slicing rules

- Do not preserve the original development order unless the user explicitly asks for that.
- Do not keep a separate `add feature` commit if the feature only becomes correct after later hardening. Fold the hardening into the feature PR.
- Drop preparatory changes that do not materially help the target PR.
- Keep each PR to one primary story.
- Keep docs-only changes separate unless they are required to explain a new public interface.

### 4. Write the PR mapping contract

For each target PR, record:

- branch name
- worktree path
- PR title
- files or hunks that belong
- source commits or source hunks
- intentionally excluded items

### 5. Maintain a PR ledger

Keep a tiny ledger per PR with:

- branch name
- worktree path
- PR number and URL once created
- last pushed commit
- merge status

Update the ledger after every push, PR creation, merge, or branch switch.

### 6. Verify the execution locus before mutating anything

Before any validation, commit, push, or PR command:

- print and verify `pwd`
- print and verify `git branch --show-current`
- print and verify `git worktree list`

Do not assume the current cwd is the target PR worktree just because the branch exists elsewhere.
Never commit or validate from the backup or source branch when the active PR has a dedicated worktree.

### 7. Summarize the command path per phase

- Summarize the command path once per PR phase, not before every git command.
- Always summarize before destructive or branch-shaping steps.
- Skip repetitive previews for routine status checks and other read-only commands.
- Typical commands to summarize before running include `git fetch`, `git switch`, `git checkout`, `git branch`, `git worktree add`, `git cherry-pick`, `git rebase`, `git push`, and `gh pr create`.

### 8. Rebuild PRs sequentially from the default branch

- Start each PR branch from the latest default branch after the previous PR is merged.
- Do not stack long-lived dependent PR branches unless the user explicitly asks for a stacked review.
- Cherry-pick whole commits only when they already match the target story.
- When a commit is too broad, use `git cherry-pick -n` or copy specific hunks and curate the result into a new commit.
- Prefer non-interactive git flows.
- When a command may invoke an editor, set an explicit editor override such as `GIT_EDITOR=true git cherry-pick --continue` or `GIT_EDITOR=true git rebase --continue`.

### 9. Validate each PR accurately

- Run the repo's normal validation for the files and behavior touched by the PR.
- Run the full repo gate when practical.
- Do not claim the full gate passed unless the exit code was actually zero.
- If the full gate fails, distinguish a new PR regression from a pre-existing repo baseline.
- If blocked by an existing baseline, report the exact failing stage and the passing targeted validations.

### 10. Keep fixtures honest

- When extracting or moving tests, re-check that fixtures still reflect real upstream formats.
- If a fixture is intentionally simplified, state that explicitly in the PR notes.

### 11. Open or update the PR deliberately

- Before `gh pr create`, run `gh pr view --json number,url,state,headRefName,baseRefName`.
- If a PR already exists for the branch, update it with `gh pr edit` instead of creating a new one.
- When no PR exists yet, default to opening `gh pr create --web` without waiting for extra user confirmation unless the user explicitly asked not to.
- After opening the browser flow, do not say the PR is open until existence is confirmed with `gh pr view`.
- Otherwise say only that the browser creation flow was opened.

### 12. Verify the push before handoff

- After `git push`, verify the remote branch head explicitly with `git ls-remote --heads origin <branch>` or `gh pr view`.
- Do not rely only on local command output when saying the PR is ready.
- Record the verified pushed commit in the PR ledger.

### 13. Keep review fixes on the PR branch

- Once a PR exists, default all review-driven fixes to the PR branch worktree.
- Do not continue applying review fixes on the original source branch unless the user explicitly asks for that.

### 14. Run the branch-to-PR-to-merge loop

- Create PR 1 from the rebuilt branch.
- Wait for user review and merge.
- Fetch the updated default branch.
- Rebuild PR 2 from the new default branch.
- Repeat until the slice plan is complete.
- After the final slice is ready or merged, offer to clean up dedicated git worktrees and prune stale worktree metadata.

## Interaction Mode

- Work autonomously once the target PR sequence is agreed.
- Do not interrupt with progress narration unless blocked.
- Report back when a PR branch is ready to open.
- Provide a descriptive PR title and body text when handing it back.
- Prefer `gh pr create --web --title ... --body ...` and open it automatically once the branch is pushed and verified, unless the user has asked for a different PR flow.
- After the last slice, explicitly ask whether to remove dedicated PR worktrees and run `git worktree prune`.
