# Skills Store Vocabulary

Cross-skill terms only; skill-local vocabulary lives in the owning skill. Handoff procedures live in each skill's `## Handoff`.

**Branch** (skill-internal): a verb-path through a skill, selected from the prompt. Not a git branch.
**AGENTS.md load**: hosts load repo instruction files (`AGENTS.md`, `CLAUDE.md`) from the workspace root upward; nearest wins; do not re-read or paste unless citing a line.
**Security cue** / **Observability cue**: sensitive surfaces → `review.gil` `security` lens; APM/trace/error/log links → matching observability tool. No vendor recipes in routers.
**Ops Ledger**: service-ops evidence DTO from `ops-chore`; admitted items seed `$dev` `plan`.
**Phase commit**: `$dev` procedure — `dev/reference/plan.md`.
**Delivery Ledger**: handoff DTO emitted by `$dev` at delivery → `review.gil` → `pull-request` / `harvest`. Fields:
- `Classification / Branches`: `surgical` | `design` and active branches
- `Target Files`: exact paths matchable against `git diff --name-only <task_baseline>`
- `Verification`: command executed + exit 0 observed
- `Phase Commits`: hashes & rationale (or explicit deferral on default branch)
- `Active Lenses`: `security`, `tests`, `perf`, `legacy`
- `Readiness`: `Yes` | `No` | `Conditional`
- `Residuals / Debt`: deferred items or N/A
