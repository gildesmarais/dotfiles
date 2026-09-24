# Conventional Comments

Mandatory for every new inline comment from `publish`; for thread replies only when the label clarifies (plain dispositions like "Addressed in abc1234" stay unlabeled).

```text
<label> (<decoration>, <decoration>): <subject>

<discussion>
```

- One lowercase label; optional lowercase decorations in parens, comma+space separated. Subject = concise actionable message; evidence, impact, next steps go in discussion after one blank line. No Markdown emphasis on the prefix.
- First line must match `^[a-z][a-z-]*( \([a-z-]+(, [a-z-]+)*\))?: .+`.
- Reject any `blocking` decoration — importance lives in severity and discussion. Severity decides whether to publish; the label says what kind of comment it is.

Labels: `issue` (bug, regression, security/privacy, contract mismatch, test gap letting wrong behavior pass) · `suggestion` (non-required improvement) · `question` (answer could change the conclusion) · `note` (verified context, no action) · `nitpick` (normally dropped) · `praise` (specific, outstanding).

Decorations: `security` · `test` · `performance` · `non-blocking` (safe to defer).

```text
issue (security, test): scope the lookup to the authorized tenant

The unscoped lookup accepts any record ID before policy evaluation, creating an IDOR path for authenticated users. Resolve the record through the policy scope and add a cross-tenant request spec.
```

## Tone

- `praise:` only when specific and earned (boundary design, strong tests, careful compat, failure handling, data minimization, risk-removing simplification) — say what and why. Zero is valid; never generic "looks good" or praise as a cushion.
- Teammate voice ("Could we…", "Please…"), direct, no excessive hedging.
