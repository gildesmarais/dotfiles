---
name: gh-pr-review
description: Review a GitHub pull request, verify findings against the actual diff and surrounding code, and post precise inline review comments or thread replies with `gh`. Use when asked to review a PR, validate a proposed finding, leave comments without submitting yet, reply on existing review threads, or confirm whether GitHub review comments actually landed.
---

# Gh Pr Review

## Overview

Review the code before commenting. Treat every finding as a claim to verify in the diff and relevant implementation, tests, or shared helpers.

Use `gh` to anchor comments on the exact PR line or reply on an existing thread. Prefer one strong, specific comment per issue over broad summaries.

## Workflow

### 1. Identify the PR

- Use the PR number or URL if the user gave one.
- Otherwise infer it from the current branch with `gh pr view`.
- Capture the PR number, base branch, head branch, and head SHA.

### 2. Read the code first

- Inspect the changed files and the implementation they exercise.
- Read enough surrounding code to understand the real runtime path, not just the changed test or helper in isolation.
- When a finding touches cross-system behavior, trace the full flow across caller, Cognito/Lambda, shared helpers, and backend/API boundaries.

### 3. Classify the action

- `new-comment`: The issue is not already covered by an open review thread.
- `thread-reply`: There is already an open thread on the same issue and you should add verified context instead of duplicating it.
- `no-comment`: The finding is not valid, is too weak, or is already sufficiently covered.
- `discussion-reply`: The thread is primarily a design thought, question, or idea rather than a concrete bug, and should receive an explicit disposition or follow-up stance instead of being silently dropped.

### 4. Draft review comments

- Lead with the bug or risk, not background.
- Explain why the current code can fail in production.
- Tie test findings to the concrete regression they would miss.
- Keep the tone direct and factual.
- Use labels like `issue:` or `note:` only when they improve scanability.

### 5. Post the comment the right way

For existing threads:

- Fetch review threads with GraphQL.
- Match by path and issue, not just file.
- Reply with `addPullRequestReviewThreadReply`.
- When you have multiple verified thread replies to post, prefer a small shell helper function so you can batch them consistently and retry the whole batch with escalation if GitHub network access is blocked.

For new inline comments:

- Use the PR head SHA and exact diff line on the changed file.
- Create a review comment through the reviews API.

Important pending-review rule:

- Creating a review with `"event": "COMMENT"` submits it immediately.
- If the user wants a pending review, create the review without an `event`.
- Add inline comments as part of that review payload.
- Submit it later only if the user explicitly asks.

### 6. Verify the comments landed

- `gh pr view --comments` often shows only the review header, not all inline bodies.
- Verify inline comments with `gh api repos/<owner>/<repo>/pulls/<pr>/reviews/<review_id>/comments`.
- Verify thread replies with GraphQL review-thread queries or the returned `html_url`.
- Give the user direct discussion links when useful.

### 7. Handle network and permission issues

- If a GitHub API call fails because of network restrictions, retry with escalated permissions.
- Do not assume the comment failed or succeeded without checking the returned review ID, comment IDs, or discussion URLs.

## Review Standard

- Prefer findings about real correctness, regression, auth/routing, contract mismatches, or missing behavior coverage.
- Avoid comments that only restate style preferences unless they materially affect maintainability or test precision.
- If a finding is already on the PR, reply on that thread with the extra evidence instead of posting a duplicate comment.
- When reviewing tests, ask what bug the test would catch and what likely bug would still pass.
- Do not silently dismiss open review threads that contain ideas, questions, or design pressure. If they are not concrete bugs, still reply with a clear stance such as `fixed in follow-up`, `good idea but intentionally deferred`, `valid concern, separate follow-up`, or `checked and did not find a current break`.

## Useful `gh` patterns

Identify the PR:

```bash
gh pr view --json number,headRefName,baseRefName,headRefOid,title,url
```

Fetch review threads:

```bash
gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner, name:$repo){ pullRequest(number:$number){ reviewThreads(first:100){ nodes { id isResolved path line comments(first:10){ nodes { id body author { login } } } } } } } }' -F owner=OWNER -F repo=REPO -F number=PR
```

Reply on an existing thread:

```bash
gh api graphql -f query='mutation($threadId:ID!, $body:String!){ addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$threadId, body:$body}) { comment { id url } } }' -F threadId=THREAD_ID -F body='issue: ...'
```

Batch multiple thread replies:

```bash
function post_reply() {
  gh api graphql -f query='mutation($threadId:ID!, $body:String!){ addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$threadId, body:$body}) { comment { id url } } }' -F threadId="$1" -F body="$2"
}

post_reply THREAD_ID_1 $'fixed in follow-up PR #1234.\n\n...'
post_reply THREAD_ID_2 $'valid concern.\n\n...'
```

Create a pending review with inline comments:

```bash
gh api repos/OWNER/REPO/pulls/PR/reviews --input review.json
```

`review.json` shape:

```json
{
  "body": "Review notes.",
  "comments": [
    {
      "path": "path/to/file.js",
      "line": 42,
      "side": "RIGHT",
      "body": "issue: ..."
    }
  ]
}
```

Verify inline comments on a review:

```bash
gh api repos/OWNER/REPO/pulls/PR/reviews/REVIEW_ID/comments
```

## Output expectations

- Report findings first, ordered by severity.
- State whether each proposed finding is valid.
- Say whether you posted a new inline comment or replied on an existing thread.
- If you encountered idea/discussion threads, say how you handled them and which ones were intentionally deferred versus fixed.
- If the review was meant to stay pending, say so explicitly and confirm whether it remained pending or was accidentally submitted.
