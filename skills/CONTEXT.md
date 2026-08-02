# SDLC Skills Domain

## Language

**Pull Request** (skill noun: `pull-request`):
A GitHub pull request lifecycle action on a remote PR or branch destined to become one.
_Avoid_: PR, gh-pr, open-pr

**Review** (skill noun: `review`):
Local analysis of a change (working tree, branch, or commit range) that produces findings or merge-prep work. Never posts to GitHub.
_Avoid_: code-review (external), gh-review, finish-review (old name)

**Branch** (skill-internal):
A distinct verb-path through a skill, selected from the user prompt. Not a git branch.
_Avoid_: sub-skill, mode, sub-path

**Comment** (`pull-request` branch):
Post verified findings as new GitHub review comments (usually pending).
_Avoid_: review (collides with skill noun), critique, feedback

**Reply** (`pull-request` branch):
Respond on an existing review thread without introducing a new finding.
_Avoid_: comment (reserved for new findings), resolve

**Resolve** (`pull-request` branch):
Close out review feedback: assess threads, change code when valid, push, mark threads resolved with commit refs.
_Avoid_: address, closeout (synonyms — one trigger only)

**Open** / **Slice** (`pull-request` branches):
Open = commit session work + push + create PR. Slice = rebuild one messy branch into intent-based smaller PRs.
_Avoid_: pr-opener, pr-slicer, split-to-prs

**Finish** (`review` branch):
Production-readiness **assessment** — findings report only; no boy-scout edits.
_Avoid_: quality (that branch changes code)

**Quality** (`review` branch):
Merge-prep **execution** — audit → plan → boy-scout refactors + tests → repo gates (absorbs former `quality-loop`).
_Avoid_: finish (assessment-only), cleanup (too vague for the description)

**Lens** (`review` branches `tests` / `perf` / `security`):
A specialized findings rubric applied to the same local diff prep as `finish`.
_Avoid_: dedicated skill per lens

**Handoff**:
`review` may end with “post these findings” → agent continues into `pull-request` `comment`. Never reverse: GitHub posting does not live under `review`.
