# Fix CI

Repair failing GitHub Actions on a PR. Frugal fetches only — never whole-run dumps or raw JSON blobs in context.

## Support

- Tools: `git`, `gh`, `jq`. Escalate network for `gh` when sandboxed.
- Prefer explicit `--json` field lists. Load [`gh-api.md`](gh-api.md) only for mutations it already covers.

## Sequence

### 1. Identify target

Accept a PR URL/number or an Actions run/job URL. Resolve to:

```bash
gh pr view <pr> --json number,url,headRefName,baseRefName,headRefOid,statusCheckRollup
```

From a run URL, map back with `gh run view <id> --json databaseId,headBranch,url,conclusion` then `gh pr list --head <branch> --json number,url`.

### 2. Isolate failures

```bash
gh pr checks <pr> --json name,state,bucket,link,workflow
```

Act only on failed/cancelled required checks (`bucket` is `fail` or `cancel`). Skip pending/skipped. If still running and the user asked to watch: `gh pr checks <pr> --watch` once — no tight poll loops.

### 3. Fetch failing logs only

For each failed check, open the linked job/run and pull **failed-step** logs:

```bash
gh run view <run-id> --job <job-id> --log-failed
```

Cap reading to the failing shard/step. Do not download entire artifact zips unless the failure is unreachable from `--log-failed`. Do not paste tokens, secrets, or credentials from logs into context or the user-visible report.

### 4. Classify

| Label                 | Action                                                             |
| --------------------- | ------------------------------------------------------------------ |
| `caused-by-pr`        | Fix on the PR branch                                               |
| `flake`               | Re-run once if known-flake; otherwise note and stop (do not churn) |
| `infra` / `unrelated` | Report; do not invent product fixes                                |
| `needs-user`          | Auth, secrets, product intent — ask                                |

### 5. Fix, verify, push

Smallest safe change on the PR head. Prefer local repro when cheap (repo's documented test/lint target for the failing job). Commit with Conventional Commits. Push to the PR head (no force unless the branch already requires it and the user consented).

### 6. Watch

```bash
gh pr checks <pr> --watch
```

Report pass/fail. Flakes that persist after one re-run → hand to user; do not loop forever.

## Guardrails

- "Why is CI failing?" without a fix ask → report only; do not push.
- Never approve or merge the PR.
- Never rewrite unrelated history or Dependabot's original commits (see `dependabot` **triage**).
