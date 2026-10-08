---
id: P-20
title: Changelog entry for 0.2, not yet released
size: XS
depends: P-18, P-19
done: false
---

## Read
- docs/design-0.2.md#41-the-plugin (the list of what 0.2 adds and changes)
- docs/design-0.2.md#21-build-order (items 9 and 11)
- CHANGELOG.md

## Touch
- CHANGELOG.md
- test/cases/02-plugin.sh

## Tests
- test_changelog_has_an_unreleased_entry_for_the_planner

## Acceptance
- CHANGELOG.md has an entry headed `## [Unreleased]`, above the entry for 0.1.2, that lists what 0.2 adds and changes in the form of the entries for 0.1.
- The entry says that the config, card and log formats stay at `version = 1`, and what a 0.1 user does to plan.
- The entry carries no version number and no date.
- `card version` still prints `card 0.1.2`, and `.claude-plugin/plugin.json` still has `"version": "0.1.2"`.
- test_repository_has_the_files_a_stranger_looks_for passes.

## Out of scope
- The version, the README's download line and the heading `## [0.2.0]`. P-24 owns them.
- Any other text of the README. P-19 owns it.
- The tag and the release.

## Notes
- The version is not changed here on purpose. Claude Code delivers the plugin to everyone who installed it when `version` in `plugin.json` changes on the main branch (design section 19, row 18), and that must wait for the trial.
- If the trial changes the plan skill or the outline format, the card that makes the change adds a line to this entry.
