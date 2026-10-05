---
id: SKILL-01
title: reference/implement.md and the next-card skill
size: S
depends: PLUG-02
done: false
---

## Read
- docs/specs/2026-10-05-workdeck-0.1-design.md (sections 10 and 10.2)
- docs/plans/2026-10-05-workdeck-0.1-plan.md (stage 8 preamble, step 8.1, section G items 18, 19 and 21)

## Touch
- reference/implement.md (new)
- skills/next-card/SKILL.md (new)
- test/cases/60-skills.sh (new)

## Tests
- skills disable model invocation
- skills name only card commands that exist

## Acceptance
- The skill follows the nine steps of spec section 10.2 and ends by telling the user to type /workdeck:handoff.
- reference/implement.md tells the agent not to commit before handoff.
- A manual run in a scratch repository is described in the log.

## Out of scope
- Worktrees, claiming.

## Notes
- $ARGUMENTS is not substituted inside injected commands; inject only card status --fetch.
