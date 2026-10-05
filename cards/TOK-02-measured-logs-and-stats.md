---
id: TOK-02
title: Measured fields in log-new and card stats
size: S
depends: TOK-01
done: true
---

## Read
- docs/specs/2026-10-05-workdeck-0.1-design.md (sections 7, 9, 13 and 14)
- docs/plans/2026-10-05-workdeck-0.1-plan.md (step 5.2)
- bin/card (cmd_log_new, cmd_tokens)

## Touch
- bin/card
- test/cases/34-log.sh
- test/cases/41-stats.sh (new)

## Tests
- log new records measured tokens
- log new records compaction from the marker
- log new ignores a hostile session id
- stats reports median and maximum per size
- stats leaves unknown out of the median

## Acceptance
- card log-new writes baseline, peak and growth from WORKDECK_TRANSCRIPT, or unknown.
- compacted is true when <git-dir>/workdeck/<session>.compacted exists, false when it does not, unknown without WORKDECK_SESSION.
- card stats prints, per size, sessions, budget, median growth, maximum growth and the share that compacted.

## Out of scope
- Suggesting new budgets from the numbers.

## Notes
- The session id is used in a file name, so it must match ^[A-Za-z0-9_-]+$ first.
