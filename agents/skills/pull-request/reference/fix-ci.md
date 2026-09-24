# Fix CI

Repair failing GitHub Actions on a PR. "Why is CI failing?" without a fix ask → report only, no push.

## Sequence

1. **Target** — `gh pr view <pr> --json number,url,headRefName,baseRefName,headRefOid,statusCheckRollup`. From a run URL: `gh run view <id> --json databaseId,headBranch,url,conclusion` → `gh pr list --head <branch> --json number,url`.
2. **Isolate** — `gh pr checks <pr> --json name,state,bucket,link,workflow`; act only on `bucket` `fail`/`cancel`. Still running and user asked to watch → `gh pr checks <pr> --watch` once, no poll loops.
3. **Logs** — `gh run view <run-id> --job <job-id> --log-failed`, capped to the failing step/shard. No artifact zips unless unreachable otherwise. Never echo secrets/tokens from logs.
4. **Classify** — `caused-by-pr` → fix on PR branch | `flake` → re-run once if known-flake, else note and stop | `infra`/`unrelated` → report, no product fix | `needs-user` (auth, secrets, product intent) → ask.
5. **Fix** — repro locally via the job's repo target when cheap; Conventional Commit; push to PR head. No force-push unless the branch already requires it and the user consented.
6. **Watch** — `gh pr checks <pr> --watch` once; report. Flake persisting after one re-run → hand to user.

Never approve/merge. Never rewrite unrelated history or Dependabot's commits (`dependabot` **triage**).
