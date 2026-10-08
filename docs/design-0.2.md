# WorkDeck 0.2 design

This is the design for release 0.2. It adds to [`design.md`](design.md), which stays the design of everything 0.1 shipped; where this file is silent, that one holds. The scope it follows is [`development/scope-0.2.md`](development/scope-0.2.md).

Date: 2026-10-06, rewritten 2026-10-09
Status: approved 2026-10-09. Reviewed that day by an agent that did not write it ([`development/review-0.2.md`](development/review-0.2.md)) and rewritten from that review. The maintainer decided four questions (section 20) and had the rest attacked once more and locked (section 22). The outline format of section 5 is the one part that may still change, and only from the spike (section 21).
Scope: release 0.2 (the planner, and init for a repository that is already set up). Team features (0.3) get their own design.

## 1. What 0.2 adds

0.1 runs cards that a person wrote. 0.2 adds a planner. The user types `/workdeck:plan` with the path of a specification file. The run produces an outline: one row per card for the whole specification, each row saying what the card does. A script checks the outline, an agent that did not write it reviews it, the user approves it, and it lands through a pull request that changes nothing else.

A row is then a card without a body. `card next` offers it when its dependencies are done. `/workdeck:next-card` creates the card file from the row, writes the body against the code as it is at that moment, checks it with a script, asks the user for a yes, commits the approved card, and implements it. Handoff is as in 0.1.

Init also changes. On a repository that already has `workdeck.conf` it no longer stops; it offers what the planner needs.

## 2. Goals and non-goals

Goals for 0.2:

1. A person with an existing codebase and a specification in a markdown file gets cards that pass `card lint` and name real paths, without writing them by hand.
2. The planner's output is checked by a script wherever a script can decide, as goal 4 of 0.1 requires of a session's output.
3. A card body is written against code that exists: no card names a file that an unfinished card has yet to create.
4. Planning costs one pull request per outline, not one per card.
5. A repository set up with 0.1 keeps working with no change, and a CI workflow pinned to `card` 0.1.2 keeps passing on a deck that 0.2 planned.
6. 0.2 produces the first measured S and M sessions and the first record of how planned cards hold up.

Not in 0.2:

- Specifications from an issue, a URL or a typed paragraph, and specifications in several files.
- A codebase map.
- Claiming, worktrees and parallel sessions, a script check that orders cards touching the same file, and two people planning at once (0.3).
- A planner that implements, or that replans without being asked.
- A changed tests gate, new default budgets, or any item of `development/later.md`.

## 3. Decisions already made

| Decision | Choice | Reason |
|---|---|---|
| Form of the planner | A fifth typed skill, `/workdeck:plan`, running in the main session | It has to show the user an outline and wait for an answer. A skill with `context: fork` runs in a subagent that does not see the conversation and, by default, in the background (section 19, rows 1 and 2), and a subagent has no tool for asking the user (row 6). |
| Input | One markdown file committed in the repository | Cards can cite it under `Read` and the planner needs no network. |
| Outline | One file per specification, outside the card files | An outline-only card would have empty sections and fail `card lint`. A marker key in the front matter would fail `card lint` 0.1.2 (`unknown front matter key`). |
| When a body is written | By next-card, at the start of the session that implements it | Writing bodies in plan runs as dependencies finished cost one plan pull request per dependency wave. 0.1's own deck has a longest chain of seven: at least nine plan pull requests beside its 25 card pull requests, each plan run reading the specification and the code again. Writing every body up front names files that do not exist yet. Just in time has neither cost. What it gives up is in section 18. |
| What a row holds | The cut: title, size, dependencies, headings, what it does and what it does not | The writing session has no memory of the planning session. A title and a heading do not say which part of the heading is this row's. |
| A row in the deck | A card with no file. Same states, same commands | No second state model, no hint that sends the user to another skill, and `card next` stays the one answer to "what now". |
| Landing | A pull request from a `plan/` branch that changes only outlines | Merging it is the record that the outline was approved. |
| Plans in flight | No state for them. One person plans; a second run for the same specification writes the same file and git reports the conflict | Finding an unmerged plan needed a scan of every `plan/*` branch, and branches stay behind after a squash merge because the permission entries deny deleting them. |
| Row fields once a card exists | Ignored. The card file wins | Keeping both equal needs a check, and the check fails every time a user edits a card. |
| Formats | `version = 1` stays. No configuration key, no front matter key, no new file at the top level of the cards directory or in the log directory | `card` 0.1.2 exits 2 on an unknown configuration key and fails lint on the other three. |
| Script checks | A new command, `card plan`. `card lint` is unchanged | A deck that passes lint today must still pass. |

