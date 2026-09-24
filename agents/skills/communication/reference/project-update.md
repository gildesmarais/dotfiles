# Project Update

Project notes, status reports, meeting outcomes, Jira updates → one short update comparable across projects for executives, managers, product owners, and engineers.

## Required format

`<Project> | <Status> | <Progress> | <Risk/Blocker> | <Next>`

Status: `🟢 On Track` | `🟡 Attention Needed` | `🔴 At Risk`

## Rules

- ≤200 characters unless the user asks for longer.
- Outcomes over activities; no implementation detail or engineering task lists; plain business language; concrete numbers when they aid scanning.
- Keep only status, key progress, the single most decision-relevant blocker, and the next meaningful milestone (not a generic next action). Missing element → infer cautiously, conservative wording.
- Use the input's project name unless asked to rename.
- Real progress but a policy or dependency threatens the next batch/milestone → `🟡 Attention Needed`, not `🟢 On Track`.
- Blocker phrasing is operational and system-first ("customer sign-off gating rollout", "running short on rollout candidates"); neutral tone — no diplomacy, manager-calming, or persuasion.

## Examples

- `Identity | 🟡 Attention Needed | SSO complete, RBAC underway | Legacy integrations slowing rollout | Pilot in July`
- `Platform | 🟢 On Track | CI/CD migration finished | No major risks | Decommission old runners`
