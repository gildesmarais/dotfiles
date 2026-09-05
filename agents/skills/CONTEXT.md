# SDLC Skills Domain

## Language

**Pull Request** (skill noun: `pull-request`):
A GitHub pull request lifecycle action on a remote PR or branch destined to become one.
Not: PR, gh-pr, open-pr

**Review** (skill noun: `review.gil`):
Local analysis of a change (working tree, branch, or commit range) that produces findings or merge-prep work. Executions: `findings` (no GitHub) | `publish` (e2e → GitHub `COMMENT`) | `quality` (merge-prep code changes). Verified-ledger posting stays on `pull-request` **`comment`**.
Not: review (common-tool name), code-review (external), gh-review, finish-review

**Branch** (skill-internal):
A distinct verb-path through a skill, selected from the user prompt. Not a git branch.
Not: sub-skill, mode, sub-path

**Comment** (`pull-request` branch):
Post verified findings as new GitHub review comments (usually pending).
Not: review.gil (skill noun), critique, feedback

**Reply** (`pull-request` branch):
Respond on an existing review thread without introducing a new finding.
Not: comment (reserved), resolve

**Resolve** (`pull-request` branch):
Close out review feedback: assess threads, change code when valid, push, mark threads resolved with commit refs.
Not: address, closeout

**Open** / **Slice** (`pull-request` branches):
Open = commit session work + push + create PR. Slice = rebuild one messy branch into intent-based smaller PRs.
Not: pr-opener, pr-slicer, split-to-prs

**Fix-ci** (`pull-request` branch):
Repair failing GitHub Actions on a PR — failing-job logs only, classify, fix+push, watch once.
Not: explaining CI without a fix ask (report-only); whole-run log dumps

**Conflicts** (`pull-request` branch):
Rebase/merge a PR branch onto its base; preserve intents; push (lease when rebase).
Not: starting fix-ci or resolve from this branch

**Unblock chain** (`pull-request` routing rule, not a branch):
conflicts → resolve → fix-ci in order; refresh live PR state each pass; never approve/merge.
Not: a dedicated unblock-pr skill; autopilot that merges

**Dependabot** (skill noun: `dependabot`):
Store-owned Dependabot configure + PR triage. Branches: `configure` | `triage`.
Not: third-party mega-guide; hand-editing when the repo already generates manifests from ownership config

**Configure** / **Triage** (`dependabot` branches):
Configure = draft/optimize `dependabot.yml`. Triage = risk skim + fallout via `pull-request` fix-ci/conflicts; report approve-readiness; stop before approve/merge.
Not: rewriting Dependabot commits; auto-merge from triage

**PR Sweep** (skill noun: `pr-sweep`):
Read-only multi-repo attention ledger (Intent). Branch: `report`. Compact rows: repo, PR, blocker, store invocation.
Not: fixing, commenting, or inlining diffs/logs; a `pull-request` branch

**Sweep ledger**:
One-row-per-item output from `pr-sweep`; invocations only — no diffs or CI excerpts.
Not: a todo list the sweep itself executes

**Findings** (`review.gil` execution):
Read-only production-readiness report — no boy-scout edits, no GitHub writes. Baseline lens: [`review.gil/reference/finish.md`](review.gil/reference/finish.md).
Not: finish (old execution name), quality (changes code)

**Publish** (`review.gil` execution):
End-to-end PR review → reconcile drafts → submit GitHub `COMMENT` (or leave PENDING when draft-only). Owns Assure's GitHub path.
Not: pull-request `comment` (posts an already-verified ledger)

**Quality** (`review.gil` execution):
Merge-prep **execution** — audit → plan → boy-scout refactors + tests → repo gates.
Not: findings (assessment-only), cleanup (too vague)

**Lens** (`review.gil` under `findings` / `quality`: `tests` / `perf` / `security` / `legacy`):
A specialized findings rubric applied to the same local diff prep as `findings`.
Not: dedicated skill per lens; treating `finish` as an execution

**Legacy** (`review.gil` lens, always under `quality`):
Dead compat — dual public names, superseded store/wire hydrate, deprecated markers. Findings report it; `quality` deletes it and invents no shims.
Not: cleanup, tech-debt, dedicated legacy skill, `refactor-legacy` under `architecture`

**Handoff**:
`publish` → `review.gil`; verified-ledger posting → `pull-request` **`comment`** — never reverse. Structural findings may **name** an `architecture` craft branch as remediation — naming is not running. Land ask + readiness Yes/Conditional → `pull-request` **`open`**. Unblock → conflicts → resolve → fix-ci. `pr-sweep` → ledger only → `pull-request` / `dependabot` / `review.gil`. Dependabot CI fallout → `pull-request` **`fix-ci`**.

