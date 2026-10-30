# Open

Finished local change → commit → push → `gh pr create --web`. Autonomous; ask only when a required input can't be derived safely (a missing ticket is not a blocker).

## Ticket

First match of `/[A-Z][A-Z0-9]+-\d+/` in `git branch --show-current`. Found → put it in the commit title, PR title, and body. None → continue ticketless; request one only in a top-level interactive session when repo law requires it.

## Commit scope

- Session-touched files only, as explicit `git add` paths after `git status --short`. Evidence order: files changed this session → files tied to the stated task → minimal dirty set completing the work. Ambiguous → list candidates, ask.
- Never clean, revert, or stash unrelated changes; staged diff must equal the intended files.
- Cite Assure / validation evidence when available (soft precondition, never a block on an explicit open).

## Commit message

Prefer phase commits from Build. If the tree is still dirty, commit session-touched files once, Conventional Commits ([`../../dev/reference/plan.md`](../../dev/reference/plan.md)), ticket right after scope:

```text
type(scope): [ABC-123] summary
type(scope): summary
```

Repo-local commit conventions also apply. `Resolves: DEBT-<NUMBER>`: [`../../harvest/reference/debt.md`](../../harvest/reference/debt.md).

## PR

- Title/body per [`pr-narrative.md`](pr-narrative.md), rebuilt from full `base...HEAD`; list only validation actually run.
- Base branch: `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name` → `git symbolic-ref refs/remotes/origin/HEAD` → repo-declared base; ask only if underivable.
- Push with upstream, confirm, then `gh pr create --web --base <default> --title … --body …`. `gh` unavailable/unauthenticated → give the URL/manual step.

## Jira sync

Ticket derived (or `jira-ticket` flow) and a Jira tool available → run `jira-ticket` **Post-PR Jira sync** without re-asking. Unavailable / no transition → report and continue.

## Output

Branch, ticket, commit hash + title, validation run, PR flow opened / URL, Jira status (or why skipped), local files intentionally left out.
