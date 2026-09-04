# Dependabot.yml keys (slim)

`version: 2` required. Top-level: optional `registries`, `multi-ecosystem-groups`; required `updates[]`.

## Update entry (required fields)

| Key                         | Notes                                                                                                 |
| --------------------------- | ----------------------------------------------------------------------------------------------------- |
| `package-ecosystem`         | e.g. `bundler`, `npm`, `gomod`, `docker`, `github-actions`, `pip`, `uv`, `cargo`, `terraform`         |
| `directory` / `directories` | Singular = one path (no globs). Plural supports `*` / `**`                                            |
| `schedule.interval`         | `daily` \| `weekly` \| `monthly` \| … \| `cron` (+ `day` / `time` / `timezone` / `cronjob` as needed) |

## Common optional fields

| Key                                  | Use                                                                                                    |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------ |
| `groups`                             | Bundle related deps into fewer PRs (`patterns`, `exclude-patterns`, `update-types`, `dependency-type`) |
| `open-pull-requests-limit`           | Cap concurrent version-update PRs                                                                      |
| `ignore`                             | Pin out deps/versions with a reason                                                                    |
| `allow`                              | Allowlist deps when you want a narrow surface                                                          |
| `labels` / `reviewers` / `assignees` | PR metadata (org rules may override)                                                                   |
| `vendor`                             | Vendor folder updates where applicable                                                                 |
| `cooldown`                           | Delay minor/patch noise when available                                                                 |

## Minimal example

```yaml
version: 2
updates:
  - package-ecosystem: bundler
    directory: "/"
    schedule:
      interval: weekly
      day: monday
    open-pull-requests-limit: 5
    groups:
      ruby-deps:
        patterns: ["*"]
```

For registries, multi-ecosystem groups, or rare ecosystems: check current GitHub Dependabot docs — do not invent keys.
