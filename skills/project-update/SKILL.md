---
name: project-update
description: Use when converting project notes, meeting outcomes, Jira updates, status reports, or bullet points into a concise project status update that is comparable across projects.
---

# Message Project Update Distiller

Turn project notes into a short, comparable stakeholder update.

## When to Use

Use this skill when the user wants a project update distilled from:

- project notes
- status reports
- meeting outcomes
- Jira updates
- bullet points

Assume the audience includes executives, managers, product owners, and engineers.

Do not use it for:

- drafting a Slack message or announcement
- writing a persuasive escalation or decision request
- summarizing a non-project topic
- producing a multi-paragraph update
- softening or tailoring a message for a sensitive stakeholder audience

## Output Rules

- Maximum 200 characters unless the user explicitly asks for a longer update.
- Focus on outcomes, not activities.
- Remove implementation detail.
- Use plain business language.
- Make updates comparable across projects.
- Default to returning only the final distilled update.
- Prefer concrete numbers when they materially improve scan value.
- Keep the tone neutral and operational rather than persuasive or audience-calibrated.

## Keep Only

Retain only:

- current status
- key progress
- major risk or blocker
- next meaningful milestone

If one of these elements is missing, omit unnecessary detail, infer cautiously, and keep the wording conservative.

## Required Format

Use this format:

`<Project> | <Status> | <Progress> | <Risk/Blocker> | <Next>`

Status values:

- `🟢 On Track`
- `🟡 Attention Needed`
- `🔴 At Risk`

## Distillation Standard

- Prefer concrete business progress over engineering task lists.
- Summarize the most decision-relevant blocker only.
- Use the next milestone, not a generic next action.
- Keep wording compact enough that multiple project updates can be scanned side by side.
- Use the project name the input already uses unless the user asks to rename it.
- If progress is real but a policy or dependency threatens the next batch or milestone, prefer `🟡 Attention Needed` over `🟢 On Track`.
- Use blocker phrasing that reflects the operational constraint, for example "customer sign-off gating rollout" or "running short on rollout candidates".
- Keep blocker language system-first where possible, but do not add diplomacy, manager-calming language, or long-form explanation.

## Examples

- `Identity | 🟡 Attention Needed | SSO complete, RBAC underway | Legacy integrations slowing rollout | Pilot in July`
- `Platform | 🟢 On Track | CI/CD migration finished | No major risks | Decommission old runners`
- `Security | 🔴 At Risk | Audit findings identified | Resource constraints | Remediation plan approval`
