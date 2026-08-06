# SDLC Skills Domain

## Language

**Pull Request** (skill noun: `pull-request`):
A GitHub pull request lifecycle action on a remote PR or branch destined to become one.
_Avoid_: PR, gh-pr, open-pr

**Review** (skill noun: `review.gil`):
Local analysis of a change (working tree, branch, or commit range) that produces findings or merge-prep work. Never posts to GitHub.
_Avoid_: review (conflicting/common-tool name), code-review (external), gh-review, finish-review (old name)

**Branch** (skill-internal):
A distinct verb-path through a skill, selected from the user prompt. Not a git branch.
_Avoid_: sub-skill, mode, sub-path

**Comment** (`pull-request` branch):
Post verified findings as new GitHub review comments (usually pending).
_Avoid_: review.gil (collides with skill noun), critique, feedback

**Reply** (`pull-request` branch):
Respond on an existing review thread without introducing a new finding.
_Avoid_: comment (reserved for new findings), resolve

**Resolve** (`pull-request` branch):
Close out review feedback: assess threads, change code when valid, push, mark threads resolved with commit refs.
_Avoid_: address, closeout (synonyms — one trigger only)

**Open** / **Slice** (`pull-request` branches):
Open = commit session work + push + create PR. Slice = rebuild one messy branch into intent-based smaller PRs.
_Avoid_: pr-opener, pr-slicer, split-to-prs

**Finish** (`review.gil` branch):
Production-readiness **assessment** — findings report only; no boy-scout edits.
_Avoid_: quality (that branch changes code)

**Quality** (`review.gil` branch):
Merge-prep **execution** — audit → plan → boy-scout refactors + tests → repo gates (absorbs former `quality-loop`).
_Avoid_: finish (assessment-only), cleanup (too vague for the description)

**Lens** (`review.gil` branches `tests` / `perf` / `security`):
A specialized findings rubric applied to the same local diff prep as `finish`.
_Avoid_: dedicated skill per lens

**Handoff**:
`review.gil` may end with “post these findings” → agent continues into `pull-request` `comment`. Never reverse: GitHub posting does not live under `review.gil`.

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
Architecture-facing docs — ADRs, design notes, diagrams, system overviews. **Verify/rewrite only** (Solution-adjacent). Does not author net-new HLD/ADR; that author path is deferred.
_Avoid_: adr (too narrow), design (ambiguous with product design), authoring greenfield HLD from this branch

**Triage** (shared):
Four-way document classification (`accurate`, `partial`, `misleading`, `obsolete`) that sets effort before rewriting. Shared by both branches.
_Avoid_: per-branch classification vocabularies

**Evidence ladder** (branch-local):
The ordered source list a branch trusts. Deliberately different per branch: `editor` starts at code and tests, `architecture` starts at live runtime behavior.
_Avoid_: one flattened ordering for both branches

**Handoff**:
`docs` **`architecture`** may precede craft when a mental model needs verifying first (Solution-adjacent). When the user wants end-of-branch production readiness instead, use the generic `review.gil` workflow. HLD/ADR **author** remains deferred — do not invent an author branch here.

# Intent Skills Domain

## Language

**Prompt-synthesis** (skill noun: `prompt-synthesis`):
Transforms rough notes into a dense paste-ready agent brief. Grills material gaps before emit; never executes the underlying task.
_Avoid_: prompt-engineer, refine-prompt (triggers only — not skill nouns)

**Code** / **architecture** / **product** (`prompt-synthesis` branches):
Class rubrics that enrich Context / Constraints / Verify. Default path is Shared prep only when no class fits.
_Avoid_: general branch; Role/Context/Task/Deliverable templates

**Brief fields** (`prompt-synthesis` emit):
**Goal** · **Context** · **Success** · **Constraints** (omit if empty) · **Verify**. Success = done-when; Verify = proof steps.
_Avoid_: Role/persona, SynthesisLog, naming OS skills in the emitted brief

**Handoff**:
Stops at the paste-ready brief. Does not hand off into Build / Assure / Ship. Intent entrypoints that start from Jira still use `jira-ticket` (and `product-owner` **`gate`** when scope is non-trivial). Spec/PRD router is **deferred** — no first-party `spec` skill.

# Product Skills Domain

## Language

**Product-owner** (skill noun: `product-owner`):
Product domain router — admit/defer/reject scope and protect golden paths. Exactly one Product skill; grow branches here.
_Avoid_: product (no parallel skill), product-gate, po

**Gate** (`product-owner` branch, default):
Admission before non-trivial user-facing scope: Build Now / Build Later / Research Further / Reject.
_Avoid_: prioritize, story-slice, experiment (stub branches — not authored this pass; stay stubs)

**Decision vocabulary** (`gate`):
**Build Now** | **Build Later** | **Research Further** | **Reject** — plus Confidence and Forced Challenge. Cite repo product docs or mark `unknown`.
_Avoid_: ship-it, defer, maybe (use the four decisions only)

**Golden path** / **click budget** / **mental model**:
Product constraints cited from repo docs (`AGENTS.md`, `ROADMAP.md`, or equivalents) — never invented.
_Avoid_: inventing budgets or paths when docs are silent → Research Further

**Handoff**:
Before non-trivial product scope, Intent entrypoints (`jira-ticket`, feature asks) load `product-owner` **`gate`**. Continue impl only on **Build Now** → `architecture` and/or `{lang}-dev` / overlay. Never let `architecture` / `*-dev` / `review.gil` answer “should we build X?”. `grilling` is Decide-only stress-test (third-party install); product-owner keeps doctrine when the topic is scope.

# Dev Skills Domain

## Language

