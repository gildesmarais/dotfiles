---
name: gh-review-resolve
description: Resolve GitHub pull request review comments end to end. Use when working on a branch with an open GitHub PR and the goal is to fetch unresolved review comments, assess which findings are valid, implement the valid ones, run the repo's normal quality gates, push grouped commits, and resolve clearly addressed review comments with precise commit-hash references. Trigger on requests to address PR comments, review unresolved comments, fix review feedback, or close out GitHub PR review threads.
---

# GH Review Resolve

Resolve GitHub PR review feedback without requiring the user to paste review-comment JSON manually. Own the full closeout loop after coding starts: discover the PR, fetch unresolved comments, assess validity, fix what is valid, run project gates, push, and resolve only the comments clearly addressed by the pushed commit(s).

## Execution Contract

- Required tools: `git`, `gh`, `jq`.
- Use non-interactive commands and explicit flags by default.
- Escalate permission for networked `gh` commands when sandboxing blocks them.
- Do not ask the user to manually fetch PR or review-comment data unless automated discovery fails.

## Support Files

- Use the bundled helper at `scripts/gh-review-comments`.
- Resolve that path relative to this skill directory, not the repo working directory.
- Run it from the skill directory or invoke it by an absolute path derived from the skill location.
- Prefer:
  `./scripts/gh-review-comments --filter unresolved --format json <pr-url>`
- Expect a top-level JSON object with `pr` metadata and `threads`.
- Expect each thread entry to include `thread_id`, `resolved`, `path`, `line`, `html_url`, and `comments`.
- If `gh pr view` already returned a PR URL or number, pass that explicit identifier into the helper instead of relying on helper-side rediscovery.
- If the helper cannot run, fall back to direct `gh` queries rather than asking the user to fetch review data manually.

## Canonical Sequence

1. `git branch --show-current`
2. `gh pr view --json url,number`
3. `./scripts/gh-review-comments --filter unresolved --format json <pr-url>`

## Workflow

1. Identify the current branch with `git branch --show-current`.
2. Find the matching PR yourself.
3. Use `gh pr view` first for the current branch. Fall back to `gh pr status` only if `gh pr view` does not identify the PR cleanly.
4. Only ask the user when there is no matching PR or multiple plausible PRs.
5. Fetch unresolved review comments yourself. If PR discovery already returned a URL or number, pass it into the helper explicitly.
6. Prefer the bundled helper with JSON output so comment text, paths, line numbers, resolution state, and URLs remain structured.
7. Use non-interactive commands and flags. Do not rely on prompts or browser flows inside the skill path unless the user explicitly asked for that.
8. Escalate permissions for `gh` or other networked commands when required instead of asking the user to paste data manually.
9. Classify comments into:
   - `valid/actionable`
   - `needs user decision`
   - `stale/not applicable`
   - `already addressed`
10. Frontload only the blocking questions:
   - product intent is unclear
   - multiple plausible interpretations would change the edit
   - the comment conflicts with current branch direction
   - a required fact is not discoverable locally
11. Implement the valid findings autonomously.
12. Group commits by concern when comments fall into distinct areas.
13. Rely on the local repo instructions for which quality gates to run. Do not redefine repo-specific checks in this skill.
14. Do not commit or push until the relevant repo-level gates have passed, or you have clearly reported why a gate could not run.
15. Push the branch after the grouped commit set is ready.
16. Resolve only the review comments you clearly addressed in the pushed commit(s).
17. Leave ambiguous or partially addressed comments open and summarize the remaining gap.
18. If PR discovery is confused by fork context or local repo remotes, switch to the explicit PR URL and continue.

## Resolution Rules

- Resolve comments only after the corresponding changes are pushed.
- Use precise resolution text with the commit hash.
- Prefer the repo's existing PR-comment tooling when available. Otherwise use `gh api` or GraphQL directly to resolve review threads.
- Prefer this template:
  `Addressed in <hash>: <precise change summary>.`
- If a comment is only partly addressed, leave it unresolved and explain why in your user-facing summary instead of force-resolving it.

## Assessment Standard

Be stricter on coherence than on literal compliance. A comment is valid when addressing it improves correctness, clarity, consistency, maintainability, or user experience within the current branch direction.

Do not apply comments mechanically when they:

- conflict with explicit user guidance
- are stale relative to current code or docs
- require product decisions the user has not made
- would degrade the coherence of the overall change

## Operating Style

- Prefer end-to-end ownership over partial analysis.
- Do not wait for pasted GitHub review JSON when the PR can be discovered and queried directly.
- Keep the workflow agent-compatible: deterministic commands, explicit flags, and local relative paths.
- Keep user updates concise and concrete.
- Explain which comments were addressed, which were left open, and why.
- Mention the pushed commit hash in the final closeout summary.
