# Conventional Comments

Mandatory format for every new inline review comment posted by `publish`. Use it for thread replies when the label clarifies the reply; concise conversational replies are allowed.

## Schema

```text
<label> (<decoration>, <decoration>): <subject>

<discussion>
```

Decorations and discussion are optional. When there are no decorations:

```text
<label>: <subject>

<discussion>
```

## Formatting rules

- Use a single lowercase label.
- Put optional lowercase decorations in parentheses, separated by comma + space.
- Keep the subject concise and actionable; it is the main message.
- Put supporting evidence, impact, reasoning, and next steps in the discussion after one blank line.
- Do not wrap the prefix in Markdown emphasis; preserve machine readability.
- Validate the first line against:

```text
^[a-z][a-z-]*( \([a-z-]+(, [a-z-]+)*\))?: .+
```

- Reject any comment that uses a `blocking` decoration.

## Approved labels

| Label        | Use when                                                                                                                |
| ------------ | ----------------------------------------------------------------------------------------------------------------------- |
| `issue`      | Concrete bug, regression, security/privacy problem, contract mismatch, or test gap that can let incorrect behavior pass |
| `suggestion` | Concrete improvement not required for correctness                                                                       |
| `question`   | Missing context whose answer can materially change the review conclusion                                                |
| `note`       | Verified context or constraint that helps the author but requires no action                                             |
| `nitpick`    | Very small polish; normally dropped by publish triage                                                                   |
| `praise`     | Specific recognition for an outstanding, elegant, unusually safe, or especially maintainable change                     |

## Approved decorations

| Decoration     | Use when                                                             |
| -------------- | -------------------------------------------------------------------- |
| `security`     | Authz, privacy, tenancy, secrets, or other security-relevant concern |
| `test`         | Missing or insufficient behavioral coverage                          |
| `performance`  | Material runtime or query-cost concern                               |
| `non-blocking` | Optional suggestion/nitpick intentionally safe to defer              |

Do **not** use `blocking`. Importance is communicated through finding severity and discussion while publishing a GitHub `COMMENT` review.

Severity (Critical / Important / Nice-to-Have) and Conventional Comments labels remain separate: severity controls whether the ledger publishes the finding; the label communicates what kind of comment it is.

## Examples

Undecorated issue:

```text
issue: unknown status silently returns the full register

Unrecognized `status` values fall through to `all`, so a client typo or meta-key mixup becomes an unfiltered listing. Prefer `422` for unknown values; only blank status should mean “no filter.”
```

Multiple decorations:

```text
issue (security, test): scope the lookup to the authorized tenant

The unscoped lookup accepts any record ID before policy evaluation, creating an IDOR path for authenticated users. Resolve the record through the policy scope and add a cross-tenant request spec.
```

Suggestion with non-blocking decoration:

```text
suggestion (non-blocking): extract the repeated permission lookup

This is duplicated across the two policies. A shared helper could reduce drift, but it does not need to hold up this PR.
```

Earned praise:

```text
praise: keeping the register read-only makes the trust boundary exceptionally clear

Separating support reads from the existing v3 mutation path avoids a second deletion entry point and makes the authorization model much easier to audit.
```

Reject:

```text
issue (blocking): fix the metric undercount
```

## Human touch

- Look actively for 0–2 genuinely outstanding choices: elegant boundary design, unusually strong tests, careful compatibility, clear failure handling, data minimization, or a simplification that removes risk.
- Publish `praise:` only when specific and earned. Explain what was done well and why it matters.
- Never use generic “looks good,” “nice work,” or praise as a buffer before criticism.
- Keep tone direct, collaborative, and written to a teammate. Prefer “This can…” / “Could we…” / “Please…” over robotic verdict language.
- Do not weaken concrete findings with excessive hedging. Human does not mean vague.
- Never manufacture praise to satisfy a quota. Zero praise comments is valid when nothing is exceptional.

## Thread replies

Use Conventional Comments when a reply introduces or sharpens a finding:

```text
issue (test): cover completed requests in the inventory metric

Agree this is a real regression — restore inventory `team_data_finished.count` to “any `team_data_finished_at` present.” Keeping `required_action:ready_for_archival` exclusive of completed is fine. Please add a completed-row example so the undercount cannot land again.
```

Do not force a label onto a simple disposition such as “Addressed in abc1234,” and do not post a bare “agree.”
