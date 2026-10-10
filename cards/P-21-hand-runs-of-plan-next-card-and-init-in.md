---
id: P-21
title: Hand runs of plan, next-card and init in a scratch repository
size: S
depends: P-13, P-14, P-15, P-17
done: false
---

## Read
- docs/design-0.2.md#17-testing (the last item)
- docs/design-0.2.md#103-workdeckinit
- docs/design-0.2.md#101-workdeckplan-spec-path-what-to-change
- docs/design-0.2.md#102-workdecknext-card-id
- docs/development/review-0.2.md (the third pass row on the plan skill's commands under init's permission entries)
- docs/evidence.md (the section "Not yet shown")
- templates/settings-permissions.json
- examples/hello-deck/README.md (a small repository to copy as the scratch repository)

## Touch
- docs/evidence.md
- test/cases/02-plugin.sh

## Tests
- test_evidence_records_the_hand_runs_of_plan_next_card_and_init

## Acceptance
- The plan skill, the changed next-card and the changed init were each run by hand in a scratch repository, with the plugin loaded from a checkout of the main branch with `--plugin-dir`.
- The plan run was made under exactly the permission entries init writes, with no other settings. docs/evidence.md lists each prompt it raised.
- The plan run was interactive, typed by the maintainer, on the model the maintainer works with. The page says whether the session delegated the search and waited for both subagents (design section 19, row 15), and whether the reviewer ran a second time.
- The row that next-card started had a dependency, and the dependency's card was merged first.
- The next-card run started a row: the card was written, approved, committed alone, and implemented up to handoff. The page says whether the stop hook stayed quiet after the approval commit.
- The handoff of that card produced a pull request body with the part "Changes to the card since it was approved". The page says what it held.
- The init run was made on a repository that already had `workdeck.conf`. The page says what each of the four steps offered.
- For each run the page gives the growth `card tokens` prints.
- Each fault found is listed with the file it is in. None is fixed in this card; each becomes a card or a quick card of its own, merged before P-22 starts.
- The page's "Not yet shown" section is updated for what these runs showed.

## Out of scope
- Fixing a fault in a skill, an agent, a template or bin/card.
- The trial of ten planned cards. P-22 and P-23 own it.
- A run in someone else's repository.

## Notes
- Each run is its own session in the scratch repository. This card's session tells the maintainer what to run and writes the page from the logs and transcripts that come back.
- The spike's runs were headless, on another model, and its one card came from a row with no dependency (docs/development/spike-0.2.md, the last paragraph). The two acceptance items above close those three gaps before the trial.
- The scratch repository needs a specification of a few sections. Write one for the example deck's code; do not use the 0.3 design, which is the trial's.
- "Exactly the permission entries init writes" means a settings file that holds only the template's entries, and no user-level allow rules. The quick-card run of 0.1 failed to show this for handoff because the maintainer's own settings applied too.
- From the second review of P-12 (docs/development/review-0.2.md, fifteenth pass): the plan reviewer was run twice on one outline and gave two `must-fix` findings in one run and none in the other, and it named 8 and 9 of 19 joined `does` lines. Run it twice on the outline of this card and say whether the `must-fix` findings agree. If "two rows claim the same work" is what differs, the default is to narrow it to "the same requirement". A specification planned at a level other than 2 was not run either.
