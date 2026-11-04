# Review

Others' PRs (`review-requested`). Operator approves/merges by hand, never agent.

1. Spawn read-only strongest/high Hand (`Task`, ≤12 turns) loading `review.gil`
   `findings` on URL. Scratch → `/tmp/ops-github/<id>.log`. Return Findings +
   Readiness (≤12 lines). Brief/tiers:
   [`../../brain/reference/orchestrate.md`](../../brain/reference/orchestrate.md).
2. Verdict + AskQuestion for per-PR OK before GitHub write:
   - `<repo#n> — "<title>" · Ready for human review` when mergeability is
     positive (`Readiness: Yes`, 0 Critical/Important, CI green); operator
     approves by hand.
   - `<repo#n> — "<title>" · Follow-up (<Readiness>)` else (blockers/unrun gates).
3. On OK: submit `COMMENT` review (\`\`\`suggestion blocks; `pull-request`
   `comment` / host APIs; never `APPROVE`/`/approve`).
4. Unrun gate → AskQuestion; never guess green.
5. Record `ops-github ledger decide <id> done|deferred`.

Budget: `budgets.review` Hands/wake; security-matrix stays frontier.
