---
id: P-02
title: Outline reader and card plan: the format check
size: M
depends: P-01, S-04
done: false
---

## Read
- docs/design-0.2.md#5-outline-format
- docs/design-0.2.md#9-the-card-command (the rows for `card plan`)
- docs/design-0.2.md#111-card-plan (the row Outline format)
- docs/design-0.2.md#8-configuration-and-compatibility (the first row of the table)
- docs/design-0.2.md#16-trust-and-input-handling
- docs/design-0.2.md#22-decisions-locked-and-what-is-deferred (decision 5)
- docs/development/spike-0.2.md (whether section 5 changed)
- bin/card (LINT_LIB, lint_cards, base_ref, base_show, wt_cards, sizes, need_id, usage, main)
- test/cases/13-lint.sh (the style of a case per rule)
- test/lib.sh

## Touch
- bin/card
- test/cases/35-plan.sh (new)
- test/lib.sh (a helper that writes an outline)
- docs/reference.md (one line for `card plan`; test_reference_names_every_card_command fails without it)

## Tests
- test_plan_with_no_outline_says_so_and_exits_zero
- test_plan_passes_a_well_formed_outline
- test_plan_passes_an_outline_with_no_not_planned_section
- test_plan_reports_a_missing_front_matter_key
- test_plan_reports_an_unknown_front_matter_key
- test_plan_reports_a_spec_path_that_leaves_the_repository
- test_plan_reports_a_spec_path_with_a_space
- test_plan_reports_a_level_that_is_not_a_digit_from_1_to_6
- test_plan_reports_a_file_name_that_is_not_the_prefix_in_lowercase
- test_plan_reports_a_row_with_no_size
- test_plan_reports_a_row_with_no_does
- test_plan_reports_a_key_twice_that_may_appear_once
- test_plan_reports_an_unknown_row_key
- test_plan_reports_every_failure_with_its_file
- test_plan_reads_the_working_tree_copy_of_an_outline_before_the_base_branch_copy
- test_plan_with_an_unknown_subcommand_is_a_usage_error

## Acceptance
- The outline format is the one in design section 5 as it stands after the spike. This card read docs/development/spike-0.2.md first and follows any change it made.
- `card plan` checks every outline in `<cards_dir>/plan/` and prints each failure with the file. It exits 1 on any failure and reports every failure it finds, not only the first.
- With no outline, `card plan` prints one line that says so and exits 0.
- Each condition in the row Outline format of the table in section 11.1 fails the check.
- A `spec` with a space in it fails.
- An outline with no `## Not planned` section passes the format check (added by the spike, P-01).
- For each outline file, the working tree's copy is read if there is one, otherwise the base branch's. Rows are not merged from the two.
- `spec` is refused unless it is a relative path inside the repository with no `..`. The prefix is validated before it is used in a file name or a pattern.
- Nothing in an outline is sourced or evaluated.
- `card help` lists `plan`, and `card plan --help` prints its arguments.
- `card lint`, `card list`, `card next`, `card status` and `card show` print what they printed before this card.
- bin/card is still one file and runs on bash 3.2 with mawk, gawk and the awk of macOS.

## Out of scope
- The checks Ids and Sizes. P-02b owns them.
- The checks Dependencies, Specification and Coverage, and the line for a changed specification. P-03 owns them.
- `card plan new` and `card plan accept`. P-04 owns them.
- The plan branch check. P-05 owns it.
- Rows in `list`, `next`, `status` and `show`. P-06 and P-07 own them.
- `card plan start` and `card plan check`. P-09 and P-10 own them.
- The full reference text for the outline format. P-19 owns it.

## Notes
- The reader written here is used by P-03 to P-09. Give it one function that prints rows in a tab-separated form, as META_AWK does for cards, so later cards do not parse the file again.
- A row heading is `## <id> <title>`, and `## Not planned` is the one second-level heading that is not a row.
- cards/REVIEW.md, Portability: no awk interval expressions and no POSIX classes.
- If the budget warning appears, do not split with the reader half built: P-02b to P-10 all read through it. Finish the reader and move unfinished format rules to the remainder.
