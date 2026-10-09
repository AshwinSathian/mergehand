---
id: P-08
title: Byte-for-byte test of list, next and status against card 0.1.3
size: S
depends: P-06, S-04
done: true
---

## Read
- docs/design-0.2.md#17-testing (the third item)
- docs/design-0.2.md#8-configuration-and-compatibility
- docs/design-0.2.md#2-goals-and-non-goals (goal 5)
- cards/REVIEW.md (Conventions: a test touches no network)
- test/run.sh
- test/lib.sh
- test/cases/14-list.sh
- test/cases/21-state.sh
- test/cases/23-status.sh
- .github/workflows/ci.yml

## Touch
- test/cases/70-compat.sh (new)
- test/lib.sh (a helper that writes `card` 0.1.3 into the case's temporary directory)
- .github/workflows/ci.yml (a step that fetches the tag)
- docs/development/review-0.2.md (added at handoff: the record of the second review)

## Tests
- test_list_next_and_status_match_card_0_1_3_when_there_is_no_outline

## Acceptance
- A case runs every 0.1 case of `list`, `next` and `status` in a repository with no outline, and compares the output and the exit code of each `card` call byte for byte with those of `card` 0.1.3.
- The case fails when one byte differs, and prints the command and both outputs.
- The 0.1.3 file is read with `git show v0.1.3:bin/card` from this repository. The case itself makes no network call.
- Where the 0.1.3 file cannot be had, the case prints `skip:` with the reason and passes. In CI it fails instead of skipping.
- The CI workflow fetches the `v0.1.3` tag in a step of its own before the tests, on macOS and on Ubuntu, and the mawk and gawk runs see it too.
- If the comparison finds a difference in bin/card as it stands, this card reports it and stops. It does not change bin/card.

## Out of scope
- Any change to bin/card. A difference is a defect of P-06 and becomes a card of its own.
- `card` 0.1.3 `lint` against a deck that has an outline. P-18 owns it.
- `card show`, which has no row to compare in a repository with no outline.

## Notes
- `v0.1.3` is the tag S-04's merge gets. The tag `v0.1.2` cannot be used: its `card` reads `mergehand.conf` and exits 2 in every repository the cases build.
- A CI checkout is shallow and has no tags: `git fetch --depth 1 origin tag v0.1.3` in the workflow is enough. A clone without the tag skips locally.
- test_plugin_validates_strictly shows the pattern for a case that skips locally and fails in CI.
- One way to run "every 0.1 case" without copying them: source the three case files with `card` replaced by a function that runs both versions and compares.
- The helper is used again by P-18.
