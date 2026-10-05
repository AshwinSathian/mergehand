---
id: SKILL-04
title: Init skill
size: M
depends: PLUG-02
done: true
---

## Read
- docs/design.md (section 10.1)
- docs/development/plan-0.1.md (step 8.4)
- templates/claude-md-section.md
- templates/settings-permissions.json

## Touch
- skills/init/SKILL.md (new)
- test/cases/60-skills.sh

## Tests
- init names only templates that exist

## Acceptance
- The eight steps of spec section 10.1; nothing existing is overwritten and nothing is committed.
- A second run stops at step 1.

## Out of scope
- Writing a first card from a description.

## Notes
- Re-read the settings and permissions pages for the rule syntax before writing the entries.