## 4. Repository layout

### 4.1 The plugin

Added:

```
skills/plan/SKILL.md
agents/plan-reviewer.md
```

Changed:

- `bin/card`: the `plan` command; rows in `list`, `next`, `status` and `show`.
- `hooks/stop.sh`: one condition (section 13).
- `skills/next-card/SKILL.md`: writes the card when it starts a row (section 10.2).
- `skills/handoff/SKILL.md`: one line in the pull request body (section 10.4).
- `skills/init/SKILL.md`: section 10.3, and its closing line, which says 0.1 does not write cards.
- `agents/reviewer.md`: one step (section 12.2).
- `reference/implement.md`: step 6 says the approved card is already committed.
- `templates/settings-permissions.json`, `templates/claude-md-section.md`, `templates/workdeck.yml`.
- `README.md`, `docs/reference.md`, `CHANGELOG.md`, `.claude-plugin/plugin.json`.

The plan skill is invoked as `/workdeck:plan`. The agent is addressed as `workdeck:plan-reviewer`.

### 4.2 A project that uses the planner

```
docs/specs/auth.md                   # the specification; any path in the repository
cards/plan/auth.md                   # the outline for that specification
cards/AUTH-01-token-store.md         # a card, as in 0.1, once next-card has written it
```

`cards/plan/` is `<cards_dir>/plan/`. `card` 0.1.2 lists card files with a glob over the top level of the cards directory, so no command of it reads an outline as a card. Its state lookup greps the whole cards directory on the base branch for `done: true` lines and discards every path that is not a card; an outline has no such line. The scope gate already skips everything under the cards directory.

## 5. Outline format

```
---
spec: docs/specs/auth.md
spec_blob: 3b18e512dba79e4c8300dd08aeb37f8e728b8dad
prefix: AUTH
level: 2
---

## AUTH-01 Token store
- size: S
- spec: Storage
- does: A token is stored hashed, with its expiry
- does: A stored token can be looked up by its hash

## AUTH-02 Token refresh
- size: S
- depends: AUTH-01
- spec: Refresh
- spec: Errors
- does: A refresh returns a new token and makes the old one invalid
- does: An expired token is refused with 401
- not: Counting refreshes (AUTH-03)

## Not planned
- Overview
- Non-goals
```

Rules:

- The file is `<cards_dir>/plan/<prefix in lowercase>.md`. The name follows from the prefix, so two specifications that are both called `spec.md`, as every Spec Kit specification is, cannot collide.
- The front matter is flat `key: value` lines, as in a card. `spec` is a path inside the repository with no `..`. `spec_blob` is what `git hash-object` prints for that file when the outline was written or last accepted. `prefix` matches `[A-Z][A-Z0-9]*` and is not `Q`, which the quick lane uses. `level` is a digit from 1 to 6: the heading level at which this specification's sections sit.
- A row is a second-level heading `## <id> <title>` followed by items. The id is the prefix, a hyphen and digits; a letter suffix is for split remainders and is not written in an outline. The title follows the rules of a card title.
- The items of a row are `- <key>: <text>`, one line each. `size` appears once and names a size that has a budget. `depends` appears at most once and is a comma-separated list of ids. `spec` appears any number of times, each naming one heading of the specification at the outline's level. `does` appears at least once. `not` appears any number of times. Any other key is an error.
- A `does` line is a statement that is true or false when the card is finished. A `not` line names what a reader might expect here and the row that owns it.
- A row with no `spec` item is allowed, for work no single heading asks for (a migration, a CI job). The plan reviewer looks at each such row.
- `## Not planned` lists headings of the specification, at the outline's level, that produce no card.
- A heading is compared as the tests gate compares names: lowercased, with every character that is not a letter or digit removed.
- An id is never used again after its row is removed.

## 6. Rows in the deck

The set of cards (design.md, section 6) gains one source: a row whose id has no card file on the base branch or in the working tree. Outlines are read from the same two places as card files, and the working tree's copy wins.

Such a row is a card with the row's title, size and dependencies and `done: false`. Its state is computed by the table of design.md, section 6, with one difference: it is `ready` only when each dependency is done and every card whose id is that dependency's id plus a letter is done too. A split leaves the original card `done` and its unfinished part in `<id>b`; without this rule a row could start on code that the remainder has still to write. The rule applies to rows only. Cards with a file keep the 0.1 rule, so nothing changes for a deck that has no outline.

