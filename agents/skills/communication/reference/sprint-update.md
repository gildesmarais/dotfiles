# Sprint Update

Closed-sprint recap + active-sprint kickoff for a public team Slack channel. Atlassian MCP is required. Applies Shared prep and [`slack-message.md`](slack-message.md) Output. Returns the draft, then AskQuestion: post / Slack draft / stop — never mutate without that answer. Distinct from `project-update` (one comparable status line).

## Config

Read `<project>/.agents/tracker.md` → `## Sprint update`. Need: Jira project key, board ID, Slack channel, audience roles/squads for heads-up. Optional: epic→theme map from `<project>/.agents/product.md`. Absent → ask once; offer to write the block. Never invent audience teams.

## MCP recipe

1. `getAccessibleAtlassianResources` → `cloudId` + site URL (`…/browse/<KEY>`).
2. Pick any project issue → `getJiraIssue` with `fields: ["*all"]`, `expand: "names"` → field whose name is `Sprint` (site-specific ID; never hardcode).
3. Paginate `searchJiraIssuesUsingJql`: `project = <KEY> AND sprint in closedSprints()` and `… openSprints()`, order by rank; follow `nextPageToken`. Minimal fields: `summary`, `status`, `parent`, `created`, `assignee`, `labels`, `issuetype`, plus the Sprint field.
4. From Sprint arrays: **closed** = latest `completeDate` with matching `boardId`; **active** = `state: active` on that board. Keep `name`, `goal`, `startDate`, `endDate`, `completeDate`.

## Classify

| Bucket | Rule |
| --- | --- |
| Done (closed) | In closed sprint; status category Done |
| Carry-over | In both sprints; not Done |
| Planned (active) | Active sprint only; group under sprint `goal` lines, else epic |
| Unplanned candidates | `created` after closed `startDate`, or labels/summaries that look like incident/support |

Done work: cluster by epic, then theme-merge for the audience (config map wins). Confirm unplanned with **one** AskQuestion covering support/incident links, capacity cost, and kudos. Read Slack/incident channels only when the user supplies links. Capacity numbers only from the user — mark any inference.

## Render

Standard markdown (Slack MCP converts). Skeleton:

1. Title + **TL;DR** (shipped theme + capacity hit if any + current focus + date range)
2. **Heads-up** — only roles/squads from config or user input
3. **Incident/support** (if any) — consequence + mitigation; link channel/ticket; kudos with Slack mention when given
4. **Shipped** — theme bullets; every key linked
5. **Sprint goals** — active `goal` text as numbered list; tickets under each; flag goal-count mismatches in the draft notes, not the channel body
6. Soft CTA: questions in thread

## Hygiene

- Security/ops closed holes → new control only; no leakage detail, patient IDs, error counts, or incident forensics ([`outward-text.md`](outward-text.md)).
- Outcomes over mechanisms; translate for mixed audience.
- Every listed key must exist in the queried sprints or the user's input.

## Done when

Draft returned; keys verified; delivery AskQuestion answered (posted, Slack-drafted, or stopped).
