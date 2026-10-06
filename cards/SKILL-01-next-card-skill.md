---
id: SKILL-01
title: reference/implement.md and the next-card skill
size: S
depends: PLUG-02
done: true
---

## Read
- docs/design.md (sections 10 and 10.2)
- docs/development/plan-0.1.md (stage 8 preamble, step 8.1, section G items 18, 19 and 21)

## Touch
- reference/implement.md (new)
- skills/next-card/SKILL.md (new)
- test/cases/60-skills.sh (new)
- docs/development/findings.md (added during the card: finding 8 from the manual run, finding 9 from the security review)

## Tests
- skills disable model invocation
- skills name only card commands that exist

## Acceptance
- The skill follows the nine steps of spec section 10.2 and ends by telling the user to type /mergehand:handoff.
- reference/implement.md tells the agent not to commit before handoff.
- A manual run in a scratch repository is described in the log.

## Out of scope
- Worktrees, claiming.

## Notes
- $ARGUMENTS is not substituted inside injected commands; inject only card status --fetch.
