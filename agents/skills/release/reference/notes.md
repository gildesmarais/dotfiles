# notes

1. **Range** — previous tag…new tag, merge-base…HEAD, or user bounds.
2. **Inspect** — `git log --pretty=…` (`git show` for depth); parse types per [`CONTEXT.md`](../../CONTEXT.md).
3. **Group** — Breaking (`BREAKING CHANGE` / `!`) → Features (`feat`) → Fixes (`fix`) → other (`perf`, `refactor`, `docs`, …). Drop `chore`/`ci`/`style`/`test` unless a full dump is asked.
4. **Emit** — concise bullets from descriptions; bodies only for needed rationale; nothing absent from history.
5. **Stop** — no PRs, tags, flags, promotions, rollbacks.

Thin or non-conventional history → report the gap; rewrite past commits only on explicit ask.
