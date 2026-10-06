# Changelog

Notable changes to Workdeck. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html). While the version is below 1.0, a minor release may change file formats; `workdeck.conf` carries a `version` key so `card` can refuse a format it does not know.

Claude Code keeps an installed plugin at the version in `plugin.json`, so every fix that users should receive comes with a version bump and a tag.

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
