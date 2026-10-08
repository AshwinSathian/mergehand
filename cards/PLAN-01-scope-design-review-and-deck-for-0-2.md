---
id: PLAN-01
title: Scope, design, review and deck for 0.2
size: M
depends:
done: false
---

## Read
- README.md
- docs/design.md
- docs/reference.md
- docs/evidence.md
- docs/development/findings.md
- docs/development/later.md
- docs/development/plan-0.1.md
- CHANGELOG.md
- skills/
- reference/implement.md
- templates/
- cards/REVIEW.md

## Touch
- docs/design-0.2.md (new)
- docs/development/scope-0.2.md (new)
- docs/development/review-0.2.md (new)
- docs/development/README.md (one row per new record)
- test/cases/02-plugin.sh (one case; the tests gate needs a named test)

## Tests
- development records for 0.2 are listed and exist

## Acceptance
- The scope note is one page and says what 0.2 is, who it is for, what is out and the open risks. The maintainer approved it before the design was written.
- The design is its own file, numbered like docs/design.md. Every claim about Claude Code behavior cites the documentation page it came from, and anything not checked is marked unverified.
- The review record lists each finding of an agent that did not write the design, and which the maintainer accepted.
- The scope and the design agree with each other and with the review record: no rule is in one and missing from the other.
- Every 0.2 card was created with `card new`, has Read, Touch, Tests, Acceptance and Out of scope filled in, a size and its dependencies. `card lint` passes.
- The deck follows the build order of the design's section 21. Its first card is the spike, sized XS or S, and every card that parses an outline depends on it.
- No card of the deck writes the 0.3 design. The trial card names it under `Read` and says it must exist.

## Out of scope
- Product code: bin/card, hooks/, skills/, agents/, templates/ and reference/. The 0.2 cards own it.
- A version bump, a tag, a release and repository settings.
- Changes to docs/design.md, README.md and CHANGELOG.md. A 0.2 card owns each.

## Notes
- The 0.2 cards are files under cards/, which the scope gate skips, so they are not in Touch.
- Commits carry no Co-Authored-By trailer and the pull request body carries no generated-with line.
- The maintainer approves each of the four outputs before the next is started.
- 2026-10-09: a second review rewrote the scope and the design (docs/development/review-0.2.md). The maintainer decided its four questions and had the rest attacked again and locked (design section 22). The first three outputs are approved; the deck is next.
- The 0.3 design is written by Claude Code as its own card, not by a card of this deck. The second trial repository is chosen after the build; the trial card carries that question.
- 2026-10-09: the deck is P-01 to P-24, in the order of design section 21. T-01 is the card for the 0.3 design and is outside the deck; its id sorts after the deck so that `card next` offers the spike first. Writing the deck found five faults in the design, the largest that changing the version on the main branch releases the plugin. They are amended in the design and recorded as the fourth pass of docs/development/review-0.2.md, with one exception added to cards/REVIEW.md.
