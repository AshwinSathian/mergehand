---
id: DOC-03
title: Three plugin eval cases
size: M
depends: SKILL-02, SKILL-03, SKILL-04
done: false
---

## Read
- docs/specs/2026-10-05-workdeck-0.1-design.md (section 17)
- docs/plans/2026-10-05-workdeck-0.1-plan.md (step 9.3, section B on evals)

## Touch
- evals/* (new)
- .gitignore
- test/cases/02-plugin.sh

## Tests
- every eval case has a prompt and a grader

## Acceptance
- Cases: init on an empty project, next-card with one ready card, quick on a one-line bug.
- Graders check files and tool use, not prose.

## Out of scope
- Running evals in CI.

## Notes
- Evals call the model on the owner's account. Ask before each run and report the cost.
- Open: whether an eval prompt can run a skill that has disable-model-invocation.
