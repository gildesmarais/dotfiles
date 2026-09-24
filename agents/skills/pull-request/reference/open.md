# Open

Finished local change → commit → push → `gh pr create --web`. Autonomous; ask only when a required input can't be derived safely (missing ticket is not a blocker).

## Ticket

First match of `/[A-Z][A-Z0-9]+-\d+/` in `git branch --show-current`. Found → put it in the commit title, PR title, and body. None → continue ticketless (title/scope from branch slug or diff); request one only in a top-level interactive session when repo law requires it.

## Commit scope

- Only session-touched files; `git add` explicit paths after `git status --short`. Evidence order: files the agent changed this session → files tied to the stated task and modified this session → minimal dirty set completing the work. Ambiguous → list candidates, ask.
- Never clean, revert, or stash unrelated changes. Confirm staged diff = intended files before committing.
- Note Assure / validation evidence when available (soft precondition; not a block when the user explicitly opens).

## Commit message

Prefer phase commits already authored during Build. Only if the tree is still dirty, commit session-touched files once with Conventional Commits (format SoT: [`CONTEXT.md`](../../CONTEXT.md)), ticket right after scope:

```text
type(scope): [ABC-123] summary
type(scope): summary
```

Also satisfy repo-local commit conventions/body sections.

## PR

- Title/body per [`pr-narrative.md`](pr-narrative.md), rebuilt from full `base...HEAD`; list only validation actually run.
- Base branch: `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name` → `git symbolic-ref refs/remotes/origin/HEAD` → repo-declared base; ask only if underivable.
- Push with upstream; confirm push succeeded; `gh pr create --web --base <default> --title … --body …` (quote safely; avoid shell-reinterpreted backticks). `gh` unavailable/unauthenticated → give the URL/manual step.

## Jira sync

Ticket derived (or `$jira-ticket` flow) and Atlassian MCP available → run `jira-ticket` **Post-PR Jira sync** (→ **Ready for Review**, comment PR URL) without re-asking. Unavailable / no transition → report and continue.

## Output

Branch, ticket, commit hash + title, validation run, PR flow opened / URL, Jira status (or why skipped), local files intentionally left out.
