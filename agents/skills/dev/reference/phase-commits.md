# Phase commits

Load when committing (plan phase or surgical milestone). Definition: [`../../CONTEXT.md`](../../CONTEXT.md) § Phase commit.

- Detect the default branch early (`AGENTS.md` / remote HEAD).
- Off default: after each plan phase or surgical milestone, validate → ≥1 Conventional Commit with a rationale body before the next. Format: CONTEXT (absent → conventionalcommits.org v1.0.0).
- On default: commit only when the pipeline batch already said so. The batch has not run → ask once there, not mid-phase. Never silently commit on main/master.
- `release` `notes` consumes history later — don't defer authoring. Overlays never restate this.
