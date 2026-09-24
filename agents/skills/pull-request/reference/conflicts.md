# Conflicts

Make the PR mergeable onto base, preserving intent on both sides. Escalate network for fetch/push when sandboxed.

## Sequence

1. `gh pr view <pr> --json number,url,headRefName,baseRefName,mergeable,headRefOid`; `git fetch origin <base> <head>`; `git checkout <head>`.
2. Strategy: rebase onto base for a clean feature branch; merge base into head when shared or user asked. Unsure and shared → ask once.
3. Per conflicted path: read both sides + context; classify `ours` | `theirs` | `blend` | `needs-user`; prefer a blend keeping base correctness and branch intent. Never drop migrations, public API, or tests from either side without saying why. Genuine product fork → abort, restore clean tree, ask.
4. Finish: `git add <paths> && git rebase --continue` (repeat) or `git add <paths> && git commit`. Run the cheapest relevant gate.
5. Push: rebased non-shared branch → `git push --force-with-lease`; merge path → regular push.
6. Confirm `gh pr view <pr> --json mergeable,mergeStateStatus` — done when mergeable (or dirty only from CI).

No `git reset --hard` or force without lease unless recovering a failed rebase with user approval. Don't start **fix-ci**/**resolve** here — the unblock chain does.
