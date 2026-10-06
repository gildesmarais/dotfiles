# Phase commits

Load when committing (plan phase or surgical milestone).

After each plan phase, validate → ≥1 [Conventional Commit](https://www.conventionalcommits.org/) (v1.0.0) with a rationale body. Off the default branch by default; on the default branch ask early. Carriers: `$dev` Shared prep (Build), `architecture` Shared prep (Solution). `release` `notes` only consumes merged history.

- Detect the default branch early (`AGENTS.md` / remote HEAD).
- Off default: after each plan phase or surgical milestone, validate → ≥1 Conventional Commit with a rationale body before the next. Format: Conventional Commits v1.0.0 (store vocabulary names this **Phase commit**).
- On default: commit only when the pipeline batch already said so. The batch has not run → ask once there, not mid-phase. Never silently commit on main/master.
- `release` `notes` consumes history later — don't defer authoring. Overlays never restate this.
