# Findings

What turned out awkward or wrong while building Workdeck 0.1 with itself, with what happened and a proposed fix. Nothing here was fixed silently: a finding stayed open until the maintainer decided.

Findings 1 to 3 and 6 answer four questions the maintainer asked before the build started: does the tests gate give false failures on real test files; does the post-tool-use hook add a noticeable delay; do shell `case` patterns surprise someone used to gitignore globs; and does deriving state from branches survive squash merges and deleted branches. Each is pinned by tests, so the evidence can be re-run.

## 1. The tests gate gives false failures on idiomatic nested tests

**Status:** decided (finding 11): documented, and the gate message now says nested names are not joined. No windowed match. **Evidence:** `test/cases/33-tests.sh`, fixtures in `test/fixtures/lang/`. Run `/bin/bash test/run.sh test_lang`.

The gate lowercases a `Tests` line and each line of the changed files, strips everything but letters and digits, and looks for the first inside the second. Sixteen cases across four languages:

| Language | Test as written | Card line | Gate | Correct? |
|---|---|---|---|---|
| Go | `func TestRefreshRotatesTheToken` | refresh rotates the token | found | yes |
| Go | `t.Run("expired refresh token is rejected", …)` | expired refresh token is rejected | found | yes |
| Go | table case `{name: "keeps the session"}` under `TestRefresh` | refresh keeps the session | missing | **false failure** |
| Python | `def test_refresh_rotates_the_token` | refresh rotates the token | found | yes |
| Python | `parametrize(…, ids=["zero ttl is rejected", …])` | zero ttl is rejected | found | yes |
| Python | `class TestRefresh: def test_keeps_the_session` | refresh keeps the session | missing | **false failure** |
| Python | `def test_does_not_leak_the_token` | doesn't leak the token | missing | **false failure** |
| TypeScript | `it('refresh rejects an expired token')` | refresh rejects an expired token | found | yes |
| TypeScript | ``test(`refresh returns 401 on a revoked token`)`` | refresh returns 401 on a revoked token | found | yes |
| TypeScript | `describe('refresh')` wrapping `it('rotates the token')` | refresh rotates the token | missing | **false failure** |
| TypeScript | a name wrapped over two lines by the formatter | the full name | missing | **false failure** |
| Rust | `fn refresh_rejects_an_expired_token` | refresh rejects an expired token | found | yes |
| Rust | `mod refresh { fn rotates_the_token }` | refresh rotates the token | missing | **false failure** |
| Rust | `fn refresh_rejects_an_expired_token` | refresh rejects expired token | missing | **false failure** |
| TypeScript | `const networks = []`, no such test | works | found | **false pass** |
| TypeScript | `// TODO: revokes every session on logout` | revokes every session on logout | found | **false pass** |

Seven false failures and two false passes. The pattern is clear: a test whose name lives on one line and matches the card word for word is found; a name that is split across a nesting level (Go table cases, Python classes, `describe` plus `it`, Rust modules), wrapped by a formatter, or reworded by one small word is not. Nesting is the normal style in three of the four languages, so this will come up on most cards in those projects.

Each false failure costs one edit to the card line, and the edit shows in the PR diff, which is what the spec intends. The cost is friction, not wrong results. The false passes are the reviewer's job by design (spec section 11).

**Proposed fix, in order of preference:**

1. Say it where the card is written. `reference/implement.md` and the README tell the author to write each `Tests` line as the name the test will have on its own line: the innermost `it`, the method name, the table case. No code change.
2. If that is not enough in practice, match the words of the card line in order within a window of about 20 lines, instead of inside one line. That fixes nesting and wrapped names, and raises false passes. It is in `docs/development/later.md`, not built.

## 2. `Touch` entries are shell `case` patterns, and four cases surprise a gitignore user

**Status:** fixed in R-03 (finding 11): an entry ending in `/` now covers the directory and a leading `/` or `./` is ignored, so rows 1 and 4 of the table below now match. The other rows stand. **Evidence:** `test/cases/32-touched.sh`. Run `/bin/bash test/run.sh touch_pattern`.

| Entry | Changed file | A gitignore user expects | `case` gives |
|---|---|---|---|
| `src/` | `src/a.ts` | match | **no match** |
| `a.ts` | `src/a.ts` | match (any depth) | **no match** |
| `**/a.ts` | `a.ts` | match | **no match** |
| `/src/a.ts` | `src/a.ts` | match (anchored) | **no match** |
| `!src/gen.ts` | `src/gen.ts` | negation | literal `!`, no match |
| `src/*.ts` | `src/x/y.ts` | no match | **match** |
| `*.ts` | `src/x/y.ts` | match | match |
| `**/a.ts` | `src/x/a.ts` | match | match |
| `src/*` | `src/x/y.ts` | match | match |
| `src/[ab].ts` | `src/b.ts` | match | match |

