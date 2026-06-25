# GitHub API patterns for PR review resolution

Reference for `gh-pr` thread fetch, reply, resolve, and verification. Prefer the bundled `scripts/gh-review-comments` helper for structured thread data; use these patterns when the helper cannot run or for mutations the helper does not cover.

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

## Verify replies and resolution

- `gh pr view --comments` often shows only the review header, not all inline bodies.
- Verify inline comments with `gh api repos/<owner>/<repo>/pulls/<pr>/reviews/<review_id>/comments`.
- Verify thread replies with GraphQL review-thread queries or the returned `html_url`.
- Re-fetch unresolved threads to confirm resolution state:

```bash
./scripts/gh-review-comments --filter unresolved --format json <pr-url>
```

Do not assume a mutation succeeded without checking the returned comment ID, discussion URL, or refreshed thread state.

## Network and permissions

- If a GitHub API call fails because of network restrictions, retry with escalated permissions.
- Do not assume the comment failed or succeeded without checking the returned review ID, comment IDs, or discussion URLs.
