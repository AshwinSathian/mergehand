---
id: R-03
title: Filter context text, normalise Touch entries, gate edge cases
size: S
depends:
done: true
---

## Read
- docs/findings.md (findings 1, 2 and 11)
- bin/card (META_AWK, deck_table, last_log_done, cmd_touched, cmd_tests, section_items, cmd_new, LINT_LIB)

## Touch
- bin/card
- test/cases/13-lint.sh
- test/cases/21-state.sh
- test/cases/23-status.sh
- test/cases/30-new.sh
- test/cases/32-touched.sh
- test/cases/33-tests.sh

## Tests
- status does not print an invalid size
- next does not print invalid depends
- status ignores a log with text in its name
- touch pattern directory entry covers the directory
- touch pattern leading slash is ignored
- touch ignore directory entry
- gate heading with trailing space
- gate file named like an awk assignment
- lint crlf names only the crlf file
- new rejects a size that is a regex
- new rejects titles lint would reject

## Acceptance
- card status, list and next print a size only when it looks like a size, a dependency only when it is a valid id, and a log file name only when it has no free text.
- A Touch or touch_ignore entry ending in / covers everything under that directory; a leading / or ./ is ignored.
- The tests gate's message says that nested names are not joined.
- card new refuses every size and title that card lint would then reject.

## Notes
- Not built, by decision: lint rules for Touch entries, and a windowed tests match.