A row whose card is being written or implemented has a `card/<id>` branch, and is `active`, `blocked` or `review` by the rules that already exist. Once the card file is on the base branch or in the working tree, the row's fields are ignored and the card's are used.

`card list` and `card next` print `[row]` after the title of a row that has no card file. `card show <id>` for such a row prints a first line `row: no card file yet` and then the row as written in the outline.

## 7. Planned cards

A planned card is an ordinary 0.1 card that next-card created from a row. It has no extra key. `card plan start <id>` creates it:

- the front matter from the row's id, title, size and dependencies;
- under `Read`, one item: the specification's path and a comment, `(row <id>: <heading>; <heading>)`;
- under `Acceptance`, the row's `does` lines;
- under `Out of scope`, the row's `not` lines.

The session then fills in the rest (section 10.2), and `card plan check <id>` checks the result against the tree:

- **Its paths exist.** Each `Read` entry, taken up to the first space and with any `#anchor` removed, names a file or directory. Each `Touch` entry whose comment does not start with `(new)` matches at least one file, tracked or untracked.
- **What it creates is not there yet.** A `Touch` entry marked `(new)` is a full path and matches no file.
- **`Out of scope` has an item.**

These are true when the body is written and stop being true as soon as the work starts: the new file exists, a file the card removes is gone. So the check runs once, before the user is asked, and is not a handoff gate and not a CI step.

## 8. Configuration and compatibility

No key is added to `workdeck.conf`. `budget.PLAN` would have been accepted by `card` 0.1.2, which takes any `budget.<NAME>`, but every budget key is also a card size, so it would have made `PLAN` one.

| Situation | What happens |
|---|---|
| A 0.1 repository, plugin updated to 0.2, planner not used | Nothing changes. With no outline, `card plan` prints one line and exits 0, and every other command prints what it prints today. |
| CI workflow pinned to `card` 0.1.2, deck planned by 0.2 | `card lint` passes. An outline is in a subdirectory it does not read. A planned card arrives in its own pull request with a body, and the cards it depends on are done, so they exist. |
| `card` 0.1.2 used by hand in a planned repository | It does not see rows: `card next` offers only cards that have a file. |
| A hand-written card that depends on a row with no card file | `card lint` fails in 0.1.2 and in 0.2: `depends on X, which is not a card`. Start the row first, or do not depend on it. |
| A user wants `card plan` in CI | They change the tag in the workflow. The template gains a second step. |
| A 0.1 repository whose user wants the planner | They run `/workdeck:init` again (section 10.3). |
| A 0.2 plugin with a 0.1 `card` first on the PATH | `card plan` prints `unknown command 'plan'` and exits 2. The plan skill stops and says to update `card`. |

## 9. The `card` command

| Command | Behavior |
|---|---|
| `card plan` | Checks every outline (section 11.1). Prints each failure with the file. Exit 1 on any failure. With no outline it says so and exits 0. |
| `card plan new <spec path> <PREFIX> [--level N]` | Creates the outline file with its front matter filled in and no rows. `level` defaults to 2. Refuses a prefix that an outline or a card already uses, `Q`, an existing file, a specification that is not tracked, and one with no heading at that level. |
| `card plan accept <PREFIX>` | Sets `spec_blob` to the specification's current value. |
| `card plan start <id>` | Creates the card file for a row (section 7) and prints its path. Refuses an id with no row, and one that already has a card file. |
| `card plan check <id>` | Checks one card against the tree (section 7). Exit 1 on any failure. |
| `card list`, `card next`, `card status`, `card show` | Include rows (section 6). Unchanged for a repository with no outline. |

Exit codes and message conventions are those of 0.1.

## 10. Skills

### 10.1 `/workdeck:plan <spec path> [what to change]`

Typed by the user, with `disable-model-invocation: true`, like the other four.

