# Comment

Post **already-verified** findings as review comments. End-to-end retrieve → review → publish → stop, use `review.gil` `publish`.

Policy: "post"/"submit" → one review, `event: "COMMENT"`, all inline comments. "Draft"/"pending" → no event, never submit unless later asked explicitly. Never `APPROVE` / `REQUEST_CHANGES`. Label/decoration grammar → [`../../review.gil/reference/conventional-comments.md`](../../review.gil/reference/conventional-comments.md). API mechanics: [`gh-api.md`](gh-api.md).

## Sequence

1. **PR** — URL/number or `gh pr view --json number,headRefName,baseRefName,headRefOid,title,url`; capture head SHA.
2. **Re-verify** each finding in the diff and the runtime path it exercises. Never post from a summary alone.
3. **Dedupe** — fetch existing threads; match by path + issue. Classify: `publish-inline` | `reply-existing` | `review-body-only` | `drop`.
4. **Anchor** — RIGHT-side diff lines of the PR patch; if the exact line is unchanged, use the nearest changed line that represents the issue.
5. **Draft** — lead with bug/risk and production failure mode; test findings name the regression that would still pass. One comment per distinct issue. New inline: Conventional Comments first line (validate regex in conventional-comments.md). Existing-thread replies may be conversational. Don't silently dismiss idea/design threads: reply with a stance (`fixed in follow-up`, `intentionally deferred`, `separate follow-up`, `checked, no current break`).
6. **Post** — replies via `addPullRequestReviewThreadReply`. New inline via reviews API at head SHA. One pending review per user. Draft asked → never fall back to standalone or regular PR comments.
7. **Verify** each landed comment (path, body, URL) per [`gh-api.md`](gh-api.md).

## Output

Findings by severity with validity; per finding: new inline vs thread reply vs dropped; how idea threads were handled; review ID + discussion links; if pending was asked, confirm it is still pending.
