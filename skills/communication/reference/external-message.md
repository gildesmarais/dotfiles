# External Message

Draft a customer, partner, or public-facing message with no internal jargon, no unconfirmed commitments, and a legal-safe tone.

## When to Use

Use this branch when the user wants to draft an email or support-ticket reply for:

- customers / end users
- partners / vendors
- the general public

This branch is for support/status-style messages, not marketing or press/PR copy.

## Output Rules

- Default to returning only the final message.
- Add improvement notes only if the user explicitly asks for them.
- No internal team, system, tool, or process names — describe from the reader's perspective.
- Never commit to unconfirmed dates, features, or fixes; use careful or conditional language when timing is not confirmed.
- Formal, legal-safe tone: no admissions of fault, no liability-implying language, no absolute guarantees.
- Acknowledge the reader's situation before explaining status.
- Close with a clear next step or contact point.
- Keep the message concise and scannable; prefer short paragraphs over walls of text.

## Writing Standard

Always:

- open by acknowledging the reader's request, issue, or context
- explain status in plain language the reader would use
- separate what is known from what is still under review
- state next steps the reader can expect, without inventing timelines
- offer a contact path or how to follow up

Avoid:

- internal names such as services, squads, ticket systems, or release trains
- absolute promises ("will be fixed by Friday", "guaranteed", "never happens again")
- admissions of legal fault or negligence
- blame directed at the reader, a partner, or another vendor
- casual filler or marketing enthusiasm
- oversharing internal process detail that does not help the reader act

## Preferred Phrasing

Prefer phrases such as:

- "Thank you for reaching out about..."
- "We understand this is disruptive / important because..."
- "Here is the current status..."
- "We are reviewing this and will follow up when we have a confirmed update."
- "If you need anything further, reply to this message / contact..."

Avoid phrases such as:

- "Our backend / Platform team / Jira ticket..."
- "This will definitely be fixed by..."
- "We apologize for our failure / negligence..."
- "As per our internal policy..."
- "Hope that helps!"

## Examples

Before:

`Sorry our Identity service broke SSO. The Platform squad is looking at AUTH-4421 and we guarantee a fix by Friday so you can keep integrating.`

After:

`Thank you for reporting the sign-in issue. We understand this is blocking your integration work. We have confirmed the problem on our side and are actively investigating. We will follow up as soon as we have a confirmed update and next steps. If you need anything further in the meantime, reply to this message.`

Commitment softening:

- `We will ship the feature next week.`
- `We are working on this and will share a confirmed timeline once it is available.`

Jargon removal:

- `The checkout microservice returned 503s after the canary on payments-v3.`
- `Checkout was briefly unavailable during a recent update. Service has been restored, and we are monitoring stability.`
