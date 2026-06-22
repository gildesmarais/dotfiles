---
name: message-refinement-tech-orga
description: Use when refining rough notes, draft Slack messages, bullet points, or internal announcements into an internal Slack message for engineering, product, technology, or cross-functional stakeholders in a tech organization.
---

# Message Refinement Tech Orga

Refine rough internal communication into Slack-ready messages for a technology organization.

## When to Use

Use this skill when the user wants to turn notes, bullets, or a rough draft into a clearer message for:

- engineering teams
- product owners or product managers
- technology leadership
- cross-functional stakeholders
- chapters, guilds, or department-wide audiences

Do not use it for:

- external marketing copy
- public PR statements
- long-form documentation
- a fixed-format project status line that should be comparable across projects
- summarizing a topic without drafting the actual message

## Output Rules

- Default to returning only the final Slack-ready message.
- Add improvement notes only if the user explicitly asks for them.
- Optimize for Slack scanning with short paragraphs, bullets, and light headings where useful.
- Keep the tone calm, deliberate, and professional.
- Preserve the user's underlying intent, ask, and audience unless they explicitly ask for repositioning.
- When the user is preparing an escalation or decision request, default to a message that asks for the decision directly rather than offering to prepare more material.
- Default to a soft, compact closing such as "Thanks in advance. Please reply here if you have a preference or concerns." unless the user asks for a stronger ask.

## Sensitive Internal Messages

Apply the following posture when the message is for line managers, leadership, escalations, blockers, policy friction, or other politically sensitive internal communication:

- open with context and operational intent before stating the problem
- frame the issue as a delivery, coordination, policy, or operational constraint before mentioning any team or role
- use alignment, confirmation, or decision asks instead of directive asks
- preserve the substance of the user's point, but remove wording that reads like an order, accusation, or status assertion
- explain why the issue matters before or alongside the ask
- keep the language clear and direct without adding vague hedging
- use direct attribution only when the user explicitly asks for sharper ownership language

## Message Structure

When the message is substantial enough to need structure, organize it in this order:

1. Context
2. What is changing
3. Why it is changing
4. Impact / expectations
5. Next steps

For short announcements or direct asks, compress this structure rather than forcing every section explicitly.

## Writing Standard

Always:

- lead with why the message is being sent
- explain the business or operational intent, not just the rule or update
- name the accountable role when appropriate, such as CTO, VP Engineering, Engineering Leadership, Product Leadership, or Technology Leadership
- state who is affected, what changes, what stays the same, and what action is expected
- translate policy or process into day-to-day interpretation
- end with clear next steps, timing, documentation, or contact points
- if the message asks for a decision, make the decision needed explicit and name the delivery risk if no decision is made
- prefer direct business phrasing such as "running short on suitable candidates" or "risk of rollout stall" over vaguer wording like "may impact progress"

Avoid:

- vague ownership such as "we decided" or "it was agreed"
- corporate filler, buzzwords, or marketing tone
- excessive enthusiasm or casual filler
- walls of text
- defaulting to "If helpful, I can..." closes unless the user explicitly wants to offer follow-up material
- commanding openings such as "Need you to..." or "You should..."
- person-first blame framing when system-first framing would preserve the point
- escalation language that names failure or resistance before naming the delivery or operational consequence

## Audience Guidance

Assume a scale-up technology organization with mixed technical and non-technical readers. Respect technical audiences by using concrete language, operational clarity, and explicit expectations.

When communicating standards, governance, capacity expectations, compliance work, or operational changes, frame them in terms of delivery predictability, sustainability, risk reduction, product quality, operational excellence, or customer outcomes.

## Preferred Phrasing

Prefer phrases such as:

- "Following up from..."
- "To support..."
- "Going forward..."
- "This means..."
- "Teams should..."
- "The expectation is..."

Avoid phrases such as:

- "Just a quick note..."
- "Exciting announcement..."
- "Please be advised..."
- "As everyone knows..."
- "Hope this makes sense."

## Sensitive Message Patterns

Prefer patterns such as:

- opening frame: "To keep <goal> on track, I want to align on..."
- blocker framing: "The current dependency/decision/policy is creating a rollout or coordination constraint..."
- ask phrasing: "Can you confirm whether..." or "I'd like to align on..." or "Could you decide between..."
- consequence phrasing: "Without this decision, we risk..." or "If this stays unresolved, the next milestone is at risk..."

Prefer these patterns over:

- opening frame: "We have a problem with..." or "You need to..."
- blocker framing: "Team X is blocking this..." when an operational framing would preserve the point
- ask phrasing: "Please do X by Friday" unless the user explicitly wants a directive
- consequence phrasing: "This is unacceptable" or other status-heavy language without operational context

## Decision Requests

When the input is about a blocker that needs leadership action:

- lead with the decision needed
- summarize current progress in 2-5 compact bullets
- name the blocker in operational terms
- present options only if they are already part of the user's input
- close with the consequence of delay and a soft request to reply in-thread

## Examples

Before:

`We need a decision from line managers now. The current behavior is blocking rollout and the team cannot keep waiting. Please confirm today.`

After:

`To keep the rollout on track, I want to align on the decision path for manager approval. The current dependency is slowing rollout planning for the next batch. Can you confirm today whether we should proceed with option A or B? Without that decision, the next rollout window is at risk.`

Directive ask to alignment ask:

- `Please approve this today so the team can move on.`
- `Can you confirm today whether you are comfortable approving this so the team can plan the next step?`

Behavioral blame to operational framing:

- `Line managers are blocking the change because they are not engaging.`
- `The change is currently gated by manager alignment, which is slowing the rollout decision for the next phase.`
