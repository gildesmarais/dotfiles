# Intake

Delta sweep of assigned and incoming tickets. Caller is stateless; state lives on disk. Read-only: never transition, comment, or edit.

## Inputs

From the caller, else `<project>/.agents/tracker.md`:

- `--state-dir <dir>`, default `~/.local/state/ops/<profile>`.
- Cloud/site and intake `projects` (`APP,OPS`).
- `parked_statuses` (`On Hold`, `Parking lot`, `Backlog` when unready).
- Operator account id, to tell your comments from a teammate's.

Missing → ask once. GitHub issues (`issue-assigned` from `ops-github tick`) are not swept here.

## Sweep

One `searchJiraIssuesUsingJql` call; `fields`: `summary, status, priority, assignee, updated, project, parent, comment`. Never `description` or `*all`: payload stays near 3 KB.

```text
(assignee = currentUser() AND statusCategory != Done) OR (project in (<projects>) AND statusCategory = "To Do" AND created >= -7d) ORDER BY updated DESC
```

## Ledger

`<state-dir>/jira-ledger.json`: `key -> {status, last_comment_id, summary, url}`.

- Missing ledger and a legacy `jira.txt` (`~/.local/state/ops-github/jira.txt` or `<state-dir>/jira.txt`) → seed each listed key as seen with current fields, so the first run does not flood old tickets.
- Missing ledger, no legacy file → first run emits only tickets assigned to the operator.
- Write atomically (temp file, then rename) after emitting.

## Emit

Deltas only, each with `key`, `summary`, `url`, `status`:

1. `new` — key unseen, or moved from a parked status into active/Ready; status not in `parked_statuses`.
2. `transition` — status changed on an active assigned ticket (`from → to`).
3. `comment` — `last_comment_id` changed and its author is not the operator.

Also return `active`: the metadata map of every assigned open ticket, so callers can join items by key. No deltas → `quiet: true`.

## Handoff

Per delta, the caller asks (`N. <key> — "<title>" — <url>`): challenge / implement / skip. Challenge → `challenge`; implement → `implement` (branches of this skill). Skip → keep the ledger entry so it does not re-surface.
