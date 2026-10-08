---
id: P-15
title: Reviewer step for a planned card, and handoff's approved-card diff
size: S
depends: P-09, P-14
done: false
---

## Read
- docs/design-0.2.md#122-reviewer
- docs/design-0.2.md#104-workdeckhandoff
- docs/design-0.2.md#14-trial-and-release (the measure read from the pull request body)
- docs/development/review-0.2.md (finding 19, and the third pass row on the reviewer's step)
- docs/design.md#11-mechanical-gates (why a `Touch` addition used to show in the diff)
- agents/reviewer.md
- skills/handoff/SKILL.md
- test/cases/60-skills.sh (test_handoff_runs_the_gates_in_order)

## Touch
- agents/reviewer.md
- skills/handoff/SKILL.md
- test/cases/02-plugin.sh
- test/cases/60-skills.sh

## Tests
- test_reviewer_checks_a_planned_card_against_its_specification_headings
- test_handoff_prints_the_changes_to_the_card_since_it_was_approved

## Acceptance
- agents/reviewer.md has one more step. When a `Read` item of the card has a comment that starts with `(row `, the item is a specification and the comment names headings in it.
- The step lists each requirement under those headings that no `Acceptance` item covers and no `Out of scope` item excludes. Each is a `should-fix` finding.
- For a card with no such item the reviewer does what it did in 0.1.
- Step 7 of skills/handoff/SKILL.md has one addition. When the card's branch has an `<id>: card as approved` commit, the pull request body gains a part headed "Changes to the card since it was approved".
- That part is the output of `git diff <that commit> HEAD -- <card file>`, leaving out the `done` line.
- For a branch with no such commit, the body is what it was in 0.1.
- Split mode is unchanged, and handoff does not edit an outline.
- test_reviewer_agent_is_read_only and test_handoff_runs_the_gates_in_order pass unchanged.

## Out of scope
- The commit that this reads. P-14 owns it.
- `card plan` as a handoff gate. Section 22, decision 3, says no.
- The quick skill. Section 10.4 says it does not change.
- templates/pull_request_template.md. The design does not list it as changed.

## Notes
- The same trap as P-14: `<id>: card as approved` in a code span reads as the command `card as` in test_skills_name_only_card_commands_that_exist, which also reads agents/*.md. Follow what P-14 did.
- Handoff commits in step 7, so "HEAD" in the diff is the commit handoff has just made. Say in the skill at which point the diff is taken.
- This is the review of a card body by an agent that did not write it. It comes after the work, which section 12.2 names as the cost of writing bodies just in time.
