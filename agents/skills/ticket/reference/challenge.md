# Challenge

Review an incoming ticket before anyone builds it. Writes no code; posts to the tracker only after the operator's per-ticket OK.

1. **Fetch** per `SKILL.md` Shared prep. Read the code the ticket names, enough to test its claims.
2. **Gate:** run `product-owner` `gate` on the ask ([`../../product-owner/reference/gate.md`](../../product-owner/reference/gate.md)). Pure bug, refactor, or infra skips it — verdict `Fix`.
3. **Challenge** — at most five gaps, highest cost first, each one question the reporter can answer:
   - AC: observable and testable, or only intent?
   - Scope: one slice, or several stories (→ `story-slice` on Build Now)?
   - Evidence: repro, logs, or metric behind the claim; does the code agree?
   - Risk: security, data, or rollout cue; dependency on another team or ticket.
   - Cheaper path: config, existing feature, or a smaller first slice.
4. **Report** to the operator: verdict line, then the gaps.
5. **Draft** a ticket comment per [`../../communication/reference/outward-text.md`](../../communication/reference/outward-text.md): verdict, the questions, nothing else. AskQuestion for OK, edit, or skip; on OK post it via the adapter. Never change status here.

Next: Build Now or `Fix` with operator go → **implement**; else stop.

Done when: verdict and gaps reported; comment posted or skipped by the operator.
