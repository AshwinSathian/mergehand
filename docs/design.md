# Mergehand 0.1 design

This is the design the build followed. Sections 19, 19.1 and 19.2 list every change made to it and why. How the build went is in [`development/`](development/).

Date: 2026-10-05
Status: implemented. Approved 2026-10-05 after adversarial review; amended during the build (sections 19 to 19.2)
Scope: release 0.1 (core, runner, quick lane). The planner (0.2) and team features (0.3) get their own specs.

## 1. What Mergehand is

Mergehand is a Claude Code plugin that runs a software project as a series of cards. A card is one unit of work sized to fit one agent session without context compaction. Each card names what to read, which files to touch, which tests must exist and what must be true at the end. A session takes one card, implements it, passes the project's check command, gets an independent review and opens one pull request. A person merges.

The plugin installs the engine: skills, hooks, a reviewer agent and a `card` command. An init skill writes the project side into the repository: cards, session logs, a config file, a PR template and a short protocol section in `CLAUDE.md`.

## 2. Goals and non-goals

Goals for 0.1:

1. A repository with hand-written cards can run the full loop: start a card, implement, hand off, open a PR.
2. Small changes and bug fixes have a lane that skips planning but keeps the check, the review and the PR.
3. Session context growth is measured in tokens, recorded per card, and compared against the card's size.
4. Rules that can be checked by a script are checked by a script, not left to instructions the agent may ignore.
5. Card and log files never produce merge conflicts when several branches are open, so 0.3 can add parallel work without a format change.

Not in 0.1:

- Generating cards from a specification or onboarding an existing codebase (0.2).
- Claiming cards, worktrees and parallel sessions (0.3). The file formats allow them; no command implements them yet.
- Agent harnesses other than Claude Code.
- Hosts other than GitHub for the PR step. Everything before the PR step needs only git.
- Native Windows shells. The scripts need bash and awk.

## 3. Decisions already made

| Decision | Choice | Reason |
|---|---|---|
| Form | Claude Code plugin plus an init skill | A plugin can ship skills, agents, hooks and executables. It cannot ship permissions or a `CLAUDE.md`, so those are written into the repository by init. |
| Harness | Claude Code only | Hooks and subagents are what make the rules enforceable. |
| State | One file per card, one file per session log, generated status | A single status file and a single log conflict on every parallel merge, and a hand-edited status file grows without limit. |
| In-progress state | Derived from branches and PRs, not stored | No commit is needed to claim a card, and a stale claim cannot be left behind in a file. |
| Scripts | One bash file, `bin/card`, using only git, awk, sed, grep, sort and the standard POSIX tools. It must run on bash 3.2, the version macOS ships. | Nothing to install, and one file can be fetched by CI or a person without the plugin. Ceiling: no native Windows. Upgrade path: a single Go binary with the same commands. |
| Handoff trigger | The user types `/mergehand:handoff` | Handoff pushes a branch and opens a PR. A person starts that. Skills with `disable-model-invocation` also cannot call each other. |
| Command name | `card` | `deck` is taken by two existing command-line tools. |

## 4. Repository layout

### 4.1 The plugin (this repository)

```
.claude-plugin/plugin.json
.claude-plugin/marketplace.json     # this repo is its own marketplace; plugin source "./"
skills/init/SKILL.md
skills/next-card/SKILL.md
skills/handoff/SKILL.md
skills/quick/SKILL.md
agents/reviewer.md
hooks/hooks.json
hooks/session-start.sh
hooks/stop.sh
hooks/pre-compact.sh
hooks/post-tool-use.sh
bin/card                             # single file; on the Bash tool's PATH while the plugin is enabled
reference/implement.md               # implementation steps shared by next-card and quick
templates/                           # files init copies into a project
test/                                # shell tests and fixture repositories
```

