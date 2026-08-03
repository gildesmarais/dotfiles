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

# Communication Skills Domain

## Language

**Communication** (skill noun: `communication`):
Drafting or distilling a written communication artifact for a specific audience and format.
_Avoid_: comms, messaging (too vague)

**One-on-one** (`communication` branch):
Summarize raw 1:1 notes into a compact, speaker-aware bullet list.
_Avoid_: notes, minutes (minutes implies a formal multi-participant meeting — different scope, not covered)

**Slack-message** (`communication` branch):
Refine rough notes into an internal Slack-ready message for a tech organization, including sensitive/escalation framing.
_Avoid_: message (collides with the skill-level artifact), announcement

**Project-update** (`communication` branch):
Distill project notes into a single comparable status line.
_Avoid_: status-report, update (too vague)

**External-message** (`communication` branch):
Draft a customer, partner, or public-facing message with no internal jargon, no unconfirmed commitments, legal-safe tone.
Marketing copy / public PR-press statements are out of scope (persuasive/brand-voice vs legal-safe support tone).
_Avoid_: customer-message, support-reply (too narrow — also covers partners and public)

**Handoff**:
`communication` hands off to `docs-editor` when the ask is actually a README, runbook, or product doc rather than a message. Never reverse.
