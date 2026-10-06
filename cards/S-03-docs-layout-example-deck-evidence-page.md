---
id: S-03
title: Docs layout, example deck, evidence page, evals cut
size: M
depends:
done: true
---

## Read
- docs/development/findings.md (finding 12)
- docs/design.md (sections 3, 4.1, 6, 17, 20)

## Touch
- docs/*
- examples/* (new)
- templates/mergehand.yml
- test/cases/02-plugin.sh
- test/cases/32-touched.sh (a test name changes spelling)
- test/cases/21-state.sh (spelling and a docs path in comments)
- test/cases/33-tests.sh (spelling and a docs path in comments)
- mergehand.conf (the ignored notes moved)
- CONTRIBUTING.md
- bin/card (spelling in comments)
- hooks/* (spelling in comments)
- skills/* (spelling)
- reference/implement.md (spelling)
- cards/REVIEW.md

## Tests
- example deck lints and lists
- docs have one design file and a development folder
- nothing claims evals that do not exist

## Acceptance
- The design is docs/design.md; the plan, the findings and the later notes are under docs/development/, each with a line saying what it is.
- examples/hello-deck/ holds a config, two cards and one session log with real figures, and its README shows real card output.
- docs/evidence.md gathers the measurements a reader can check.
- The plugin eval card is removed and the design says why.
- Spelling is American throughout.

## Notes
- From the comparison against respected repositories, 2026-10-06.
- Card and log files that name the old paths are updated too, so no link is dead.
