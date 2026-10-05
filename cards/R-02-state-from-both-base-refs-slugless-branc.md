---
id: R-02
title: State from both base refs, slugless branches, release hint
size: M
depends:
done: true
---

## Read
- docs/findings.md (findings 3, 8 and 11)
- docs/specs/2026-10-05-workdeck-0.1-design.md (section 6)
- bin/card (base_ref, base_done, deck_table, card_branches, id_of_branch, cmd_next)
- hooks/stop.sh

## Touch
- bin/card
- hooks/stop.sh
- test/cases/20-base.sh
- test/cases/21-state.sh
- test/cases/40-tokens.sh
- test/cases/52-hook-stop.sh

## Tests
- base done on local base counts before push
- base done on origin counts when local base is behind
- base done with diverged bases is the union
- next does not offer a card merged locally
- base card on unpushed local base is not branch only
- base done tolerates spaces around true
- state branch without slug is active
- stop blocks on a branch without slug
- tokens prints the budget on a branch without slug
- next none ready says how to release an active card

## Acceptance
- A card is done when done: true is in its front matter on origin/<base> or on the local base branch.
- A card committed on either base ref is not treated as existing only on the current branch.
- A branch named card/<id> with no slug counts as that card's branch everywhere: state, status, budget and the stop hook.
- card next, with nothing ready and a card active or blocked, says that deleting the branch releases the card, and prints no branch name.
- The stop hook exits 0 when git log fails.

## Notes
- Not built, by decision: a "local when strictly ahead" rule, and telling local from remote branches.
- A card file renamed between the two base refs is not handled.
