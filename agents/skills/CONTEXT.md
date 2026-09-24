# Skills Store Vocabulary

Glossary SoT. Handoff procedures live in each skill's `## Handoff`.

**Branch** (skill-internal): a verb-path through a skill, selected from the prompt. Not a git branch.

## Ship / Assure

**Pull Request** (`pull-request`): lifecycle action on a remote PR or branch destined to become one.

**Review** (`review.gil`): local analysis of a working tree, branch, or commit range. Executions: `findings` | `publish` | `quality`.

**Findings** (`review.gil`): read-only production-readiness report — no edits, no GitHub writes. Baseline: [`review.gil/reference/finish.md`](review.gil/reference/finish.md). Not: `finish` (baseline reference, not an execution).

**Publish** (`review.gil`): end-to-end PR review → reconcile drafts → submit GitHub `COMMENT` (or leave PENDING when draft-only). Not: `pull-request` `comment`.

**Quality** (`review.gil`): merge-prep execution — audit → plan → boy-scout refactors + tests → repo gates. Changes code; never inferred from "review".

**Lens** (`review.gil` `tests` / `perf` / `security` / `legacy`): findings rubric applied to the same diff prep. Not: a skill per lens.

**Legacy** (lens; always under `quality`): dead compat — dual public names, superseded store/wire hydrate, deprecated markers. Findings report it; `quality` deletes it without shims. Not: `refactor-legacy`.

**Comment** (`pull-request`): post already-verified findings as review comments (usually pending). Not: `review.gil` `publish`.

**Reply** (`pull-request`): respond on an existing thread; no new findings, no code.

**Resolve** (`pull-request`): assess threads, fix valid ones, push, mark resolved with commit refs.

**Open** / **Slice** / **Retitle** (`pull-request`): commit + push + create PR | rebuild one branch into intent-based smaller PRs | narrative-only title/body update.

**Fix-ci** (`pull-request`): repair failing Actions — failing-job logs only, classify, fix + push, watch once. Not: explaining CI without a fix ask (report-only).

**Conflicts** (`pull-request`): rebase/merge onto base; preserve intents; push (lease when rebased).

**Unblock chain** (`pull-request` routing rule, not a branch): conflicts → resolve → fix-ci; live PR state each pass; never approve/merge.

**Dependabot** (`dependabot`): `configure` (draft/optimize `dependabot.yml`) | `triage` (risk skim + fallout via `pull-request` fix-ci/conflicts; approve-readiness only). Never auto-merge or rewrite bot commits.

**PR Sweep** (`pr-sweep`, branch `report`): read-only multi-repo attention ledger. **Sweep ledger** rows: repo, PR, blocker, store invocation — no diffs or CI excerpts. Not: a `pull-request` branch.

**Release** (`release`, branch `notes`): notes from Conventional Commits in a merged ship range, grouped Breaking → Features → Fixes → other. Notes-only.

## Explain

**Communication** (`communication`): draft or distill a message for an audience. Branches: `one-on-one` | `slack-message` | `project-update` | `external-message` (no internal jargon, no unconfirmed commitments; marketing/press out of scope).

**Docs** (`docs`): verify and rewrite an existing document against the repo. Branches: `editor` (README, contributor, operator, feature docs, runbooks) | `architecture` (ADRs, design notes, diagrams — verify/rewrite only, no net-new HLD/ADR) | `evidence` (control/auditor packs). Not: the `architecture` skill.

**Doc-class** (shared by `docs` branches): `accurate` | `partial` | `misleading` | `obsolete`, classified before rewriting.

**Evidence ladder** (branch-local): ordered trusted sources; `editor` starts at code/tests, `architecture` at live runtime.

## Intent

**Triage** (`triage`, branch `intake`): incident/ops evidence → **Triage Ledger** → `product-owner` `gate` and/or `$dev` `plan`. Playbooks under `reference/`. Never implements.

**Prompt-compiler** (`prompt-compiler`, branch `compile`): raw intent → `.agents/compile/<slug>.yaml`, then `$dev plan` in the same turn. Never plans or executes.

**Intent DTO fields**: `intent_spec.version` · `slug` · `invariants` · `blast_radius.allowed_domains` · `trade_offs.breaking_changes` · `circuit_breaker.approved`. Not: tasks, files, commands, gates, retries, dependencies, statuses.

**Orchestrator** (`orchestrator`, branch `run`): brain for a plan already enqueued at `.agents/plan/<slug>.md`. One `$dev implement` hand at a time on one worktree; the hand prompt is the plan path and phase id. Brain checks bounds, runs the gate, commits. Plan stays immutable.

