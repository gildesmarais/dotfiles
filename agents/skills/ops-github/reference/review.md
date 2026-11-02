# Review

Others' PRs only (`review-requested`). Never approve or merge.

1. Spawn a read-only strongest / high Hand (`Task`, timebox ≤12 turns) loading
   `review.gil` `findings` on the URL. Scratch → `/tmp/ops-github/<id>.log`.
   Return Findings + Readiness only (≤12 lines to chat). Hand brief / tiers:
   [`../../brain/reference/orchestrate.md`](../../brain/reference/orchestrate.md).
2. Show a one-line verdict. AskQuestion for per-PR OK before any GitHub write.
3. On OK: submit a `COMMENT` review (not approve). Prefer \`\`\`suggestion
   blocks. Use `pull-request` `comment` / host review APIs; never `/approve`.
4. If a local gate can't run, AskQuestion — do not guess green.
5. Record `ops-github ledger decide <id> done|deferred` after the outcome.

Budget: ≤4 review Hands per wake (`budgets.review`); overflow carries.
Security-matrix hits stay frontier tier.
