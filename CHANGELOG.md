# Changelog

Notable changes to WorkDeck. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html). While the version is below 1.0, a minor release may change file formats; `workdeck.conf` carries a `version` key so `card` can refuse a format it does not know.

Claude Code keeps an installed plugin at the version in `plugin.json`, so every fix that users should receive comes with a version bump and a tag.

## [0.1.2] - 2026-10-06

### Fixed

- The quick skill did not say that a card item starts with `- `. In the first run from the marketplace it wrote bare lines under `Touch`, and the scope gate did not match them. The skill now says so and runs `card lint` before it shows the card.
- `card lint` reported such a section as having no items, with no hint. The message now says what an item is.

## [0.1.1] - 2026-10-06

### Changed

- The README shows a session, compares the plugin with other projects, and has sections on upgrading and on what to do when a skill stops. The command list, the card states and the configuration keys moved to `docs/reference.md`.
- Releases carry `card` and `card.sha256`.

### Fixed

- The handoff skill told the user to push when the repository has no remote. It now says to merge the branch, or to add a remote.
- The init skill and the design said teammates get the plugin from the project settings. Each teammate installs it once.
- `SECURITY.md` said `card --fetch` was the only network access in the plugin. The skills pull, push and call `gh`.
- The README said the license card was the last card of 0.1 and that the project was built in the open. Neither was true.

## [0.1.0] - 2026-10-06

First release: the core, the runner and the quick lane.

### Added

- `card`, a single-file bash command: `next`, `show`, `list`, `status`, `new`, `done`, `lint`, `touched`, `tests`, `tokens`, `log-new`, `stats`, `conf`.
- Card files with flat front matter, and one session log per session.
- Card state derived from branches, pull requests and the base branch; nothing is stored but `done`.
- Two mechanical gates: `card touched` (scope) and `card tests` (named tests exist).
- Context growth measured from the session transcript and recorded in each session log.
- Four hooks: session status, a budget warning, a log guard and a compaction marker.
- Skills `/workdeck:init`, `/workdeck:next-card`, `/workdeck:handoff` and `/workdeck:quick`, and a reviewer agent.

### Not in this release

- Writing cards from a specification (planned for 0.2).
- Claiming cards, worktrees and parallel sessions (planned for 0.3).
- Hosts other than GitHub for the pull request step, and native Windows shells.

[0.1.2]: https://github.com/AshwinSathian/workdeck/releases/tag/v0.1.2
[0.1.1]: https://github.com/AshwinSathian/workdeck/releases/tag/v0.1.1
[0.1.0]: https://github.com/AshwinSathian/workdeck/releases/tag/v0.1.0
