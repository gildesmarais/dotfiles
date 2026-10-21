# Reply

Respond on existing review threads only: no new findings (→ **comment**), no code, no commit/push, no resolving unless asked.

## Sequence

1. **Discover + Fetch** — target threads via Shared prep `gh-review-comments` (fallback [`gh-api.md`](gh-api.md)); ask only when no PR or several plausible.
2. **Assess** each thread in code, then classify: `valid/actionable` | `needs user decision` | `stale/not applicable` | `already addressed` | `pushback`.
3. **Draft** — direct, grounded in verified behavior; Conventional Comments labels only when they add clarity. Draft-only ask → don't post.
4. **Post** — `addPullRequestReviewThreadReply`, matched by thread id; batch helper in [`gh-api.md`](gh-api.md).

## Summary

Threads replied; skipped + why; discussion URLs.
