---
spec: docs/design.md
spec_blob: a3d6da27077d394cb29f5a0f3b1483375a9b5769
prefix: WD
level: 2
---

## WD-01 Plugin manifests and Makefile
- size: S
- spec: 4. Repository layout
- does: `.claude-plugin/plugin.json` exists and names the plugin `workdeck`
- does: `.claude-plugin/marketplace.json` exists with the plugin source `./`
- does: `claude plugin validate --strict` passes on both manifests, and `make validate` names `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` explicitly
- does: `make lint` and `make validate` pass in a tree with only the manifests, because their file lists no longer name `scripts/` or any file that does not exist, and `make lint` skips a pattern that matches nothing
- does: The `bench` target is removed from the Makefile
- not: Skills, agent and hooks directories (WD-02 to WD-09)

## WD-02 Init skill and templates
- size: M
- depends: WD-01
- spec: 10. Skills
- does: `skills/init/SKILL.md` exists with `disable-model-invocation: true` and carries the eight steps of section 10.1 in order
- does: `templates/` holds the files init copies: a `cards/REVIEW.md` with empty rule headings, a PR template, the "WorkDeck session protocol" section for `CLAUDE.md` (about 20 lines, pointing at the four skills) and the CI workflow that downloads `bin/card` at the release tag and runs `card lint`
- does: The skill stops when `workdeck.conf` exists
- does: The skill detects a check command and the default branch and asks the user to confirm both before writing `workdeck.conf`, and shows the `check` command to the user before writing its permission entry
- does: The skill shows the permission entries as a diff before merging them into `.claude/settings.json`, and the entries allow and deny what section 10.1 step 5 lists
- does: The skill offers the CI workflow and offers the `extraKnownMarketplaces` and `enabledPlugins` entries, and writes neither without a yes
- does: The skill does not commit and does not create the log directory
- does: The skill ends by printing the next step: write a card with `card new`, or use `/workdeck:quick`
- not: The other three skills (WD-03, WD-04, WD-05)

## WD-03 Next-card skill and implement reference
- size: S
- depends: WD-01
- spec: 10. Skills
- does: `skills/next-card/SKILL.md` exists with `disable-model-invocation: true` and carries steps 1 to 9 of section 10.2, including resuming a card in progress and removing a `## Blocked` section once answered
- does: `reference/implement.md` holds the implementation steps shared by next-card and quick (read only `Read` and `Touch`, a plan of at most 10 lines, tests first and seen failing, run only touched tests while iterating)
- does: The skill runs `card status --fetch` first and stops on a dirty tree
- not: The quick skill, which reuses `reference/implement.md` (WD-05)
- not: Handoff, which the user types next (WD-04)

## WD-04 Handoff skill and gates
- size: M
- depends: WD-01
- spec: 10. Skills
- spec: 11. Mechanical gates
- spec: 15. Errors
- does: `skills/handoff/SKILL.md` exists with `disable-model-invocation: true` and carries steps 1 to 8 of section 10.3, including the `split` mode
- does: The skill runs the gates in the order format (`card lint`), scope (`card touched <id>`), tests (`card tests <id>`) and stops at the first failure
- does: The skill resolves a scope or tests failure by one of the two ways of section 11 and says that the change shows in the PR diff
- does: The skill runs the reviewer agent `workdeck:reviewer` with the card id and the base branch, skips it for an XS card only when `reviewer = off`, and lists unfixed `should-fix` findings in the PR body
- does: The skill stops before the push, saying what remains, when the repository has no remote or there is no network
- does: The skill stops after the push, printing the PR URL for opening by hand, when `gh` is missing or not signed in
- does: The skill stops after reporting and does not start a second card
- not: The reviewer agent itself (WD-06)
- not: The `card` gate commands, which exist in `bin/card`
- not: The hook behaviour in section 15, which belongs to the hook rows (WD-07 to WD-09)

## WD-05 Quick skill
- size: XS
- depends: WD-03
- spec: 10. Skills
- does: `skills/quick/SKILL.md` exists with `disable-model-invocation: true` and carries steps 1 to 3 of section 10.4
- does: The skill creates an XS card with the id `Q-<yymmddhhmm>` from the current time, leaves `Read` empty and fills `Touch`, `Tests` and `Acceptance` from the description after reading the relevant code
- does: The skill shows the card to the user for a yes or an edit before creating the branch
- does: The skill follows `reference/implement.md` from the branch step

## WD-06 Reviewer agent
- size: S
- depends: WD-01
- spec: 12. Reviewer agent
- does: `agents/reviewer.md` exists, addressed as `workdeck:reviewer`, with the tools Read, Grep, Glob and Bash only
- does: The agent receives a card id and a base branch and follows the four steps of section 12, including checking every rule in `cards/REVIEW.md`
- does: The agent is told to assume the code has defects
- does: The agent reports findings as `must-fix`, `should-fix` or `nit`, each with file and line, the problem in one sentence and a failure scenario, and one line per category when it finds nothing

