---
id: P-09
title: card plan start
size: S
depends: P-06
done: true
---

## Read
- docs/design-0.2.md#7-planned-cards (the first list)
- docs/design-0.2.md#9-the-card-command (the row for `card plan start`)
- docs/design-0.2.md#15-errors (the row for `card plan start`)
- docs/design-0.2.md#122-reviewer (the reviewer's step fires on the comment this command writes)
- docs/design-0.2.md#16-trust-and-input-handling
- bin/card (cmd_new, the outline reader of P-02, the row lookup of P-06, need_id)
- test/cases/30-new.sh

## Touch
- bin/card
- test/cases/37-plan-start.sh (new)
- docs/reference.md (the argument line, if `card help` gains one)

## Tests
- test_plan_start_creates_the_card_file_from_the_row
- test_plan_start_writes_the_specification_and_its_headings_under_read
- test_plan_start_writes_a_comment_with_no_headings_for_a_row_with_no_spec_item
- test_plan_start_copies_the_does_lines_to_acceptance
- test_plan_start_copies_the_not_lines_to_out_of_scope
- test_plan_start_prints_the_path_of_the_card
- test_plan_start_refuses_an_id_with_no_row
- test_plan_start_refuses_an_id_that_has_a_card_file
- test_plan_start_rejects_a_malformed_id
- test_plan_start_card_has_no_front_matter_key_that_card_0_1_3_does_not_know

## Acceptance
- `card plan start <id>` creates the card file for a row and prints its path. The file name is the one `card new` would give for that id and title.
- The front matter has the row's id, title, size and dependencies and `done: false`, and no other key.
- `Read` has one item: the specification's path and a comment, `(row <id>: <heading>; <heading>)`, with the row's `spec` headings in the order of the outline. For a row with no `spec` item the comment is `(row <id>)`.
- `Acceptance` has the row's `does` lines as items. `Out of scope` has the row's `not` lines as items.
- `Touch` and `Tests` are present and empty.
- It exits 1 with the reason for an id with no row, and for an id that already has a card file on the base branch or in the working tree.
- The file is written in the working tree and nothing is committed.

## Out of scope
- Filling in `Touch`, `Tests` and the rest of `Read`. The next-card skill does that (P-14).
- Checking the card against the tree. P-10 owns `card plan check`.
- Refusing a row whose dependencies are not done. next-card picks only a ready row; the command does not check state.
- Editing the outline. Nothing writes to an outline after a card exists.

## Notes
- The comment must start with `(row `. The reviewer's new step (P-15) fires on exactly that.
- A heading may contain `;` or `)`. Write the headings as they are in the outline; the reviewer reads the comment, no script parses it.
- cmd_new already writes the front matter, the slug and the empty sections. Reuse it.
