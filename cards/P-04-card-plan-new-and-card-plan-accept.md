---
id: P-04
title: card plan new and card plan accept
size: S
depends: P-03
done: false
---

## Read
- docs/design-0.2.md#9-the-card-command (the rows for `card plan new` and `card plan accept`)
- docs/design-0.2.md#5-outline-format (the front matter, and the rule for the file name)
- docs/design-0.2.md#15-errors (the row for a specification with no heading at the level)
- docs/design-0.2.md#16-trust-and-input-handling
- bin/card (the outline reader of P-02, the heading scan of P-03, cmd_new, wt_cards)
- test/cases/30-new.sh (the style of the cases for `card new`)

## Touch
- bin/card
- test/cases/36-plan-new.sh (new)
- docs/reference.md (the argument lines for the two commands, if `card help` gains them)

## Tests
- test_plan_new_writes_the_front_matter_and_no_rows
- test_plan_new_defaults_the_level_to_2
- test_plan_new_takes_a_level
- test_plan_new_refuses_a_prefix_that_an_outline_uses
- test_plan_new_refuses_a_prefix_that_a_card_uses
- test_plan_new_refuses_the_prefix_q
- test_plan_new_refuses_a_file_that_exists
- test_plan_new_refuses_a_specification_that_is_not_tracked
- test_plan_new_refuses_a_path_that_leaves_the_repository
- test_plan_new_names_the_levels_that_have_headings
- test_plan_accept_sets_spec_blob_to_the_current_value
- test_plan_accept_refuses_a_prefix_with_no_outline

## Acceptance
- `card plan new <spec path> <PREFIX> [--level N]` creates `<cards_dir>/plan/<prefix in lowercase>.md` with `spec`, `spec_blob`, `prefix` and `level` filled in and no rows, and prints the path.
- `spec_blob` is what `git hash-object` prints for the specification.
- `level` defaults to 2.
- It refuses a prefix that an outline or a card already uses, the prefix `Q`, an existing file, and a specification that is not tracked. Each refusal exits 1 with the reason.
- For a specification with no heading at the level it exits 1 and names the levels that have headings.
- `card plan accept <PREFIX>` sets `spec_blob` to the specification's current value and changes no other line.
- After `card plan accept`, `card plan` no longer prints the line for a changed specification.
- A malformed prefix or a missing argument is a usage error, exit 2.

## Out of scope
- Writing rows. The plan skill writes them (P-13).
- Any check that `card plan` runs. P-02, P-03 and P-05 own them.
- A command that removes or renames an outline.

## Notes
- A new outline fails Coverage until it has rows. That is intended: the plan skill runs `card plan` after it writes them.
- The design gives no exit code for `card plan accept` with a prefix that has no outline. This card uses exit 1, as `card plan start` does for an id with no row.
