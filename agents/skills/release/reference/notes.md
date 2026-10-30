# notes

1. **Range** — previous tag…new tag, merge-base…HEAD, or user-named bounds; prefer default-branch merges.
2. **Inspect** — `git log` (`git show` for depth); parse [Conventional Commit](https://www.conventionalcommits.org/en/v1.0.0/) types. Never invent commits.
3. **Group** — Breaking (`BREAKING CHANGE` / `!`) → Features → Fixes → other (`perf`, `refactor`, `docs`, …). Drop `chore`/`ci`/`style`/`test` unless a full dump is asked.
4. **Emit** — concise bullets from descriptions; bodies only for needed rationale.

Thin or non-conventional history → report the gap; rewrite past commits only on explicit ask.
