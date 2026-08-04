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
`communication` hands off to `docs` **`editor`** when the ask is actually a README, runbook, or product doc rather than a message. Never reverse.

# Docs Skills Domain

## Language

**Docs** (skill noun: `docs`):
Verifying and rewriting an existing document against the repository.
_Avoid_: documentation, writing (too vague), docs-editor / docs-architecture (old names)

**Editor** (`docs` branch):
Public-facing and operational docs — README, contributor, operator, feature docs, runbooks. Optimizes for reader action.
_Avoid_: readme (too narrow), writer (implies net-new docs)

**Architecture** (`docs` branch):
Architecture-facing docs — ADRs, design notes, diagrams, system overviews. Optimizes for safe decisions against verified runtime behavior.
_Avoid_: adr (too narrow), design (ambiguous with product design)

**Triage** (shared):
Four-way document classification (`accurate`, `partial`, `misleading`, `obsolete`) that sets effort before rewriting. Shared by both branches.
_Avoid_: per-branch classification vocabularies

**Evidence ladder** (branch-local):
The ordered source list a branch trusts. Deliberately different per branch: `editor` starts at code and tests, `architecture` starts at live runtime behavior.
_Avoid_: one flattened ordering for both branches

**Handoff**:
`docs` **`architecture`** may precede implementation work when a mental model needs verifying first. When the user wants end-of-branch production readiness instead, use the generic `review` workflow.

# Product Skills Domain

## Language

**Product-owner** (skill noun: `product-owner`):
Product domain router — admit/defer/reject scope and protect golden paths. Exactly one Product skill; grow branches here.
_Avoid_: product (no parallel skill), product-gate, po

**Gate** (`product-owner` branch, default):
Admission before non-trivial user-facing scope: Build Now / Build Later / Research Further / Reject.
_Avoid_: prioritize, story-slice, experiment (stub branches — not authored)

**Decision vocabulary** (`gate`):
**Build Now** | **Build Later** | **Research Further** | **Reject** — plus Confidence and Forced Challenge. Cite repo product docs or mark `unknown`.
_Avoid_: ship-it, defer, maybe (use the four decisions only)

**Golden path** / **click budget** / **mental model**:
Product constraints cited from repo docs (`AGENTS.md`, `ROADMAP.md`, or equivalents) — never invented.
_Avoid_: inventing budgets or paths when docs are silent → Research Further

**Handoff**:
Before non-trivial product scope, Intent entrypoints (`jira-ticket`, feature asks) load `product-owner` **`gate`**. Continue impl only on **Build Now** → `architecture` and/or `{lang}-dev` / overlay. Never let `architecture` / `*-dev` / `review` answer “should we build X?”. `grilling` is Decide-only stress-test; product-owner keeps doctrine when the topic is scope.

# Dev Skills Domain

## Language

**Architecture** (skill noun: `architecture`):
Language-free Solution craft: structure, types, measured performance. Exactly one architecture router.
_Avoid_: deep-modules / refactor-types as top-level skills; docs `architecture` (that is documentation verify/rewrite)

**Deep-modules** / **refactor-types** / **performance** / **refactor-boundaries** (`architecture` branches):
Module depth & seams | type hygiene | measure→optimize | wire/adapter contracts (`refactor-boundaries` is stub until earned).
_Avoid_: bare branch name `refactor`; language-named branches (`refactor-rust`)

**`refactor-<concern>`**:
Only legal form for refactor branches under `architecture`. New concerns use the expansion law in `architecture` Shared prep — never a top-level `refactor-*` skill.
_Avoid_: `refactor`, `refactor-misc`, `cleanup` as skill or branch names

**Language-runtime** / **`*-dev`**:
Thin language adapter (`ruby-dev`, `rust-dev`). Classify `surgical` | `design` | `review-hand-off`; on `design`, load `architecture`.
_Avoid_: inlining module/type/perf craft inside `*-dev`

**Overlay**:
Framework or domain delta composed with one `*-dev` (`ruby-on-rails-dev`, `mir-architect`).
_Avoid_: standalone mega-router that picks languages

**Design** (classification, not a skill):
`*-dev` class meaning structural/type/perf craft is earned — hand off to `architecture`.
_Avoid_: treating “design” as a skill noun

**Deepen**:
Signal that selects `architecture` **`deep-modules`** — not a skill name.
_Avoid_: deepen-modules skill

**Harvest**:
Append learning-log bullets tagged by branch under `architecture/reference/learning-log.md` (or language-only harvest in optional `*-dev` `reference.md`).
_Avoid_: growing frozen router checklists for every lesson

**Expansion law**:
Seven rules in `architecture` Shared prep before adding a branch. Prefer harvest over new branches; never invent a top-level craft skill when a `refactor-<concern>` branch fits.

**Third-party packs**:
Optional agent installs (`ms-rust`, `rust-performance`, vendor React packs). Not first-party kinds; never source of truth for the OS.

**Handoff**:
`*-dev` `design` → `architecture` (branch pick inside). `architecture` / `*-dev` → `review` / `pull-request` for assure/ship. No reverse: craft does not own Product gate.