Users install with `/plugin marketplace add AshwinSathian/mergehand` and `/plugin install mergehand@mergehand`. Skills are invoked as `/mergehand:init`, `/mergehand:next-card`, `/mergehand:handoff` and `/mergehand:quick`. The reviewer agent is addressed as `mergehand:reviewer`.

This repository is also a Mergehand project: its own `mergehand.conf`, `cards/` and `log/` sit at the root, beside `docs/`, `examples/`, `scripts/` and the usual repository files.

The plugin's `bin/` is on the PATH only for commands Claude runs through the Bash tool. Hooks and the commands a skill injects with `!` call `${CLAUDE_PLUGIN_ROOT}/bin/card` by full path.

People and CI need `card` without Claude Code. Because it is one file that needs only git and standard Unix tools, the README gives a one-line download of `bin/card` at a release tag, and init offers a CI workflow that does the same and runs `card lint`.

### 4.2 A project that uses Mergehand

```
mergehand.conf
cards/AUTH-03-token-refresh.md       # one file per card
cards/REVIEW.md                      # project rules the reviewer must check; owned by the project
log/2026-10-05-AUTH-03-1.md          # one file per session
.github/pull_request_template.md     # only if the project has none
.github/workflows/mergehand.yml       # optional: runs card lint on pull requests
CLAUDE.md                            # gains one "Mergehand session protocol" section
.claude/settings.json                # gains permission entries and the marketplace reference
```

`cards/` and `log/` are the defaults. Both paths are set in `mergehand.conf`.

## 5. Card format

```
---
id: AUTH-03
title: Token refresh
size: M
depends: AUTH-02
done: false
---

## Read
- docs/auth.md#refresh
- src/auth/session.ts

## Touch
- src/auth/refresh.ts (new)
- src/auth/refresh.test.ts (new)

## Tests
- refresh rotates the token
- expired refresh token is rejected

## Acceptance
- Binary statements. All must hold.

## Out of scope
- What this card must not do, and which card owns it.

## Notes
- Traps, decisions, hints.
```

Rules:

- The front matter is flat `key: value` lines between two `---` lines. It is not parsed as YAML. Nested values, quotes and multi-line values are lint errors.
- `id` matches `[A-Z][A-Z0-9]*-[0-9]+[a-z]?`. The file name starts with the id. Every command validates an id against this pattern before using it in a branch name or a search pattern.
- `title` is at most 80 characters with no control characters.
- `size` is one of the sizes defined in `mergehand.conf`. The defaults are `XS`, `S` and `M`.
- `depends` is a comma-separated list of ids, or empty.
- `done` is `true` or `false`. It is the only state stored in the file.
- `Read`, `Touch`, `Tests` and `Acceptance` are required sections, except that an `XS` card may leave `Read` empty.
- `Touch` entries are paths or globs relative to the repository root. The text after the first space is a comment. An entry ending in `/` covers everything under that directory, and a leading `/` or `./` is ignored.
- A card that is waiting on a person adds a `## Blocked` section with the question.
- A split card keeps its id for the finished part. The remainder becomes a new card with a letter suffix (`AUTH-03b`) that depends on the original.

Order is by id in natural sort order (`sort -V`), so `AUTH-2` comes before `AUTH-10`. Order across prefixes is alphabetical; `depends` expresses any ordering that matters.

## 6. State model

A card is in exactly one state, computed by `card` when asked. The first matching row wins:

| State | Condition |
|---|---|
| `done` | `done: true` in the card file as it exists on the base branch |
| `review` | an open PR exists from the card's branch |
| `blocked` | the card's branch exists and the card has a `## Blocked` section on it |
| `active` | the card's branch exists, locally or on the remote |
| `ready` | not done, no branch, every dependency done |
| `waiting` | not done, no branch, a dependency not done |

A card's branch is `card/<id>-<slug>`, or `card/<id>` when the card has no slug. Only the `card/<id>` prefix matters to state.

