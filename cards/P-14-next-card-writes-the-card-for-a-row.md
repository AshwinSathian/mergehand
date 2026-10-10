---
id: P-14
title: next-card writes the card for a row
size: M
depends: P-07, P-09, P-10, P-11
done: false
---

## Read
- docs/design-0.2.md#102-workdecknext-card-id
- docs/design-0.2.md#7-planned-cards
- docs/design-0.2.md#41-the-plugin (the lines for next-card and reference/implement.md)
- docs/design-0.2.md#15-errors (the rows for a no, and for a row that cannot be done as cut)
- docs/design-0.2.md#18-risks (the first row)
- docs/design-0.2.md#19-claude-code-behavior-this-design-relies-on (rows 10 and 11)
- docs/development/review-0.2.md (finding 19)
- docs/development/spike-0.2.md (whether a session could write a card from a row alone)
- skills/next-card/SKILL.md
- skills/quick/SKILL.md (a card that is untracked until the yes)
- reference/implement.md
- test/cases/60-skills.sh

## Touch
- skills/next-card/SKILL.md
- reference/implement.md
- test/cases/60-skills.sh

## Tests
- test_next_card_writes_the_card_for_a_row_before_the_branch_exists
- test_next_card_fills_touch_tests_and_read_from_the_code
- test_next_card_leaves_the_row_item_under_read_as_it_was_written
- test_next_card_runs_lint_and_plan_check_before_it_asks
- test_next_card_deletes_the_card_file_after_a_no
- test_next_card_commits_the_approved_card_alone
- test_next_card_sends_the_user_to_revise_the_outline_when_a_row_cannot_be_done_as_cut
- test_implement_reference_says_the_approved_card_is_already_committed

## Acceptance
- Steps 1 to 5 of skills/next-card/SKILL.md are unchanged.
- Step 6 has a branch for a card whose `card show` output starts with `row:`, with the six steps of section 10.2 in that order.
- `Touch` is full paths taken from the code as read, with `(new)` on a file the card creates. `Tests` is one item per test, written as the innermost name the test will have, in the style of the tests it will sit beside.
- The first `Read` item, with its `(row ...)` comment, is left as `card plan start` wrote it. The skill says so, and says why: the reviewer checks the card against those headings.
- `Acceptance` and `Out of scope` start as the row's lines. The skill says to keep them unless they are wrong, and to add to them.
- `card lint` and `card plan check <id>` both run before the card is shown to the user.
- After a no, and when the row cannot be done as cut, the card file is deleted and no branch exists. In the second case the user is told to revise the outline with the plan skill.
- For a card written this way, step 7 creates the branch and commits the card file alone with the message `<id>: card as approved` before step 8.
- reference/implement.md, step 6, says the approved card of a planned card is already committed and that nothing else is committed before handoff.
- A card with a file starts as it did in 0.1: no step of this branch runs for it.
- The skill does not tell the model to invoke a skill, and every `card` command it names exists.
- Rows 10 and 11 of design section 19 were read again for this card. The session log gives the result for each.

## Out of scope
- `card plan start`, `card plan check` and the first line of `card show`. P-09, P-10 and P-07 own them.
- The stop hook's condition. P-11 owns it; without it the approval commit blocks the first turn.
- Handoff's part of the pull request body, and the reviewer's step. P-15 owns both.
- An approval commit for a quick card. docs/development/later.md has it.
- A changed budget for a card whose body is written in its session. Section 22, decision 6.

## Notes
- Claims are read again on the pages of section 19, through Context7 (`/websites/code_claude`) as the design did. The session log gives the date and the result for each row. If a claim no longer holds, the card stops with a `## Blocked` section; it does not edit the design.
- test_skills_name_only_card_commands_that_exist reads every `card <word>` inside a code span as a command. The message `<id>: card as approved` in backticks reads as the command `card as` and fails the case. Teach the case the exception, or write the message so it does not match; do not drop the backticks without saying so.
- test_implement_reference_says_not_to_commit must still pass. The reference still says not to commit; it adds that one commit already exists.
- test_skills_never_tell_the_model_to_invoke_a_skill: the plan skill is named as something the user types.
- In the spike a session that wrote a card from a row added a sub-heading to the `(row ...)` comment and an anchor to the path. Nothing checks this by script, on purpose: once a card exists it wins over its row (review finding 18). The user sees the card before the yes.
- That session could not see what the neighbouring rows own, except through the row's `not` lines. Where the session has to guess what a neighbour owns, it writes the guess under `Notes` and says it to the user with the card. That is not step 4 of section 10.2: the spike's session guessed this way and the row was still enough. Step 4 is for its two cases only, and a revision it causes is the hard stop of design section 14.
- The same reference is used by `/workdeck:quick`. Its text must stay true for a quick card, which has no approval commit.
- From P-11: step 6 of reference/implement.md says a commit made now blocks the end of every turn. That is no longer so for a commit that changes only the cards directory.
