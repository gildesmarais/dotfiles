# Sprint Update

Closed-sprint recap + active-sprint kickoff as a Slack draft (Atlassian MCP). Overrides [`slack-message.md`](slack-message.md): one-line bullets, no delivery question.

## Config

`<project>/.agents/tracker.md`: team channel, Jira key, `## Sprint update` (board ID, squad, heads-up audience). Optional epic→theme map: `.agents/product.md`. Missing → ask once, write to `tracker.md`. Invent no audience.

## Fetch

1. `getAccessibleAtlassianResources` → `cloudId`, site URL; one issue via `getJiraIssue` (`fields: ["*all"]`, `expand: "names"`) → the `Sprint` field id.
2. `getJiraBoardSprintData` on the board: **active** = `state: active`; **closed** = latest `completeDate`. Keep sprint names; no ISO weeks.
3. JQL `project = <KEY> AND sprint = <id>` per sprint (not `closedSprints()`), by rank, paginated; fields `summary, status, issuetype, created, labels`, Sprint.
4. `slack_read_channel`: newest message containing `Sprint update` — incident continuity only.

## Rank

- **Lead theme:** closed goal line with most Done (no Duplicates or dependency clones). Cross-team work earns one intro sentence.
- **Prompt defense:** security/dependency patch created mid-sprint, Done → Login & security, one intro sentence. State the merged PR's new control; link it.
- **Kickoff:** active `goal` from the board at draft time. Issues under their matching goal line; unmatched, Won't Do, Duplicate → operator note only.
- **Carry** (both sprints, not Done) → under its active goal.
- **Heads-up:** audience with an open carry; shipped asks move to Shipped.
- **Incident close:** prior recap's ticket now Done → one outcome block, same channel mention.

Capacity only if the user or the prior recap stated it for this sprint. No names or thanks unless the user gave them. Ask only when the channel is unknown, two sprints are active, or the active goal is empty.

## Render

Standard markdown. Link every key `[CAT-1](https://<site>/browse/CAT-1)`. One outcome per bullet; no mechanism, patient counts, or closed weakness ([`outward-text.md`](outward-text.md)). Omit empty sections.

```text
:rocket: **{squad} — Sprint update: {closed} recap · {active} kickoff**

**TL;DR:** Last sprint we {lead outcome}. {defense clause} {capacity clause} This sprint (**{start} – {end}**) we {goal lines}.

:eyes: **Heads-up for other teams**
- **{Team}:** {need} ({links})

:rotating_light: **Incident support: {name}** (<#CHANNELID>)

:white_check_mark: **Shipped in {closed}**

:shield: **{Lead theme}** _(the big one)_
- {outcome} ({link})

:closed_lock_with_key: **Login & security**
- {new control} ({pr}, {ticket})

:hammer_and_wrench: **Rollout & cleanup**
- {outcome} ({link})

:dart: **Sprint goals {active}**
1. :key: **{goal}** _(top priority)_
    - {outcome} ({links})

Questions? Reply in the thread :speech_balloon:
```

Goal emoji: key = credentials, hospital = rollout, shield = safety.

## Done when

`slack_send_message_draft` saved in the channel (`attached_draft_exists` → stop, say so); reply with its link and the unmatched keys. Every key exists in a sprint or user input. Post only when told.
