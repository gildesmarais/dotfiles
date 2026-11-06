# Digest

## Search

Run in parallel. `only_my_channels: true`. Newest first. Ids come from Shared prep.

1. Mentions: `slack_search_public_and_private`, no keywords, `include_bots: false`, filter `to:<@<operator-id>> after:<window> -in:<#<github-inbox-channel>>`. Open the thread when the latest message is not the operator.
2. Saved: filter `is:saved`.
3. Prod pager: `slack_read_channel` on `<prod-pager-channel>`, `detailed`, until a message is older than the window. State is the attachment title (`Triggered`, `Re-Triggered`, `Warn`, `Recovered`). Keyword search does not see those titles. Do not search the word `health`.
4. A page that names an incident channel or chat: read that thread. The human narrative is in `<incident-channel>`.

## Channels

| Role | Config key | Use |
| --- | --- | --- |
| Prod pager | `<prod-pager-channel>` | Only channel for pager state. |
| Dev alerts | `<dev-alerts-channel>` | Drop. Recovered empty error-tracking. |
| Incident | `<incident-channel>` | Human incident thread. |
| GitHub inbox | `<github-inbox-channel>` | Out. That inbox is `ops-github`. |

## Keep

- **Do:** one bullet per thread. Keep it when the latest message asks the operator for something he has not answered. Link the question.
- **Health open:** `Triggered`, `Re-Triggered`, or `Warn` with no later `Recovered` for the same monitor and group.
- **Health closed:** recovered, or a person marked it resolved. One line: what happened, resolution permalink, follow-up ticket if the thread named one.

## Drop

- Recovered log-index anomalies and Known Bad Inputs probing.
- Configured chronic RUM monitor ids unless the body names chat, login, or payments. If still unpaired, one clause: unrecovered, chronic monitor.
- Canary PRs, merged chores, Dependabot reminder dumps.
- Personnel and role threads.

## Report

Lead with how many chores are open and whether prod is quiet.

**Do** — who, the ask, permalink.

**Health** — open pages, then one recovered line.

Close with one sentence naming what was dropped.

A credential in a message: say to delete it and link the message. Do not repeat the value.