**Pipeline batch**: one message before any pipeline file is written, asking only what the opening prompt left open — product admission when a feature needs it, intent gaps, circuit-breaker consent, commit on the default branch, land a PR. Answered once.

**Delivery offer**: after `.agents/plan/<slug>.md` exists, one question — execute with multi-agent, or enqueue for the orchestrator? Skip it when the opening prompt already named the runner. Enqueue writes nothing further; the plan file is the queue.

**Lifecycle**: `product-owner` gate when a feature is not already admitted → `prompt-compiler compile` → `$dev plan` → delivery offer → multi-agent (one agent per phase; `depends_on` waits; disjoint phases together) or a later `orchestrator run` → one `review.gil findings` pass in `.agents/run/<slug>.md` → `pull-request open` only when land was in the batch. Repeated failure: reset to the last green commit and halt.

## Product

**Product-owner** (`product-owner`): the only Product skill. Branches: `gate` (default) | `story-slice` | `rebaseline` | `groom`; stubs `prioritize`, `experiment`.

**Gate** decision vocabulary: **Build Now** | **Build Later** | **Research Further** | **Reject**, plus Confidence and Forced Challenge.

**Story-slice**: admitted scope (Build Now / founder override) → Given/When/Then stories with cited interaction budgets before `$dev` `plan`.

**Golden path** / **click budget** / **mental model** / **persona**: product constraints cited from repo docs — never invented.

**Health Capacity Budget**: ~20% capacity (or 1 debt tranche per 3–4 feature tranches) for high-friction items from `.agents/debt-ledger.md`.

## Build / Solution

**Dev** (`dev`): Build router, branches `plan` | `implement`. Owns classify, route, validation, phase commits, API truth, observability/security cues, post-delivery Assure. `plan` procedure: `dev/reference/plan-pipeline.md`.

**Classification**: `surgical` | `design` | `review-hand-off`. **Design** = structural/type/perf craft earned → `architecture`. Axioms ride along on every `implement`.

**Language-runtime** (`ruby-dev`, `rust-dev`, `swift-dev`, `typescript-dev`) and **Overlay** (`ruby-on-rails-dev`, `swiftui-dev`): deltas loaded by `$dev`. Not: Build entries.

**API truth**: ladder repo docs → Dash → Context7 → pack secondary → unknown; warn once on first material fallthrough per session.

**Security cue**: authn/authz, tenancy, PII/PHI, secrets, exports, webhooks, raw SQL, privileged ops → `review.gil` `security`.

**Observability cue**: APM / traces / error / log links → matching observability MCP when available.

**Architecture** (`architecture`): language-free craft. Branches `philosophy` | `deep-modules` | `refactor-types` | `refactor-boundaries` | `performance` | `design-patterns`; **Structure-survey** is a discovery mode, not a craft branch. **Deepen** signals `deep-modules`. Refactor branches are only `refactor-<concern>`; expansion law: `architecture/reference/growth.md`.

**Delivery Ledger** (the one handoff DTO; `$dev` → `review.gil` → `pull-request` / `harvest`):

- `Classification / Branches`: `surgical` | `design` and active branches
- `Target Files`: exact paths matchable against `git diff --name-only <task_baseline>`
- `Verification`: command executed + exit 0 observed
- `Phase Commits`: hashes & rationale (or explicit deferral on default branch)
- `Active Lenses`: `security`, `tests`, `perf`, `legacy`
- `Readiness`: `Yes` | `No` | `Conditional`
- `Residuals / Debt`: deferred items or N/A

**Phase commit**: after each plan phase, validate → ≥1 [Conventional Commit](https://www.conventionalcommits.org/) (v1.0.0) with a rationale body. Off the default branch by default; on the default branch ask early. Carriers: `$dev` Shared prep (Build), `architecture` Shared prep (Solution). `release` `notes` only consumes merged history.

## Harvest

**Harvest** (`harvest`): `distill` (default; preventive mantras → project rules or store references) | `debt` (→ `<project>/.agents/debt-ledger.md`). After store edits: `skill doctor`; drift → `skill backfill` → `rcup`.

**Preventive Mantra**: one imperative sentence — "When X, always Y to prevent Z" or "Avoid X; use Y instead because Z".

**Debt Ledger** (`.agents/debt-ledger.md`): project backlog of architectural friction; admitted by `product-owner` under the Health Capacity Budget, executed by `orchestrator` / `$dev`.

## Decide

**Grilling** (third-party `grilling`): one-hard-question stress-test. Not for "should we build X?" (→ `product-owner` `gate`).