The dangerous direction is safe: every surprise but one makes the gate stricter than expected, so the author gets a scope failure and fixes the entry. The exception is `src/*.ts` matching `src/x/y.ts`, which is looser, and is stated in the spec.

`src/` matching nothing is the one that will bite most often, because listing a directory is the obvious way to say "anything in here", and the failure message lists every file under it as out of scope.

**Proposed fix:** make `card lint` reject a `Touch` entry that ends in `/`, a leading `/` and a leading `!`, each with a message that gives the working form (`src/*`). That is three cheap checks and turns a confusing gate failure into a clear lint error. Not built; needs a decision because it changes what lint accepts. The README gets this table either way.

## 3. State from branches: squash merges are fine, abandoned branches are not noticed

**Status:** fixed in R-02 (finding 11): `done` is read from both base refs, and `card next` says how to release a card held by a branch. The last two rows of the table below describe the behavior before the fix. **Evidence:** `test/cases/21-state.sh` (`test_squash_*`, `test_branch_deleted_*`), `test/cases/22-fetch.sh`.

| Situation | State | Right? |
|---|---|---|
| Squash-merged into base, local branch left behind | `done` | yes: `done` on base wins over any branch |
| Branch deleted without a merge | `ready` again | yes |
| Squash-merged on the remote, remote branch deleted, local refs stale | `active` until `card … --fetch`, then `done` | yes, and `next-card` passes `--fetch` |
| PR closed without merging, branch kept | `active` forever | **no** |
| Merged into local base, not pushed, remote exists | not `done` until pushed | **surprising** |

Squash merges do not break the model, because state never asks whether a branch was merged; it reads `done` from the base branch.

Two gaps:

- A branch that is kept after its PR is closed holds its card `active` indefinitely, and blocks every card that depends on it. `card status` deliberately prints no branch names (they are chosen by whoever pushed them), so the user is not told which branch to delete. **Proposed fix:** `card next`, when nothing is ready, prints for each active card whether its branch is local, remote or both, without the name; and the README says that deleting the branch is how a card is released.
- With a remote, `done` is read from `origin/<base>` (spec section 6), so a merge made locally stays invisible until it is pushed. This is as specified, and correct for the PR workflow. It is wrong for someone who merges locally. **Proposed fix:** when the local base is strictly ahead of `origin/<base>`, read from the local one. Not built, because it reopens a section 19 decision.

## 4. Process start-up dominates everything on macOS

**Status:** informational. **Evidence:** measured on this machine (Apple silicon, macOS, `/usr/bin/git`).

Starting any process costs about 5 ms; starting git costs about 17 ms, because `/usr/bin/git` is a shim. A `card` command is a few dozen processes. Measured: `card conf base` 54 ms before configuration loading was rewritten as one awk pass; `card list` 112 ms and `card status` 189 ms on a nine-card deck; `card status` 0.6 s on a deck of 300 cards with 30 active branches. All are far inside the 10-second hook timeout.

It matters for the post-tool-use hook, which runs after every tool call. The spec's "about 10 ms" figure covers parsing the transcript only. The hook also has to start bash, find the repository and read the branch, so its floor on this machine is nearer 40 ms. HOOK-02 measures it properly and reports.

## 5. `sort -V` on a whole line does not give natural id order

**Status:** fixed before the bootstrap, recorded because the spec names `sort -V`.

Sorting `id<TAB>path` lines with `sort -V` puts `AUTH-03b` before `AUTH-03`, because the version comparison runs on into the path. The index is sorted with `sort -t <TAB> -k1,1V`, which works on BSD and GNU sort. `test_list_natural_order` caught it.

## 6. The post-tool-use hook costs 45 ms per tool call on a card branch, and grows with the transcript

**Status:** decided (finding 11): documented, nothing built. If it is ever felt, first let `card` skip its own repository lookup when run from the root. **Evidence:** `/bin/bash scripts/bench-hook.sh` on this machine (Apple silicon, macOS, bash 3.2.57), 50 runs per path.

