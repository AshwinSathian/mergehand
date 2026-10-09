---
id: Q-2610091341
title: Amend the design and the deck from the spike
size: XS
depends:
done: true
---

## Read

## Touch
- docs/design-0.2.md
- docs/development/scope-0.2.md
- docs/development/review-0.2.md
- docs/development/spike-0.2.md
- docs/development/README.md
- test/cases/02-plugin.sh

## Tests
- test_review_record_answers_what_the_spike_asked_for

## Acceptance
- Each item under "What this means for the deck" in docs/development/spike-0.2.md has a row in the fifth pass of docs/development/review-0.2.md that says what was done, why it was turned down, or that nothing changes.
- The design and cards P-12, P-13, P-14 and P-21 carry what was accepted.
- No file under bin/, hooks/, skills/, agents/, templates/ or reference/ changed.

## Out of scope
- skills/plan/SKILL.md and agents/plan-reviewer.md. P-13 and P-12 write them.

## Notes
- The cards amended are under cards/, which the scope gate skips.
