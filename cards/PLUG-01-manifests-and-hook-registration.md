---
id: PLUG-01
title: Plugin and marketplace manifests, hooks.json
size: S
depends: HOOK-01, HOOK-02, HOOK-03, HOOK-04
done: false
---

## Read
- docs/specs/2026-10-05-workdeck-0.1-design.md (section 4.1)
- docs/plans/2026-10-05-workdeck-0.1-plan.md (section B, step 7.1)

## Touch
- .claude-plugin/plugin.json (new)
- .claude-plugin/marketplace.json (new)
- hooks/hooks.json (new)
- .github/workflows/ci.yml
- test/cases/02-plugin.sh (new)

## Tests
- hooks json names existing executable scripts
- plugin manifest has name version description and author

## Acceptance
- claude plugin validate --strict . prints Validation passed.
- hooks.json wraps the events in a top-level hooks key and gives each command a 10 second timeout.
- CI installs Claude Code and runs the validate command.

## Out of scope
- userConfig, publishing, adding the marketplace anywhere.

## Notes
- Re-read manifest-reference, marketplace-reference and hooks on code.claude.com and cite them in the log.
- Quote the variable: "\"${CLAUDE_PLUGIN_ROOT}\"/hooks/x.sh", or validate warns.
- Try source "./" for the root plugin first, then ".".
