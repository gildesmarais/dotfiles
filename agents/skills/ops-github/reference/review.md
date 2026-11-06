# Review

Others' PRs (`review-requested`). Operator approves/merges by hand, never agent.

1. Spawn read-only strongest/high Hand (`Task`, ≤12 turns) loading `review.gil`
   `findings` on URL. Scratch → `/tmp/ops-github/<id>.log`. Return Findings +
   Readiness (≤12 lines). Brief/tiers:
   [`../../brain/reference/orchestrate.md`](../../brain/reference/orchestrate.md).
2. Digest row (`tick.md`): class, `repo#n`, title, author, head → base, URL,
   readiness, human step. AskQuestion buttons only:
   `N. <class> — <repo#n> — <url>` plus the line below.
   - Ready (`Readiness: Yes`, 0 Critical/Important, CI green) → `You merge`.
   - Else `Follow-up (<Readiness>)` → the blocker.
3. On OK: `COMMENT` review (\`\`\`suggestion; `pull-request` `comment`; never
   `APPROVE`). Tell `<repo#n> — <url>`, review URL, human step.
4. Unrun gate → AskQuestion; never guess green.
5. Record `ops-github ledger decide <id> done|deferred`.

Budget: `budgets.review` Hands/wake; security-matrix stays frontier.
