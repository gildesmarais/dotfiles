# Sprint Update

Closed-sprint recap + active-sprint kickoff for a public team Slack channel. Atlassian MCP is required. Applies Shared prep. Shape below overrides [`slack-message.md`](slack-message.md): one-line bullets, not a report, and no delivery question when the channel is known.

Distinct from `project-update` (one comparable status line).

## Config

Read `<project>/.agents/tracker.md`. Use its team channel, Jira project key, and `## Sprint update` (board ID, squad name, audience roles for heads-up). Optional epic→theme map: `<project>/.agents/product.md`.

Absent → ask once for channel + board + project key + audience, write them to `tracker.md`, then continue. Never invent an audience. After a draft is saved, the channel is known: do not ask again next time.

## MCP recipe

1. `getAccessibleAtlassianResources` → `cloudId` + site URL (`…/browse/<KEY>`).
2. One project issue → `getJiraIssue` `fields: ["*all"]`, `expand: "names"` → the field whose name is `Sprint`. Do not hardcode the id.
3. Resolve sprints from that field, or `getJiraBoardSprintData` on the tracker board: **active** = `state: active`; **closed** = latest `completeDate` on that board. Keep `name`, `goal`, `startDate`, `endDate`. Use those names as written. Do not renumber them to ISO weeks.
4. Two JQL queries, not `sprint in closedSprints()`: `project = <KEY> AND sprint = <closedId>` and `… sprint = <activeId>`, order by rank. Paginate with `nextPageToken`. Fields: `summary`, `status`, `issuetype`, `created`, `labels`, plus Sprint. Parent is often empty in compact view; theme-merge from the goal text and summaries.
5. Latest channel recap: `slack_read_channel` on the tracker channel, the newest message whose text contains `Sprint update`. Use it for incident continuity only.

## What leads

Rank before writing. Ticket count is not importance.

| Rank | Rule |
| --- | --- |
| Lead shipped theme | The closed **goal line** with the most Done issues that are not Duplicate and not a recurring dependency clone. If those summaries cross product, clients, and the data pipeline, the section intro is one sentence: alignment across squads and departments, from product through the data pipeline. |
| Prompt defense | Done, created after the closed sprint `startDate`, and a security/runtime/dependency patch. Own first bullets under Login & security, plus one sentence that a widely reported issue needed a same-day defense. Open the merged PR (Jira development field or `gh pr view`) and state the **new control** only. Link one PR. |
| Kickoff | Active sprint `goal` field, read at draft time. The board wins over chat. Each active issue goes under the goal line its summary matches. No match, or Won't Do, or Duplicate → out of the body; name the keys in the operator note. |
| Heads-up | Tracker audience that still has an open carry on the active goal. An ask that shipped moves to Shipped. |
| Incident close | The previous recap named a ticket that is now Done. One block, the outcome, the same channel mention. Do not retell the incident. |

Carry = in both sprints, not Done. It belongs under the active goal, not in a failure section.

## Capacity, kudos, questions

- A capacity fraction or engineer-days appears only when the user already stated it this session, or the previous recap stated it for this same sprint. Otherwise omit it. Do not ask.
- No names or thanks unless the user named someone.
- Do not confirm unplanned, support, or kudos before drafting. File mid-sprint Done support on the matching shipped line. File same-day security as the prompt defense.
- Ask only when the channel is unknown, two sprints are active, or the active goal is empty.

## Render

`slack_send_message_draft` takes **standard markdown** and converts it. Do not hand the operator Slack mrkdwn to reformat. Emoji shortcodes and `<#CHANNELID>` pass through.

Fill this skeleton. Section intros only on the lead theme and the prompt defense. Every other line is one outcome and its link. Link every key `[CAT-1](https://<site>/browse/CAT-1)`. Drop Duplicate. Drop mechanism, patient counts, and the weakness behind a closed hole ([`outward-text.md`](outward-text.md)).

```text
:rocket: **{squad} — Sprint update: {closed name} recap · {active name} kickoff**

**TL;DR:** Last sprint we {lead outcome}. {Prompt defense, one clause, if any.} {Capacity clause, only if known.} This sprint (**{active start} – {active end}**{, capacity N/N if known}) we {active goal lines, in order}.

:eyes: **Heads-up for other teams**
- **{Team}:** {what they still need} ({links}).

:rotating_light: **Incident support: {name}** (<#CHANNELID>)
{One sentence: our side is done, link the ticket.} {Capacity clause if that incident is why.}

:white_check_mark: **Shipped in {closed name}**

:shield: **{Lead theme}** _(the big one)_
{One sentence of alignment, only when the work crossed teams.}
- {outcome} ({link})

:closed_lock_with_key: **Login & security**
{One sentence, only for a prompt defense.}
- {new control} ({pr link}, {ticket})

:hammer_and_wrench: **Rollout & cleanup**
- {outcome} ({link})

:dart: **Sprint goals {active name}**

1. :key: **{goal 1}** _(top priority)_
    - {outcome} ({links})
2. :hospital: **{goal 2}**
    - {outcome} ({links})
3. :shield: **{goal 3}**
    - {outcome} ({links})

Questions, or something here affects your team? Reply in the thread :speech_balloon:
```

Omit a section that has no items. Keep the emoji on the section that remains. Goal emoji follows the goal's subject (key = credentials, hospital = rollout, shield = deletion/safety); reuse these three before inventing one.

## Deliver

Channel known → `slack_send_message_draft` to that channel. Reply with the channel link and one note: keys left off because they match no goal line. `attached_draft_exists` → stop and say a draft is already there. Send only when the user says post.

## Done when

Draft saved in the tracker channel. Keys in the body exist on the closed sprint, the active sprint, or the user's input. No paste left for the operator to reformat.
