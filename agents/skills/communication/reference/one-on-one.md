# One-on-One

Raw 1:1 notes (markdown, blockquotes, shorthand, `Q:`/`A:`/`q:` markers) → post-meeting summary the note taker sends to the other person so both can verify what was said.

## Output

- Two-person voice: **I** = note taker, **You** = other person; both must recognize themselves.
- One flat bullet list, one bullet per question/topic, no cap, no grouped sections or paragraphs. Completeness beats brevity — drop nothing substantive; merge only fragments that restate the same point.
- Bullets typically open with the note taker's action ("I asked about X.", "I showed Y.", "I offered Z.") then the response. Keep the note taker's own remarks, offers, and asks as "I …".
- Other person: "You: …" for multi-part answers; woven prose ("You'll …", "You want …", "You think …") for single points.
- Keep unresolved questions, concerns, commitments, and process friction inline. No editorializing, invented certainty, or fabricated takeaways.
- Fix shorthand and typos in ordinary words only ("mentatilty" → "mentality"). Carry proper nouns, ticket IDs, and codenames verbatim — never expand, explain, or "correct" them.

## Steno notation

- Any line whose marker chain contains `>` → other person (**You**). Lines without `>` — including `-` sub-points indented under their answers — → note taker (**I**).
- `> Q:` = other person asked; bare `Q:`/`q:` = note taker asked. `A:` = note taker's answer; `> A:` = other person's.
- Indented follow-ups belong to the item above unless context clearly breaks.
- Genuinely unclear attribution → "we discussed X". Wrong attribution in a shared note is worse than vague.

## Example

Input:

```markdown
Q: noshow on quarterly leadership sync?

> took part in the beginning
> catched up via meeting notes
> Q: project-northstar - we had team meeting last week to align on approach. are next steps clear?
> is clear.
> work started.
> sync with alex

- tickets are high level, align before work early i.e. in deep dive
- great to see stacked PRs of the PRJ-204 already up
  > AI topic: thinks best is tool-alpha right now, tool-beta. switched thru some tools.
  > I replied it's great example for info sharing, accessibility needs some work
```

Output:

- I asked about the no-show at the quarterly leadership sync. You took part at the beginning and caught up via meeting notes.
- I asked whether next steps on project-northstar are clear after last week's team alignment. You: it's clear, work has started, and you'll sync with Alex. I noted that tickets are high-level, so align before work starts — e.g. in a deep dive. Great to see stacked PRs for PRJ-204 already up.
- You on AI: tool-alpha feels best right now, then tool-beta; you've switched through some tools. I replied that it's a great example of info sharing; accessibility still needs work.
