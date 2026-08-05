# notes

Derive release notes from Conventional Commits already present in the merged ship range.

## Earn this branch

User asks for changelog / release notes / “what shipped” for a tag, merge range, or named ship window.

## Checklist

1. **Range** — Resolve the commit range (previous tag…new tag, merge-base…HEAD, or user bounds). Prefer default-branch merges.
2. **Inspect** — `git log --pretty=…` (and `git show` for deep-dives). Parse Conventional Commit types from history. Format SoT: [`CONTEXT.md`](../../CONTEXT.md).
3. **Group** — Breaking (`BREAKING CHANGE` / `!`) → Features (`feat`) → Fixes (`fix`) → other (`perf`, `refactor`, `docs`, …). Drop noise (`chore`/`ci`/`style`/`test`) unless the user wants full dump.
4. **Emit** — Concise bullets from commit descriptions; use bodies only when they add rationale readers need. Do not invent entries absent from history.
5. **Stop** — Do not open PRs, tag, flag, promote, or roll back.

## Sequencing

Consume only. If history is thin or non-conventional, report the gap; do not rewrite past commits unless the user explicitly asks for a history rewrite (out of this branch’s default path).