`done: true` is written on the card branch by handoff, so it reaches the base branch only when the PR merges. An abandoned branch holds its card `active` until the branch is deleted; deleting the branch releases the card.

The set of cards is the union of the card files on the base branch and those in the working tree. A card that exists only on the current branch (a quick card, or the remainder of a split) takes its `done` value from the working tree, unless it has a branch or an open pull request of its own: then `done: true` means only that handoff ran, and the card is `review`, `blocked` or `active` until it merges. For every other card, `done` is read from the base branch: from `origin/<base>` and from the local base branch, and done on either counts, because done never reverts. A merge made locally therefore counts before it is pushed, and one made on the remote counts as soon as it is fetched. Reading the working tree would be wrong: on a card branch after handoff it already says `done: true` although nothing has merged.

Branches come from the refs already in the local repository (`git for-each-ref`). `card` makes no network call unless given `--fetch`, which runs `git fetch --prune` first and reads open PRs with `gh pr list`. The session-start hook never passes `--fetch`, so starting a session is fast and works offline. `next-card` does pass it. Without `--fetch`, a card with an open PR is reported as `active`. With `--fetch` but without a working `gh`, it is also reported as `active` and `card` says so on stderr.

## 7. Session log format

One file per session, named `<date>-<id>-<n>.md`, where `n` is the next free number for that card on that date.

```
---
card: AUTH-03
date: 2026-10-05
outcome: done
branch: card/AUTH-03-token-refresh
pr: 42
size: M
budget_tokens: 100000
baseline_tokens: 57000
peak_tokens: 141300
growth_tokens: 84300
compacted: false
---

## Done
## Tests
## Deviations
## Follow-ups
```

`outcome` is one of `done`, `split`, `blocked`, `review-fixes`. The measured fields (`budget_tokens`, `baseline_tokens`, `peak_tokens`, `growth_tokens`, `compacted`) are written by `card log-new`, not by the agent. `pr` is optional: the log is committed before the PR exists, so `card log-new` does not write it and a person may add it later. The text after the front matter is limited to 40 lines; `card lint` enforces the limit.

## 8. Configuration

`mergehand.conf` is `key = value` lines with `#` comments. It is parsed with awk and never sourced, because sourcing would run whatever the repository contains.

| Key | Default | Meaning |
|---|---|---|
| `version` | `1` | Format version of the config, card and log files. `card` refuses a version it does not know. |
| `check` | none, required | Command that must pass before handoff, for example `make check` or `npm test` |
| `base` | `main` | Branch that cards start from and PRs target |
| `cards_dir` | `cards` | Where card files live |
| `log_dir` | `log` | Where session logs live |
| `budget.XS` | `35000` | Growth budget in tokens for an XS card |
| `budget.S` | `70000` | Growth budget in tokens for an S card |
| `budget.M` | `100000` | Growth budget in tokens for an M card |
| `touch_ignore` | empty | Comma-separated globs the scope gate ignores, for lockfiles and generated files |
| `status_max_chars` | `6000` | Cap on the session-start status text |
| `reviewer` | `on` | `off` skips the reviewer agent for XS cards only |

A budget limits growth: the peak context size of the session minus its size at the first turn. The first-turn size is the baseline, which holds the system prompt, tool definitions, installed plugins and hook output. It is commonly tens of thousands of tokens and differs between machines, so an absolute budget would mean something different for every user. The defaults assume a 200,000-token window with a baseline near 60,000. `card stats` exists so a project can replace them with numbers from its own sessions.

## 9. The `card` command

