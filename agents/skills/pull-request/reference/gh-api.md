# GitHub API patterns for pull-request

Single reference for **comment**, **resolve**, and **reply** branches. Prefer the bundled `scripts/gh-review-comments` helper for structured thread data; use these patterns when the helper cannot run or for mutations the helper does not cover.

End-to-end PR review + publish (retrieve → review → reconcile drafts → submit) is owned by the **`review.gil` skill `publish`** execution and its `reference/github-state.md`. This file remains the API helper for posting already-verified findings and for resolve/reply.

**Submission policy:** “post/submit” creates one review with `event: COMMENT`. “Draft/pending” omits `event` and uses the pending-review flow below. Never submit `APPROVE` or `REQUEST_CHANGES`.

## Identify the PR

```bash
git branch --show-current
gh pr view --json number,url,headRefName,baseRefName,headRefOid,title
```

## Fetch review threads

### Bundled helper (preferred)

```bash
./scripts/gh-review-comments --filter unresolved --format json <pr-url>
```

Returns:

```json
{
  "pr": { "owner": "...", "repo": "...", "number": 123, "url": "..." },
  "threads": [
    {
      "thread_id": "PRRT_...",
      "resolved": false,
      "path": "app/models/foo.rb",
      "line": 42,
      "html_url": "https://github.com/...",
      "comments": [
        {
          "user": { "login": "reviewer" },
          "created_at": "...",
          "body": "...",
          "html_url": "..."
        }
      ]
    }
  ]
}
```

### Direct GraphQL fallback

```bash
gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner, name:$repo){ pullRequest(number:$number){ reviewThreads(first:100){ nodes { id isResolved path line comments(first:20){ nodes { id body url author { login } createdAt } } } } } } }' -F owner=OWNER -F repo=REPO -F number=PR
```

Paginate with `after` cursor when `pageInfo.hasNextPage` is true.

## Explicit pending-review state machine

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
│      (never APPROVE or REQUEST_CHANGES)                      │
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

## Reply on a thread

Match by thread id, not only by path and line, before replying.

```bash
gh api graphql -f query='mutation($threadId:ID!, $body:String!){ addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$threadId, body:$body}) { comment { id url } } }' -F threadId=THREAD_ID -F body=$'note: ...'
```

Batch multiple replies:

```bash
function post_reply() {
  gh api graphql -f query='mutation($threadId:ID!, $body:String!){ addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$threadId, body:$body}) { comment { id url } } }' -F threadId="$1" -F body="$2"
}

post_reply THREAD_ID_1 $'Addressed in abc1234: ...'
post_reply THREAD_ID_2 $'note: This is already covered by ...'
```

## Resolve a thread

Resolve only after the corresponding changes are pushed.

```bash
gh api graphql -f query='mutation($threadId:ID!){ resolveReviewThread(input:{threadId:$threadId}) { thread { isResolved } } }' -F threadId=THREAD_ID
```

Resolution reply before or with resolve:

```text
Addressed in <hash>: <precise change summary>.
```

## Verify replies, comments, and resolution

- `gh pr view --comments` often shows only the review header, not all inline bodies.
- Verify inline comments with `gh api repos/<owner>/<repo>/pulls/<pr>/reviews/<review_id>/comments`.
- Verify thread replies with GraphQL review-thread queries or the returned `html_url`.
- Re-fetch unresolved threads to confirm resolution state:

```bash
./scripts/gh-review-comments --filter unresolved --format json <pr-url>
```

Use REST review comments for verification after posting, but use GraphQL to add threads to an existing pending review.

Do not assume a mutation succeeded without checking the returned comment ID, discussion URL, or refreshed thread state.

## 422 pitfalls and recovery

| Error                                                                              | Cause                                                   | Recovery                                                                        |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------- |
| `422 User can only have one pending review per pull request` on `POST .../reviews` | Pending review already exists                           | Fetch the pending review node ID and use `addPullRequestReviewThread`           |
| `422` about pending review on `POST .../pulls/{pr}/comments`                       | Standalone inline comment conflicts with pending review | Do not switch to standalone inline comments if user asked for draft review form |
| Wrong review ID in GraphQL mutation                                                | Used REST numeric ID instead of GraphQL node ID         | Fetch pending review via GraphQL and use the `id` field                         |

**Key rules:**

- The GraphQL mutation uses the pending review node ID, not the numeric REST review ID.
- When the user asked for draft review comments, preserve that distinction all the way through. A regular PR comment or standalone inline comment is not equivalent.
- If GitHub network calls fail in the sandbox, retry with escalation and then verify the created review before reporting success.

## Network and permissions

- If a GitHub API call fails because of network restrictions, retry with escalated permissions.
- Do not assume the comment failed or succeeded without checking the returned review ID, comment IDs, or discussion URLs.
