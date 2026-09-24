# Configure

One `.github/dependabot.yml` per repo (GitHub ignores multiples), on the default branch. Ownership generator present → stop, use it.

1. **Ecosystems** — scan manifests (Gemfile, package.json, go.mod, Dockerfiles, `.github/workflows`…). `uv.lock` → `uv`; pnpm/yarn → `npm`.
2. **Directories** — monorepo globs need `directories` (plural); `directory` has no globs. `github-actions` uses `/`.
3. **Entries** — one block per ecosystem + directory set; keys per [`yml-keys.md`](yml-keys.md).
4. **Tighten** — `groups` for noisy ecosystems, `open-pull-requests-limit`, `ignore` only with a stated reason (YAML over `@dependabot ignore`), `cooldown` when useful.
5. **Validate** — YAML parses; no unintended duplicate ecosystem+directory entries.
