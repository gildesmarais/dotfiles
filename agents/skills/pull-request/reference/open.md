# Open

Turn a finished local change into a clean branch push plus browser-based PR flow.

Keep the workflow autonomous by default. Only stop to ask the user when a required input cannot be derived safely, especially the ticket number.

## Workflow

1. Inspect branch and worktree.
2. Derive the ticket number from the branch name.
3. Identify the session-touched files to include.
4. Validate the intended commit scope and recent verification evidence. Prefer noting Assure outcome / validation evidence when available (soft precondition — not a hard block when the user explicitly opens).
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

- Use Conventional Commits. Format SoT: [`CONTEXT.md`](../../CONTEXT.md) — do not paste a second copy here.
- Prefer history already authored per phase during Solution/Build. If the tree is still dirty at PR open, apply the same format once for session-touched files (leftover applicator — not the authoring home).
- Put the ticket immediately after the scope in square brackets when the branch encodes one.
- Format the title as:

```text
type(scope): [ABC-123] summary
```

- Prefer `fix` for bug fixes, `feat` for user-visible additions, `refactor` for behavior-preserving internal changes, `docs` for documentation-only changes, and `chore` for maintenance work.
- Keep the summary short and concrete; body = rationale / intent when useful.
- When the repository has local commit conventions, satisfy them too.
- If the repo requires commit body sections, include them.

## PR Title And Body

Write title and body per [`pr-narrative.md`](pr-narrative.md) (shared with **retitle**).

- Prefer the conventional commit shape when it still matches the diff: `type(scope): [ABC-123] summary`.
- Rebuild narrative from full `base...HEAD`, not the latest commit alone.
- Reuse the derived ticket in the PR title and body when the branch encodes one.
- Use validation commands actually run; if missing, say so plainly.

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

## After PR exists — Jira sync

When a ticket key was derived from the branch (or the session is a `$jira-ticket` flow) and Atlassian MCP is available:

- Run **Post-PR Jira sync** from the `jira-ticket` skill: transition the issue to **Ready for Review** (half-automatic) and comment the PR URL when possible.
- Do not ask the user to restate “move to review” if they already asked to open the PR for that ticket.
- If Atlassian is unavailable or no matching transition exists, report that and continue; do not fail the PR open.

## Output

Report:

- branch name
- derived ticket
- commit hash and title
- validation commands run
- whether the PR browser flow was opened (or REST/`gh pr create` URL)
- Jira status after Post-PR sync (or why skipped)
- any residual local files intentionally left out of the commit
