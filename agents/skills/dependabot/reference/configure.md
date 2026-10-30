# Configure

One `.github/dependabot.yml` per repo (GitHub ignores multiples), on the default branch.

1. **Ecosystems** — scan manifests (Gemfile, package.json, go.mod, Dockerfiles, `.github/workflows`…). `uv.lock` → `uv`; pnpm/yarn → `npm`.
2. **Directories** — monorepo globs need `directories` (plural); `directory` has no globs. `github-actions` uses `/`.
3. **Entries** — one block per ecosystem + directory set; keys per [`yml-keys.md`](yml-keys.md).
4. **Tighten** — `groups` for noisy ecosystems, `open-pull-requests-limit`, `cooldown` when useful, `ignore` only with a stated reason (YAML over `@dependabot ignore`).
5. **Validate** — YAML parses; no duplicate ecosystem+directory entries.