## WD-07 Hook registration and session-start hook
- size: S
- depends: WD-01
- spec: 13. Hooks
- does: `hooks/hooks.json` registers `SessionStart`, `PostToolUse`, `Stop` and `PreCompact`, each with a timeout of 10 seconds, calling its script by `${CLAUDE_PLUGIN_ROOT}` path
- does: `hooks/session-start.sh` prints `card status` and stays under `status_max_chars`
- does: `hooks/session-start.sh` appends `export WORKDECK_TRANSCRIPT=` and `export WORKDECK_SESSION=` to `$CLAUDE_ENV_FILE`
- does: `session-start.sh` prints nothing and exits 0 when the project has no `workdeck.conf`
- does: `session-start.sh` does not pass `--fetch`
- does: A shell test checks that `hooks/hooks.json` maps each of the four events to its script name with a timeout of 10 seconds (it does not require the other three scripts to exist yet), and one runs the hook with fixture JSON on stdin in a project without `workdeck.conf` and asserts no output and exit 0
- not: The other three hook scripts (WD-08, WD-09)

## WD-08 Budget warning and compaction hooks
- size: S
- depends: WD-07
- spec: 13. Hooks
- does: `hooks/post-tool-use.sh` does nothing off a `card/*` branch
- does: It reads the transcript path from the hook's stdin `transcript_path`, the card id from the `card/<id>` branch name, and the growth and budget from `card tokens`, and does not parse the transcript itself
- does: On a `card/*` branch, when growth exceeds the card's budget and no warning file exists for the session, it returns `additionalContext` with the measured figure and the instruction to ask the user to run `/workdeck:handoff split`, then writes the warning file under `<git-dir>/workdeck/`
- does: When `card tokens` reports `unknown`, it skips the check and warns about nothing
- does: It warns once per session and never blocks
- does: A tool call made by a subagent (input carries `agent_id`) is ignored
- does: `hooks/pre-compact.sh` writes the compaction marker as `<git-dir>/workdeck/<session_id>.compacted` (the file `session_compacted` in `bin/card` reads) and never blocks
- does: Both scripts exit 0 at once without `workdeck.conf`
- does: Shell tests cover each of the above with fixture transcripts and JSON on stdin
- not: The log guard (WD-09)

## WD-09 Stop log guard
- size: XS
- depends: WD-07
- spec: 13. Hooks
- does: On a `card/*` branch with commits, a clean tree and no log file for the card added on the branch, `hooks/stop.sh` blocks with a message to run handoff or to record a blocked outcome
- does: `stop.sh` exits 0 when `stop_hook_active` is true
- does: `stop.sh` exits 0 off a `card/*` branch and without `workdeck.conf`
- does: Shell tests cover each of the above

## WD-10 Skill and plugin tests and CI
- size: M
- depends: WD-02, WD-03, WD-04, WD-05, WD-06, WD-07, WD-08, WD-09
- spec: 17. Testing
- does: Shell tests check each skill's front matter (`disable-model-invocation: true`) and that every `card` command a skill names exists
- does: A shell test checks that handoff names the gates in the order lint, touched, tests
- does: A shell test checks that every script registered in `hooks/hooks.json` exists and is executable
- does: `make validate` passes against `.claude-plugin/`, `skills/` and `agents/`, and `make lint` covers `hooks/*.sh`
- does: The CI workflow still runs on macOS with `/bin/bash` and on Linux, running `shellcheck` over the hook scripts and `claude plugin validate --strict` on both manifests and on `agents/` and `skills/`
- not: Tests of a single hook, which come with the hook (WD-07 to WD-09)

## WD-11 README
- size: XS
- spec: 14. Token measurement
- spec: 18. Risks
- does: `README.md` exists and gives the install commands `/plugin marketplace add AshwinSathian/workdeck` and `/plugin install workdeck@workdeck`
- does: `README.md` gives a one-line download of `bin/card` at a release tag, for people and CI without Claude Code
- does: `README.md` states the four known limits of section 14: the transcript format is not a documented interface, a resumed session keeps its first baseline, subagent turns are not counted, and a budget is a warning threshold only
- does: `README.md` says plainly that 0.1 runs cards and 0.2 writes them
- not: Any change to the transcript measurement, which `bin/card tokens` already does

## Not planned
- 1. What WorkDeck is
- 2. Goals and non-goals
- 3. Decisions already made
- 5. Card format
- 6. State model
- 7. Session log format
- 8. Configuration
- 9. The `card` command
- 16. Trust and input handling
- 19. Changes from the adversarial review
- 20. Open questions
