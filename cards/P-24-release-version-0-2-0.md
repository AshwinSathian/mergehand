---
id: P-24
title: Release: version 0.2.0
size: XS
depends: P-23
done: false
---

## Read
- docs/evidence.md (the trial record that P-23 wrote)
- docs/design-0.2.md#14-trial-and-release (the last paragraph)
- docs/design-0.2.md#21-build-order (item 11)
- docs/design-0.2.md#22-decisions-locked-and-what-is-deferred (decision 1)
- docs/design-0.2.md#19-claude-code-behavior-this-design-relies-on (row 18)
- CHANGELOG.md
- README.md#upgrade
- README.md#roadmap

## Touch
- bin/card (the version, in the header comment and in VERSION)
- .claude-plugin/plugin.json
- CHANGELOG.md
- README.md (the download line, the Upgrade section and the Roadmap line)
- templates/workdeck.yml (the step that runs `card plan`)
- test/cases/02-plugin.sh

## Tests
- test_plugin_manifest_and_card_agree_on_the_version
- test_workflow_template_runs_card_plan_after_card_lint

## Acceptance
- The question under `Blocked` is answered yes, and the answer is under `Notes` with its date.
- `card version` prints `card 0.2.0`, and `.claude-plugin/plugin.json` has `"version": "0.2.0"`.
- CHANGELOG.md's entry for the planner is headed `## [0.2.0]` with the date of this card, and nothing is left under `## [Unreleased]`.
- templates/workdeck.yml has a second step that runs `card plan`, after the step that runs `card lint`.
- The README's download line names `v0.2.0`, its Upgrade section says what a 0.1 user does, and its Roadmap says 0.2 is released.
- test_repository_has_the_files_a_stranger_looks_for and test_readme_install_line_matches_the_manifests pass.
- Row 18 of design section 19 was read again for this card. The session log gives the result.
- No file changes other than those under `Touch`.

## Out of scope
- The tag, the release notes on the host and repository settings. The maintainer makes the tag on the merge commit of this card.
- Any fix to the planner. A fault the trial found is a card of its own, merged before this one.
- A change to the config, card or log format version.

## Blocked
Has the maintainer read the trial record in docs/evidence.md and decided to release 0.2.0? And does the main branch hold a reachable command or skill of an unfinished 0.3 feature (design section 22, decision 1)? This card goes on only after a yes to the first and a no to the second.

## Notes
- Merging this card is the release for plugin users: they receive the main branch as it is at that commit, whatever the tag is on. Read the main branch, not only this diff, before handoff.
- Between this merge and the tag, the README's download line and a workflow written by init name a tag that does not exist. Make the tag right after the merge.
- The claim is read again through Context7 (`/websites/code_claude`), pages `plugins/host-marketplace` and `plugins/loading`.
