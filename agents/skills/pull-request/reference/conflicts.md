# Conflicts

Rebase or merge a PR branch onto its base so the PR is mergeable. Preserve intent on both sides.

## Support

- Tools: `git`, `gh`. Escalate network for fetch/push when sandboxed.
- Identify PR with explicit field lists only:

```bash
gh pr view <pr> --json number,url,headRefName,baseRefName,mergeable,headRefOid
```

## Sequence

### 1. Sync

```bash
git fetch origin <base> <head>
git checkout <head>
```

Prefer **rebase onto base** when the PR is a clean feature branch; use **merge base into head** when the branch is shared or the user asked to merge. If unsure and history is shared with others → ask once.

### 2. Resolve each conflict

For every conflicted path:

1. Read both sides and surrounding code (not just markers).
2. Classify: `ours` | `theirs` | `blend` | `needs-user`.
3. Prefer a blend that keeps base correctness and branch intent.
4. Never drop migrations, public API, or test coverage from either side without stating why.

If intents genuinely conflict (product fork) → abort, restore a clean tree, and ask.

### 3. Finish

```bash
# rebase path
git add <paths> && git rebase --continue   # repeat until done

# merge path
git add <paths> && git commit
```

Run the repo's cheapest relevant gate when available. Push:

- Rebase onto base usually needs `git push --force-with-lease` — only after a successful rebase of a non-shared branch.
- Merge path: regular push.

### 4. Confirm

```bash
gh pr view <pr> --json mergeable,mergeStateStatus
```

Done when mergeable (or dirty only for CI, not conflicts).

## Guardrails

- No `git reset --hard` / force without lease unless recovering a failed rebase the user approved.
- Do not start **fix-ci** or **resolve** from this branch — callers in the unblock chain do that next.
