# GitHub API patterns (comment / resolve / reply)

Prefer `scripts/gh-review-comments`; use these for fallback and mutations. End-to-end review publishing is owned by `review.gil` `publish` and its `review.gil/reference/github-state.md`; this file only covers posting verified findings, resolve, and reply.

Policy: post/submit → one review with `event: COMMENT`. Draft/pending → omit `event`. Never `APPROVE` / `REQUEST_CHANGES`.

## Identify PR

```bash
gh pr view --json number,url,headRefName,baseRefName,headRefOid,title
```

## Fetch threads

```bash
./scripts/gh-review-comments --filter unresolved --format json <pr-url>
# → {pr:{owner,repo,number,url}, threads:[{thread_id,resolved,path,line,html_url,comments:[{user:{login},created_at,body,html_url}]}]}
```

GraphQL fallback (paginate with `after` while `pageInfo.hasNextPage`):

```bash
gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner, name:$repo){ pullRequest(number:$number){ reviewThreads(first:100){ nodes { id isResolved path line comments(first:20){ nodes { id body url author { login } createdAt } } } } } } }' -F owner=OWNER -F repo=REPO -F number=PR
```

## Pending review state machine

One pending review per user per PR.

1. No pending review → `POST repos/OWNER/REPO/pulls/PR/reviews` with inline `comments`, **no `event`** (`"event": "COMMENT"` submits immediately).
2. Pending exists → `addPullRequestReviewThread` with the pending review **node ID** (GraphQL `id`, not REST numeric id). Never create a second.
3. Submit only on explicit ask → `POST .../reviews/{id}/events` with `event: COMMENT`.

```bash
# fetch pending
gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner, name:$repo){ pullRequest(number:$number){ id reviews(first:50, states:[PENDING]){ nodes { id databaseId state body } } } } }' -F owner=OWNER -F repo=REPO -F number=PR

# create pending: review.json = {"body":"…","comments":[{"path":"…","line":123,"side":"RIGHT","body":"issue: …"}]}
gh api repos/OWNER/REPO/pulls/PR/reviews --input review.json

# append to pending
gh api graphql -f query='mutation($reviewId:ID!, $path:String!, $line:Int!, $body:String!){ addPullRequestReviewThread(input:{pullRequestReviewId:$reviewId, path:$path, line:$line, side:RIGHT, body:$body}) { thread { id comments(first:1){ nodes { url body } } } } }' -F reviewId=REVIEW_NODE_ID -F path='path/to/file.rb' -F line=123 -F body=$'issue: ...'
```

## Reply (match by thread id, not path/line)

```bash
post_reply() {
  gh api graphql -f query='mutation($threadId:ID!, $body:String!){ addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$threadId, body:$body}) { comment { id url } } }' -F threadId="$1" -F body="$2"
}
post_reply THREAD_ID $'Addressed in abc1234: ...'
```

## Resolve (only after push)

Reply `Addressed in <hash>: <precise change summary>.` before or with:

```bash
gh api graphql -f query='mutation($threadId:ID!){ resolveReviewThread(input:{threadId:$threadId}) { thread { isResolved } } }' -F threadId=THREAD_ID
```

## Verify

- `gh pr view --comments` often shows only the review header. Inline comments: `gh api repos/<owner>/<repo>/pulls/<pr>/reviews/<review_id>/comments`. Replies: returned `url` or thread query. Resolution: re-run the helper with `--filter unresolved`.
- Never report success without the returned review/comment ID, URL, or refreshed thread state. On sandbox network failure, retry escalated, then verify.

## 422 recovery

| Error                                                            | Recovery                                                                  |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `User can only have one pending review per pull request`         | Fetch pending node ID → `addPullRequestReviewThread`                      |
| Pending-review conflict on `POST .../pulls/{pr}/comments`        | Draft was asked: don't fall back to standalone inline or regular comments |
| GraphQL mutation rejects review id                               | Used REST numeric id — use GraphQL `id`                                   |
