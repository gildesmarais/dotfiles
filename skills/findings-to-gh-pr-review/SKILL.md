---
name: findings-to-gh-pr-review
description: Verify written review findings against the current GitHub pull request diff and post them as pending inline review comments with `gh`. Use when Codex already has concrete findings and the user wants them posted on the PR as draft review comments at exact file and line locations, without submitting the review.
---

# Findings To Gh Pr Review

Turn concrete findings into precise pending PR review comments. Verify each finding in code before posting, anchor it to an actual changed diff line, and avoid duplicating existing threads.

## Workflow

1. Identify the target PR.
   If the user gives a PR number or URL, use it.
   Otherwise infer the PR from the current branch with `gh pr view`.
   Capture the PR number, base branch, head branch, and head SHA.

2. Treat every finding as a claim to verify.
   Read the changed spec or source file, the relevant production code, and the PR diff around the target line.
   Do not post findings from a review summary alone.

3. Check whether the issue is already covered.
   Fetch existing review threads with `gh api graphql`.
   If an open or pending thread already covers the same issue, prefer a thread reply or skip posting rather than duplicating the comment.

4. Match each finding to a diff line.
   Use the changed file and the PR patch, not only the working tree line number.
   Post only on lines that exist on the RIGHT side of the diff.
   If the exact line is not changed in the PR, attach to the nearest changed line that still represents the issue clearly.

5. Draft comments as concrete findings.
   Lead with the bug or confidence gap.
   Explain what the test or code currently asserts.
   Explain why that misses a real regression or blesses the wrong contract.
   State the stronger test shape or behavior check when helpful.
   Keep the tone direct and factual.

6. Check review state before posting.
   GitHub only allows one pending review per user per PR.
   If you do not already have a pending review, create one pending review with all new inline comments.
   If you already have a pending review, append new threads to that existing review instead of trying to create a second pending review.

7. Keep the review pending unless the user explicitly asks to submit it.
   Do not set a review `event` when creating the review.
   Do not fall back to standalone review comments if the user asked for draft review comments.

8. Verify the comments landed.
   Fetch `repos/<owner>/<repo>/pulls/<pr>/reviews/<review_id>/comments`.
   Confirm the path, body, and discussion URL for each comment.
   Report the review ID and discussion links back to the user.

## Comment Standard

- Post only findings that are already well-formed and high confidence.
- Prefer one comment per distinct issue.
- When the finding concerns tests, say what bug would still pass.
- When the finding concerns changed behavior, tie it to the concrete runtime path.
- Do not restate broad summaries as multiple weak comments.

## `gh` Patterns

Identify the PR:

```bash
gh pr view --json number,headRefName,baseRefName,headRefOid,url
```

Fetch review threads:

```bash
gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner, name:$repo){ pullRequest(number:$number){ reviewThreads(first:100){ nodes { id isResolved path line comments(first:20){ nodes { id body url } } } } } } }' -F owner=OWNER -F repo=REPO -F number=PR
```

Fetch pending reviews for the PR:

```bash
gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner, name:$repo){ pullRequest(number:$number){ id reviews(first:50, states:[PENDING]){ nodes { id databaseId state body } } } } }' -F owner=OWNER -F repo=REPO -F number=PR
```

Create a pending review:

```json
{
  "body": "Review notes.",
  "comments": [
    {
      "path": "spec/path/file_spec.rb",
      "line": 123,
      "side": "RIGHT",
      "body": "issue: ..."
    }
  ]
}
```

```bash
gh api repos/OWNER/REPO/pulls/PR/reviews --input review.json
```

Append a new inline thread to an existing pending review:

```bash
gh api graphql -f query='mutation($reviewId:ID!, $path:String!, $line:Int!, $body:String!){ addPullRequestReviewThread(input:{pullRequestReviewId:$reviewId, path:$path, line:$line, side:RIGHT, body:$body}) { thread { id comments(first:1){ nodes { url body } } } } }' -F reviewId=REVIEW_NODE_ID -F path='path/to/file.rb' -F line=123 -F body=$'issue: ...'
```

Verify review comments:

```bash
gh api repos/OWNER/REPO/pulls/PR/reviews/REVIEW_ID/comments
```

## Review State Pitfalls

- If `gh api repos/.../pulls/<pr>/reviews --input review.json` returns `422` with `User can only have one pending review per pull request`, fetch the pending review and append threads with `addPullRequestReviewThread`.
- If `gh api repos/.../pulls/<pr>/comments` returns a `422` about a pending review, do not switch to standalone inline comments. That breaks the user's request to keep everything in draft review form.
- The GraphQL mutation uses the pending review node ID, not the numeric REST review ID.
- Use REST review comments for verification after posting, but use GraphQL to add threads to an existing pending review.
- When the skill says "draft review comments", preserve that distinction all the way through. A regular PR comment or standalone inline comment is not equivalent.

## Boundaries

- Do not post a finding you have not re-verified in code.
- Do not submit the review unless the user explicitly asks.
- Do not duplicate an existing thread on the same issue.
- Do not attach comments to unchanged lines if a changed line can represent the issue.
- Do not create a second pending review when one already exists for the same user.
- If GitHub network calls fail in the sandbox, retry with escalation and then verify the created review before reporting success.
