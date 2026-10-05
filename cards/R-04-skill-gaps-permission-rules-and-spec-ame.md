---
id: R-04
title: Skill gaps, permission rules and spec amendments from the review
size: M
depends:
done: true
---

## Read
- docs/development/findings.md (finding 11)
- skills/next-card/SKILL.md
- skills/quick/SKILL.md
- skills/handoff/SKILL.md
- skills/init/SKILL.md
- reference/implement.md
- templates/settings-permissions.json

## Touch
- skills/*
- reference/implement.md
- templates/settings-permissions.json
- test/cases/02-plugin.sh
- test/cases/60-skills.sh
- docs/design.md
- docs/development/plan-0.1.md
- cards/DOC-01-readme.md (notes for the README from the review)

## Tests
- permission template does not deny the handoff push
- permission template denies known bad pushes
- skills do not use command substitution
- next card can resume a card in progress

## Acceptance
- next-card offers to resume a card that is active or blocked on a local branch, and says to remove the Blocked section once it is answered.
- quick runs date as its own command, and deletes the card file when the user declines.
- handoff deletes the pull request body file after gh pr create.
- init no longer creates log/ or a .gitkeep; card log-new creates the directory.
- The permission template denies the force and delete forms the review listed and still allows the push that handoff runs.
- The spec, the plan and the findings say what the code now does.

## Notes
- Not done: a live handoff against a remote under these permission rules. It needs a nested Claude session on the owner's account.
- Not built, by decision: card branch, allowing git commit or git add.