| Path | Median | 95th percentile |
|---|---|---|
| Not a Workdeck project | 2 ms | 2 ms |
| Workdeck project, not on a card branch | 2 ms | 2 ms |
| Card branch, already warned | 4 ms | 5 ms |
| Card branch, under budget, 2 MB transcript | 45 ms | 51 ms |
| Same, with a 1 MB tool result on stdin | 53 ms | 57 ms |
| Card branch, under budget, 20 MB transcript | 127 ms | 151 ms |

The first three paths start no process or one: the hook reads `.git/HEAD` itself instead of calling git, which is why a project that does not use Workdeck, or a session on `main`, pays 2 ms.

The fourth path is the one that matters, and the spec's "about 10 ms, so running on every tool call costs little" is off by a factor of four to five. Parsing the transcript is the small part. The rest is `card tokens` starting up: about 17 ms for each of two git calls on macOS, plus awk and sort processes to find the card's size. A session of 200 tool calls on a card branch pays about 9 seconds in total at 2 MB. Next to model latency that is not noticeable call by call.

The fifth and sixth rows show the two ways it gets worse: a large tool result has to be read from stdin, and the whole transcript is re-read on every call, so cost grows with session length. This session's own transcript was 2.1 MB after building stages 1 to 5, so 20 MB is a long session, not a typical one.

The card for this work said to stop and report if the under-budget median passed 50 ms. It is 45 ms at 2 MB and over at 20 MB, so here are the options, none built:

1. **Skip the git calls.** The hook already knows the repository root and the branch. Passing them to `card tokens` removes about 34 ms and brings the 2 MB case near 12 ms. Smallest change; adds two internal environment variables to `bin/card`.
2. **Read only what is new.** Keep the byte offset, baseline and peak in `<git-dir>/workdeck/<session>.state` and read the transcript from that offset. Cost stops growing with session length. More code, and state that can go stale.
3. **Measure less often.** Run the measurement on every tenth call, or only when the transcript has grown by some amount. One line of code; a warning can arrive up to nine tool calls late.

Recommendation: option 1 now if 45 ms bothers anyone, option 2 only if long sessions turn out to be common.

## 7. `claude plugin validate --strict` checks less than its documentation says

**Status:** decided (finding 11): the spec now says what validate covers. **Evidence:** Claude Code 2.1.261, run on this repository and on a copy with one deliberate fault.

- `claude plugin validate --strict .` on a directory that holds both manifests validates the marketplace manifest and stops. The plugin manifest needs its own call with the path to `plugin.json`. CI and `test_plugin_validates_strictly` run both.
- The manifest reference says an unquoted `${CLAUDE_PLUGIN_ROOT}` in a shell-form hook command draws a warning. A copy of `hooks/hooks.json` with the quotes removed passed both calls. On this version nothing in validate reads `hooks/hooks.json`.

So "CI runs validate against the current release" (spec section 18) guards the manifests and not the hook registration. `test_hooks_json_names_existing_executable_scripts` covers the gap with grep: four events, four executable scripts, quoted root, 10-second timeouts, top-level `hooks` key.

**Proposed fix:** none needed in the code. The spec's risk table should say what validate covers.

The marketplace entry's source is `"./"` as the spec says; validate accepts it.

## 8. The agent names the card branch from the title, not the file

**Status:** decided (finding 11): `card branch` rejected. Only the `card/<id>` prefix matters, and a branch with no slug is now recognized (R-02). **Evidence:** manual run of `/workdeck:next-card` in a scratch repository (Claude Code 2.1.261, `--plugin-dir`, 9 turns).

The card file was `GREET-01-fix-greeting.md` with the title "Fix the greeting". The skill said the branch is `card/` plus the file name without `.md`. The agent created `card/GREET-01-fix-the-greeting`. State still works, because it matches `card/<id>-*`, but the rule "the branch is named after the file" is an instruction, and the spec's own goal 4 says a rule a script can check should be checked by a script.

The same run confirmed what the plan left open: the plugin loads with `--plugin-dir`; a skill with `disable-model-invocation: true` runs when typed; the `` !`...` `` injection of `card status --fetch` ran and its output reached the prompt; the agent wrote the test first, named `test_greet_says_hello_with_the_name`, and did not commit.

**Proposed fix:** add `card branch <id>`, which prints `card/<file name without .md>`, and have the skills run `git checkout -b "$(card branch <id>)"`. One small command, no judgment left to the agent. Not built: it adds a command to section 9. The skill text now says "from the file, not from the title", which is a weaker fix.

## 9. The permission template let a card branch be pushed onto another branch