# Communication Skills Domain

## Language

**Communication** (skill noun: `communication`):
Drafting or distilling a written communication artifact for a specific audience and format.
Not: comms, messaging

**One-on-one** (`communication` branch):
Summarize raw 1:1 notes into a compact, speaker-aware bullet list.
Not: notes, minutes

**Slack-message** (`communication` branch):
Refine rough notes into an internal Slack-ready message for a tech organization, including sensitive/escalation framing.
Not: message (skill artifact), announcement

**Project-update** (`communication` branch):
Distill project notes into a single comparable status line.
Not: status-report, update

**External-message** (`communication` branch):
Draft a customer, partner, or public-facing message with no internal jargon, no unconfirmed commitments, legal-safe tone. Marketing/PR-press out of scope.
Not: customer-message, support-reply

**Handoff**:
`communication` → `docs` **`editor`** when the artifact is a README/runbook, not a message. Never reverse.

# Docs Skills Domain

## Language

**Docs** (skill noun: `docs`):
Verifying and rewriting an existing document against the repository.
Not: documentation, writing, docs-editor, docs-architecture

**Editor** (`docs` branch):
Public-facing and operational docs — README, contributor, operator, feature docs, runbooks.
Not: readme, writer

**Architecture** (`docs` branch):
Architecture-facing docs — ADRs, design notes, diagrams, system overviews. **Verify/rewrite only**; no net-new HLD/ADR author path.
Not: adr, design (product), authoring greenfield HLD

**Doc-class** (shared):
Four-way classification (`accurate`, `partial`, `misleading`, `obsolete`) before rewriting. Shared by both branches.
Not: triage (Intent noun); per-branch classification vocabularies

**Evidence ladder** (branch-local):
Ordered source list each branch trusts. `editor` starts at code/tests; `architecture` starts at live runtime.
Not: one flattened ordering for both branches

**Handoff**:
`docs` **`architecture`** may precede craft when a mental model needs verifying. End-of-branch readiness → `review.gil`. HLD/ADR author deferred.

# Intent Skills Domain

## Language

**Triage** (skill noun: `triage`):
Intent intake — incident/ops evidence → Triage Ledger → `product-owner` **`gate`** and/or `$dev` **`plan`**. Branch: **`intake`**; playbooks under `reference/`. Does not implement or answer "should we build X?".
Not: Doc-class; implementing; conflating with `jira-ticket` / `prompt-compiler`

**Intake** (`triage` branch):
Default verb-path: evidence checklist, route table, required Triage Ledger, one-way handoff.
Not: peer branches duplicating handoff

**Prompt-compiler** (skill noun: `prompt-compiler`):
Compiles raw intent into persisted IR (invariants + atomic task DAG), then dispatches workers through `$dev` `implement` with orchestrator gates.
Not: mutating app code outside `$dev` workers

**Compile** / **run** (`prompt-compiler` branches):
`compile` writes `.agents/compile/<slug>.yaml` and stops. `run` resumes IR `status`, dispatches next `pending` task via `$dev`.
Not: auto-dispatch without IR approval; parallel worktree dispatch

**IR fields** (`prompt-compiler` emit):
`version` · `invariants` · `circuit_breaker` · `tasks[]` (`id`, `name`, `target_files`, `read_context`, `verification_gate`, `max_retries`, `depends_on`, `status`). Equivalent syntax of `$dev` `plan` — not a competing format.
Not: five-field briefs; inventing gates; dual plan formats

**Lifecycle**:
Ingest → grill gaps → `compile` → user approves → `run` via `$dev` → gates → full DAG → `review.gil` **`findings`**. On repeated failure: reset to last green task commit and halt.
Not: blind `git reset --hard`; trusting worker green claims; skipping Assure after green DAG

**Handoff**:
`triage` → `product-owner` **`gate`** and/or `$dev` **`plan`**. `compile` stops at IR file. `run` → `$dev` only. Jira entry → `jira-ticket`. Incident without Jira/IR → `triage` first. Spec/PRD router deferred. Morning PR attention → `pr-sweep` **`report`** (not `triage`).

**Orchestrator** (skill noun: `orchestrator`):
Sequential delivery of admitted tranches from repo roadmap docs.
Discovers tranches, spawns `$dev` workers, gates on validation, updates roadmap.
Roadmap is the state — no separate tracking file.
Not: prompt-compiler (single-prompt IR); jira-ticket (ticket entry); triage (incident intake)

**Run** (`orchestrator` branch):
Default and only branch. Discover → dispatch → gate → update → advance.

**Handoff**:
`run` → `$dev` `implement` per tranche. Full completion → `review.gil` **`findings`**.
Land → `pull-request` **`open`**. Circuit break → halt.

