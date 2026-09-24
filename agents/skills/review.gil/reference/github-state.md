# GitHub state machine (`publish`)

`event: COMMENT` only; abort any payload with another event. Resolve/reply helpers owned by `pull-request` live in that skill's reference/gh-api.md.

Pending review state comes from `pr-context.sh --publish` `pending_reviews` (filtered to `gh api user --jq .login`; fails closed on truncation). GitHub allows **one** pending review per user per PR.

```text
No pending → POST /repos/{owner}/{repo}/pulls/{pr}/reviews {commit_id, body, comments[], event: "COMMENT"} → verify
Pending    → snapshot node id + drafts → deletePullRequestReviewComment (drop) → addPullRequestReviewThread (new)
             → POST .../reviews/{databaseId}/events {"event":"COMMENT","body":...} → verify pending queue empty
Replies    → addPullRequestReviewThreadReply, after main review succeeds
```

## Create + submit (no pending)

```bash
gh api repos/OWNER/REPO/pulls/PR/reviews --input review.json
# {"commit_id":"HEAD_SHA","event":"COMMENT","body":"## Review findings\n\n...",
#  "comments":[{"path":"app/x.rb","line":42,"side":"RIGHT","body":"issue (test): subject\n\n..."}]}
```

## Delete one draft comment (preferred over discarding the review)

```bash
gh api graphql -f query='mutation($id:ID!){deletePullRequestReviewComment(input:{id:$id}){clientMutationId}}' -F id=COMMENT_NODE_ID
```

## Append to pending review

Use the pending review GraphQL node `id`, not REST `databaseId`.

```bash
gh api graphql -f query='
mutation($reviewId:ID!, $path:String!, $line:Int!, $body:String!) {
  addPullRequestReviewThread(input:{pullRequestReviewId:$reviewId, path:$path, line:$line, side:RIGHT, body:$body}) {
    thread { id comments(first:1){ nodes { url body } } }
  }
}' -F reviewId=REVIEW_NODE_ID -F path='path/to/file.rb' -F line=123 -F body=$'issue: ...'
```

## Submit pending as COMMENT

```bash
gh api repos/OWNER/REPO/pulls/PR/reviews/REVIEW_DATABASE_ID/events --input - <<'EOF'
{ "event": "COMMENT", "body": "## Review findings\n\n..." }
EOF
```

## Reply on existing thread

```bash
gh api graphql -f query='
mutation($threadId:ID!, $body:String!) {
  addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$threadId, body:$body}) { comment { id url body } }
}' -F threadId=THREAD_ID -F body=$'issue (test): ...'
```

## Last resort: delete whole pending review

Only when per-comment reconcile is impossible; snapshot the preserved ledger, recreate, verify before submit.

```bash
gh api graphql -f query='mutation($id:ID!){deletePullRequestReview(input:{pullRequestReviewId:$id}){pullRequestReview{id state}}}' -F id=REVIEW_NODE_ID
```

## Recovery

- `422 User can only have one pending review per pull request` → append via `addPullRequestReviewThread`; never create a second.
- GraphQL "wrong review ID" → you passed REST numeric ID; use GraphQL `id`.
- Partial failure → re-fetch pending comments + threads, resume from actual state; never blindly replay.
- Head SHA changed between ledger and mutation → abort, refresh, re-anchor.

## Verify

```bash
gh api repos/OWNER/REPO/pulls/PR/reviews/REVIEW_ID/comments --jq '.[] | {path, line, html_url, body: .body[0:120]}'
```

Review `state` is `COMMENTED`; no PENDING review remains for the current user (unless draft-only); every discussion URL returned.
