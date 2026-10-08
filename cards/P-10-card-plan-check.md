---
id: P-10
title: card plan check
size: S
depends: P-02
done: false
---

## Read
- docs/design-0.2.md#7-planned-cards (the three rules, and the paragraph after them)
- docs/design-0.2.md#112-card-plan-check-id
- docs/design-0.2.md#113-what-a-script-cannot-decide (the fourth limit)
- docs/development/review-0.2.md (findings 12 and 13)
- bin/card (section_items, matches_any, cmd_touched, card_path)
- test/cases/32-touched.sh

## Touch
- bin/card
- test/cases/38-plan-check.sh (new)
- docs/reference.md (the argument line, if `card help` gains one)

## Tests
- test_plan_check_passes_a_card_whose_paths_exist
- test_plan_check_reports_a_read_path_that_does_not_exist
- test_plan_check_ignores_the_anchor_and_the_comment_of_a_read_entry
- test_plan_check_accepts_a_read_entry_that_names_a_directory
- test_plan_check_reports_a_touch_entry_that_matches_no_file
- test_plan_check_accepts_a_touch_entry_that_matches_an_untracked_file
- test_plan_check_reports_a_new_path_that_exists
- test_plan_check_reports_a_new_path_that_is_an_ignored_file
- test_plan_check_does_not_count_an_ignored_file_for_a_touch_entry
- test_plan_check_reports_a_new_entry_that_is_not_a_full_path
- test_plan_check_reports_an_out_of_scope_section_with_no_item
- test_plan_check_reports_every_failure
- test_plan_check_refuses_an_id_with_no_card_file

## Acceptance
- `card plan check <id>` checks one card against the tree and exits 1 on any failure, after printing every failure.
- Each `Read` entry, taken up to the first space and with any `#anchor` removed, names a file or directory.
- Each `Touch` entry whose comment does not start with `(new)` matches at least one file, tracked or untracked. A file that git ignores does not count: the scope gate cannot see a change to it.
- A `Touch` entry marked `(new)` is a full path and matches no file. Anything at that path fails it, an ignored file included.
- `Out of scope` has an item.
- The command is not run by `card lint`, by `card plan` with no argument, or by any gate of handoff.
- It works on any card with a file, planned or written by hand.

## Out of scope
- Whether the paths are the right ones. The user approves the card and the reviewer reads the work.
- Running the check at handoff or in CI. Section 7 says why: it stops being true as soon as the work starts.
- Checking that a `Tests` line names a test. `card tests` does that at handoff.

## Notes
- A `Touch` entry is used only as a `case` pattern, as in 0.1. matches_any holds the rules for a trailing `/` and a leading `./`.
- This card reads no outline. It depends on P-02 only for the `plan` command it hangs under.
- `git ls-files` and `git ls-files --others --exclude-standard` give the files the scope gate sees. A `(new)` path is tested on disk.
