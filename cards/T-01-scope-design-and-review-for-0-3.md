---
id: T-01
title: Scope, design and review for 0.3
size: M
depends:
done: false
---

## Read
- README.md#roadmap
- docs/design.md
- docs/design-0.2.md
- docs/development/scope-0.2.md (the form of a scope note, and what 0.2 left to 0.3)
- docs/development/review-0.2.md (the form of a review record; findings 6 and 31 on cards that touch the same file)
- docs/development/findings.md
- docs/development/later.md
- cards/PLAN-01-scope-design-review-and-deck-for-0-2.md (the method this card repeats)
- cards/REVIEW.md
- bin/card (card_branches, deck_table, base_ref: how state is read from branches today)
- hooks/

## Touch
- docs/development/scope-0.3.md (new)
- docs/design-0.3.md (new)
- docs/development/review-0.3.md (new)
- docs/development/README.md (one row per new record)
- test/cases/02-plugin.sh (one case; the tests gate needs a named test)

## Tests
- test_development_records_for_0_3_are_listed_and_exist

## Acceptance
- The scope note is one page and says what 0.3 is (teams: claiming a card, worktrees, parallel sessions), who it is for, what is out and the open risks. The maintainer approved it before the design was written.
- The design is its own file, docs/design-0.3.md, numbered like docs/design.md. It adds to docs/design.md and docs/design-0.2.md and says so.
- Every claim about Claude Code or git behavior cites the documentation page it came from, and anything not checked is marked unverified.
- An agent that did not write the design reviewed the scope and the design against the code, and was told to assume both are wrong. The review record lists each finding with its evidence, and which the maintainer accepted.
- The scope and the design agree with each other and with the review record: no rule is in one and missing from the other.
- The maintainer approved each of the four outputs before the next was started: the scope note, the design, the review record, and the design as amended from the review.
- The design is one markdown file that is committed, so `/workdeck:plan` can take it as written.
- No file under bin/, hooks/, skills/, agents/, templates/ or reference/ changed.

## Out of scope
- A deck for 0.3. The planner writes it in the 0.2 trial (P-22 and P-23); this card writes no card.
- Product code for 0.3.
- Any change to docs/design-0.2.md or to a card of the 0.2 deck.
- Shaping the design's sections to suit the planner. It is written for people; the bias of an author who knows it will be planned is recorded in docs/development/scope-0.2.md, risk 9.

## Notes
- This card is outside the 0.2 deck and depends on none of its cards. It can be started by id at any time while 0.2 is built. P-22 waits for it.
- Its id sorts after the deck on purpose, so `card next` offers the deck first. A design written after the spike (P-01) knows whether the outline format of 0.2 changed; one written before it does not.
- 0.2 serves the plugin to users from the main branch when its version changes (docs/design-0.2.md, section 19, row 18). The 0.3 design has to say how a half-built team feature stays unreachable on that branch.
- PLAN-01 took more than one session for the same four outputs. If the budget warning appears, hand off with `/workdeck:handoff split`: the scope note is the natural first part. P-22 is a card with a file and does not wait for a remainder, so in that handoff change P-22's `depends` from T-01 to the remainder that writes docs/design-0.3.md.
- 0.2 left these to 0.3: claiming, worktrees and parallel sessions, a script check that orders cards touching the same file, and two people planning at once (docs/design-0.2.md, section 2).
- The reviewer is a subagent launched for the purpose, not the session that wrote the design. Its reading stays out of this session's context, which is most of what makes the card fit. A pass by the writing agent is weaker evidence and the record says so where one is made, as the third part of docs/development/review-0.2.md does.
- test_docs_have_one_design_file_and_a_development_folder fails on any tracked file that names one of the old documentation directories; its pattern lists them.
