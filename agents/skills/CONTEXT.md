# Skills Store Vocabulary

Glossary SoT. Handoff procedures live in each skill's `## Handoff`.

**Branch** (skill-internal): a verb-path through a skill, selected from the prompt. Not a git branch.
**AGENTS.md load**: Cursor already injects every `AGENTS.md` from the workspace root upward; nearest file wins; do not re-read or paste unless citing a line. Global identity is `~/.cursor/rules/000-rules.mdc`, installed by `rcup` from `cursor/rules/`.

## Ship / Assure

**Lens** (`tests` / `perf` / `security` / `legacy`): findings rubric on the same diff prep.
**Surface**: Cursor subagent whose output folds into the one finish report.
**Legacy** (lens; always under `quality`): dead compat — dual public names, superseded hydrate, deprecated markers. Findings report it; `quality` deletes without shims.
**Unblock chain**: conflicts → resolve → fix-ci; never approve/merge. Preserve intents; push (lease when rebased).

## Explain

**Doc-class** / **Evidence ladder**: `accurate` | `partial` | `misleading` | `obsolete`; `editor` starts at code/tests, `architecture` at live runtime.

## Intent

**Triage Ledger**: incident/ops evidence DTO → product-owner `gate` and/or `$dev` `plan`. Never implements.

## Product

**Gate** vocabulary: **Build Now** | **Build Later** | **Research Further** | **Reject**, plus Confidence and Forced Challenge.
**Golden path** / **click budget** / **mental model** / **persona** / **doctrine ledger**: sections of `<project>/.agents/product.md`. Cite only; absent → `unknown`.
**Health Capacity Budget**: ~20% capacity (or 1 debt tranche per 3–4 feature tranches) for high-friction items from `.agents/debt-ledger.md`.

## Build / Solution

**Classification**: `surgical` | `design` | `review-hand-off`. **Design** → `architecture`. Axioms on every `implement`.
**API truth**: repo docs → Dash → Context7 → pack secondary → unknown; warn once on first material fallthrough per session.
**Security cue** / **Observability cue**: sensitive surfaces → `review.gil` `security` lens; APM/trace/error/log links → matching observability MCP. No vendor recipes in routers.
**Delivery Ledger**: handoff DTO emitted by `$dev` Handoff → `review.gil` → `pull-request` / `harvest`.
**Phase commit**: `$dev` procedure — `dev/reference/phase-commits.md`.

## Harvest

**Preventive Mantra**: one imperative sentence — "When X, always Y to prevent Z" or "Avoid X; use Y instead because Z".
**Debt Ledger** (`.agents/debt-ledger.md`): architectural friction backlog; admitted by `product-owner` under Health Capacity Budget; executed by `$dev`.

## Decide

**Grilling** (third-party `grilling`): one-hard-question stress-test. Scope asks → `product-owner` `gate`.