**Architecture** (skill noun: `architecture`):
Language-free Solution craft: structure, types, measured performance. Exactly one architecture router.
_Avoid_: deep-modules / refactor-types as top-level skills; docs `architecture` (that is documentation verify/rewrite)

**Deep-modules** / **refactor-types** / **performance** / **refactor-boundaries** (`architecture` branches):
Module depth & seams | type hygiene | measure→optimize | wire/adapter contracts.
_Avoid_: bare branch name `refactor`; language-named branches (`refactor-rust`)

**Structure-survey** (`architecture` survey mode):
Peer-directory discovery (canonical shape, snowflakes, promote/relocate/fold). Not a craft branch — findings multi-load craft branches.
_Avoid_: treating survey as a fifth craft branch; auto-loading on bare “promote” / “unify” or generic review

**`refactor-<concern>`**:
Only legal form for refactor branches under `architecture`. New concerns use the expansion law in `architecture/reference/growth.md` — never a top-level `refactor-*` skill.
_Avoid_: `refactor`, `refactor-misc`, `cleanup` as skill or branch names

**Language-runtime** / **`*-dev`**:
Thin language adapter (`ruby-dev`, `rust-dev`). Classify `surgical` | `design` | `review-hand-off`; on `design`, load `architecture`.
_Avoid_: inlining module/type/perf craft inside `*-dev`

**Overlay**:
Framework or domain delta composed with one `*-dev`. Published: `ruby-on-rails-dev` (+ `ruby-dev`); `swiftui-dev` (+ `swift-dev`).
_Avoid_: standalone mega-router that picks languages

**Design** (classification, not a skill):
`*-dev` class meaning structural/type/perf craft is earned — hand off to `architecture`.
_Avoid_: treating “design” as a skill noun

**Deepen**:
Signal that selects `architecture` **`deep-modules`** — not a skill name.
_Avoid_: deepen-modules skill

**Harvest**:
Protocol in `architecture/reference/growth.md` (Growing reference + Ingress). Stage in `architecture/reference/learning-log.md` → sparse-promote into matching `reference/<branch>.md` → drop noise (language-only harvest in optional `*-dev` `reference.md` unchanged in spirit).
_Avoid_: append-only forever doctrine in the log; growing frozen router checklists for every lesson; loading growth.md on every craft session

**Expansion law**:
Seven rules in `architecture/reference/growth.md` before adding a branch. Prefer sparse harvest over new branches; never invent a top-level craft skill when a `refactor-<concern>` branch fits.

**Install** (this store via [`npx skills`](https://github.com/vercel-labs/skills)):
Published skills: `npx skills add gildesmarais/dotfiles/agents/skills` (browse with `--list`). This machine with `rcm`: `rcup` → `~/.agents/skills/`. Details: `agents/skills/README.md` Install.

**Third-party packs**:
Optional agent installs (`grilling`, `swift-*`, vendor React packs). Not first-party kinds; not OS source of truth. Install with a separate `npx skills add` — see `agents/skills/README.md` Optional packs. Store depth packs (`ms-rust`, `rust-performance`) install with the rest of the store (`npx skills` / `rcup`).

**Conventional Commits** (format — single SoT):

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

- `fix:` PATCH · `feat:` MINOR · `BREAKING CHANGE:` / `!` → MAJOR
- Other types: `build:`, `chore:`, `ci:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`, …
- Footers: git-trailer style

**Phase commit** (when to commit — not at release):
After each Solution/Build plan phase (architecture phase, surgical milestone, or user-named plan step): validate → ≥1 Conventional Commit; body = rationale / intent / why. Dirty tree at PR open: `pull-request` **`open`** applies the same format once if needed. `release` **`notes`** consumes merged history only — never invents commits.
Carriers: `architecture` Shared prep (Solution) and every language-runtime `*-dev` Contracts section (Build). Overlays must not duplicate. Solution/Build implementation plans end each phase with validate → commit (cite this entry; do not fork the format).

**Handoff**:
`*-dev` `design` → `architecture` (branch pick inside). `architecture` / `*-dev` → `review.gil` / `pull-request` for assure/ship. No reverse: craft does not own Product gate. Changelog after merge → `release` **`notes`**.

# Ship Skills Domain

## Language

**Release** (skill noun: `release`):
Changelog / release notes derived from Conventional Commits in a merged ship range. Notes-only — no flag, promote, or rollback.
_Avoid_: release-ops, ship-notes (use `notes`), absorbing `pull-request` lifecycle

**Notes** (`release` branch):
Group Breaking → Features → Fixes → other from `git log` in the ship range. Consumer of history authored during Solution/Build phases.
_Avoid_: inventing commits; waiting until notes to write history

**Handoff**:
Compose with `pull-request` — never absorb PR open/slice/resolve. Phase CC authoring lives in `architecture` / `*-dev`; at PR open, `pull-request` **`open`** applies the format only if the tree is still dirty.

# Decide Skills Domain

## Language

**Grilling** (third-party skill noun: `grilling`):
Stress-test interview — one hard question at a time. Upstream Decide skill (not a first-party store router).
Install (from dotfiles root): `npx skills add https://github.com/mattpocock/skills --skill grilling -a cursor -a codex -y`
Sibling optional packs (`swift-*`): same `npx skills` pattern — see `agents/skills/README.md` Optional packs. Store depth packs (`ms-rust`, `rust-performance`): same paths as other store skills (`npx skills` / `rcup`).
_Avoid_: using grilling to answer “should we build X?” (that stays `product-owner` **`gate`**)

**Handoff**:
Decide-only. May stress Intent briefs, Product gate proposals, or Solution craft choices. Product doctrine and evidence rules stay with `product-owner` when the topic is scope.