| Command | Behavior |
|---|---|
| `card next` | Prints the first `ready` card in natural id order (section 5), or says that none is ready and why. When a card is held by a branch it says that deleting the branch releases it, without naming the branch. |
| `card show <id>` | Prints one card |
| `card list` | One line per card: state, id, size, title |
| `card status` | Current branch and its card, cards in `active`, `review` and `blocked`, the next ready card, and the last log entry for the current card. Truncated to `status_max_chars` with a note when cut. |
| `card new <id> <title> [--size S] [--depends ids]` | Creates a card file from the template |
| `card done <id>` | Sets `done: true` in the card file |
| `card lint` | Checks every card and log file. Exit 1 on any error. |
| `card touched <id>` | Compares the files changed against `base` with the card's `Touch` list. Files under `cards_dir` and `log_dir` and files matching `touch_ignore` are skipped. Entries are matched as shell `case` patterns, so `*` also matches `/`. Prints files changed but not listed, and files listed but not changed. Exit 1 when unlisted files changed. "Changed" means different from the point where the branch left the base branch, including uncommitted and untracked files, because handoff runs the gates before it commits. |
| `card tests <id>` | The tests gate of section 11. Prints each `Tests` line that has no match in the files changed. Exit 1 when any is missing. |
| `card conf <key>` | Prints one configuration value with its default applied. Skills and hooks read `check`, `base` and `log_dir` this way. |
| `card tokens [transcript]` | Prints baseline, peak and growth for a session transcript. Defaults to `$MERGEHAND_TRANSCRIPT`. On a card branch it also prints the card's budget and size. |
| `card log-new <id> <outcome>` | Creates the log file with the measured fields filled in and empty sections for the agent |
| `card stats` | Per size: number of sessions, budget, median and maximum `growth_tokens`, share that compacted |

`card lint` checks: front matter keys and values, id format and file name, duplicate ids, dependencies that name no card, dependency cycles, required sections, sizes that have no budget, and log entry length.

Exit codes: 0 success, 1 a check failed, 2 usage or configuration error. Every error message starts with `card:` and names the file.

## 10. Skills

All four skills set `disable-model-invocation: true`. They run only when the user types them.

### 10.1 `/mergehand:init`

1. Stop if `mergehand.conf` exists, and say so.
2. Detect a check command from the project (`Makefile` target, `package.json` script, and similar) and the default branch. Ask the user to confirm both.
3. Write `mergehand.conf`, `cards/REVIEW.md` (a template with empty rule headings) and a PR template if the project has none. The log directory is created by the first `card log-new`.
4. Append the session protocol section to `CLAUDE.md`, creating the file if needed. The section is about 20 lines and points at the skills.
5. Show the user the permission entries as a diff, then merge them into `.claude/settings.json` on approval: allow `card`, the check command, read-only git commands, pushing `card/*` branches and `gh pr create`; deny force-push, `git reset --hard`, branch deletion and `gh pr merge`.
6. Offer the CI workflow that downloads `bin/card` at the installed release tag and runs `card lint` on pull requests.
7. Offer to add the marketplace under `extraKnownMarketplaces` and the plugin under `enabledPlugins` in `.claude/settings.json`, so teammates who open the repository are prompted to install it.
8. Print the next step: write a card with `card new`, or use `/mergehand:quick`.

Init does not commit. The user reviews and commits the result.

### 10.2 `/mergehand:next-card [id]`

1. Run `card status --fetch`.
2. If the current user has an open card PR with changes requested, check out that branch and address the comments. Do not start a new card.
3. If the working tree is dirty, stop and ask.
4. Update the base branch with a fast-forward pull.
5. Pick the requested card or `card next`. If it is `active` or `blocked` and its branch is local, offer to resume it on that branch. Otherwise stop if it is not `ready`, and name the dependency or branch that prevents it.
6. If the card has a `## Blocked` section, ask the question before writing code. Once it is answered, remove the section and record the answer under `Notes`.
7. Create the branch `card/<id>-<slug>`.
8. Follow `reference/implement.md`: read what the card lists under `Read` plus the code under `Touch`, and do not read further without saying why; state a plan of at most 10 lines; write the tests named on the card and confirm they fail for the expected reason; implement until they pass, running only the touched tests while iterating.
9. Tell the user the card is ready and that `/mergehand:handoff` is the next command. Handoff is typed by the user (section 3).

