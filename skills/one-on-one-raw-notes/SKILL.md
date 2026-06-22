---
name: one-on-one-raw-notes
description: Use when summarizing raw one-on-one markdown notes, especially when they include speaker direction, blockquotes, Q/A markers, shorthand, or fragmented note-taking syntax.
---

# One-on-One Raw Notes

Turn raw 1:1 notes into a small, speaker-aware summary that is easy to scan later.

## When to Use

Use this skill when the user wants a compact summary distilled from:

- raw one-on-one notes
- markdown notes with blockquotes
- shorthand or fragmented note-taking
- `Q:` / `A:` markers
- speaker-directed notes where who said what matters

Do not use it for:

- project status updates meant to be comparable across projects
- drafting a Slack message or announcement
- long-form meeting minutes
- retrospective summaries across many participants
- polished stakeholder communication

## Output Rules

- Default to returning only the final summary.
- Keep the result small and scannable, usually `4-6` bullets total.
- Default to one flat bullet list rather than grouped sections.
- Do not use `Asked`, `Said`, `Takeaways`, `you`, or `they` labels by default.
- Preserve speaker attribution when it changes meaning.
- Preserve direction indirectly through phrasing when needed, for example by framing a point as a question, concern, preference, or observation.
- Lightly clean up shorthand, fragments, and typos into readable bullets.
- Do not rewrite the notes into paragraphs by default.
- Do not invent certainty when attribution or meaning is ambiguous.

## Steno Notation

Interpret the raw markdown using these direction rules:

- `>` means the other person said or asked the content.
- unquoted lines are the note taker's side unless the text clearly indicates otherwise.
- `Q:` marks a question.
- `A:` marks an answer.
- quoting overrides bare `Q:` / `A:` direction, so `> Q:` means the other person asked the question.
- indented follow-up lines belong to the item immediately above unless the notes clearly break context.
- shorthand, fragments, and misspellings should be normalized lightly for readability without changing intent.
- if a line is too ambiguous to attribute confidently, keep the wording conservative rather than forcing speaker certainty.

## Distillation Standard

- Prefer the few points most useful for recalling the conversation later.
- Keep both content and attribution compact.
- Merge repeated fragments into one clean bullet when they clearly describe the same point.
- Preserve unresolved questions, concerns, or process friction when they appear central.
- Summarize questions as open points, concerns, or topics to clarify.
- Summarize statements as observations, preferences, constraints, or takeaways.
- If no clear takeaway exists, do not fabricate one.

## Examples

Input:

```markdown
> Q: how should access requests work once the team grows?
> what happens if the approver is away?

Q: Where does delivery usually slow down the most?

> usually around incidents / response quality matters a lot
> test environments are close enough to miss issues until later stages
> differences between review and staging slow things down
> dependencies across services make rollout coordination harder
> release alignment takes time
```

Output:

- Questions around how access requests should work as the team grows, including fallback when an approver is unavailable.
- Delivery seems to slow down most around incidents and response quality.
- Incident handling quality has a major effect on operational speed.
- Differences between review and staging make issues harder to catch early and slow delivery.
- Cross-service dependencies and release alignment add coordination overhead.

Input:

```markdown
> worried about handoffs between product / eng
> unclear owner once incident spans teams
> Q: where is the biggest confusion?
> usually after first escalation
```

Output:

- Biggest confusion appears during cross-team incidents after the first escalation.
- Handoffs between product and engineering feel weak.
- Ownership often becomes unclear once an incident spans teams.

Input:

```markdown
A: prefers smaller rollouts
A: wants clearer success signal
```

Output:

- Prefers smaller rollouts.
- Wants a clearer signal for rollout success.
