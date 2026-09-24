# @dependabot commands

`@dependabot merge`, `close`, `reopen` were removed (Jan 2026) — merging is a human `gh pr merge` / auto-merge action, never this skill's.

| Command                                                    | Effect                                                   |
| ---------------------------------------------------------- | -------------------------------------------------------- |
| `@dependabot rebase`                                       | Rebase onto target (prefer when review state matters)    |
| `@dependabot recreate`                                     | Rebuild from scratch — overwrites manual edits           |
| `@dependabot ignore this dependency`                       | Close + stop updates for that dep                        |
| `@dependabot ignore this major/minor/patch version`        | Close + stop that version band                           |
| `@dependabot show DEPENDENCY_NAME ignore conditions`       | Show stored ignores                                      |
| `@dependabot ignore DEPENDENCY_NAME` [+ version band]      | Grouped PR: drop dep from the group                      |
| `@dependabot unignore *` / `DEPENDENCY_NAME` [+ condition] | Grouped PR: clear ignores; bot closes and opens fresh PR |

Manual commits on the bot branch: include `[dependabot skip]` so Dependabot can still rebase.
