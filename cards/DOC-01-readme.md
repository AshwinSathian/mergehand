---
id: DOC-01
title: README and known limits
size: S
depends: SKILL-02, SKILL-03, SKILL-04
done: false
---

## Read
- docs/specs/2026-10-05-workdeck-0.1-design.md (sections 1, 2, 4.1, 14 and 18)
- docs/findings.md

## Touch
- README.md
- test/cases/02-plugin.sh

## Tests
- readme names every card command

## Acceptance
- Install commands, the loop on one screen, the known limits of spec section 14, the Touch matching rule, and the plain statement that 0.1 runs cards and 0.2 writes them.

## Out of scope
- A website, badges.

## Notes
- Known limits to state, from the review (finding 11): a transcript path containing a double quote gives `unknown` tokens; a file whose name git quotes (a double quote or a newline in it) cannot be listed in `Touch`; a symlinked card file is followed.
- Permissions: the deny rules match the command as written and are not a security boundary, so the base branch needs protection on the host. `git commit` and `git add` are deliberately not allowed, so an unattended handoff stops at the commit prompt. `gh pr create` is allowed with any `--body-file`.
- Touch: an entry ending in `/` covers the directory; a bare file name matches only at the repository root; `!` does not negate. The table is in finding 2.
- Tests gate: write each line as the innermost test name; nested names are not joined (finding 1).
- A card is released by deleting its branch. `done` counts from the local or the remote base branch.
- The plugin cannot be installed on claude.ai or Cowork because it has a top-level `bin/`.
