# Conventional Comments

Mandatory for every new inline comment from `publish`; for thread replies only when the label clarifies (plain dispositions like "Addressed in abc1234" stay unlabeled).

```text
<label> (<decoration>, <decoration>): <subject>

<discussion>
```

- One lowercase label; optional lowercase decorations in parens, comma+space separated. Subject = concise actionable message; evidence, impact, next steps go in discussion after one blank line. No Markdown emphasis on the prefix.
- First line must match `^[a-z][a-z-]*( \([a-z-]+(, [a-z-]+)*\))?: .+`.
- Reject any `blocking` decoration — importance lives in severity and discussion. Severity decides whether to publish; the label says what kind of comment it is.

Labels: `issue` (bug, regression, security/privacy, contract mismatch, test gap) · `suggestion` · `question` · `note` · `nitpick` (normally dropped) · `praise` (specific, outstanding).

Decorations: `security` · `test` · `performance` · `non-blocking` (safe to defer).

## Tone

- `praise:` only when specific and earned — say what and why. Zero is valid; never generic "looks good".
- Teammate voice ("Could we…", "Please…"), direct, no excessive hedging.
