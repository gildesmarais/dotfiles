# Report

## Discover

Stay on these two sets unless the user widens scope (never walk all org PRs):

```bash
gh search prs --review-requested=@me --owner=<org> --state=open \
  --json url,repository,title,number,updatedAt --limit 50
gh search prs --author=@me --owner=<org> --state=open \
  --json url,repository,title,number,isDraft --limit 50
```

Possibly blocked authored PR → only:

```bash
gh pr view <url> --json url,mergeable,mergeStateStatus,statusCheckRollup,reviewDecision,author
```

Dependabot = `author.login` matching `dependabot*` / `app/dependabot`.

## Classify (one primary blocker per PR, highest wins)

1. Conflicts (`mergeable == CONFLICTING`)
2. Failing checks on authored PRs
3. Unresolved review on authored PRs (only with a cheap signal; skip deep thread fetch)
4. Review requested on others' PRs
5. Stale or red Dependabot PRs in these sets

## Emit

| Priority | Repo       | PR         | Blocker                                               | Invocation       |
| -------- | ---------- | ---------- | ----------------------------------------------------- | ---------------- |
| 1        | `org/repo` | `#N` title | conflicts \| red-ci \| review-requested \| dependabot | exact `/skill …` |

Empty → `No PRs need attention in <org>.`
