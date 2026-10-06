---
id: Q-2610052330
title: Deny refspec pushes in the permission template
size: XS
depends:
done: true
---

## Read

## Touch
- templates/settings-permissions.json
- test/cases/02-plugin.sh
- mergehand.conf (touch_ignore for the findings and later notes, which every card may add to)

## Tests
- permission template denies refspec pushes

## Acceptance
- The template denies `git push` with a colon refspec and with a second refspec after a card branch.
- `docs/development/findings.md` and `docs/development/later.md` no longer fail the scope gate in this repository.

## Out of scope

## Notes
- From the automated security review of the PLUG-02 commit; finding 9 in docs/development/findings.md.
