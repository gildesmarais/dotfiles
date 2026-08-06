# Comment

Post **already-verified** findings as new GitHub review comments on a specific pull request.

For end-to-end “retrieve PR → review → reconcile drafts → publish”, stop and use the **`review.gil` skill `publish`** execution instead. The `comment` branch is for findings the user or another workflow already verified.

## Overview

Treat every finding as a claim to re-verify in the diff and relevant implementation, tests, or shared helpers before posting.

Use `gh` to anchor comments on the exact PR line or reply on an existing thread. Prefer one strong, specific comment per issue over broad summaries.

**Submission policy:** “post” or “submit” means one `event: "COMMENT"` review. “Draft” or “pending” means create/append without an event and do not submit. Never submit `APPROVE` or `REQUEST_CHANGES`.

## Workflow

### 1. Identify the PR

- Use the PR number or URL if the user gave one.
- Otherwise infer it from the current branch with `gh pr view`.
- Capture the PR number, base branch, head branch, and head SHA.

```bash
gh pr view --json number,headRefName,baseRefName,headRefOid,title,url
```

### 2. Read the code first

- Inspect the changed files and the implementation they exercise.
- Read enough surrounding code to understand the real runtime path, not just the changed test or helper in isolation.
- When a finding touches cross-system behavior, trace the full flow across callers, external services, shared helpers, and backend/API boundaries.
- Treat every finding as a claim to verify. Do not post findings from a review summary alone.

### 3. Check whether the issue is already covered

- Fetch existing review threads with `gh api graphql`.
- If an open or pending thread already covers the same issue, prefer a thread reply or skip posting rather than duplicating the comment.
- Match by path and issue, not just file.

### 4. Classify the action

- `publish-inline`: The issue is not already covered by an open review thread.
- `reply-existing`: An open thread already covers the issue; add verified context or a clear disposition instead of duplicating it.
- `review-body-only`: The point belongs in the review summary but has no precise inline anchor.
- `drop`: The finding is invalid, weak, duplicate, or already answered.

### 5. Match findings to diff lines

- Use the changed file and the PR patch, not only the working tree line number.
- Post only on lines that exist on the RIGHT side of the diff.
- If the exact line is not changed in the PR, attach to the nearest changed line that still represents the issue clearly.
- Do not attach comments to unchanged lines if a changed line can represent the issue.

### 6. Draft review comments

- Lead with the bug or risk, not background.
- Explain why the current code can fail in production.
- Tie test findings to the concrete regression they would miss.
- Keep the tone direct and factual.
- Format every new inline finding as `label [(decorations)]: subject`, followed by one blank line and concise evidence/impact. Use lowercase `issue`, `suggestion`, `question`, `note`, `nitpick`, or `praise`; optional decorations are `security`, `test`, `performance`, or `non-blocking`. Never use `blocking`.
- Validate each first line against `^[a-z][a-z-]*( \([a-z-]+(, [a-z-]+)*\))?: .+`.
- Existing-thread replies may remain conversational when a label would add no clarity.
- Post only findings that are already well-formed and high confidence.
- Prefer one comment per distinct issue.

### 7. Post the comment the right way

**For existing threads:**

- Reply with `addPullRequestReviewThreadReply`.
- When you have multiple verified thread replies to post, prefer a small shell helper function so you can batch them consistently and retry the whole batch with escalation if GitHub network access is blocked.

**For new inline comments:**

- Use the PR head SHA and exact diff line on the changed file.
- Create a review comment through the reviews API.

**Pending review rules:**

- Creating a review with `"event": "COMMENT"` submits it immediately.
- For “post” or “submit,” create one review with `"event": "COMMENT"` and all verified inline comments.
- Only when the user explicitly wants a pending/draft review, create the review without an `event`.
- Add inline comments as part of that review payload.
- Submit a pending review later only if the user explicitly asks.
- GitHub only allows one pending review per user per PR.
- If you do not already have a pending review, create one pending review with all new inline comments.
- If you already have a pending review, append new threads to that existing review instead of trying to create a second pending review.
- Do not fall back to standalone review comments if the user asked for draft review comments.

See [`gh-api.md`](gh-api.md) for the pending review state machine, `addPullRequestReviewThread`, and 422 recovery.

### 8. Verify the comments landed

- `gh pr view --comments` often shows only the review header, not all inline bodies.
- Verify inline comments with `gh api repos/<owner>/<repo>/pulls/<pr>/reviews/<review_id>/comments`.
- Verify thread replies with GraphQL review-thread queries or the returned `html_url`.
- Confirm the path, body, and discussion URL for each comment.
- Give the user direct discussion links when useful.
- Report the review ID and discussion links back to the user.

### 9. Handle network and permission issues

- If a GitHub API call fails because of network restrictions, retry with escalated permissions.
- Do not assume the comment failed or succeeded without checking the returned review ID, comment IDs, or discussion URLs.

## Review standard

- Prefer findings about real correctness, regression, auth/routing, contract mismatches, or missing behavior coverage.
- Avoid comments that only restate style preferences unless they materially affect maintainability or test precision.
- If a finding is already on the PR, reply on that thread with the extra evidence instead of posting a duplicate comment.
- When reviewing tests, ask what bug the test would catch and what likely bug would still pass.
- When the finding concerns tests, say what bug would still pass.
- When the finding concerns changed behavior, tie it to the concrete runtime path.
- Do not restate broad summaries as multiple weak comments.
- Do not silently dismiss open review threads that contain ideas, questions, or design pressure. If they are not concrete bugs, still reply with a clear stance such as `fixed in follow-up`, `good idea but intentionally deferred`, `valid concern, separate follow-up`, or `checked and did not find a current break`.

## Output expectations

- Report findings first, ordered by severity.
- State whether each proposed finding is valid.
- Say whether you posted a new inline comment or replied on an existing thread.
- If you encountered idea/discussion threads, say how you handled them and which ones were intentionally deferred versus fixed.
- If the review was meant to stay pending, say so explicitly and confirm whether it remained pending or was accidentally submitted.

## Boundaries

- Do not post a finding you have not re-verified in code.
- Do not submit when the user explicitly asks for draft/pending state.
- Do not duplicate an existing thread on the same issue.
- Do not create a second pending review when one already exists for the same user.
- When the user asked for draft review comments, preserve that distinction all the way through. A regular PR comment or standalone inline comment is not equivalent.
