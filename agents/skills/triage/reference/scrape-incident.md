# Scrape incident playbook

Signals: Botasaurus, scrape-api, `challenge_block`, `timeout/work`, fail-closed scrape UX, SoundCloud-shaped hostile hosts. Never re-grill these locks unless new evidence contradicts them.

## Locks

| Lock            | Value                                                                                                      |
| --------------- | ---------------------------------------------------------------------------------------------------------- |
| Outcome         | (1) honest `BLOCKED_SURFACE` UX **+** (2) stop timeout false-hope when challenge is knowable               |
| Mechanism       | **A** — classify `challenge_block` before burning work into `timeout`                                      |
| User words SSOT | `html2rss-web` `ErrorClassifier::Decision#message`                                                         |
| Journey SSOT    | Existing Feed Flow / `decideJourney` kinds — no new journey states                                         |
| Rejected        | Bypass, cookie/session UI, raise timeout ladders, soften-all-timeouts, Decision→COPY remap, host denylists |

## Shots

- **Shot 1** (`triage` → PO and/or `$dev` `plan`): Sentry → local reproduce → ledger → admit/plan.
- **Shot 2** (`$dev` `implement`, after approval): Phase A scrape-api fail-faster → Phase B web copy/chrome → Phase C journey matrix → `review.gil` **quality** per PR.

Triage names Shot 2 in ledger **Next** / Residuals; never executes implement or Assure.

## Default class

`both` when prod shows timeout false-hope **and** create UX needs fail-closed copy; `eng` when only scraper classification/queue is wrong and wire Decision is already honest.
