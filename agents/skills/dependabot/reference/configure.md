# Configure

Create or optimize a single `.github/dependabot.yml` on the default branch.

## Sequence

1. **Detect ecosystems** — scan manifests (Gemfile, package.json, go.mod, Dockerfiles, `.github/workflows`, etc.). Prefer `uv` when `uv.lock` exists; pnpm/yarn use ecosystem `npm`.
2. **Map directories** — use `directories` (plural) with globs for monorepos; `directory` does not support globs. Actions ecosystem uses `/`.
3. **Draft entries** — one update block per ecosystem (+ directory set). Require `version: 2`, `package-ecosystem`, `directory`/`directories`, `schedule.interval`.
4. **Tighten** — groups for noisy ecosystems; `open-pull-requests-limit`; `ignore` only with a stated reason; cooldown when supported and useful.
5. **Validate** — YAML parses; no duplicate conflicting entries for the same ecosystem+directory without intent.

Load [`yml-keys.md`](yml-keys.md) for key/value details. Do not invent undocumented keys.

## Guardrails

- One `dependabot.yml` per repo (GitHub does not support multiples).
- Prefer transparent `ignore` in YAML over silent `@dependabot ignore` for team repos.
- If the repo generates Dependabot/CODEOWNERS from ownership config → stop and use that tool instead of hand-editing.