1. Stop on a dirty tree. Check out the base branch and update it with a fast-forward pull, as next-card does.
2. Run `gh pr list --author @me --state open --json number,headRefName`. If a pull request from a `plan/` branch is open, say so. If its branch is local, offer to check it out and address the comments on it, then go to step 6. Otherwise stop. Without `gh`, go on.
3. Stop if the path is not a tracked file. Look in `<cards_dir>/plan/` for an outline whose `spec` is that path.
4. Create the branch `plan/<yymmddhhmm>`, with the time from `date +%y%m%d%H%M` as in the quick lane.
5. Write or revise.
   - **No outline.** Read the specification. Get to know the code it concerns by delegating the search to the built-in Explore subagent, so file contents stay out of this session's context (section 19, rows 4 and 5). Propose a prefix and the heading level at which the specification's sections sit, and ask the user to confirm both. Run `card plan new`. Write the rows and the `Not planned` list. A row is one session's work. A dependency is written only where a row needs code that another row creates.
   - **An outline exists.** Run `card plan`. If it says the specification changed, show the user the difference with `git diff <spec_blob> HEAD:<spec>` and propose the rows it calls for. Apply what the user asked for after the path. Only a row with no card file and no `card/<id>` branch may be changed or removed; for any other, the card is what gets edited. Run `card plan accept`.
6. Run `card plan`. Fix what it reports and run it again.
7. Launch the `workdeck:plan-reviewer` subagent with the outline's path and the base branch, and wait for it. Fix every `must-fix` finding and run step 6 again. Keep every finding, with what was done about it.
8. Show the user the outline as a table, and under it the findings that were not fixed, each with the reason. Go on after a yes. After an edit, go back to step 6. After a no, restore or delete the outline file, check out the base branch and stop.
9. Commit, push the branch and open the pull request with `gh pr create`. The body has the rows, the `Not planned` list, every reviewer finding with what was done about it, the figures `card tokens` prints, and, for a run that revised an outline, what the user asked for or which change to the specification caused it. With no remote, or no `gh`, stop where handoff stops and say what remains.
10. Report the pull request URL and stop. The session writes no card and no code.

### 10.2 `/workdeck:next-card [id]`

Steps 1 to 5 are unchanged. A row is picked like any card. Step 6 gains a branch for a card whose `card show` output starts with `row:`.

1. Run `card plan start <id>`.
2. Read the specification headings the card lists, and the code the work concerns.
3. Fill in the card. `Touch`: full paths taken from the code as read, with `(new)` on a file the card creates. `Tests`: one item per test, written as the innermost name the test will have, in the style of the tests it will sit beside. `Read`: the files a session must read first, after the specification. `Acceptance` and `Out of scope` start as the row's lines; keep them unless they are wrong, and add to them. Change `size` if the row's guess no longer holds.
4. If the row cannot be done as it was cut (it needs code that no finished card provides, or it overlaps another row), delete the card file, tell the user to revise the outline with `/workdeck:plan <spec path>`, and stop.
5. Run `card lint` and `card plan check <id>`. Fix what they report.
6. Show the card to the user and ask for a yes or an edit. After a no, delete the card file and stop.

The file is written on the base branch and is untracked until the yes, as a quick card is, so a no leaves no branch behind. Step 7 then creates the branch, and for a card written this way commits the card file alone with the message `<id>: card as approved` before step 8 starts.

### 10.3 `/workdeck:init`

Steps 2 to 8 of design.md section 10.1 are unchanged for a repository with no `workdeck.conf`. Step 1 changes: when the file exists, init says so and continues with the steps below instead of stopping. A new repository gets steps 2 and 3 below after its step 7. Each step asks first and writes nothing without a yes. Nothing existing is overwritten, and nothing is committed.

