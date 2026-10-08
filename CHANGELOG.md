# Changelog

Notable changes to WorkDeck. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html). While the version is below 1.0, a minor release may change file formats; `workdeck.conf` carries a `version` key so `card` can refuse a format it does not know.

Claude Code keeps an installed plugin at the version in `plugin.json`, so every fix that users should receive comes with a version bump and a tag.

## [Unreleased]

### Changed

- The project is called WorkDeck again. The name Mergehand, used in 0.1.1 and 0.1.2, is dropped. The plugin and its marketplace are `workdeck`, so the skills are `/workdeck:init`, `/workdeck:next-card`, `/workdeck:handoff` and `/workdeck:quick`.
- The configuration file is `workdeck.conf`, the CI workflow template is `workdeck.yml`, the environment variables are `WORKDECK_TRANSCRIPT` and `WORKDECK_SESSION`, and the compaction markers are in `<git-dir>/workdeck/`.

### Moving from 0.1.1 or 0.1.2

Nothing reads the Mergehand names, so a repository set up with those versions does nothing until it is moved:

1. Uninstall the old plugin and remove its marketplace, then install `workdeck@workdeck`.
2. Rename `mergehand.conf` to `workdeck.conf`.
3. In `CLAUDE.md`, change the section heading to `## WorkDeck session protocol` and the skill names in it to `/workdeck:`.
4. In `.claude/settings.json`, change any `mergehand` entry that init added.
5. Rename the workflow file `mergehand.yml` to `workdeck.yml` if you copied the template.

## [0.1.2] - 2026-10-06

### Fixed

- The quick skill did not say that a card item starts with `- `. In the first run from the marketplace it wrote bare lines under `Touch`, and the scope gate did not match them. The skill now says so and runs `card lint` before it shows the card.
- `card lint` reported such a section as having no items, with no hint. The message now says what an item is.

## [0.1.1] - 2026-10-06

### Changed

- The project is renamed from WorkDeck to Mergehand, because the old name belongs to an existing product. Version 0.1.0 was released under the old name.
- The plugin and its marketplace are `mergehand`, so the skills are `/mergehand:init`, `/mergehand:next-card`, `/mergehand:handoff` and `/mergehand:quick`.
- The configuration file is `mergehand.conf`, the CI workflow template is `mergehand.yml`, the environment variables are `MERGEHAND_TRANSCRIPT` and `MERGEHAND_SESSION`, and the compaction markers are in `<git-dir>/mergehand/`.
- The `card` command keeps its name and its arguments.
- The README shows a session, compares the plugin with other projects, and has sections on upgrading and on what to do when a skill stops. The command list, the card states and the configuration keys moved to `docs/reference.md`.
- Releases carry `card` and `card.sha256`.

### Fixed

- The handoff skill told the user to push when the repository has no remote. It now says to merge the branch, or to add a remote.
- The init skill and the design said teammates get the plugin from the project settings. Each teammate installs it once.
- `SECURITY.md` said `card --fetch` was the only network access in the plugin. The skills pull, push and call `gh`.
- The README said the license card was the last card of 0.1 and that the project was built in the open. Neither was true.

### Moving from 0.1.0

Nothing reads the old names, so a repository set up with 0.1.0 does nothing until it is moved:

1. Uninstall the old plugin and remove its marketplace, then install `mergehand@mergehand`.
2. Rename `workdeck.conf` to `mergehand.conf`.
3. In `CLAUDE.md`, change the section heading to `## Mergehand session protocol` and the skill names in it to `/mergehand:`.
4. In `.claude/settings.json`, change any `workdeck` entry that init added.

## [0.1.0] - 2026-10-06

First release: the core, the runner and the quick lane.

### Added

- `card`, a single-file bash command: `next`, `show`, `list`, `status`, `new`, `done`, `lint`, `touched`, `tests`, `tokens`, `log-new`, `stats`, `conf`.
- Card files with flat front matter, and one session log per session.
- Card state derived from branches, pull requests and the base branch; nothing is stored but `done`.
- Two mechanical gates: `card touched` (scope) and `card tests` (named tests exist).
- Context growth measured from the session transcript and recorded in each session log.
- Four hooks: session status, a budget warning, a log guard and a compaction marker.
- Skills `/mergehand:init`, `/mergehand:next-card`, `/mergehand:handoff` and `/mergehand:quick`, and a reviewer agent.

### Not in this release

- Writing cards from a specification (planned for 0.2).
- Claiming cards, worktrees and parallel sessions (planned for 0.3).
- Hosts other than GitHub for the pull request step, and native Windows shells.

[0.1.2]: https://github.com/AshwinSathian/workdeck/releases/tag/v0.1.2
[0.1.1]: https://github.com/AshwinSathian/workdeck/releases/tag/v0.1.1
[0.1.0]: https://github.com/AshwinSathian/workdeck/releases/tag/v0.1.0
