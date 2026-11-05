# Open

Finished local change → commit → push → `gh pr create`. Autonomous; ask only when a required input can't be derived safely (missing ticket is not a blocker).

## Ticket

First match of `/[A-Z][A-Z0-9]+-\d+/` in `git branch --show-current`; with tracker kind github (`.agents/tracker.md`) also a leading `<N>-` branch prefix, or a `#N`/issue URL from the session → issue `#N`. Found → put the key or `#N` in the commit title, PR title, and body. None → continue ticketless; request one only in a top-level interactive session when repo law requires it.

## Commit scope

- Session-touched files only, as explicit `git add` paths after `git status --short`. Evidence order: this session → stated task → minimal dirty set. Ambiguous → list candidates, ask.
- Never clean, revert, or stash unrelated changes; staged diff must equal the intended files.
- Cite Assure / validation evidence when available (soft precondition; never block an explicit open).

## Commit message

Prefer phase commits from Build. If dirty, commit session-touched files once, Conventional Commits ([`../../dev/reference/plan.md`](../../dev/reference/plan.md)), ticket right after scope:

```text
type(scope): [ABC-123] summary
type(scope): summary
```

Repo-local conventions also apply. `Resolves: DEBT-<NUMBER>`: [`../../harvest/reference/debt.md`](../../harvest/reference/debt.md).

## PR

- Title/body per [`pr-narrative.md`](pr-narrative.md), rebuilt from full `base...HEAD`; list only validation actually run.
- Base: `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name` → `git symbolic-ref refs/remotes/origin/HEAD` → repo-declared base; ask only if underivable.
- Push with upstream, confirm, then `gh pr create --base <default> --title … --body …`. `gh` unavailable → URL/manual step.

## Ticket sync

PR resolves a ticket (Jira key or GitHub issue; derived or `ticket` flow) → `ticket` **Post-PR sync** without re-asking. Unavailable / no transition → report and continue. Own PR with Delivery Ledger `Rollout` removal owed → `ticket` `create` Cutover follow-up (same epic; trigger if known); else Residuals + say so. Report ticket ID in Output.

## Output

Branch, ticket, commit hash + title, validation run, PR URL, ticket status (or why skipped), files left out.