# Product Skills Domain

## Language

**Product-owner** (skill noun: `product-owner`):
Product domain router — admit/defer/reject scope and protect golden paths. Exactly one Product skill.
Not: product (parallel skill), product-gate, po

**Gate** (`product-owner` branch, default):
Admission before non-trivial user-facing scope: Build Now / Build Later / Research Further / Reject.
Not: prioritize, experiment (stubs)

**Story-slice** (`product-owner` branch):
Admitted (`Build Now` / founder override) scope → Given/When/Then stories with cited interaction budgets before `$dev` `plan`.
Not: slicing Rejected or uncited scope; inventing SLAs when docs are silent

**Decision vocabulary** (`gate`):
**Build Now** | **Build Later** | **Research Further** | **Reject** — plus Confidence and Forced Challenge. Cite repo product docs or `unknown`.
Not: ship-it, defer, maybe

**Golden path** / **click budget** / **mental model**:
Product constraints from repo docs (`AGENTS.md`, `ROADMAP.md`, equivalents) — never invented.
Not: inventing budgets when docs are silent

**Handoff**:
Intent entrypoints load `product-owner` **`gate`** before non-trivial scope. **Build Now** → `story-slice` when stories/UX AC are needed, else `$dev` only. Never let `architecture` / `dev` / `*-dev` / `review.gil` answer "should we build X?". `grilling` is Decide-only stress-test.

# Dev Skills Domain

## Language

**Dev** (skill noun: `dev`):
Build domain router — implementation plans and code changes. Branches `plan` | `implement`. Owns classify, route, validation, phase commits, API truth, observability/security cues, post-delivery Assure.
Not: treating `{lang}-dev` as Build entry; inlining architecture craft

**Plan** (`dev` branch):
Implementation-plan carrier. Procedural SoT: `dev/reference/plan-pipeline.md`.
Not: separate Solution plan skill; skipping classify/route

**API truth** / **warn-once fallthrough**:
Do not invent material APIs. Ladder: repo docs → Dash → Context7 → pack secondary → unknown. Warn once on first material fallthrough in session.
Not: warn-at-load; inventing APIs; assuming Dash tool names

**Observability cue**:
APM / traces / error tracking / logging links → matching observability MCP when available.
Not: vendor SoT under Build; inventing observability skill

**Security cue**:
Authn/authz, tenancy, PII/PHI, secrets, exports, webhooks, raw SQL, privileged ops → `review.gil` **`security`** on Assure.
Not: duplicating overlay security matrices in `$dev`

**Post-delivery Assure**:
Before delivery report on `$dev` `implement`: `review.gil` **`findings`** (procedure in `$dev` Handoff). Orchestrated workers skip per-task Assure.
Not: implementer self-check as sole review; silent Assure skip

**Architecture** (skill noun: `architecture`):
Language-free Solution craft: structure, types, measured performance.
Not: craft branches as top-level skills; docs `architecture`

**Deep-modules** / **refactor-types** / **performance** / **refactor-boundaries** (`architecture` branches):
Module depth & seams | type hygiene | measure→optimize | wire/adapter contracts.
Not: bare `refactor`; language-named branches

**Structure-survey** (`architecture` survey mode):
Peer-directory discovery. Not a craft branch — findings multi-load craft branches.
Not: treating survey as fifth craft branch; auto-loading on generic review

**`refactor-<concern>`**:
Only legal refactor branch form under `architecture`. Expansion law: `architecture/reference/growth.md`.
Not: `refactor`, `refactor-misc`, `cleanup` as skill names

**Language-runtime** / **`*-dev`**:
Adapters loaded by `dev` (`ruby-dev`, `rust-dev`, `swift-dev`, `typescript-dev`). Deltas only.
Not: competing Build entry; inlining craft in `*-dev`

**Overlay**:
Framework delta composed via `$dev` with one `*-dev`. Published: `ruby-on-rails-dev`, `swiftui-dev`.
Not: standalone mega-router; duplicating phase-commit law

**Design** (classification, not a skill):
Structural/type/perf craft earned → hand off to `architecture`. Axioms ride along on every implement.
Not: "design" as skill noun; defaulting to surgical to save a load

**Delivery Ledger** (shared handoff shape):
Markdown DTO passed across handoffs (`$dev` implement → `review.gil`, and `review.gil` → `pull-request` / `harvest`). Standardized fields:
- `Classification / Branches`: `surgical` | `design` and active branches
- `Target Files`: List of changed files
- `Verification`: Command executed + exit 0 observed
- `Phase Commits`: Hashes & rationale (or explicit deferral on default branch)
- `Active Lenses`: Triggered review lenses (`security`, `tests`, `perf`, `legacy`)
- `Readiness`: `Yes` | `No` | `Conditional`
- `Residuals / Debt`: Deferred items, architectural debt, or N/A
Not: inventing a second handoff schema per skill; conversational prose handoffs without bounded fields

