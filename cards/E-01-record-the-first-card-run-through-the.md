---
id: E-01
title: Record the first card run through the real loop
size: S
depends:
done: true
---

## Read
- log/2026-10-06-DOC-02-1.md
- docs/evidence.md
- README.md

## Touch
- docs/evidence.md
- docs/development/README.md
- README.md
- CHANGELOG.md
- test/cases/02-plugin.sh
- bin/card (added during the card: a branch-only card showed as done while its pull request was open; found when this card was handed off)
- test/cases/20-base.sh (the test for that)
- test/cases/22-fetch.sh (the test for that)
- docs/design.md (section 6 and 19.2 item 35 for that)

## Tests
- plugin manifest names the license
- evidence names the first pull request
- base branch only card is not done after handoff
- fetch branch only card with open pull request is review

## Acceptance
- docs/evidence.md gives the figures from the DOC-02 session log and links pull request 1.
- The README and the development index say that one card went through the full loop against the hosted repository, and no longer say that none did.
- The license test checks a four-digit year and does not depend on the line number of the SPDX line.
- The changelog entry for 0.1.0 has a date.

## Notes
- This card is itself handed off as a pull request, so the review state can be observed against the real host.
