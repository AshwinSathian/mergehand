---
id: P-11
title: Stop hook: leave out commits that change only the cards directory
size: XS
depends: S-04
done: true
---

## Read
- docs/design-0.2.md#13-hooks
- docs/development/review-0.2.md (finding 19 for why; its command is the unanchored one that the fourth pass corrects)
- hooks/stop.sh
- test/cases/52-hook-stop.sh

## Touch
- hooks/stop.sh
- test/cases/52-hook-stop.sh
- docs/design-0.2.md (section 13, after the second review: what is given up)
- docs/development/review-0.2.md (the fourteenth pass)

## Tests
- test_stop_passes_after_a_commit_that_changes_only_the_cards_directory
- test_stop_blocks_after_a_card_only_commit_and_a_code_commit
- test_stop_card_only_commit_respects_cards_dir
- test_stop_counts_commits_from_the_root_when_run_in_a_subdirectory
- test_stop_counts_a_nested_directory_named_like_the_cards_directory

## Acceptance
- The count of commits that belong to the branch leaves out those that change nothing outside the cards directory: `git rev-list --count HEAD --not <base refs> -- ':(top)' ':(top,exclude)<cards_dir>'`.
- On a card branch whose only commit changes a card file, with a clean tree and no session log, the hook exits 0.
- After a further commit that changes a file outside the cards directory, it exits 2 as before.
- The cards directory is read from the configuration, not assumed to be `cards`.
- The hook still exits 0 on any internal error, and every case of test/cases/52-hook-stop.sh that existed passes unchanged.

## Out of scope
- The commit itself. next-card makes it (P-14).
- The budget warning and the session-start hook. Section 13 says neither changes.
- An approval commit for a quick card. docs/development/later.md has it.

## Notes
- The hook does not change directory, and a pathspec without `top` is relative to where git runs. In a subdirectory the unanchored form counted 0 for a branch with a code commit at the root (review record, fourth pass). The case for it must fail before the change is made.
- A directory named like the cards directory deeper in the tree, `src/cards/` for one, is code. The anchored exclude leaves it counted.
- Given up, by decision: a commit that only adds a `## Blocked` section to the card no longer trips the guard.
- `card conf cards_dir` is one more process per stop. The hook already calls `card conf` twice.
- It can be done at any point after S-04 and before P-14.
- After the second review: the search for the session log is anchored too, and both commands carry `--no-literal-pathspecs`. Neither is in the acceptance above. The reasons are in the fourteenth pass of docs/development/review-0.2.md.