Other people's open PRs do not block step 5. Only an unmerged dependency does.

### 10.3 `/mergehand:handoff [split]`

1. Run the `check` command. Fix failures that belong to this card. Report failures that predate it and stop.
2. Run the mechanical gates (section 11).
3. Run the reviewer agent with the card id and the base branch (skipped for an XS card when `reviewer = off`). Fix every `must-fix` finding. List unfixed `should-fix` findings in the PR body with a reason.
4. Split mode: create the remainder card with `card new <id>b`, move the unfinished items to it, and edit the current card so its `Acceptance` describes only what is done.
5. `card done <id>`.
6. `card log-new <id> <outcome>`, then fill in the four sections.
7. Commit, push the branch, and open the PR with the template filled in. If `gh` is missing or not authenticated, stop after the push and print the URL for opening the PR by hand.
8. Report the PR URL, the findings left open, measured tokens against budget, and the next ready card. Then stop. A session does not start a second card.

### 10.4 `/mergehand:quick "<description>"`

For a change that needs no plan: a bug fix, a rename, a small addition.

1. Create an `XS` card with the id `Q-<yymmddhhmm>` from the current time (`Q-2610051432`). A counter would give two people the same id on separate branches. `Touch`, `Tests` and `Acceptance` are filled in from the description after reading the relevant code. `Read` stays empty.
2. Show the card to the user for a yes or an edit.
3. Create the branch and follow `reference/implement.md`, as `next-card` does from its step 7.

If the work passes the `XS` budget, the budget hook says so. If it touches files beyond the card, the scope gate fails at handoff. Either way the user decides whether to split or to write a proper card.

## 11. Mechanical gates

Handoff runs these in order and stops at the first failure:

| Gate | Command | Fails when |
|---|---|---|
| Format | `card lint` | any card or log file is malformed |
| Scope | `card touched <id>` | a changed file matches no `Touch` entry |
| Tests | search the files changed on the branch for each `Tests` line | a named test is missing |

A scope failure has two valid resolutions: revert the stray change, or add the file to `Touch` with a comment saying why. The second is visible in the PR diff, so the reviewer and the person merging both see that the scope grew.

The tests gate lowercases each `Tests` line and each line of the changed files, strips every character that is not a letter or digit, and looks for the first inside the second. `refresh rotates the token` therefore matches `test_refresh_rotates_the_token`, `TestRefreshRotatesTheToken` and `it('refresh rotates the token')`. A failure is resolved like a scope failure: rename the test or edit the card line, and the edit shows in the diff. The name must appear on one line: the name of a `describe` block, a class or a module is not joined to the name inside it, so a card line is written as the innermost name. It is a presence check. Whether the test asserts the right thing is the reviewer's job.

## 12. Reviewer agent

`agents/reviewer.md` is read-only: Read, Grep, Glob and Bash. It receives the card id and the base branch, and it works from the diff and the card. It did not write the code and is told to assume the code has defects.

Procedure:

1. For each `Acceptance` item and each `Tests` line, find the code or test that satisfies it and confirm the test asserts what the card says. Run the touched tests.
2. Check every rule in `cards/REVIEW.md` against the diff.
3. Look for behavior that contradicts a document listed under `Read` with no change to that document in the same diff.
4. Look for changes outside the card's stated scope.

Output: findings marked `must-fix`, `should-fix` or `nit`, each with file and line, the problem in one sentence, and a concrete failure scenario. One line per category when it finds nothing.

`cards/REVIEW.md` is where a project puts its own rules: architectural constraints, security checklists, banned patterns. The plugin ships no project rules.

## 13. Hooks

Every hook exits 0 at once when the project has no `mergehand.conf`. Plugin hooks run in every project where the plugin is enabled, so this check comes first in each script.

