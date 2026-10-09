---
id: P-18
title: Compatibility test: card 0.1.3 lint on a planned deck
size: S
depends: P-02b, P-03, P-08, P-09, S-04
done: false
---

## Read
- docs/design-0.2.md#17-testing (the second item)
- docs/design-0.2.md#8-configuration-and-compatibility (rows 2 to 4 of the table)
- docs/design-0.2.md#42-a-project-that-uses-the-planner (why 0.1.3 does not read an outline as a card)
- docs/design-0.2.md#2-goals-and-non-goals (goal 5)
- docs/development/review-0.2.md ("What the reviewer looked for and did not find")
- test/cases/70-compat.sh
- test/lib.sh (the helpers of P-02 and P-08)
- cards/REVIEW.md (Conventions)

## Touch
- test/cases/70-compat.sh (created by P-08)
- test/lib.sh

## Tests
- test_card_0_1_3_lint_passes_a_deck_with_an_outline_a_planned_card_and_a_split_remainder
- test_card_0_1_3_next_offers_only_cards_that_have_a_file
- test_card_0_1_3_lint_fails_a_card_that_depends_on_a_row_with_no_file
- test_planned_deck_passes_card_plan

## Acceptance
- A case builds a deck with an outline under `<cards_dir>/plan/`, a card that `card plan start` created and that has a filled body, and a split remainder with a letter suffix, and runs `card` 0.1.3 `lint` on it. Lint passes.
- On that deck `card` 0.1.3 `next` and `list` print no row.
- A hand-written card that depends on a row with no card file fails `card lint` in 0.1.3 and in this version, with `depends on <id>, which is not a card`.
- The same deck passes `card plan` of this version.
- The 0.1.3 file is found as P-08 finds it. The cases skip where P-08's case skips and fail in CI where it fails.
- If a case fails because of bin/card as it stands, this card reports it and stops. It does not change bin/card; the defect becomes a card of its own.

## Out of scope
- Any change to bin/card.
- The byte-for-byte comparison of `list`, `next` and `status`. P-08 owns it.
- The trial repositories' CI, which stays on 0.1.3 and tests the same claim on real decks. P-22 and P-23 record it.

## Notes
- The design says "fixture deck". cards/REVIEW.md says each test builds its own repository through test/lib.sh. Build the deck in the case with the helpers; add no file under test/fixtures/ unless a helper cannot do it, and say so in the log if it cannot.
- The planned card is made by running `card plan start` of this version and then filling `Touch` and `Tests`, so the test follows the format as it is, not as this card remembers it.
