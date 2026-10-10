# Changelog

Notable changes to WorkDeck. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html). While the version is below 1.0, a minor release may change file formats; `workdeck.conf` carries a `version` key so `card` can refuse a format it does not know.

Claude Code keeps an installed plugin at the version in `plugin.json`, so every fix that users should receive comes with a version bump and a tag.

## [Unreleased]

The planner, which the README calls 0.2. It is on the main branch and has no version yet: `card version` and `plugin.json` still say 0.1.3. A new install takes the main branch and receives it; a plugin installed earlier keeps 0.1 until the version changes.

### Added

- The skill `/workdeck:plan <spec path> [what to change]`. It cuts a specification, one markdown file committed in the repository, into an outline with one row per card. A script checks the outline, an agent that did not write it reviews it, you approve it, and it lands through a pull request from a `plan/*` branch that changes nothing else.
- The agent `workdeck:plan-reviewer`, which reviews an outline against its specification.
- `card plan` in five forms: `card plan` checks every outline, `card plan new <spec path> <PREFIX> [--level N]` creates one, `card plan accept <PREFIX>` records the specification the outline was approved against, `card plan start <id>` creates the card file for a row, and `card plan check <id>` checks one card against the working tree.
- Outlines, in `<cards_dir>/plan/`. A row is a card without a body.

### Changed

- `card list`, `card next`, `card status` and `card show` include rows. In a repository with no outline they print what they printed before.
- `/workdeck:next-card` writes the card when it starts a row. It fills the body in against the code as it is, checks it, asks for a yes before any code, and commits the approved card alone.
- `/workdeck:handoff` adds to the pull request body what changed in a planned card since it was approved.
- `/workdeck:init` no longer stops in a repository that has `workdeck.conf`. It offers the permission entries the settings file lacks, lockfiles and generated files for `touch_ignore`, review rules taken from the repository, and the current protocol section. It asks before each. A first run in a new repository also offers the `touch_ignore` entries and the review rules.
- The reviewer agent lists the requirements under a planned card's specification headings that the card neither covers nor excludes.
- The end-of-turn hook does not count commits that change only the cards directory, so the commit of an approved card does not ask for a session log.
- The permission template allows the push of a `plan/*` branch, and denies that push with a further argument and a push that deletes a branch. The protocol section for `CLAUDE.md` has two new lines.

### Upgrading from 0.1

- The configuration, card and session log formats do not change, and `workdeck.conf` stays at `version = 1`. A repository that does not use the planner works as before.
- To plan in a repository set up with 0.1, update the plugin once this is released, run `/workdeck:init` again, and commit what it wrote before you type `/workdeck:plan`. A plugin installed before then has neither the skill nor the changed init.
- A CI workflow that names the tag `v0.1.3` keeps passing on a planned deck, because that `card` does not read outlines. One thing fails it, at that tag and on the main branch: a card written by hand that depends on a row with no card file. The `card` at that tag has no `plan` command.

## [0.1.3] - 2026-10-09

The code of 0.1.2 under the name WorkDeck. The project was renamed after `v0.1.2` was tagged and the version was not changed, so that tag holds the former name, Mergehand.

### Changed

- The configuration file is `workdeck.conf` and the skills are `/workdeck:*`. The plugin and its marketplace are both named `workdeck`. Nothing else differs from 0.1.2.

### Upgrading from 0.1.2

- A plugin installed under the former name stays as it is: its skills are `/mergehand:*` and its `card` reads `mergehand.conf`. Remove it and install `workdeck@workdeck`, as the README's install section says.
- The `card` at the tag `v0.1.2` reads `mergehand.conf`, and exits 2 in a repository with `workdeck.conf`. Download `card` from `v0.1.3`.
- A CI workflow that names the tag `v0.1.2` has to name `v0.1.3`.
- `card` does not read `mergehand.conf`. A repository that still has that file renames it to `workdeck.conf`.

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

[0.1.3]: https://github.com/AshwinSathian/workdeck/releases/tag/v0.1.3
[0.1.2]: https://github.com/AshwinSathian/workdeck/releases/tag/v0.1.2
[0.1.1]: https://github.com/AshwinSathian/workdeck/releases/tag/v0.1.1
[0.1.0]: https://github.com/AshwinSathian/workdeck/releases/tag/v0.1.0
