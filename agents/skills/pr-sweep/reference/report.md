# Report

Build a prioritized attention ledger. Compact rows only.

## Discover

Require `<org>` from the user or automation prompt. Do not invent a default.

```bash
# Review requests waiting on you
gh search prs --review-requested=@me --owner=<org> --state=open \
  --json url,repository,title,number,updatedAt --limit 50

# Your open PRs (author)
gh search prs --author=@me --owner=<org> --state=open \
  --json url,repository,title,number,isDraft --limit 50
```

For each authored PR that might be blocked, fetch only:

```bash
gh pr view <url> --json url,mergeable,mergeStateStatus,statusCheckRollup,reviewDecision,author
```

Detect Dependabot with `author.login` matching `dependabot*` / `app/dependabot`. Do not walk all org PRs — stay on review-requested + authored sets unless the user widens scope.

## Classify (priority order)

1. Merge conflicts (`mergeable == CONFLICTING` or equivalent)
2. Failing checks on authored PRs
3. Unresolved review feedback on authored PRs (only if cheap signal exists; otherwise skip deep thread fetch)
4. Review requested on others' PRs
5. Open Dependabot PRs in the authored/review sets that look stale or red

One primary blocker per PR. Prefer the highest-priority label.

## Emit

Markdown table, one row per item:

| Priority | Repo       | PR         | Blocker                                               | Invocation       |
| -------- | ---------- | ---------- | ----------------------------------------------------- | ---------------- |
| 1        | `org/repo` | `#N` title | conflicts \| red-ci \| review-requested \| dependabot | exact `/skill …` |

Empty set → `No PRs need attention in <org>.`

No diffs. No log excerpts. No JSON dumps.