| Event | Script | Behavior |
|---|---|---|
| `SessionStart` | `session-start.sh` | Prints `card status`. Output stays under `status_max_chars`, which must be below the harness limit of 10,000 characters for injected context. |
| `PostToolUse` | `post-tool-use.sh` | Budget warning, described below. |
| `Stop` | `stop.sh` | Log guard, described below. |
| `PreCompact` | `pre-compact.sh` | Writes a marker file for the session. Never blocks. |

Every hook sets a 10-second timeout. Session state lives in `<git-dir>/mergehand/`, which is per worktree and never committed: one file per session id for the compaction marker and one for the budget warning.

The session-start hook also appends `export MERGEHAND_TRANSCRIPT=<transcript_path>` and `export MERGEHAND_SESSION=<session_id>` to `$CLAUDE_ENV_FILE`. That is the documented way to hand a value from a hook to later Bash tool commands, and it is how `card tokens` and `card log-new` find the transcript.

Budget warning (`PostToolUse`, on a `card/*` branch only). After each tool call the hook computes growth from the transcript. When growth exceeds the card's budget and no warning file exists for the session, it returns `additionalContext` with the measured figure and the instruction to finish the current step and ask the user to run `/mergehand:handoff split`, then writes the warning file. It warns once per session and never blocks. Tool calls made by a subagent are ignored (the hook input carries `agent_id`), so the reviewer cannot use up the one warning. A `Stop` hook would be too late for this: it fires only when a turn ends, and one long turn can run from under budget to compaction. Measured on macOS: 2 ms when the session is not on a card branch, 4 ms once the warning has been given, and about 45 ms on a card branch with a 2 MB transcript (127 ms at 20 MB). The cost is dominated by process start-up, not by parsing, and grows with the transcript because the whole file is read each time.

Log guard (`Stop`, on a `card/*` branch only). If the branch has commits, the tree is clean and no log file for this card was added on the branch, block with a message to run handoff, or to record a blocked outcome when the session is waiting on a person.

The hook exits 0 when `stop_hook_active` is true, so it can never loop.

Known limit: the log guard passes once any log file for the card exists on the branch, so a later review-fixes session on the same branch is not forced to add its own entry. Handoff still writes one.

`PreCompact` does not block because blocking compaction on a full context window would leave the session unable to continue. Recording it is enough: the log entry shows `compacted: true`, and `card stats` shows how often each size compacts.

## 14. Token measurement

Hooks receive `transcript_path` but no token counts. The transcript is JSON Lines, and each assistant message carries a `usage` object. The context size of a turn is `input_tokens + cache_creation_input_tokens + cache_read_input_tokens`. `card tokens` extracts these with grep and awk. Baseline is the first turn's size, peak is the largest, and growth is peak minus baseline. The transcript is append-only, so the peak survives compaction.

Known limits, stated in the README:

- The transcript format is not a documented interface. If the fields are missing, `card tokens` prints `unknown`, the budget check is skipped and the log records `unknown` for the measured fields. Nothing fails. A fixture transcript in `test/` pins the expected shape, so a format change shows up as a failing test in CI.
- A resumed session keeps its transcript, so its baseline is the first turn of the original session.
- Subagent turns are recorded in their own transcripts. The figure covers the main session only, which is the context that compaction threatens.
- A budget is a threshold for a warning. It does not stop the model from continuing.

## 15. Errors

| Situation | Behavior |
|---|---|
| No `mergehand.conf` | Hooks stay silent. `card` exits 2 and suggests `/mergehand:init`. |
| `check` not set | `card lint` and handoff exit 2 |
| Not a git repository | `card` exits 2 |
| No remote, or no network | State uses local branches. Handoff stops before the push and says what remains. |
| `gh` missing or not authenticated | `review` state is unavailable and reported as such. Handoff stops after the push. |
| Card id not found | Exit 1 with the list of ids that start with the same prefix |
| Two cards with one id | `card lint` fails. Every other command refuses to act on that id. |
| Dirty tree at `next-card` | Stop and ask the user |

