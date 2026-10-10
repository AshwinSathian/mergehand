---
id: P-23
title: Trial record: ten planned cards in the evidence page
size: M
depends: P-22
done: false
---

## Read
- docs/design-0.3.md (the first trial specification; it must be on the base branch)
- docs/design-0.2.md#14-trial-and-release
- docs/design-0.2.md#2-goals-and-non-goals (goal 6)
- docs/design-0.2.md#18-risks
- docs/design-0.2.md#22-decisions-locked-and-what-is-deferred (decision 1)
- docs/development/scope-0.2.md (the section "How we will know it works")
- docs/evidence.md (the trial section that P-22 wrote)
- log/ (the session logs of the trial cards)

## Touch
- docs/evidence.md
- docs/development/README.md
- test/cases/02-plugin.sh

## Tests
- test_evidence_records_the_trial_of_the_planner

## Acceptance
- Ten planned cards were implemented and merged across the two trial repositories before this card started. If fewer were, the card stops with a `## Blocked` section.
- For each of the ten, docs/evidence.md has every measure of the table in design section 14, read from the place that table names.
- The two repositories' figures are in separate tables.
- The page gives, for each plan run, its growth and the outline findings with what was done about each, from the plan pull request's body.
- The page says how many of the ten were S and how many M, and says in words whether goal 6 was met.
- The page says whether any row had to be cut again before its card could be written. If one was, the page says the release waits, and for what.
- The page says whether either trial repository's CI, on `card lint` 0.1.3, failed on a planned deck.
- The page says which case of section 22, decision 1, holds on the main branch: no reachable half of a 0.3 feature, or one, named.
- The page states no threshold and no verdict. The maintainer reads the record and decides whether to tag.
- Every figure on the page can be traced to a pull request, a session log or a command, and the page says which.
- Every fault that P-21 listed is closed by a merged card, or is listed on the page as open.

## Out of scope
- The version, the tag, and the decision to release. P-24 carries it.
- A change to the plan skill, the outline format or any check because of what the trial showed. Each is a card of its own, written after the maintainer has read the record.
- New default budgets. Section 22, decision 6: the trial's figures decide, in a later card.
- The README's Evidence section. A quick card after the tag decision.

## Notes
- The second repository may be private. Then its figures are from its logs and cannot be checked from outside; say so, as the page does for the quick-card run of 0.1.
- The measure "files added to `Touch` after approval" is read from the part of each pull request body that handoff writes (P-15). If a body lacks it, `git diff <approval commit> HEAD -- <card file>` on the merged branch gives the same.
- With ten cards no count carries a threshold: a planner that misses a file on half its cards passes a "more than half" test 62 times in 100. Do not write one into the page.
- From the second review of P-15 (`docs/development/review-0.2.md`, eighteenth pass): a card that had a review-fixes session has the part as its first handoff wrote it. Handoff does not write the body again, so a `Touch` line added while fixing review comments is missing from it. For such a card read `git diff <approval commit> HEAD -- <card file>` on the merged branch, not the body.
