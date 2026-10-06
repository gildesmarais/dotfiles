# Skills Store Vocabulary

Glossary SoT. Handoff procedures live in each skill's `## Handoff`.

**Branch** (skill-internal): a verb-path through a skill, selected from the prompt. Not a git branch.
**AGENTS.md load**: Cursor already injects every `AGENTS.md` from the workspace root upward; nearest file wins; do not re-read or paste unless citing a line. Global identity is `~/.cursor/rules/000-rules.mdc`, installed by `rcup` from `cursor/rules/`.

## Ship / Assure

**Pull Request** (`pull-request`): lifecycle action on a remote PR or branch destined to become one.
**Review** (`review.gil`): local analysis of a working tree, branch, or commit range. Executions: `findings` | `publish` | `quality`.
**Findings** (`review.gil`): read-only production-readiness report — no edits, no GitHub writes. Baseline: `review.gil/reference/finish.md`. Not: `finish` (baseline reference, not an execution).
**Publish** (`review.gil`): end-to-end PR review → reconcile drafts → submit GitHub `COMMENT` (or leave PENDING when draft-only). Not: `pull-request` `comment`.
**Quality** (`review.gil`): merge-prep — audit → plan → boy-scout refactors + tests → repo gates. Changes code; never inferred from "review".
**Lens** (`review.gil` `tests` / `perf` / `security` / `legacy`): findings rubric on the same diff prep. Not a skill per lens.
**Surface**: Cursor subagent whose output folds into the one finish report. Not a lens or execution.
**Legacy** (lens; always under `quality`): dead compat — dual public names, superseded store/wire hydrate, deprecated markers. Findings report it; `quality` deletes without shims. Not: `refactor-legacy`.
**Comment** / **Reply** / **Resolve** (`pull-request`): post verified findings as review comments | respond on an existing thread | assess threads, fix valid ones, push, mark resolved with commit refs.
**Open** / **Slice** / **Retitle** (`pull-request`): commit + push + create PR | rebuild one branch into intent-based smaller PRs | narrative-only title/body update.
**Fix-ci** (`pull-request`): repair failing Actions — failing-job logs only, classify, fix + push, watch once. Not: explain CI without a fix ask.
**Conflicts** / **Unblock chain** (`pull-request`): rebase/merge onto base; preserve intents; push (lease when rebased). Unblock = conflicts → resolve → fix-ci; never approve/merge.
**Dependabot** (`dependabot`): `configure` | `triage` (risk skim + fallout via `pull-request` fix-ci/conflicts; approve-readiness only). Never auto-merge or rewrite bot commits.
**PR Sweep** (`pr-sweep`, `report`): read-only multi-repo attention ledger (repo, PR, blocker, store invocation). Not a `pull-request` branch.
**Release** (`release`, `notes`): Conventional Commits notes in a merged ship range (Breaking → Features → Fixes → other). Notes-only.

## Explain

**Communication** (`communication`): draft or distill a message. Branches: `one-on-one` | `slack-message` | `project-update` | `external-message` (no internal jargon / unconfirmed commitments; marketing out of scope).
**Docs** (`docs`): verify/rewrite an existing document. Branches: `editor` | `architecture` (verify-only; no net-new HLD/ADR) | `evidence`. Not the `architecture` skill.
**Doc-class** / **Evidence ladder**: `accurate` | `partial` | `misleading` | `obsolete` before rewrite; `editor` starts at code/tests, `architecture` at live runtime.

## Intent

**Triage** (`triage`, `intake`): incident/ops evidence → **Triage Ledger** → `product-owner` `gate` and/or `$dev` `plan`. Never implements.
**Prompt-compiler** (`prompt-compiler`, `compile`): raw intent → `.agents/compile/<slug>.yaml`, then `$dev plan` same turn. Only when asked to compile.
**Intent DTO fields**: `intent_spec.version` · `slug` · `invariants` · `blast_radius.allowed_domains` · `trade_offs.breaking_changes`. Not tasks/files/commands/gates/retries.
**Orchestrator** (`orchestrator`, `run`): brain for `.agents/plan/<slug>.md`. One `$dev implement` hand at a time; bounds, gate, commit. Plan immutable.
**Pipeline batch** / **Delivery offer** / **Lifecycle**: `$dev` `plan` procedures — `dev/reference/plan-pipeline.md`.

## Product

**Product-owner** (`product-owner`): only Product skill. Branches: `gate` (default) | `story-slice` | `rebaseline` | `groom`; stubs `prioritize`, `experiment`.
**Gate** vocabulary: **Build Now** | **Build Later** | **Research Further** | **Reject**, plus Confidence and Forced Challenge.
**Story-slice**: admitted scope → Given/When/Then stories with cited interaction budgets before `$dev` `plan`.
**Golden path** / **click budget** / **mental model** / **persona** / **doctrine ledger**: sections of `<project>/.agents/product.md`. Cite only; absent → `unknown`.
**Health Capacity Budget**: ~20% capacity (or 1 debt tranche per 3–4 feature tranches) for high-friction items from `.agents/debt-ledger.md`.

## Build / Solution

**Dev** (`dev`): Build router (`plan` | `implement`). Classify, route, validation, phase commits, API truth, cues, post-delivery Assure. Plan: `dev/reference/plan-pipeline.md`.
**Classification**: `surgical` | `design` | `review-hand-off`. **Design** → `architecture`. Axioms on every `implement`.
**Language-runtime** / **Overlay** (`ruby-dev`, `rust-dev`, `swift-dev`, `typescript-dev`; `ruby-on-rails-dev`, `swiftui-dev`): deltas loaded by `$dev`. Not Build entries.
**API truth**: repo docs → Dash → Context7 → pack secondary → unknown; warn once on first material fallthrough per session.
**Security cue** / **Observability cue**: sensitive surfaces → `review.gil` `security` lens; APM/trace/error/log links → matching observability MCP. No vendor recipes in routers.
**Architecture** (`architecture`): language-free craft (`philosophy` | `deep-modules` | `refactor-types` | `refactor-boundaries` | `performance` | `design-patterns`); **Structure-survey** is discovery. Expansion: `architecture/reference/growth.md`.
**Delivery Ledger** (handoff DTO; `$dev` → `review.gil` → `pull-request` / `harvest`):

- `Classification / Branches`: `surgical` | `design` and active branches
- `Target Files`: exact paths matchable against `git diff --name-only <task_baseline>`
- `Verification`: command executed + exit 0 observed
- `Phase Commits`: hashes & rationale (or explicit deferral on default branch)
- `Active Lenses`: `security`, `tests`, `perf`, `legacy`
- `Readiness`: `Yes` | `No` | `Conditional`
- `Residuals / Debt`: deferred items or N/A
  **Phase commit**: `$dev` procedure — `dev/reference/phase-commits.md`.

## Harvest

**Harvest** (`harvest`): `distill` (preventive mantras → project rules or store references) | `debt` (→ `<project>/.agents/debt-ledger.md`). After store edits: `skill doctor`; drift → `skill backfill` → `rcup`.
**Preventive Mantra**: one imperative sentence — "When X, always Y to prevent Z" or "Avoid X; use Y instead because Z".
**Debt Ledger** (`.agents/debt-ledger.md`): architectural friction backlog; admitted by `product-owner` under Health Capacity Budget; executed by `orchestrator` / `$dev`.

## Decide

**Grilling** (third-party `grilling`): one-hard-question stress-test. Not for "should we build X?" (→ `product-owner` `gate`).
