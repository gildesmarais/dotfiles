# Setup

First run, or `/ops reconfigure`. One interview, no per-leaf prompts.

## Profile

`<profile>`: slug of the workspace or org (`acme`). Config
`~/.local/state/ops/<profile>/config.json`. `OPS_GITHUB_STATE_DIR`:
`~/.local/state/ops/<profile>/github`, or the existing
`~/.local/state/ops-github` when one org only.

## Discover (parallel, silent)

Tier 1 Hands, read-only:

- `ops-github setup-facts` → owners, candidate exclusions.
- `<project>/.agents/tracker.md` + Atlassian cloud and visible projects →
  `jira.projects`, `parked_statuses`.
- Slack operator id, `#alerts` and incident channels (`$ops-slack` Shared prep).

A channel whose tool is missing or unauthenticated defaults to Off.

## Ask (one `AskQuestion`)

1. GitHub owners (multi-select), `OPS_GITHUB_PARKED_LABELS`, exclusions.
2. Jira projects and parked statuses, or Off.
3. Slack mentions, saved items, `#alerts`, or Off.
4. Brief cadence (default `30m`); auto, or `OPS_GITHUB_DRY=1` (default for the
   first days and new owners).

## Write

- `config.json`: `profile`, `github {owners, state_dir, parked_labels, dry}`,
  `jira {projects, parked_statuses}`, `slack {scope}`, `brief_every`.
- `~/.local/state/ops-slack/config.md` only if absent, so standalone `/ops-slack` works.
- `$ops-github` setup with the answers; then `ticket` `intake` once to seed
  `jira-ledger.json` (no flood).
- Offer, never edit settings: Claude Code `statusLine` =
  `cat "${OPS_GITHUB_STATE_DIR:-$HOME/.local/state/ops-github}/status.txt" 2>/dev/null`.

## Banner

Print after setup and on every start:

```text
ops [<profile>] · gh:<owners> · jira:<projects|off> · slack:<scope|off> · brief:<Nm> · auto:<on|dry> · pid:<pid>
(/ops reconfigure · /ops brief · /ops wrap)
```

`pid` is `watcher_pid` from `ops-github doctor`, `-` before arming.
