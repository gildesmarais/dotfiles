# Reply

Respond on existing review threads only: no new findings (→ **comment**), no code, no commit/push, no resolving unless asked.

## Sequence

1. **Discover** — `gh pr view --json url,number` (fallback `gh pr status`); ask only when no PR or several plausible.
2. **Fetch** — `./scripts/gh-review-comments --filter unresolved --format json <pr-url>` (skill-dir-relative; fallback [`gh-api.md`](gh-api.md)).
3. **Assess** each thread in code, then classify: `valid/actionable` (substantive reply, may note deferred fix) | `needs user decision` (ask before posting) | `stale/not applicable` (explain) | `already addressed` (cite code/commit) | `pushback` (correct the misread).
4. **Draft** — direct, grounded in verified behavior; Conventional Comments labels (`note:`, `issue:`, `suggestion:`, `question:`) only when they add clarity. State anything still unverified. Draft-only ask → don't post.
5. **Post** — `addPullRequestReviewThreadReply`, matched by thread id (not path/line); batch helper in [`gh-api.md`](gh-api.md).

## Summary

Threads replied; skipped + why; discussion URLs.
