---
id: P-02b
title: card plan: ids and sizes
size: S
depends: P-02
done: false
---

## Read
- docs/design-0.2.md#111-card-plan (the rows Ids and Sizes)
- docs/design-0.2.md#5-outline-format (the rules for an id and for `size`)
- docs/design-0.2.md#16-trust-and-input-handling
- bin/card (the outline reader of P-02, sizes, valid_id, wt_cards)
- test/cases/35-plan.sh

## Touch
- bin/card
- test/cases/35-plan.sh (created by P-02)

## Tests
- test_plan_reports_a_malformed_row_id
- test_plan_reports_a_row_id_that_carries_a_letter
- test_plan_reports_a_row_id_with_another_prefix
- test_plan_reports_an_id_in_two_rows
- test_plan_reports_two_outlines_that_share_a_prefix
- test_plan_reports_the_prefix_q
- test_plan_reports_a_size_with_no_budget
- test_plan_reports_a_prefix_that_a_card_of_another_outline_uses

## Acceptance
- A row's id fails when it is malformed, carries a letter, does not start with the outline's prefix, or appears in two rows.
- Two outlines that share a prefix fail, and so does the prefix `Q`.
- A row's size fails when it has no budget in `workdeck.conf`.
- The checks run after the format check of P-02 and before those of P-03, in the order of the table in section 11.1.
- Every failure is printed with its file, and the exit code is 1.

## Out of scope
- The outline reader and the format check. P-02 owns them.
- Dependencies, Specification and Coverage. P-03 owns them.
- Checking that a removed id is not used again. Section 11.3 lists it as a limit no script checks; the plan skill carries the rule (P-13).

## Notes
- The file name rule means two outlines can share a prefix only when one of them also breaks that rule. The check is still in the table; keep both messages.
- This card was cut from P-02 after the review of the deck: 21 tests in one card was twice the largest card of 0.1.
