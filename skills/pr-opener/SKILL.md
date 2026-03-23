---
name: pr-opener
description: "Prepare git commit history and open a GitHub pull request in the browser. Use when the user wants Codex to commit the current session's work, derive a ticket like ABC-123 from the branch name, craft a conventional commit and PR title in the form scope: [TICKET-NR] summary, push the branch, and open `gh pr create --web` with a helpful prefilled description."
---

# PR Opener

Turn a finished local change into a clean branch push plus browser-based PR flow.

Keep the workflow autonomous by default. Only stop to ask the user when a required input cannot be derived safely, especially the ticket number.

## Workflow

1. Inspect branch and worktree.
2. Derive the ticket number from the branch name.
3. Identify the session-touched files to include.
4. Validate the intended commit scope and recent verification evidence.
5. Create a conventional commit.
6. Push the branch.
7. Open `gh pr create --web` with prefilled title and body.

## Branch And Ticket Rules

- Read the current branch name first with `git branch --show-current`.
- Extract the first ticket matching `/[A-Z][A-Z0-9]+-\d+/` from the branch name.
- If no `/[A-Z][A-Z0-9]+-\d+/` match is present, ask the user for the ticket number before committing or opening the PR.
- Reuse the derived ticket in:
  - the conventional commit title
  - the PR title
  - the PR body

## Commit Scope Rules

- Commit only session-touched files.
- Do not include unrelated modified or untracked files.
- Check `git status --short` and explicitly limit `git add` to the intended paths.
- Stay autonomous when identifying the session-touched set. Prefer evidence in this order:
  1. files the agent changed in the current session
  2. files clearly tied to the user's stated task and modified during this session
  3. the minimal set of dirty paths needed to satisfy the completed work
- When the worktree is dirty, distinguish between:
  - files that were part of the finished task and should be committed now
  - unrelated local files that must be left untouched
- If needed, inspect the staged diff, unstaged diff, recent commit history, and the conversation context to separate the intended paths from unrelated ones.
- If the session-touched set is ambiguous, summarize the candidate files and ask the user before committing.
- Never clean up, revert, or stash unrelated local changes unless the user explicitly asks.

## Commit Message Rules

- Use a conventional commit title.
- Put the ticket immediately after the scope in square brackets.
- Format the title as:

```text
type(scope): [ABC-123] summary
```

- Prefer `fix` for bug fixes, `feat` for user-visible additions, `refactor` for behavior-preserving internal changes, `docs` for documentation-only changes, and `chore` for maintenance work.
- Keep the summary short and concrete.
- When the repository has local commit conventions, satisfy them too.
- If the repo requires commit body sections, include them.

## PR Title Rules

- Default the PR title to the same pattern as the commit title:

```text
type(scope): [ABC-123] summary
```

- Keep the title aligned with the actual diff, not the branch name typo or temporary wording.

## PR Body Rules

Prefill a concise, useful description that helps reviewers immediately understand the change.

Include:
- `Summary`
- `Root Cause` for bug fixes
- `Fix`
- `Validation`
- `Ticket`

Use the actual commands already run for validation when available. If validation is missing, say so plainly instead of inventing it.

## Browser PR Flow

- Detect the repository's default branch before opening the PR.
- Prefer reliable repo metadata over guesswork. Check, in order:
  1. `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name` when `gh` is available and authenticated
  2. `git symbolic-ref refs/remotes/origin/HEAD` and extract the remote default branch name
  3. the current repo's configured base branch if the repository clearly defines one elsewhere
- Only ask the user when the default branch cannot be derived safely.
- Push with upstream tracking if needed.
- Open the PR with `gh pr create --web`.
- Pass `--base <default-branch>` using the detected default branch.
- Pass the prefilled `--title` and `--body`.
- Quote shell arguments safely. Avoid inline backticks or other shell-sensitive text that will be reinterpreted by the shell.

## Safety Checks

- Before committing, confirm the staged diff matches only the intended files.
- After committing, confirm the worktree is clean for the committed files.
- Before opening the PR, confirm the branch push succeeded.
- If `gh` is unavailable or unauthenticated, provide the PR URL or manual next step instead of blocking.

## Output

Report:
- branch name
- derived ticket
- commit hash and title
- validation commands run
- whether the PR browser flow was opened
- any residual local files intentionally left out of the commit
