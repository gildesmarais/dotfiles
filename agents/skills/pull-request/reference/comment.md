# Comment

Post **already-verified** findings as review comments. Review-then-publish end to end → `review.gil` `publish`.

Event policy + API: [`gh-api.md`](gh-api.md). Label grammar: [`../../review.gil/reference/conventional-comments.md`](../../review.gil/reference/conventional-comments.md).

## Sequence

1. **PR** — `gh pr view --json number,headRefName,baseRefName,headRefOid,title,url`; capture head SHA.
2. **Re-verify** each finding in the diff and the runtime path it exercises; never post from a summary alone.
3. **Dedupe** — fetch existing threads; match by path + issue. Classify: `publish-inline` | `reply-existing` | `review-body-only` | `drop`.
4. **Anchor** — RIGHT-side diff lines of the PR patch; if the exact line is unchanged, use the nearest changed line that represents the issue.
5. **Draft** — lead with bug/risk and production failure mode; test findings name the regression that would still pass. One comment per distinct issue. New inline and labeled replies use conventional-comments labels; plain thread replies may be conversational. Idea/design threads get a stance, never silent dismissal (`fixed in follow-up`, `intentionally deferred`, `separate follow-up`, `checked, no current break`).
6. **Post** — replies via `addPullRequestReviewThreadReply`. New inline via reviews API at head SHA. One pending review per user. Draft asked → never fall back to standalone or regular PR comments.
7. **Verify** each landed comment (path, body, URL) per [`gh-api.md`](gh-api.md).

## Output

Findings by severity with validity; per finding: inline / reply / dropped; idea-thread stances; review ID + links; pending state if a draft was asked.