**Status:** fixed by card Q-2610052330 (the first use of the quick lane on this repository). **Evidence:** automated security review of the commit that added `templates/settings-permissions.json`.

The allow rule `Bash(git push origin card/*)` is a prefix match, so it also allows `git push origin card/x:main` and `git push origin card/x main`. Deny rules are evaluated before allow rules, so the template now denies any push with a colon refspec (`Bash(git push *:*)`) and any push with a second refspec after the card branch.

The permissions page is explicit that these rules match the command as written and are not a security boundary: `git -C . push` is not matched at all. The real protection for the base branch is branch protection on the host. The README must say so (DOC-01).

## 10. The full loop ran in a real session; the reviewer's commands were denied

**Status:** fixed in SKILL-02. **Evidence:** manual run of `/workdeck:handoff` in the scratch repository (Claude Code 2.1.261, non-interactive, 24 turns).

What the run proved, which no shell test can:

- The reviewer launches under its scoped name. The session spawned one subagent for `workdeck:reviewer`. This was the open item in the plan's interface table.
- Measurement works end to end. The log has `baseline_tokens: 36917`, `peak_tokens: 40334`, `growth_tokens: 3417`, `compacted: false`. So the session-start hook ran, `CLAUDE_ENV_FILE` carried the transcript path and session id into the Bash tool, and `card log-new` read both.
- The gates, `card done`, the log, the commit and the "no remote, stop here" branch all happened in order, and `card lint` passes on the result. The card shows as `active`, not `done`, because the branch has not merged.

What went wrong: four of the reviewer's commands were denied. It called `card` by the plugin's full path, and wrapped `git merge-base` in a command substitution. Neither matches the permission entries init writes (`Bash(card *)`, `Bash(git diff *)`), and a non-interactive session cannot ask. The reviewer still returned findings, working from what it could read.

The reviewer now uses the bare `card` command and runs `git merge-base` and `git diff` as two commands.

A baseline of 36,917 tokens with only this plugin loaded is useful to know: the spec's budgets assume a baseline near 60,000 with a typical set of plugins.

## 11. Independent review of the open findings (2026-10-06)

A separate reviewer, told to assume the proposals above were wrong, went through findings 1 to 8 and then looked for defects of its own in scratch repositories. Its decisions replace the "proposed fix" lines above where they differ:

| Finding | Decision | What changed from the proposal |
|---|---|---|
| 1 tests gate | Document, and say it in the gate's message | No windowed match: it trades false failures for false passes with no evidence of the friction yet |
| 2 Touch patterns | Normalize instead of lint | A trailing `/` now covers the directory and a leading `/` or `./` is ignored. A lint error would only report the problem and would fail decks that pass today |
| 3 abandoned branch | One hint line in `card next` | No local/remote classification |
| 3 unpushed local merge | `done` is read from both the local and the remote base branch | Worse than recorded: `card next` offered a card that had already been merged locally. "Local when strictly ahead" was rejected because state would flip on every fetch |
| 6 hook timing | Document | 45 ms is under 2% of a tool round trip; all three options add an interface or state |
| 7 validate | Document | Agreed |
| 8 branch name | Rejected | Nothing depends on the slug, and a command the agent must choose to run is still an instruction. The real hole was a card with no slug, whose branch `card/<id>` was not recognized at all |

It also found thirteen defects, nine demonstrated by running them. The ones that mattered most: three places where text from a card or a log file name reached the agent's context unfiltered (`size:`, an invalid `depends:`, the log file name); `done: true` with a trailing space passing lint but never counting as done; `cards_dir = cards/` breaking both gates; and a `-v` value with a backslash that makes gawk print a warning on every `card` call, which the macOS and mawk runs would never have shown.

All are fixed in cards R-01 to R-04, each with the tests the reviewer named. Not done: a live handoff against a remote under the permission rules, because it needs a nested agent session.

## 12. Comparison with respected repositories, and a review of what waits on the maintainer (2026-10-06)

Two more independent reviews. One compared every part of the repository a person meets against twelve well-regarded repositories of the same kind: Claude Code plugins, small shell tools, and task trackers for agents. The other went through everything that was waiting on the maintainer and walked a stranger's first ten minutes.

The comparison's verdict was "a well-tested agent build log, not yet a product". What it rested on:

