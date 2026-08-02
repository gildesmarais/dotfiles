---
name: review
description: Review a local change or branch. Use when the user wants a finish readiness review, a tests/specs review, a Ruby performance review, a security/compliance review, or a quality boy-scout merge-prep pass. When another skill needs a production-readiness or test-quality pass, use this skill.
---

# Review

Local analysis of a change (working tree, branch, or commit range). Produces findings or merge-prep work. Never posts to GitHub.

## Pick branch

Map the user prompt to exactly one branch:

| Branch     | Use when                                                      |
| ---------- | ------------------------------------------------------------- |
| `finish`   | Production-readiness assessment — findings only               |
| `tests`    | Specs/tests quality review                                    |
| `perf`     | Ruby performance review                                       |
| `security` | Security/compliance review                                    |
| `quality`  | Merge-prep execution — audit, boy-scout refactors, repo gates |

When another skill needs a production-readiness or test-quality pass, use this skill with the matching branch.

## Shared prep

Every branch except **`quality`** (Phase 0 supersedes):

1. Identify repo root, target branch, and default branch.
2. Read `AGENTS.md` if present and follow repo-specific rules.
3. Run the skill-local diff script (path relative to this skill directory):
   - `scripts/compare_default_branch.sh`
   - If unavailable, run directly in the repo:
     - `git rev-list --left-right --count origin/$(git remote show origin | awk '/HEAD branch/ {print $NF; exit}')...HEAD`
     - `git --no-pager diff --stat origin/$(git remote show origin | awk '/HEAD branch/ {print $NF; exit}')...HEAD`
     - `git --no-pager diff --name-status origin/$(git remote show origin | awk '/HEAD branch/ {print $NF; exit}')...HEAD`
4. Summarize commits ahead/behind, diffstat, changed files, and high-risk areas to inspect first.

## Branch reference

Load exactly one disclosed reference file and follow it through completion:

- **`finish`** → [`reference/finish.md`](reference/finish.md)
- **`tests`** → [`reference/tests.md`](reference/tests.md)
- **`perf`** → [`reference/perf.md`](reference/perf.md)
- **`security`** → [`reference/security.md`](reference/security.md)
- **`quality`** → [`reference/quality.md`](reference/quality.md)

## Handoff

When findings branches (`finish`, `tests`, `perf`, `security`) complete and the user wants findings posted on GitHub, continue with the `pull-request` skill **`comment`** branch. Do not post review comments from this skill.

## Completion criteria

| Branch                        | Done when                                                                                                                      |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `finish`                      | Critical empty or owned; Important owned/rationale; executive Yes/No/Conditional vs default branch                             |
| `tests` / `perf` / `security` | Every lens rule applied to the scoped diff; findings severity-ordered; no GitHub posts                                         |
| `quality`                     | Audit table produced; commit stack executed (or explicit empty); gate recipe green; P0/P1 either fixed or listed for re-invoke |
