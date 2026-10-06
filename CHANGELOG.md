# Changelog

Notable changes to Mergehand. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html). While the version is below 1.0, a minor release may change file formats; `mergehand.conf` carries a `version` key so `card` can refuse a format it does not know.

Claude Code keeps an installed plugin at the version in `plugin.json`, so every fix that users should receive comes with a version bump and a tag.

## [0.1.1] - 2026-10-06

### Changed

- The project is renamed from Workdeck to Mergehand, because the old name belongs to an existing product. Version 0.1.0 was released under the old name.
- The plugin and its marketplace are `mergehand`, so the skills are `/mergehand:init`, `/mergehand:next-card`, `/mergehand:handoff` and `/mergehand:quick`.
- The configuration file is `mergehand.conf`, the CI workflow template is `mergehand.yml`, the environment variables are `MERGEHAND_TRANSCRIPT` and `MERGEHAND_SESSION`, and the compaction markers are in `<git-dir>/mergehand/`.
- The `card` command keeps its name and its arguments.

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

[0.1.1]: https://github.com/AshwinSathian/mergehand/releases/tag/v0.1.1
[0.1.0]: https://github.com/AshwinSathian/mergehand/releases/tag/v0.1.0