- No README and no license, so the purpose could not be read and the code could not be used.
- The central claim was not shown in the repository's own data. Every session log said `unknown` and there were no pull requests, because the cards had been driven by hand in one long session, without the plugin loaded.
- `bin/card` carried three comments with another tool's marker, an unreachable "not implemented yet" branch and a duplicated comment line.
- `card` had no `--version`, ignored surplus arguments (`card list --help` printed the list), and one message ended in a dangling colon.
- The plan was written in the build agent's first person, addressed to the maintainer.
- No `.gitattributes` for a tool that rejects CRLF, no security policy for a plugin that installs hooks, no changelog, no way stated to run the tests.

The second review found where a stranger gets stuck: init leaves a dirty tree and both entry skills stop on a dirty tree; `card new` writes a card that fails lint but shows as `ready`; a card committed on the local base branch and not pushed makes the fast-forward pull fail after a squash merge; and the permission template did not allow three commands that next-card runs.

Decisions taken by the maintainer: MIT license; keep the name with a line saying it is not affiliated with the Workdeck product at workdeck.com; publish privately first; keep the history and its co-author trailers; cut the plugin eval cases from 0.1; run one card through the real loop against the hosted repository before claiming the tool was built with itself.

Fixed in cards S-01 to S-03 and DOC-01. The plugin eval tool was cut because it is built for skills the model chooses to invoke with a no-plugin baseline, and all four of these skills are typed by the user.

## 13. First CI runs (2026-10-06)

**Status:** closed. **Evidence:** GitHub Actions runs 37366925623 and 37368262005 on the private repository.

The first run passed on macOS and failed on Ubuntu at the shellcheck step: Ubuntu 24.04 ships an older shellcheck that reports SC2015 on three chained conditions that 0.11.0 accepts. Fixed by writing them as `if` statements (card Q-2610060140). The second run passed on both.

What that settles, which had only been argued before:

- The suite passes on Linux with GNU tools, and again with `awk` as mawk and as gawk. The gawk escape warning from finding 11 does not appear.
- `claude plugin validate --strict` runs in CI with no credentials, on the current Claude Code release, for both manifests, `agents/` and `skills/`.
- The suite passes under bash 3.2 on a machine other than the one it was written on.

Still not shown: the pull request path against the host, and a handoff under the permission entries. The first card run through the plugin against this repository (DOC-02) covers both.

## 14. The first card through the real loop (2026-10-06)

**Status:** closed, with two notes for 0.2. **Evidence:** pull request 1, `log/2026-10-06-DOC-02-1.md`.

The maintainer ran DOC-02 with the plugin loaded against the hosted repository. Handoff pushed the branch, opened the pull request with the template filled in, CI passed on it, and it was merged. The log has real figures: baseline 53,055, peak 79,037, growth 25,982, not compacted. This closes what findings 10 to 13 left open about `git push`, `gh pr create` and a log written by a real session.

Two things it showed:

- **The XS budget is tight in a session that carries other plugins.** Adding a license file used 74% of 35,000. Part of that is a first attempt that the permission mode refused, which stayed in the same session's transcript. Even so, a session that starts at 53,000 tokens and reads a card, a few files and a reviewer's findings does not have much room in 35,000. `card stats` exists so a project can set budgets from its own sessions; the defaults may want raising once there are more than one of these to go on.
- **A refused attempt leaves no trace except in the log's prose.** The agent reported that every file write was refused by the permission mode on the first try. Nothing in Workdeck notices that a session did no work; the user ran next-card again. Worth a line in the README's quick start: the session needs permission to edit files.

The baseline of 53,055 also fits the range of 53,000 to 71,000 that the design's section 19 quotes from earlier sessions, and is well above the 36,917 measured with only this plugin loaded.

## 15. A card that lives only on its branch showed as done before it merged (2026-10-06)

**Status:** fixed in E-01. **Evidence:** pull request 2, the first one opened by the build agent against the hosted repository.

Card E-01 was created on its own branch, like every quick card. After `card done` and with its pull request open, `card list --fetch` printed `done   E-01`, and `card next` said "every card is done". The design's section 6 said a card that exists only on the current branch takes `done` from the working tree, with the quick lane in mind; it had not considered that handoff writes `done: true` on that same branch before anything merges. The effect: a quick card never showed as `review`, and a session started on its branch was told the work was finished.

No test had caught it because the stub `gh` was only ever pointed at cards that were also on the base branch. It took a real pull request for a branch-only card.

The fix is one condition: a card that is only in the working tree is done on its own word unless it has a branch or an open pull request. With the fix, the same command against the same pull request prints `review   E-01`.

Still true, and not fixable without reading other branches: from the base branch, a quick card is invisible until its pull request merges, because its file is not there.