## 16. Trust and input handling

Cards, logs and `mergehand.conf` are repository content. In a team repository they can arrive in someone else's pull request, and the session-start hook puts part of them into the agent's context.

- `card status` prints front matter fields only (id, state, size, title) plus the `Done` section of the current card's last log entry. It strips control characters and applies the size cap. A size is printed only when it looks like a size, a dependency only when it is a valid id, and a log file only when its name has no free text. Card bodies enter context only when a session starts that card.
- `mergehand.conf` is parsed, never sourced or passed to `eval`. `cards_dir` and `log_dir` must be relative paths inside the repository with no `..`, and `base` must be a valid branch name; anything else is a configuration error.
- `card status` never prints the name of a branch other than the current one, because remote branch names are chosen by whoever pushed them.
- Ids are validated against the id pattern before they appear in a branch name, a file name or a search pattern. `Touch` entries are used only as `case` patterns.
- The `check` command runs whatever the repository says, with the same trust as a `Makefile`. Init shows it to the user before writing the permission entry for it.

## 17. Testing

- `test/run.sh` runs every case with plain bash: no test framework. Each case builds a temporary git repository from a fixture, runs a command and compares output and exit code.
- Cases cover each `card` subcommand, each lint rule, each state in section 6 (using a local bare repository as the remote and a stub `gh` on the PATH), `card tokens` against fixture transcripts including a malformed one, and each hook with fixture JSON on stdin.
- CI on macOS runs the suite with `/bin/bash`, which is 3.2, so a bash 4 feature fails there.
- The hook tests include a project without `mergehand.conf` and assert no output and exit 0.
- CI runs the suite on macOS and Linux, which covers BSD and GNU versions of sed, awk and grep. CI also runs `shellcheck` and `claude plugin validate --strict` on both manifests and on the `agents/` and `skills/` directories. Validate does not read `hooks/hooks.json`; a shell test checks the hook registration instead. On Linux the suite also runs with `awk` as mawk and as gawk.
- Skills are prompts and cannot be unit tested. Shell tests check their mechanics (front matter, that every `card` command they name exists, the order of the gates), and each skill was run once by hand in a scratch repository (`development/findings.md`, findings 8 and 10). Plugin eval cases were planned and then cut: see section 19.2, item 32.

## 18. Risks

| Risk | Response in 0.1 |
|---|---|
| Larger context windows make session sizing matter less | Budgets are configuration. The parts that do not depend on window size are the scope gate, the review, the PR per card and the measured record. |
| The agent ignores instructions in a skill | Checks that matter run as scripts in handoff and in the stop hook. |
| Transcript format changes | Measurement degrades to `unknown`. Nothing else depends on it. |
| The `Touch` gate annoys users on exploratory work | Adding a file to `Touch` is one line, and `/mergehand:quick` exists for work that has no plan. |
| Claude Code changes plugin or hook behavior | CI runs `claude plugin validate --strict` against the current release. It covers the manifests, agents and skills, not the hook registration, which a shell test checks. |
| Users expect cards to be written for them | The README says plainly that 0.1 runs cards and 0.2 writes them. |

## 19. Changes from the adversarial review

Each was found by checking the draft against the Claude Code documentation or by running a prototype.

