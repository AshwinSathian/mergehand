---
id: P-03
title: card plan: dependencies, specification and coverage
size: M
depends: P-02
done: false
---

## Read
- docs/design-0.2.md#111-card-plan (the rows Dependencies, Specification and Coverage, and the paragraph on a changed specification)
- docs/design-0.2.md#5-outline-format (the items `spec` and `depends`, `Not planned`, and how a heading is compared)
- docs/design-0.2.md#113-what-a-script-cannot-decide (the known limits of coverage)
- docs/development/review-0.2.md (findings 7, 14, 15 and 16)
- docs/development/spike-0.2.md (the heading levels the spike found)
- bin/card (the outline reader of P-02, the id checks of P-02b, lint_cards for the cycle rule, base_done, cmd_tests for the comparison of names)
- test/cases/35-plan.sh

## Touch
- bin/card
- test/cases/35-plan.sh (created by P-02)
- test/lib.sh

## Tests
- test_plan_reports_a_dependency_that_is_neither_a_row_nor_a_card
- test_plan_accepts_a_dependency_on_a_card_that_has_a_file
- test_plan_reports_a_cycle_through_rows_and_cards
- test_plan_reports_a_specification_that_is_missing
- test_plan_reports_a_specification_that_is_untracked
- test_plan_reports_a_heading_that_no_row_cites
- test_plan_accepts_a_heading_listed_under_not_planned
- test_plan_checks_coverage_of_an_outline_with_no_not_planned_section
- test_plan_ignores_a_heading_inside_a_code_fence
- test_plan_reports_a_row_that_cites_a_heading_the_specification_lacks
- test_plan_lets_a_done_row_cite_a_heading_that_is_gone
- test_plan_reports_a_not_planned_heading_the_specification_lacks
- test_plan_compares_headings_without_case_or_punctuation
- test_plan_checks_only_headings_at_the_level_of_the_outline
- test_plan_says_the_specification_changed_and_exits_zero

## Acceptance
- A dependency that names neither a row nor a card fails. A cycle through rows and cards together fails.
- A `spec` file that is missing or untracked fails.
- A heading of the specification at the outline's level, outside a code fence, that no row cites and that is not under `Not planned` fails.
- A row that is not done, or the `Not planned` list, citing a heading the specification does not have at that level fails. A row whose card is done on the base branch may cite a heading that is gone.
- An outline with no `## Not planned` section is checked as one whose list is empty: it passes when every heading is cited, and a heading no row cites fails (added by the spike, P-01).
- A heading is compared as the tests gate compares names: lowercased, with every character that is not a letter or digit removed.
- Only `#` headings count. A code fence is three backticks or three tildes at the start of a line.
- When the specification differs from `spec_blob`, `card plan` prints one line naming the outline and still exits 0.
- The checks run in the order of the table in section 11.1, after those of P-02.

## Out of scope
- Counting requirements under a heading, or judging the cut. The plan reviewer does that (P-12).
- Setting `spec_blob`. P-04 owns `card plan accept`.
- The plan branch check. P-05 owns it.
- Headings underlined with `=` or `-`, and two headings with the same text. Both are known limits in section 11.3.

## Notes
- docs/design.md has ten `#` lines inside code fences (review finding 7). It is a ready fixture for the fence rule.
- A row is done when its card file says `done: true` on the base branch. This card does not need rows in the deck table; base_done is enough.
- The cycle rule of lint_cards removes nodes whose dependencies are gone. The same loop works over rows and cards together.
