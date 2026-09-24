# dependabot.yml keys

`version: 2` required. Top-level: `updates[]` (required), optional `registries`, `multi-ecosystem-groups`.

Per update, required: `package-ecosystem` (`bundler`, `npm`, `gomod`, `docker`, `github-actions`, `pip`, `uv`, `cargo`, `terraform`, …); `directory` (one path, no globs) or `directories` (`*`/`**`); `schedule.interval` (`daily`|`weekly`|`monthly`|…|`cron`, + `day`/`time`/`timezone`/`cronjob`).

Optional: `groups` (`patterns`, `exclude-patterns`, `update-types`, `dependency-type`), `open-pull-requests-limit`, `ignore`, `allow`, `labels`/`reviewers`/`assignees`, `vendor`, `cooldown`.

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

Registries, multi-ecosystem groups, rare ecosystems → check current GitHub docs; don't invent keys.