1. Budgets were absolute context sizes of 30,000 to 90,000 tokens. A prototype run over 50 real session transcripts found a baseline of 53,000 to 71,000 tokens before any work, so every session would have been over budget at its first turn. Budgets now limit growth over the baseline (sections 8 and 14).
2. The budget check ran in the `Stop` hook, which fires only at the end of a turn. It moved to `PostToolUse` (section 13).
3. `card log-new` had no way to find the transcript, because Bash tool commands do not receive `transcript_path`. The session-start hook now exports it through `CLAUDE_ENV_FILE` (section 13).
4. `next-card` and `quick` told the agent to run `handoff`, and `quick` told it to continue inside `next-card`. A skill with `disable-model-invocation` cannot be called by the model. The shared steps moved to `reference/implement.md`, and the user types handoff (sections 3 and 10).
5. `card` was reachable only from inside Claude Code. It is now one file that people and CI can download (section 4.1).
6. `done` was read from the working tree, which is wrong on a card branch after handoff. It is read from the base branch (section 6).
7. Computing state made network calls on every session start. They now happen only with `--fetch` (section 6).
8. The scope gate would have failed on every card, because the card file and the log file always change. Those directories are skipped, and `touch_ignore` covers lockfiles (section 9).
9. The tests gate could not match a phrase to a CamelCase or snake_case test name. It now compares letters and digits only (section 11).
10. Quick-lane ids from a counter collide across branches. They are time-based (section 10.4).
11. File-name order put `AUTH-10` before `AUTH-2`. Order is now natural sort by id (section 5).
12. Added: bash 3.2 as the floor, a format `version` key, a title length limit, and the trust section (16).

### 19.1 Changes from implementation planning

Found while writing the plan (`docs/development/plan-0.1.md`) and checking it against the current Claude Code documentation.

13. `card next` said file-name order, which contradicted item 11. It uses natural id order (section 9).
14. The tests gate had no command, so the agent would have done the search by hand. Added `card tests` (sections 9 and 11).
15. Skills and hooks had no way to read a configuration value. Added `card conf` (section 9).
16. The log example carried a PR number that cannot be known when the log is committed. `pr` is optional (section 7).
17. The scope and tests gates run before handoff commits, so they compare against the working tree, not the last commit (section 9).
18. `review` is reported as `active` whenever `--fetch` was not given (section 6).
19. Subagent tool calls would have consumed the single budget warning. The hook ignores them (section 13).
20. Configuration paths and the base branch name are validated, and `card status` prints no branch name but the current one (section 16).
21. The 40-line log limit counts the text after the front matter (section 7).

### 19.2 Changes from building it and from the independent review

Found while building 0.1 with its own cards, and by a separate adversarial review of the open findings (`docs/development/findings.md`, finding 11).

22. `done` was read from `origin/<base>` alone, so a card merged locally and not pushed showed as `ready` and `card next` offered it again. It is read from both base refs (section 6). This narrows item 6; the reason for item 6 still holds.
23. A card with no slug has the branch `card/<id>`, which nothing recognized. The prefix `card/<id>` is what counts (section 6).
24. A `Touch` entry ending in `/` matched nothing. It covers the directory (section 5).
25. The tests gate does not join nested test names; the spec now says so (section 11).
26. `card next` says how to release a card held by an abandoned branch (section 9).
27. The post-tool-use hook's cost was stated as about 10 ms. Measured, it is about 45 ms on a card branch (section 13).
28. `claude plugin validate` does not check hook registration (sections 17 and 18).
29. next-card can resume a card in progress, and a `## Blocked` section is removed once answered (section 10.2).
30. init no longer creates the log directory (section 10.1).
31. Text that reaches the agent's context is filtered further: a size, a dependency and a log file name are printed only when well formed (section 16).
32. The three plugin eval cases were cut from 0.1. `claude plugin eval` measures skills that the model chooses to invoke, against a baseline without the plugin; all four Mergehand skills are typed by the user, so the tool would have measured a mismatch, at about eighteen billed agent runs (section 17).
33. `card` gained `--version`, per-command `--help` and strict argument counts; a usage error prints `usage:` (section 9).
34. The license is MIT (section 20, question 1).
35. A card that exists only on its own branch showed as `done` as soon as handoff ran, so a quick card never showed as `review`. Seen on the first pull request opened by hand against the hosted repository. Such a card is not done while it has a branch or an open pull request (section 6).

## 20. Open questions

1. License. Decided: MIT.
2. Whether init should offer to write a first card from a one-paragraph description, as a bridge until the planner exists.
