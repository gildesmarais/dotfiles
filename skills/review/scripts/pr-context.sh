#!/usr/bin/env bash
# Read-only PR snapshot for the review skill.
# Usage: pr-context.sh [--publish] <pr-url-or-number>
# Default output is context-cheap finish metadata. --publish adds complete
# current-user draft and unresolved-thread state.
set -euo pipefail

MODE="finish"
if [[ "${1:-}" == "--publish" ]]; then
  MODE="publish"
  shift
fi

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 [--publish] <pr-url-or-number>" >&2
  exit 2
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is required" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

INPUT="$1"
OWNER=""
REPO=""
NUMBER=""

if [[ "$INPUT" =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
  OWNER="${BASH_REMATCH[1]}"
  REPO="${BASH_REMATCH[2]}"
  NUMBER="${BASH_REMATCH[3]}"
elif [[ "$INPUT" =~ ^[0-9]+$ ]]; then
  NUMBER="$INPUT"
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Numeric PR requires a git repo with github remote, or pass a full PR URL." >&2
    exit 1
  fi
  remote_url=$(git remote get-url origin 2>/dev/null || true)
  if [[ "$remote_url" =~ github\.com[:/]([^/]+)/([^/.]+)(\.git)?$ ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
  else
    echo "Could not parse owner/repo from origin remote. Pass a full PR URL." >&2
    exit 1
  fi
else
  echo "Unrecognized PR reference: $INPUT" >&2
  exit 2
fi

pr_json=$(gh pr view "$NUMBER" --repo "${OWNER}/${REPO}" --json \
  number,url,title,body,baseRefName,headRefName,headRefOid,author,commits,files,statusCheckRollup,reviewDecision,state)

if [[ "$MODE" == "finish" ]]; then
  jq -n \
    --arg owner "$OWNER" \
    --arg repo "$REPO" \
    --argjson pr "$pr_json" \
    '{
      owner: $owner,
      repo: $repo,
      pr: {
        number: $pr["number"],
        url: $pr["url"],
        title: $pr["title"],
        body: $pr["body"],
        state: $pr["state"],
        baseRefName: $pr["baseRefName"],
        headRefName: $pr["headRefName"],
        headRefOid: $pr["headRefOid"],
        author: $pr["author"]["login"],
        reviewDecision: $pr["reviewDecision"],
        commits: [($pr["commits"] // [])[]? | .["oid"]],
        files: [($pr["files"] // [])[]? | {path: .["path"], additions: .["additions"], deletions: .["deletions"]}],
        checks: [
          ($pr["statusCheckRollup"] // [])[]?
          | {name: (.["name"] // .["context"] // "unknown"), state: (.["state"] // .["conclusion"] // "unknown")}
        ]
      }
    }'
  exit 0
fi

me=$(gh api user --jq .login)

# shellcheck disable=SC2016 # GraphQL variables must remain literal.
graphql=$(gh api graphql -f query='
query($owner:String!, $repo:String!, $number:Int!) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$number) {
      id
      headRefOid
      reviews(first:100, states:[PENDING]) {
        pageInfo { hasNextPage }
        nodes {
          id
          databaseId
          author { login }
          body
          comments(first:100) {
            pageInfo { hasNextPage }
            nodes { id databaseId path line originalLine body }
          }
        }
      }
      reviewThreads(first:100) {
        pageInfo { hasNextPage }
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          comments(first:100) {
            pageInfo { hasNextPage }
            nodes { author { login } body url }
          }
        }
      }
    }
  }
}' -F owner="$OWNER" -F repo="$REPO" -F number="$NUMBER")

if ! jq -e '
  .data.repository.pullRequest as $pr
  | ($pr.reviews.pageInfo.hasNextPage == false)
    and ($pr.reviewThreads.pageInfo.hasNextPage == false)
    and all($pr.reviews.nodes[]?; .comments.pageInfo.hasNextPage == false)
    and all($pr.reviewThreads.nodes[]?; .comments.pageInfo.hasNextPage == false)
' >/dev/null <<<"$graphql"; then
  echo "PR review state exceeds one GraphQL page; refusing an incomplete snapshot." >&2
  exit 1
fi

pr_head=$(jq -r '.headRefOid' <<<"$pr_json")
state_head=$(jq -r '.data.repository.pullRequest.headRefOid' <<<"$graphql")
if [[ "$pr_head" != "$state_head" ]]; then
  echo "PR head changed while capturing review state; retry for a coherent snapshot." >&2
  exit 1
fi

jq -n \
  --arg owner "$OWNER" \
  --arg repo "$REPO" \
  --arg me "$me" \
  --argjson pr "$pr_json" \
  --argjson gql "$graphql" \
  '
  ($gql.data.repository.pullRequest) as $p
  | {
      owner: $owner,
      repo: $repo,
      me: $me,
      pr: {
        number: $pr["number"],
        url: $pr["url"],
        title: $pr["title"],
        body: $pr["body"],
        state: $pr["state"],
        baseRefName: $pr["baseRefName"],
        headRefName: $pr["headRefName"],
        headRefOid: $pr["headRefOid"],
        author: $pr["author"]["login"],
        reviewDecision: $pr["reviewDecision"],
        commits: [($pr["commits"] // [])[]? | .["oid"]],
        files: [($pr["files"] // [])[]? | {path: .["path"], additions: .["additions"], deletions: .["deletions"]}],
        checks: [
          ($pr["statusCheckRollup"] // [])[]?
          | {name: (.["name"] // .["context"] // "unknown"), state: (.["state"] // .["conclusion"] // "unknown")}
        ]
      },
      pending_reviews: [
        ($p["reviews"]["nodes"] // [])[]?
        | select(.["author"]["login"] == $me)
        | {
            id: .["id"],
            databaseId: .["databaseId"],
            body: .["body"],
            comments: [
              (.["comments"]["nodes"] // [])[]?
              | {id: .["id"], databaseId: .["databaseId"], path: .["path"], line: .["line"], originalLine: .["originalLine"], body: .["body"]}
            ]
          }
      ],
      unresolved_threads: [
        ($p["reviewThreads"]["nodes"] // [])[]?
        | select(.["isResolved"] == false)
        | {
            id: .["id"],
            path: .["path"],
            line: .["line"],
            isOutdated: .["isOutdated"],
            comments: [
              (.["comments"]["nodes"] // [])[]?
              | {author: .["author"]["login"], body: .["body"], url: .["url"]}
            ]
          }
      ]
    }
  '
