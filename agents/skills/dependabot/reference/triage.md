# Triage

Assess a Dependabot PR and clear fallout; stop before approve/merge.

1. **Identify** — `gh pr view <pr> --json number,url,title,author,headRefName,baseRefName,files,commits,statusCheckRollup,mergeable`; confirm bot author.
2. **Risk** — PR body / release-note links + lockfile/manifest hunks only; a few bullets. Label: `routine` (patch/minor, no break signals) | `major`/`breaking` | `security` | `needs-user` (product/migration decision).
3. **Clear blockers** (refresh live state each pass):
   - Conflicts → `@dependabot rebase` if no manual commits, else `pull-request` **conflicts**.
   - Failing CI → `pull-request` **fix-ci**: separate Conventional Commits on top, `[dependabot skip]` in subjects when the bot must rebase later.
   - Human review threads → `pull-request` **resolve** only if the user asked.
4. **Report** — risk label + rationale; CI/conflict status; manual commit hashes (or none); **Approve-ready: yes | no | conditional** + what a human should verify. Approve/auto-merge/merge only on an explicit later-turn ask, outside this branch.
