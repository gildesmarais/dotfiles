---
name: finish-review
description: Production-readiness review for a git branch at the end of delivery. Use when user asks for production quality, readiness, finishing, or a senior/principal review; includes mandatory diff vs default branch and risk/compliance posture.
---

# Finish Review

## Overview

Deliver a production-finish review for a git branch by comparing to the default branch, assessing risks, and producing a structured, decision-ready report.

## Workflow

1) Establish scope and assumptions
- Identify repo root, target branch, and default branch.
- Read `AGENTS.md` if present and follow repo-specific rules.
- Capture explicit assumptions and missing context.

2) Understand changes vs default branch (mandatory)
- Path resolution sanity check: confirm `${CODEX_HOME:-$HOME/.codex}/skills/finish-review/scripts/compare_default_branch.sh` exists and is executable before invoking it.
- Run the skill-local script (not repo-local):
  - ```${CODEX_HOME:-$HOME/.codex}/skills/finish-review/scripts/compare_default_branch.sh```
- If the script is unavailable, run this fallback directly in the repo:
  - `git rev-list --left-right --count origin/$(git remote show origin | awk '/HEAD branch/ {print $NF; exit}')...HEAD`
  - `git --no-pager diff --stat origin/$(git remote show origin | awk '/HEAD branch/ {print $NF; exit}')...HEAD`
  - `git --no-pager diff --name-status origin/$(git remote show origin | awk '/HEAD branch/ {print $NF; exit}')...HEAD`
- Summarize:
  - commits ahead/behind
  - diffstat and file list
  - high-risk areas to inspect first

3) Review in priority order (non-negotiable)
- Production readiness
- Industry-standard patterns
- Maintainability and ownership transfer
- Risk identification and due diligence
- Compliance posture clarity

4) Apply the review workflow
- Assess architecture, boundaries, responsibilities.
- Evaluate code quality, failure modes, edge cases.
- Validate config, logging, security, and ops concerns.
- Enumerate risks, debt, limitations, and compliance gaps.

5) Use the autonomous review loop until convergence or blocked
- Scan -> Evaluate -> Decide -> Document -> Re-check.
- Stop only when Critical is empty and Important has owners or rationale.

## Output format (required)

**Findings**
- Categorize as Critical / Important / Nice-to-Have.
- Each finding includes impact and recommended action.

**Non-Goals**
- List explicit exclusions and intentionally unaddressed areas.

**Confidence & Uncertainty**
- Separate known facts from inferred or unverified items.

**Compliance & Risk Posture**
- What would pass review.
- What would be flagged.
- Minimum viable remediation or compensating controls.

**Executive Summary**
- Production readiness: Yes / No / Conditional.
- Top risks.
- Immediate actions.

## Guardrails

- Do not add features or redesign unless current design creates material risk.
- Prefer proven, conventional solutions.
- Optimize for clarity over novelty.
- Treat undocumented behavior as a defect.
- If deviating from standards, write explicit justification.

## Resources

### scripts/
- `compare_default_branch.sh`: detect default branch and summarize diff vs current branch.
