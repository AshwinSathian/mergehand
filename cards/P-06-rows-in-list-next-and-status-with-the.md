---
id: P-06
title: Rows in list, next and status, with the remainder rule
size: M
depends: P-02
done: false
---

## Read
- docs/design-0.2.md#6-rows-in-the-deck
- docs/design-0.2.md#16-trust-and-input-handling (the first two items)
- docs/design-0.2.md#22-decisions-locked-and-what-is-deferred (decision 5)
- docs/design-0.2.md#8-configuration-and-compatibility (rows 1 and 3 of the table)
- docs/design.md#6-state-model
- docs/development/review-0.2.md (finding 11)
- bin/card (META_AWK, wt_meta, base_cards, base_done, card_branches, has_blocked, deck_table, cmd_next, cmd_list, cmd_status, the outline reader of P-02)
- test/cases/21-state.sh

## Touch
- bin/card
- test/cases/24-rows.sh (new)
- test/lib.sh

## Tests
- test_row_with_no_card_file_is_listed_with_its_size_and_title
- test_list_marks_a_row_that_has_no_card_file
- test_next_marks_a_row_that_has_no_card_file
- test_row_is_ready_when_its_dependencies_are_done
- test_row_is_waiting_when_a_dependency_is_not_done
- test_row_waits_for_a_split_remainder_of_its_dependency
- test_card_with_a_file_does_not_wait_for_a_remainder
- test_row_with_a_card_branch_is_active
- test_row_with_a_blocked_card_on_its_branch_is_blocked
- test_row_with_an_open_pull_request_is_review
- test_card_file_wins_over_the_fields_of_its_row
- test_outline_in_the_working_tree_wins_over_the_base_branch_copy
- test_rows_come_from_the_base_branch_when_the_working_tree_has_no_outline
- test_status_names_a_row_as_next_ready
- test_row_title_is_filtered_as_a_card_title_is
- test_list_never_prints_the_does_not_or_spec_lines_of_a_row

## Acceptance
- A row whose id has no card file on the base branch or in the working tree is a card with the row's title, size and dependencies and `done: false`.
- Its state is computed by the table of docs/design.md section 6, with one difference: it is `ready` only when each dependency is done and every card whose id is that dependency's id plus a letter is done too.
- The remainder rule applies to rows only. A card with a file keeps the 0.1 rule.
- A row with a `card/<id>` branch is `active`, `blocked` or `review` by the rules that already exist.
- Once the card file is on the base branch or in the working tree, the row's fields are ignored and the card's are used.
- `card list` and `card next` print `[row]` after the title of a row that has no card file.
- `card list`, `card next` and `card status` print a row's id, size and title only, filtered as a card's are.
- Outlines are read per file: the working tree's copy if there is one, otherwise the base branch's.
- In a repository with no outline, every case of test/cases/14-list.sh, test/cases/21-state.sh and test/cases/23-status.sh passes unchanged.

## Out of scope
- `card show` for a row. P-07 owns it.
- The comparison with the output of `card` 0.1.2. P-08 owns it.
- `card lint` for a card that depends on a row. It fails in 0.1.2 and it fails in 0.2; lint does not change.
- Any change to how a card with a file gets its state.

## Notes
- deck_table is where the set of cards is built. Rows join it there, so `list`, `next` and `status` need no change of their own beyond the `[row]` mark.
- `card status` is printed by the session-start hook and has a cap on its length (status_max_chars). A row must not make it read an outline twice or call git once per row: finding 4 measured about 17 ms for each `git ls-tree`.
- The `[row]` mark comes after the title, so the columns before it stay where 0.1 has them.
