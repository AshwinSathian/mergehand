---
id: P-07
title: card show for a row
size: S
depends: P-06
done: true
---

## Read
- docs/design-0.2.md#6-rows-in-the-deck (the last paragraph)
- docs/design-0.2.md#16-trust-and-input-handling (the second item)
- docs/design-0.2.md#102-workdecknext-card-id (next-card tells a row by the first line of `card show`)
- bin/card (cmd_show, card_path, the row lookup of P-06)
- test/cases/12-show.sh

## Touch
- bin/card
- test/cases/12-show.sh

## Tests
- test_show_prints_a_row_that_has_no_card_file
- test_show_first_line_for_a_row_says_there_is_no_card_file_yet
- test_show_prints_the_card_once_its_file_exists
- test_show_for_an_id_with_no_card_and_no_row_lists_the_same_prefix

## Acceptance
- `card show <id>` for a row with no card file prints a first line `row: no card file yet` and then the row as written in the outline: its heading and its items.
- Once the card file exists in the working tree, `card show <id>` prints the card, and no line starts with `row:`.
- For an id with no card file and no row, the message and the exit code are those of 0.1.
- The id is validated before it is used in a pattern, as today.

## Out of scope
- Rows in `list`, `next` and `status`. P-06 owns them.
- Creating the card file. P-09 owns `card plan start`.
- `card show` for a card that is on the base branch and not in the working tree. docs/development/later.md has it.

## Notes
- This is the one command, with `card plan start`, through which the `does`, `not` and `spec` lines of a row reach a session. Print them as written, with control characters removed.
- P-14 makes next-card branch on the first line. Do not change its wording after this card.
- The `row:` line is printed only when the id has no card file on the base branch and none in the working tree, which is how section 6 defines such a row. A card that is on the base branch and not in the working tree keeps the 0.1 message.
