# Triage

Assess a Dependabot PR and clear fallout. Stop before approve/merge.

## Sequence

### 1. Identify

```bash
gh pr view <pr> --json number,url,title,author,headRefName,baseRefName,files,commits,statusCheckRollup,mergeable
```

Confirm author is Dependabot (or equivalent bot). Note ecosystem from title/files.

### 2. Risk skim

Read the PR body / release notes links and the changed lockfile/manifest hunks only. Classify:

| Label                | Meaning                               |
| -------------------- | ------------------------------------- |
| `routine`            | Patch/minor, no known break signals   |
| `major` / `breaking` | Major bump or changelog break signals |
| `security`           | Security advisory update              |
| `needs-user`         | Product/migration decision required   |

Do not dump full changelogs into context — summarize in a few bullets.

### 3. Clear blockers

Refresh live state each pass:

1. Conflicts → prefer `@dependabot rebase` when the branch has **no** manual commits; otherwise `pull-request` **conflicts**.
2. Failing CI → `pull-request` **fix-ci**. Commit fixes as **separate** Conventional Commits on top of the bot commits. Never amend/rebase-away Dependabot's commits. Use `[dependabot skip]` in fix commit subjects when the bot must rebase later.
3. Unresolved human review threads → `pull-request` **resolve** only if the user asked to address comments.

### 4. Report approve-readiness

Emit a short block:

- Risk label + one-line rationale
- CI/conflicts status
- Manual commits added (hashes) or none
- **Approve-ready: yes | no | conditional** — and what a human should verify

Do **not** approve, enable auto-merge, or merge unless the user explicitly asks in a later turn (out of scope for this branch's completion).

## Guardrails

- Load [`pr-commands.md`](pr-commands.md) only when commenting `@dependabot …`.
- Frugal fetches: failed-job logs only via **fix-ci**; no whole-run dumps.
