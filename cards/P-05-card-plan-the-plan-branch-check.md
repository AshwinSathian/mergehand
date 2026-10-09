---
id: P-05
title: card plan: the plan branch check
size: S
depends: P-02
done: true
---

## Read
- docs/design-0.2.md#111-card-plan (the row Plan branch, and the sentence under the table)
- docs/design-0.2.md#18-risks (the row "The agent ignores the plan skill and implements")
- docs/development/review-0.2.md (finding 10)
- bin/card (fork_point, changed_files, cmd_touched, the `plan` command of P-02)
- test/cases/32-touched.sh (how the cases build a branch with changes)

## Touch
- bin/card
- test/cases/35-plan.sh (created by P-02)

## Tests
- test_plan_fails_on_a_plan_branch_that_changes_a_file_outside_the_outlines
- test_plan_passes_on_a_plan_branch_that_changes_only_outlines
- test_plan_branch_check_counts_uncommitted_and_untracked_files
- test_plan_branch_check_does_not_run_on_another_branch
- test_plan_branch_check_respects_cards_dir
- test_plan_branch_check_names_each_file

## Acceptance
- On a branch named `plan/*`, `card plan` fails when a file outside `<cards_dir>/plan/` differs from the point where the branch left the base branch, and names each such file.
- A change that is not committed, and a file that is not tracked, count.
- On any other branch the check does not run.
- The check runs last, after those of P-02 and P-03.
- `card touched` prints what it printed before this card.

## Out of scope
- Any other check of section 11.1. P-02 and P-03 own them.
- Stopping a plan run that edits a row which already has a card or a branch. Section 11.3 lists that as a limit no script checks.
- A hook that enforces this. The check is a command; the plan skill runs it (P-13).

## Notes
- fork_point gives the point where the branch left the base branch. changed_files cannot be used as it is: it drops every path under the cards directory and the log directory, so a card written on a plan branch would pass. Take the same two git commands without that filter, and exclude only `<cards_dir>/plan/`.
- A card file under `<cards_dir>/` but outside `<cards_dir>/plan/` is a failure here. A plan run writes no card.
