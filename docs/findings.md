# Findings

What turned out awkward or wrong while building Workdeck 0.1 with itself, with what happened and a proposed fix. Nothing here has been fixed silently: a finding stays open until the owner decides.

Findings 1 to 3 answer the challenge list in the build brief. Each is pinned by tests, so the evidence can be re-run.

## 1. The tests gate gives false failures on idiomatic nested tests

**Status:** open. **Evidence:** `test/cases/33-tests.sh`, fixtures in `test/fixtures/lang/`. Run `/bin/bash test/run.sh test_lang`.

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
2. If that is not enough in practice, match the words of the card line in order within a window of about 20 lines, instead of inside one line. That fixes nesting and wrapped names, and raises false passes. It is in `docs/later.md`, not built.

## 2. `Touch` entries are shell `case` patterns, and four cases surprise a gitignore user

**Status:** open. **Evidence:** `test/cases/32-touched.sh`. Run `/bin/bash test/run.sh touch_pattern`.

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

**Status:** open. **Evidence:** `test/cases/21-state.sh` (`test_squash_*`, `test_branch_deleted_*`), `test/cases/22-fetch.sh`.

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

**Status:** open, informational. **Evidence:** measured on this machine (Apple silicon, macOS, `/usr/bin/git`).

Starting any process costs about 5 ms; starting git costs about 17 ms, because `/usr/bin/git` is a shim. A `card` command is a few dozen processes. Measured: `card conf base` 54 ms before configuration loading was rewritten as one awk pass; `card list` 112 ms and `card status` 189 ms on a nine-card deck; `card status` 0.6 s on a deck of 300 cards with 30 active branches. All are far inside the 10-second hook timeout.

It matters for the post-tool-use hook, which runs after every tool call. The spec's "about 10 ms" figure covers parsing the transcript only. The hook also has to start bash, find the repository and read the branch, so its floor on this machine is nearer 40 ms. HOOK-02 measures it properly and reports.

## 5. `sort -V` on a whole line does not give natural id order

**Status:** fixed before the bootstrap, recorded because the spec names `sort -V`.

Sorting `id<TAB>path` lines with `sort -V` puts `AUTH-03b` before `AUTH-03`, because the version comparison runs on into the path. The index is sorted with `sort -t <TAB> -k1,1V`, which works on BSD and GNU sort. `test_list_natural_order` caught it.

## 6. The post-tool-use hook costs 45 ms per tool call on a card branch, and grows with the transcript

**Status:** open. **Evidence:** `/bin/bash test/bench-hook.sh` on this machine (Apple silicon, macOS, bash 3.2.57), 50 runs per path.

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

**Status:** open, informational. **Evidence:** Claude Code 2.1.261, run on this repository and on a copy with one deliberate fault.

- `claude plugin validate --strict .` on a directory that holds both manifests validates the marketplace manifest and stops. The plugin manifest needs its own call with the path to `plugin.json`. CI and `test_plugin_validates_strictly` run both.
- The manifest reference says an unquoted `${CLAUDE_PLUGIN_ROOT}` in a shell-form hook command draws a warning. A copy of `hooks/hooks.json` with the quotes removed passed both calls. On this version nothing in validate reads `hooks/hooks.json`.

So "CI runs validate against the current release" (spec section 18) guards the manifests and not the hook registration. `test_hooks_json_names_existing_executable_scripts` covers the gap with grep: four events, four executable scripts, quoted root, 10-second timeouts, top-level `hooks` key.

**Proposed fix:** none needed in the code. The spec's risk table should say what validate covers.

The marketplace entry's source is `"./"` as the spec says; validate accepts it.
