# GitHub API patterns for PR review posting

Reference for `gh-review-specific-pr`: pending review state machine, thread replies, inline comments, and 422 recovery.

## Identify the PR

```bash
gh pr view --json number,headRefName,baseRefName,headRefOid,url
```

## Fetch review threads

```bash
gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner, name:$repo){ pullRequest(number:$number){ reviewThreads(first:100){ nodes { id isResolved path line comments(first:20){ nodes { id body url author { login } } } } } } } }' -F owner=OWNER -F repo=REPO -F number=PR
```

## Pending review state machine

GitHub allows **one pending review per user per PR**.

```
┌─────────────────────────────────────────────────────────────┐
│  No pending review exists                                   │
│    → POST /repos/{owner}/{repo}/pulls/{pr}/reviews          │
│      (no `event` field) with inline `comments` array        │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  Pending review exists (state: PENDING)                     │
│    → addPullRequestReviewThread (GraphQL)                     │
│      using the pending review **node ID**                   │
│    → Do NOT create a second pending review                  │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼ (user explicitly asks)
┌─────────────────────────────────────────────────────────────┐
│  Submit review                                              │
│    → POST .../reviews/{id}/events with event: COMMENT       │
│      (or APPROVE / REQUEST_CHANGES)                         │
└─────────────────────────────────────────────────────────────┘
```

### Fetch pending reviews

```bash
gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner, name:$repo){ pullRequest(number:$number){ id reviews(first:50, states:[PENDING]){ nodes { id databaseId state body } } } } }' -F owner=OWNER -F repo=REPO -F number=PR
```

## Create a pending review with inline comments

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

**Important:** Do not set an `event` field when creating a pending review. Setting `"event": "COMMENT"` submits immediately.

## Append to an existing pending review

Use GraphQL `addPullRequestReviewThread` with the pending review **node ID** (not the numeric REST review ID):

```bash
gh api graphql -f query='mutation($reviewId:ID!, $path:String!, $line:Int!, $body:String!){ addPullRequestReviewThread(input:{pullRequestReviewId:$reviewId, path:$path, line:$line, side:RIGHT, body:$body}) { thread { id comments(first:1){ nodes { url body } } } } }' -F reviewId=REVIEW_NODE_ID -F path='path/to/file.rb' -F line=123 -F body=$'issue: ...'
```

## Reply on an existing thread

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

## Verify review comments

```bash
gh api repos/OWNER/REPO/pulls/PR/reviews/REVIEW_ID/comments
```

Use REST review comments for verification after posting, but use GraphQL to add threads to an existing pending review.

## 422 pitfalls and recovery

| Error                                                                              | Cause                                                   | Recovery                                                                        |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------- |
| `422 User can only have one pending review per pull request` on `POST .../reviews` | Pending review already exists                           | Fetch the pending review node ID and use `addPullRequestReviewThread`           |
| `422` about pending review on `POST .../pulls/{pr}/comments`                       | Standalone inline comment conflicts with pending review | Do not switch to standalone inline comments if user asked for draft review form |
| Wrong review ID in GraphQL mutation                                                | Used REST numeric ID instead of GraphQL node ID         | Fetch pending review via GraphQL and use the `id` field                         |

**Key rules:**

- The GraphQL mutation uses the pending review node ID, not the numeric REST review ID.
- When the skill says "draft review comments", preserve that distinction all the way through. A regular PR comment or standalone inline comment is not equivalent.
- If GitHub network calls fail in the sandbox, retry with escalation and then verify the created review before reporting success.