**Deepen**:
Signal for `architecture` **`deep-modules`** — not a skill name.

**Harvest**:
Feedback loop via `harvest` skill (`distill` for preventive mantras, `debt` for `.agents/debt-ledger.md`). Sparse-promote into reference checklists/anti-patterns; drop weak candidates. After store edits: `skill doctor`; drift → `skill backfill` → `rcup`.
Not: harvest on every implement; append-only forever logs

**Expansion law**:
Seven rules in `architecture/reference/growth.md` before adding a branch. New langs/overlays = router contract edit on `dev/SKILL.md` + README/CONTEXT index.

**Phase commit**:
After each plan phase: validate → ≥1 [Conventional Commit](https://www.conventionalcommits.org/) with rationale body — default off default branch; ask early on default branch. Carriers: `architecture` Shared prep and `$dev` Shared prep. `release` **`notes`** consumes merged history only. Procedure: `$dev` Handoff.

**Handoff** (shape only — procedure in `$dev` / `architecture` SKILL.md):
`dev` → `{lang}-dev` / overlay; `design` → `architecture` → continue `$dev`; Assure → `review.gil`; land → `pull-request` **`open`**; changelog → `release` **`notes`**; friction/learnings → `harvest`. No reverse: craft does not own Product gate.

# Ship Skills Domain

## Language

**Release** (skill noun: `release`):
Changelog / release notes from Conventional Commits in a merged ship range. Notes-only.
Not: release-ops, ship-notes, absorbing `pull-request` lifecycle

**Notes** (`release` branch):
Group Breaking → Features → Fixes → other from `git log` in ship range.
Not: inventing commits; waiting until notes to write history

**Handoff**:
Compose with `pull-request` — never absorb PR lifecycle. Phase CC authoring lives on `architecture` / `dev`; dirty tree at PR open → `pull-request` **`open`**.

# Decide Skills Domain

## Language

**Grilling** (third-party skill noun: `grilling`):
Stress-test interview — one hard question at a time. Not a first-party store router.
Not: using grilling for "should we build X?" (→ `product-owner` **`gate`**)

**Handoff**:
Decide-only. May stress Intent briefs, Product gate proposals, or Solution craft choices. Product doctrine stays with `product-owner` when topic is scope.

# Harvest Skills Domain

## Language

**Harvest** (skill noun: `harvest`):
Continuous learning and debt capture router. Turn session friction, user corrections, and review findings into durable system wisdom without polluting skills with raw noise. Branches: `distill` | `debt`.
Not: raw incident dumps; append-only forever logs

**Distill** (`harvest` branch, default):
Extract imperative preventive mantras (checklist items and anti-patterns) from session corrections, test loops, and review findings. Deduplicate and sparse-promote to project-local rules or global skill references.
Not: raw transcripts; incident postmortems; vague platitudes

**Debt** (`harvest` branch):
Log architectural friction, structural rot, leaky module seams, or performance traps to `<project>/.agents/debt-ledger.md`.
Not: burying debt in ephemeral chat; unbounded boy-scout refactors mid-feature

**Debt Ledger** (`.agents/debt-ledger.md`):
Project-level backlog of identified architectural friction and structural debt. Consumed by `product-owner` under the Health Capacity Budget and executed by `orchestrator` / `$dev`.
Not: Jira replacement; untracked todo comments

**Health Budget**:
`product-owner` capacity rule allocating ~20% capacity (or 1 debt tranche per 3–4 feature tranches) to admit high-friction items from `.agents/debt-ledger.md`.
Not: uncontrolled gold-plating; ignoring debt until velocity halts

**Preventive Mantra**:
One imperative sentence an expert recalls before repeating a mistake. Format: checklist item ("When X, always Y to prevent Z") or anti-pattern ("Avoid X; use Y instead because Z").
Not: conversational notes; multi-paragraph postmortems

**Handoff**:
`review.gil` / `pull-request` → `harvest` on non-obvious fixes, review findings, or deferred debt. `harvest debt` → `.agents/debt-ledger.md` → `product-owner` (Health Budget) → `orchestrator` / `$dev`. After global store edits: `skill doctor` → `rcup`.

# Install

Published store: `npx skills add gildesmarais/dotfiles/agents/skills` (browse `--list`). This machine (`rcm`): `rcup` → `~/.agents/skills/`. Optional third-party packs (`grilling`, `docs-sync`, `swift-*`, vendor React): separate `npx skills add` — see [`README.md`](README.md) Optional packs.
