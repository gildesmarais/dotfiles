# Comment

Post **already-verified** findings as review comments. End-to-end retrieve → review → publish → stop, use `review.gil` `publish`.

Policy: "post"/"submit" → one review, `event: "COMMENT"`, all inline comments. "Draft"/"pending" → no event, never submit unless later asked explicitly. Never `APPROVE` / `REQUEST_CHANGES`. API mechanics: [`gh-api.md`](gh-api.md).

## Sequence

1. **PR** — URL/number or `gh pr view --json number,headRefName,baseRefName,headRefOid,title,url`; capture head SHA.
2. **Re-verify** each finding in the diff and the runtime path it exercises (callers, shared helpers, API boundaries). Never post from a summary alone.
3. **Dedupe** — fetch existing threads; match by path + issue. Classify: `publish-inline` | `reply-existing` (add evidence/disposition on the open thread) | `review-body-only` (no precise anchor) | `drop` (invalid, weak, duplicate, answered).
4. **Anchor** — RIGHT-side diff lines of the PR patch (not working-tree numbers); if the exact line is unchanged, use the nearest changed line that represents the issue.
5. **Draft** — lead with bug/risk and production failure mode; test findings name the regression that would still pass. One comment per distinct issue; correctness/regression/auth/contract/coverage over style.
   - New inline first line: `label [(decorations)]: subject`, blank line, evidence/impact. Labels `issue|suggestion|question|note|nitpick|praise`; decorations `security|test|performance|non-blocking`; never `blocking`. Validate against `^[a-z][a-z-]*( \([a-z-]+(, [a-z-]+)*\))?: .+`.
   - Existing-thread replies may be conversational.
   - Don't silently dismiss idea/design threads: reply with a stance (`fixed in follow-up`, `intentionally deferred`, `separate follow-up`, `checked, no current break`).
6. **Post** — replies via `addPullRequestReviewThreadReply` (batch helper; retry whole batch escalated on network block). New inline via reviews API at head SHA. One pending review per user: create one with all comments, or append to the existing one. Draft asked → never fall back to standalone or regular PR comments.
7. **Verify** each landed comment (path, body, URL) per [`gh-api.md`](gh-api.md).

## Output

Findings by severity with validity; per finding: new inline vs thread reply vs dropped; how idea threads were handled (fixed vs deferred); review ID + discussion links; if pending was asked, confirm it is still pending (not accidentally submitted).
