---
id: SKILL-02
title: Handoff skill
size: M
depends: SKILL-01
done: true
---

## Read
- docs/specs/2026-10-05-workdeck-0.1-design.md (sections 10.3, 11 and 12)
- docs/plans/2026-10-05-workdeck-0.1-plan.md (step 8.3, section B last row)
- reference/implement.md
- agents/reviewer.md

## Touch
- skills/handoff/SKILL.md (new)
- test/cases/60-skills.sh
- agents/reviewer.md (added during the card: the manual run showed its full-path and command-substitution calls being denied)

## Tests
- handoff runs the gates in order

## Acceptance
- The eight steps of spec section 10.3, with card lint, card touched and card tests in that order.
- The manual run confirms the reviewer launches as workdeck:reviewer, or records a finding.
- Without gh the skill stops after the push and prints the URL.

## Out of scope
- Merging, starting the next card.