1. **Permission entries that are missing.** The template gains `git push -u origin plan/*` and `git push origin plan/*` under `allow`, and under `deny` the same two patterns followed by a further argument, as it has for `card/*` (finding 9). Init shows the entries the settings file lacks and merges them on approval.
2. **`touch_ignore`.** Look for tracked lockfiles and generated files (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Cargo.lock`, `go.sum`, `*.snap`, and files a `.gitattributes` marks `linguist-generated`). Show the list and add the approved ones to `touch_ignore`.
3. **Review rules.** Read `CLAUDE.md`, the contributing guide, linter configuration and CI workflows. Propose at most ten rules for `cards/REVIEW.md`, each one sentence that a reviewer can check against a diff, each with the file it was taken from. Add the approved ones under the existing headings. Rules already in the file are left as they are.
4. **The protocol section.** If `CLAUDE.md` has a `## WorkDeck session protocol` section that differs from the template, show the difference and replace the section on approval. 0.1 left an existing section alone, which would keep every 0.1 repository on the old text.

The template's section gains two lines: a `plan/*` branch changes only outlines, and next-card writes the card for a row and waits for a yes before any code.

### 10.4 `/workdeck:handoff`

One addition in step 7. When the card's branch has an `<id>: card as approved` commit, the pull request body gains a part headed "Changes to the card since it was approved" with the output of `git diff <that commit> HEAD -- <card file>`, leaving out the `done` line. In 0.1 a hand-written card was on the base branch, so a file added to `Touch` showed in the pull request's diff. A card written in its own pull request is new in that diff from top to bottom; the commit and this part of the body are what keep scope growth visible.

Split mode is as in 0.1. The remainder is a card with a file, and section 6 makes rows wait for it.

`quick` does not change.

## 11. Mechanical checks

### 11.1 `card plan`

It runs these in order and reports every failure it finds.

| Check | Fails when |
|---|---|
| Outline format | the front matter has a missing, unknown or malformed key; the file name is not the prefix in lowercase; a row has no `size`, no `does`, a key twice that may appear once, or an unknown key |
| Ids | a row's id is malformed, carries a letter, does not start with the prefix, or appears in two rows; two outlines share a prefix; the prefix is `Q` |
| Sizes | a row's size has no budget |
| Dependencies | a dependency names neither a row nor a card; the rows and cards together contain a cycle |
| Specification | the `spec` file is missing or untracked |
| Coverage | a heading of the specification at the outline's level, outside a code fence, is cited by no row and is not under `Not planned`; a row that is not done, or the `Not planned` list, cites a heading the specification does not have at that level |
| Plan branch | the current branch is a `plan/*` branch and a file outside `<cards_dir>/plan/` differs from the point where the branch left the base branch |

When the specification differs from `spec_blob`, `card plan` prints one line naming the outline and still exits 0. It cannot fail on this: 0.1's design was amended 35 times while it was built, some of those by cards in their own pull requests, and a failing check would have turned every one of them red.

The plan branch check is the mechanical form of "a plan run writes no card and no code".

### 11.2 `card plan check <id>`

The three rules of section 7.

### 11.3 What a script cannot decide

Whether each requirement has a row, whether the cut is right, whether a size is plausible, and whether two rows that change the same code should be ordered. These go to the plan reviewer.

Known limits:

- Coverage is a net for a section nobody planned, not a count of requirements. It works at one heading level, chosen per outline. Spec Kit files put their requirements in a list under one heading and OpenSpec files put each under a third-level heading; the spike (section 21) confirms both before the check is built.
- Only `#` headings count. A heading underlined with `=` or `-` is not seen, and a code fence is recognized by three backticks or tildes at the start of a line.
- Two headings with the same text count as one.
- `card plan check` is true when it runs. A file may move between the yes and the first edit; that is minutes, not days.
- No script checks that a revision left alone the rows that already have a card or a branch, or that a removed id is not used again. Both show in the plan pull request's diff.
- `card plan` is not a handoff gate. A fault in an outline does not make a card's work wrong, and a 0.1 `card` on the PATH would stop every handoff with `unknown command`. CI and the next plan run report it.

## 12. Agents

### 12.1 Plan reviewer

`agents/plan-reviewer.md` is read-only: Read, Grep, Glob and Bash. It receives the outline's path and the base branch, and reads the outline from the working tree, where it is not yet committed. It did not write the outline and is told to assume the outline is wrong.

Procedure:

1. Read the specification and the outline.
2. For each heading a row cites, list every requirement under it and find the `does` line that covers it, in that row or another. A requirement with none is a finding. A requirement that two rows claim is a finding.
3. For each row: is it one session's work; is each `does` line true or false; is the size plausible given what the row has to read and change, and given `card stats` where it has figures for that size.
4. For the rows together: does a row need code that another row creates without depending on it; would two rows change the same code with neither depending on the other. Search the code where the answer needs it, and say what was searched.
5. For each `Not planned` heading, confirm it asks for no work. For each row with no `spec` item, say whether the specification calls for it.

Output is in the form the 0.1 reviewer uses: `must-fix`, `should-fix` or `nit`, the outline's line, the problem in one sentence, and how it goes wrong.

### 12.2 Reviewer

One step is added to `agents/reviewer.md`. When a `Read` item of the card has a comment that starts with `(row `, the item is a specification and the comment names headings in it: list each requirement under those headings that no `Acceptance` item covers and no `Out of scope` item excludes. Each is a `should-fix` finding. This is the review of a card body by an agent that did not write it. It comes after the work, not before it, which is the cost of section 3's choice.

## 13. Hooks

One hook changes.

- **Log guard.** `stop.sh` blocks the end of a turn on a card branch that has commits, a clean tree and no session log. The approval commit of section 10.2 would trip it on the first turn that ends before any code is written. The count of commits now leaves out those that change nothing outside the cards directory: `git rev-list --count HEAD --not <base refs> -- . ':(exclude)<cards_dir>'`.

The budget warning is unchanged. It fires on a `card/*` branch, and growth is measured over the whole transcript from the session's first turn, so the reading and writing that next-card does before the branch exists is counted.

A plan run has no budget warning. It writes one file, and it reads through a subagent.

The session-start hook prints `card status`, whose "Next ready" line may now name a row.

## 14. Trial and release

**Before the build.** The plan prompt is drafted and run by hand, with no `card plan`, on two specifications: `docs/design.md` and a Spec Kit sample. This is the first card of the deck (section 21).

**After the build.** The planner is run on the 0.3 design in this repository and on one specification in the maintainer's other repository, until ten planned cards have been implemented, at least two of size S and two of size M. If ten cards do not include them, the evidence page says goal 6 was not met. The trial repositories run the plugin from a checkout of the main branch with `--plugin-dir` (finding 8), and their CI stays on `card lint` 0.1.2.

Nothing new is stored. For each trial card `docs/evidence.md` records:

| Measure | Read from |
|---|---|
| The row had to be cut again before its card could be written | a plan pull request whose body gives that as its cause (section 10.1, step 9) |
| Files added to `Touch`, and `Tests` lines reworded, after approval | `git diff <approval commit> HEAD -- <card file>`, which handoff puts in the pull request body |
| The size changed when the body was written | the card against its row |
| The card split | `outcome: split` in the session log |
| Growth against budget | the session log; `card stats` |
| Outline findings and what was done about each | the plan pull request's body |
| Growth of a plan run | `card tokens`, in the plan pull request's body |

The baseline is recorded beside them: 9 of the 24 hand-written cards of 0.1 had a `Touch` entry at the end that was not there when the card was first committed.

The 0.3 design is written by an agent that knows it will be planned, so its sections may suit the planner better than a specification written for people does. The evidence page keeps the two repositories' figures apart for that reason.

The maintainer reads the record and decides whether to tag. No count decides it: with ten cards, a planner that misses a file on half of them passes a "more than half" test 62 times in 100. One result stops the release: a row that had to be cut again before its card could be written. The release then waits for a change to the plan skill or the outline format, or for the maintainer's written reason in the evidence page.

## 15. Errors

| Situation | Behavior |
|---|---|
| No outline | `card plan` says so and exits 0 |
| The path given to `/workdeck:plan` is not a tracked file | The skill stops and says so |
| The specification has no heading at the outline's level | `card plan new` exits 1 and names the levels that have headings |
| A plan pull request by this user is open | The plan skill offers to resume it, or stops |
| The specification changed | `card plan` prints one line and exits 0. The plan skill shows the difference on its next run |
| `card plan start` for an id with a card file, or with no row | Exit 1 with the reason |
| The user says no to a card that next-card wrote | The card file is deleted. Nothing was committed and no branch exists |
| A row cannot be done as cut | next-card deletes the card file and names the plan skill |
| Two plan runs for one specification | Both write `<cards_dir>/plan/<prefix>.md`; the second pull request conflicts |
| `card` on the PATH is 0.1 | `unknown command 'plan'`, exit 2; the skill says to update `card` |

## 16. Trust and input handling

The specification and the outline are repository content and can arrive in someone else's pull request.

- An outline is read only from the base branch and the working tree, the two places card files are read from. `card` reads nothing from a `plan/*` branch it is not on.
- `card list`, `card next` and `card status` print a row's id, size and title, filtered as a card's are (design.md, section 16). A row's `does`, `not` and `spec` lines reach a session only through `card show` and `card plan start`, which a skill runs when the user starts that row.
- `spec` is validated like `cards_dir`: a relative path inside the repository with no `..`. The prefix is validated before it is used in a file name or a pattern.
- Nothing in an outline is sourced or evaluated. A `Touch` entry is used only as a `case` pattern, as in 0.1.
- The specification is read by the plan session, which may push a `plan/*` branch and open a pull request. A specification from an untrusted source is an instruction to that session. The README says so beside the plan skill.

## 17. Testing

- Shell tests as in 0.1: one case per row of the table in section 11.1 and per rule of section 7; a row in each state of design.md section 6, and the remainder rule; `card plan new`, `accept` and `start`; `card show`, `list` and `next` with rows; the stop hook after a card-only commit.
- A case runs `card` 0.1.2 `lint` against a fixture deck with an outline, a planned card and a split remainder, so the compatibility claim of section 8 is a test. The 0.1.2 file is fetched from the release tag in CI and the case is skipped when offline.
- A case runs every 0.1 test of `list`, `next` and `status` in a repository with no outline and compares the output byte for byte with 0.1.2's.
- The skills cannot be unit tested. Shell tests check the mechanics, as for the other four: front matter, that every `card` command a skill names exists, and the order of check, review and approval.
- The plan skill, the changed next-card and the changed init are each run by hand in a scratch repository before the trial. The plan skill's run is made under exactly the permission entries init writes, and the prompts it raises are recorded: `docs/evidence.md` still lists that as not shown for handoff.

## 18. Risks

| Risk | Response in 0.2 |
|---|---|
| The session that writes a card implements it, so the scope gate checks a list its subject wrote | The row was reviewed and approved first. The user approves the card before any code. The approved card is a commit, and handoff prints what changed in it since. The quick lane has worked this way since 0.1. |
| A row is too little to carry the cut, and the writing session cuts again | `does` and `not` lines, checked for presence by the script and for coverage by the plan reviewer. The release gate of section 14 is aimed at this. |
| Writing the body uses the card's budget | Measured in the trial. The row's size is a guess that the writing session may correct, in front of the user. |
| Sizes are guesses: three measured sessions, all XS | The trial needs two S and two M sessions. |
| `Tests` lines are written before the tests | They are now written by the session that writes the tests, minutes before. Rewording is recorded. |
| The plan run has no budget | It writes one file and reads through a subagent. A specification too large for one session is split by the user. |
| The planner is a prompt and cannot be tested by a script | The spike before the build, `card plan` on its output, the plan reviewer, and the trial. |
| The agent ignores the plan skill and implements | `card plan` fails on a `plan/*` branch that changes anything but an outline. |
| The specification changes while it is built | `card plan` says so without failing. Coverage is checked against the file as it is, so a new section fails until it has a row or a `Not planned` entry. |
| The trial builds part of 0.3 on the main branch before 0.2 is tagged | Section 22, decision 1. |
| Rows make dependencies cost a wait, so a planner leaves real ones out | The plan reviewer's step 4. Not measured in 0.2. |

## 19. Claude Code behavior this design relies on

Read on 2026-10-06 through Context7 (`/websites/code_claude`). Pages are under `https://code.claude.com/docs/en/`. Each row is read again in the card that depends on it, and rows 14 to 17 are settled by the spike.

| # | Claim | Page | Status |
|---|---|---|---|
| 1 | A skill with `context: fork` runs in a new subagent that does not see the conversation history | `skills`, `slash-commands` ("Run skills in a subagent") | read |
| 2 | That subagent runs in the background unless the skill sets `background: false` | `slash-commands` | read |
| 3 | `disable-model-invocation: true` means only the user can invoke the skill | `slash-commands` ("Control who invokes a skill") | read |
| 4 | A subagent works in its own context window and returns a summary; its tool calls stay out of the main context | `sub-agents`, `how-claude-code-works` | read |
| 5 | The built-in Explore subagent has read-only tools and skips `CLAUDE.md` | `sub-agents` ("Built-in subagents") | read |
| 6 | `AskUserQuestion` is removed from every subagent | `sub-agents` ("Available tools") | read |
| 7 | A plugin agent supports `name`, `description`, `tools` and `model`, and ignores `permissionMode`, `hooks` and `mcpServers` | `plugins/components` ("Frontmatter fields in plugin agents") | read |
| 8 | A background subagent keeps Read, Grep, Glob and Bash, so the plan reviewer has its tools either way | `sub-agents` ("Available tools") | read |
| 9 | A background subagent's permission prompts appear in the main session (from 2.1.186) | `tools-reference` ("Agent tool behavior") | read |
| 10 | `$ARGUMENTS` and `${CLAUDE_PLUGIN_ROOT}` are substituted in a plugin skill's body and in the Bash rules of `allowed-tools` | `slash-commands` ("Available string substitutions") | read |
| 11 | `` !`command` `` in a skill body runs before the prompt is sent and its output replaces it | `slash-commands` | read |
| 12 | A Bash permission rule matches the command as written; deny is evaluated before allow; the rules are not a security boundary | `permissions` | read |
| 14 | The Agent tool accepts a plugin agent's scoped name (`workdeck:plan-reviewer`) | none | unverified in the documentation; `workdeck:reviewer` launched this way in a real session (finding 10) |
| 15 | Claude follows a skill's instruction to delegate a search to Explore and to wait for a subagent before going on | none | unverified; the page says Claude chooses when to delegate and that subagents run in the background by default |
| 16 | A skill with `disable-model-invocation: true` adds nothing to every session's context | `slash-commands` says "Description not in context" | unverified: `claude plugin details` reported about 335 always-on tokens for 0.1.1 and the README attributes them to the four skills and the agent. One of the two is wrong. |
| 17 | A new plugin agent's description is in every session's context | `plugins/measure` shows agents with an always-on cost | read; the size for `plan-reviewer` is not measured |

Row 13 of the first draft, about the post-tool-use hook's input, is gone with the change it supported.

## 20. Changes from the adversarial review

The review is [`development/review-0.2.md`](development/review-0.2.md): 31 findings, each with its evidence. Four were questions for the maintainer, answered on 2026-10-09:

1. **Lifecycle.** Card bodies are written just in time by next-card. The plan pull request per wave is gone, and with it the `pending` state, the scan of `plan/*` branches, the five-cards-per-run limit and the budget warning on plan branches.
2. **Trial specification.** The 0.3 design.
3. **Init extras.** The codebase map is cut. Permission entries, `touch_ignore` and review rules stay.
4. **Release gate.** A spike before the build, then a trial that the maintainer judges, with one hard stop.

What else changed, by the review's finding number:

- 5, 6: a row carries `does` and `not` lines, and rows are blocks, not lines split on `|`.
- 7: the plan reviewer runs before the user is asked, not after.
- 8, 9: an open plan pull request can be resumed, and an outline can be revised on request.
- 10: `card plan` fails on a plan branch that changes anything but an outline.
- 11: a row waits for the split remainders of its dependencies. Handoff no longer edits the outline.
- 12, 13: path checks moved to `card plan check`, run once before work, and a `(new)` path must not exist.
- 14, 15: a changed specification is reported, not failed, and a done row may cite a heading that is gone.
- 16: the heading level is per outline.
- 17: the outline's file name comes from its prefix.
- 18: "card matches row" is gone; the card wins.
- 19: the approval commit, the stop hook's condition and the pull request body keep scope growth visible.
- 20 to 31: smaller corrections, listed in the review.

## 21. Build order

The deck is written by hand in PLAN-01. Its order, riskiest first:

1. **Spike.** A draft of `skills/plan/SKILL.md` and `agents/plan-reviewer.md`, run by hand on `docs/design.md` and on a Spec Kit sample, with no `card` code. It records: what an outline looks like and what is wrong with it; whether a second session can write a card from a row alone; the heading levels of both files; rows 14 to 17 of section 19; the growth of a plan run. The outline format of section 5 is confirmed or changed here, before anything parses it.
2. The outline format, `card plan` and its checks, `card plan new` and `accept`.
3. Rows in `list`, `next`, `status` and `show`, with the remainder rule, and the byte-for-byte test against 0.1.2.
4. `card plan start` and `card plan check`.
5. The stop hook's condition.
6. The plan skill and the plan reviewer, from the spike's drafts.
7. next-card, `reference/implement.md`, the reviewer's step and handoff's line.
8. Init, and the three templates.
9. The 0.1.2 compatibility test, the README, the reference, the changelog and the version.
10. The trial and the evidence page.

## 22. Decisions locked, and what is deferred

Locked on 2026-10-09. Each was attacked once more before it was fixed; the attacks are in the review record's third part.

1. **Where 0.2.0 is tagged from.** The main branch. A trial card that adds a command or a skill of 0.3 which a user can reach is not merged before the tag unless the feature it belongs to is complete. If the main branch still holds a reachable half of a feature when the maintainer decides to tag, the tag goes on a branch cut at the last 0.2 commit, with the planner's fixes picked onto it. Which of the two applies is a fact read at that moment, not a choice made now.
2. **The 0.3 design.** Written by Claude Code as its own hand-written card, outside the 0.2 deck. It can be written while 0.2 is built. The trial card lists it under `Read` and cannot start until it is on the base branch.
3. **`card plan` in handoff.** No (section 11.3).
4. **The quick lane's card.** It does not get an approval commit in 0.2. Recorded in `development/later.md`.
5. **Reading an outline.** For each outline file, the working tree's copy if there is one, otherwise the base branch's. Rows are not merged from the two.
6. **Budgets.** No change for a card whose body is written in its own session. The trial's figures decide.

Deferred, and blocking nothing before the trial:

- Which other repository the second trial runs in, its language and whether its tests nest. Decided after the build. The trial card carries the question.
