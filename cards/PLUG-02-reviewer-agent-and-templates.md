---
id: PLUG-02
title: Reviewer agent and init templates
size: S
depends: PLUG-01
done: true
---

## Read
- docs/specs/2026-10-05-workdeck-0.1-design.md (sections 10.1 and 12)
- docs/plans/2026-10-05-workdeck-0.1-plan.md (step 7.2)
- cards/REVIEW.md

## Touch
- agents/reviewer.md (new)
- templates/* (new)
- test/cases/02-plugin.sh
- .github/workflows/ci.yml (added during the card: agents are validated as a component directory, not through the manifest)

## Tests
- template conf parses
- claude md section is short
- reviewer agent is read only

## Acceptance
- The reviewer's tools are Read, Grep, Glob and Bash, and its body is the procedure and output format of spec section 12.
- templates/ holds REVIEW.md, the PR template, the CLAUDE.md section, workdeck.conf, the CI workflow and the permission entries.
- claude plugin validate --strict . still passes.

## Out of scope
- Project rules in the REVIEW.md template: the plugin ships none.

## Notes
- Plugin agents ignore hooks, mcpServers and permissionMode.
