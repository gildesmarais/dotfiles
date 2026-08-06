# GitHub state machine (`publish`)

Pending-review and thread mutations for the `review.gil` skill **`publish`** execution. Ordinary review publishing uses `event: COMMENT` only. Never submit `REQUEST_CHANGES` or `APPROVE` from this skill.

For resolve/reply helpers owned by the `pull-request` skill, see that skill’s `reference/gh-api.md`. End-to-end PR review + publish lives here.

## Identify the PR

```bash
gh pr view --json number,url,headRefName,baseRefName,headRefOid,title
# or
./scripts/pr-context.sh --publish <pr-url-or-number>
```

## Fetch pending review for the current user

Use the `pending_reviews` array from `pr-context.sh --publish`. It is already filtered to `gh api user --jq .login` and fails closed rather than returning truncated review state.

GitHub allows **one** pending review per user per PR.

## State machine

```text
No pending review
  → POST /repos/{owner}/{repo}/pulls/{pr}/reviews
    with commit_id, body, comments[], event: "COMMENT"
  → verify review + comment URLs

Pending review exists
  → snapshot review node id + draft comments
  → deletePullRequestReviewComment for each draft classified drop
  → addPullRequestReviewThread for each new publish-inline finding
  → POST .../reviews/{databaseId}/events  { "event": "COMMENT", "body": "..." }
  → verify; confirm pending queue empty

Useful replies on existing threads (after main review succeeds)
  → addPullRequestReviewThreadReply
```

## Create and submit in one shot (no pending)

```json
{
  "commit_id": "HEAD_SHA",
  "event": "COMMENT",
  "body": "## Review findings\n\n...",
  "comments": [
    {
      "path": "app/models/example.rb",
      "line": 42,
      "side": "RIGHT",
      "body": "issue (test): subject\n\nDiscussion..."
    }
  ]
}
```

```bash
gh api repos/OWNER/REPO/pulls/PR/reviews --input review.json
```

**Payload guard:** abort if `event` is anything other than `COMMENT`.

## Delete an individual draft comment

Prefer per-comment delete over discarding the whole pending review.

```bash
gh api graphql -f query='
mutation($id:ID!) {
  deletePullRequestReviewComment(input:{id:$id}) {
    clientMutationId
  }
}' -F id=COMMENT_NODE_ID
```

## Append a thread to the pending review

Use the pending review **GraphQL node ID** (`id`), not the REST `databaseId`:

```bash
gh api graphql -f query='
mutation($reviewId:ID!, $path:String!, $line:Int!, $body:String!) {
  addPullRequestReviewThread(input:{
    pullRequestReviewId:$reviewId,
    path:$path,
    line:$line,
    side:RIGHT,
    body:$body
  }) {
    thread { id comments(first:1){ nodes { url body } } }
  }
}' -F reviewId=REVIEW_NODE_ID -F path='path/to/file.rb' -F line=123 -F body=$'issue: ...'
```

## Submit a pending review as COMMENT

```bash
gh api repos/OWNER/REPO/pulls/PR/reviews/REVIEW_DATABASE_ID/events \
  --input - <<'EOF'
{ "event": "COMMENT", "body": "## Review findings\n\n..." }
EOF
```

## Reply on an existing thread

```bash
gh api graphql -f query='
mutation($threadId:ID!, $body:String!) {
  addPullRequestReviewThreadReply(input:{
    pullRequestReviewThreadId:$threadId,
    body:$body
  }) {
    comment { id url body }
  }
}' -F threadId=THREAD_ID -F body=$'issue (test): ...'
```

## Last-resort: delete entire pending review

Only when per-comment reconcile is impossible. Snapshot the preserved ledger first, then recreate and verify before submit.

```bash
gh api graphql -f query='
mutation($id:ID!) {
  deletePullRequestReview(input:{pullRequestReviewId:$id}) {
    pullRequestReview { id state }
  }
}' -F id=REVIEW_NODE_ID
```

## 422 recovery

| Error                                                        | Cause                    | Recovery                                                                              |
| ------------------------------------------------------------ | ------------------------ | ------------------------------------------------------------------------------------- |
| `422 User can only have one pending review per pull request` | Pending already exists   | Append via `addPullRequestReviewThread`; do not create a second pending review        |
| Wrong review ID in GraphQL                                   | Used REST numeric ID     | Use GraphQL `id` field from pending reviews query                                     |
| Partial failure mid-reconcile                                | Network / mutation error | Re-fetch pending comments and threads; resume from actual state; never blindly replay |

## Verify

```bash
gh api repos/OWNER/REPO/pulls/PR/reviews/REVIEW_ID/comments \
  --jq '.[] | {path, line, html_url, body: .body[0:120]}'
```

Confirm:

- Review `state` is `COMMENTED` (not `CHANGES_REQUESTED` / `APPROVED`)
- No PENDING review remains for the current user (unless draft-only was requested)
- Every discussion URL is returned to the user

## Scenarios to exercise mentally before mutating

1. No pending review → one-shot COMMENT create
2. Pending with keep + drop drafts → per-comment delete, append, submit COMMENT
3. Duplicate bot thread → `reply-existing` instead of new inline
4. Head SHA changed between ledger and mutate → abort, refresh, re-anchor
5. Partial API failure → inspect state, resume without duplicates
