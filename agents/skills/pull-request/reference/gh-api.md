# GitHub API patterns (comment / resolve / reply)

Prefer `scripts/gh-review-comments`; use these for fallback and mutations. End-to-end review publishing is owned by `review.gil` `publish` / `github-state.md`; this file covers posting verified findings, resolve, and reply.

Policy: post/submit → one review with `event: COMMENT`. Draft/pending → omit `event`. Never `APPROVE` / `REQUEST_CHANGES`.

## Identify PR

```bash
gh pr view --json number,url,headRefName,baseRefName,headRefOid,title
```

## Fetch threads

```bash
./scripts/gh-review-comments --filter unresolved --format json <pr-url>
```

GraphQL fallback (paginate with `after` while `pageInfo.hasNextPage`):

```bash
gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!){ repository(owner:$owner, name:$repo){ pullRequest(number:$number){ reviewThreads(first:100){ nodes { id isResolved path line comments(first:20){ nodes { id body url author { login } createdAt } } } } } } }' -F owner=OWNER -F repo=REPO -F number=PR
```

## Pending review / 422 recovery

One pending review per user per PR. Create / append / submit / draft-delete / 422 recovery: `review.gil/reference/github-state.md`.

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
