# Dependabot PR commands

Comment `@dependabot <command>` on the PR. Prefer native `gh pr merge` / auto-merge for merging — `@dependabot merge` (and close/reopen) were removed Jan 2026.

## Individual PRs

| Command                                              | Effect                                          |
| ---------------------------------------------------- | ----------------------------------------------- |
| `@dependabot rebase`                                 | Rebase onto target                              |
| `@dependabot recreate`                               | Recreate from scratch (overwrites manual edits) |
| `@dependabot ignore this dependency`                 | Close + stop future updates for that dep        |
| `@dependabot ignore this major/minor/patch version`  | Close + stop that version band                  |
| `@dependabot show DEPENDENCY_NAME ignore conditions` | Show stored ignores                             |

## Grouped PRs

| Command                                                    | Effect                                                |
| ---------------------------------------------------------- | ----------------------------------------------------- |
| `@dependabot ignore DEPENDENCY_NAME` [+ version band]      | Drop that dep from the group going forward            |
| `@dependabot unignore *` / `DEPENDENCY_NAME` [+ condition] | Clear ignores; Dependabot closes and opens a fresh PR |

## Tips

- Prefer YAML `ignore` over comment ignores for team visibility.
- Extra commits on the bot branch: include `[dependabot skip]` so Dependabot can rebase over them.
- Prefer `rebase` over `recreate` when review state matters and there are no conflicting manual edits.
