# Reviews of the 0.2 scope and design

Two adversarial reviews, each by an agent that did not write what it reviewed, a third pass in which the second reviewer attacked its own amendments before they were locked, a fourth made by the agent that wrote the deck, and a fifth on what the spike asked for. "The scope" is [`scope-0.2.md`](scope-0.2.md) and "the design" is [`../design-0.2.md`](../design-0.2.md).

## First review, 2026-10-06: the scope note

Twelve changes, listed here as they stood at the end of the scope note before the second review rewrote it. Eleven were accepted and one was not.

1. The path rule failed honest plans: four `Read` entries and eight unmarked `Touch` entries in 0.1's own cards named files that an earlier card created. A path could come from a `(new)` entry of a dependency.
2. "Exists as a card file" did not say where. A second batch cut from the base branch failed `card lint` 0.1.2 with `depends on AUTH-02, which is not a card`. Bodies waited until dependencies were done on the base branch, with one plan pull request open at a time.
3. "A 0.1 user changes nothing else" was false: init stops on an existing `workdeck.conf`, the permission entries cover only `card/*`, and a workflow at 0.1.2 has no `card plan`.
4. The one-third tripwire sat at the rate hand-written cards already show, and its remedy did not follow from the measure.
5. The measures had nowhere to be stored in the version 1 formats. They are read from pull requests.
6. Ordering cards that touch the same file cannot be decided for glob entries, and where it can it turns the deck into a chain: `bin/card` is in 10 of 25 cards here. It moved to the reviewer and to 0.3.
7. The heading check counted `#` lines inside code fences (ten in `docs/design.md`) and had no answer to a specification edited after approval.
8. A batch of three to five wrote dependent cards against code that did not exist. The batch became the rows whose dependencies are done.
9. Splits and id collisions were not covered.
10. `cards/MAP.md` fails `card lint` 0.1.2. New files go in one subdirectory.
11. Not accepted: cutting the codebase map and the `REVIEW.md` proposals.
12. Outline approval left no record. Merging the first plan pull request is the approval.

The second review overturned items 2, 8 and 11 and replaced the mechanism of items 1, 7 and 9.

## Second review, 2026-10-09: scope, design and PLAN-01

The reviewer read the three documents against `bin/card` 0.1.2, the hooks, the skills, the findings and the repository's own cards and history. Evidence that was measured is marked with how.

"Decided" means the maintainer answered the question on 2026-10-09. "Amended" means the scope and the design were changed; the maintainer then asked for the amendments to be attacked once more and locked, which is the third part of this record.

### Questions put to the maintainer

**1. Late writing costs one plan pull request per dependency wave.** Measured on this repository's 25 card files: the longest dependency chain is seven cards, and with five cards per run the deck needs at least nine plan runs, each a pull request, beside 25 card pull requests. Each run starts a new session and reads the specification and the code again. The scope listed this as risk 5 without a number. Three lifecycles were offered: waves as drafted, every body up front in one pull request, or bodies written just in time by next-card. **Decided: just in time.** This removed the `pending` row state, the scan of `plan/*` branches, the limit of five and the budget warning on plan branches, and it made findings 20 to 23 moot.

**2. The trial gates the release and has no subject.** Both documents listed "which specification" as unanswered while making the trial's result a condition of release. **Decided: the 0.3 design.** It does not exist yet; see finding 27.

**3. The codebase map makes an optional file a CI failure.** `card plan` failed when a map item named a path that was gone, so renaming a directory in any pull request turned the check red. The first review had already recommended cutting it. With just-in-time writing the session that needs to know the code reads it. **Decided: the map is cut; permission entries, `touch_ignore` and review rules stay.** The reviewer had offered to keep the project's test naming style as one line in the outline; that is dropped too, because the session that writes a `Tests` line now reads the tests it will sit beside.

**4. The thresholds cannot do their job, and the design builds checks before it has seen a plan.** With ten cards, a planner whose true rate of missed `Touch` files is one half still passes a "more than half" test with probability 0.62 (binomial, ten trials). The budget threshold needs five sessions per size and ten cards over three sizes will not give them. The baseline was written as "seven or eight of 24"; measured by comparing each card's `Touch` paths at its first commit with those on the main branch, it is 9 of 24. Separately, the draft specified eleven mechanical checks and no step in which the prompt was run before they were built, although the prompt is the part nobody has seen work. **Decided: a spike first, then a trial that the maintainer judges, with one hard stop.**

### Holes in the mechanism

**5. A row carried too little to review or to write from.** A row was an id, a size, dependencies, a title and heading names. The plan reviewer was asked whether "the cut is right" and whether acceptance covers the specification, with nothing in the row saying which part of a heading was that row's. Under just in time it is worse: the session that writes the card has only the row. Amended: `does` and `not` lines.

**6. Rows split on `|`** could not hold a title or a heading containing one, and had a variable number of trailing fields. Amended: a row is a block of `key: text` items.

**7. The user approved the outline before the adversarial reviewer saw it.** Step 4 of the plan skill asked for a yes; step 8 launched the reviewer. Amended: the reviewer runs first and its open findings are shown with the outline.

**8. An open plan pull request could not be revised.** With a row `pending` the plan skill stopped. A person who asked for changes on the plan pull request had no command that would make them. next-card has this loop for card pull requests. Amended: the plan skill offers to resume.

**9. An outline could not be revised on request.** The only revision path was "the specification changed". Replanning is the normal case: of the 24 cards 0.1 was built with, eight (R-01 to R-04, S-01 to S-03, E-01) came from reviews and first runs, not from the plan. Amended: the plan skill takes a request after the path, and may change rows that have no card and no branch.

**10. Nothing mechanical stopped a plan run from implementing.** The design's own risk table said so. Goal 2 says a script decides what a script can. Amended: `card plan` fails on a `plan/*` branch that changes a file outside the outlines.

**11. The scope's split check was dropped by the design, and what replaced it does not hold.** The scope said no row may depend on a card with an unfinished split remainder. The design checked only that the remainder had a row. With that row present, a row depending on `AUTH-02` became writable as soon as `AUTH-02` was done, while `AUTH-02b` still held the code it needed. The fix asked handoff to edit the outline and "tell the user", and a teammate on the 0.1 plugin would not have done either. Amended: a row waits for every lettered remainder of its dependencies. Handoff does not touch the outline.

**12. Path checks ran forever and were only true once.** `card plan` checked the paths of every planned card that was not done, on every run. A file renamed by an unrelated pull request, or by the card's own work, failed the check for a card nobody had edited; with `card plan` in CI that is a red build. The design did not say whether "done" was read from the working tree or the base branch, which decides whether the card's own pull request fails. Amended: `card plan check <id>` runs once, before the user approves the card.

**13. `(new)` was a free pass.** An entry marked `(new)` was not checked at all, so marking every entry passed. Amended: a `(new)` path must not exist.

**14. A changed specification failed `card plan`.** Any edit, a typo included, changed `git hash-object` and failed the check until `card plan accept` ran, which in the drafted flow meant a plan run and a pull request. `docs/design.md` records 35 amendments made while 0.1 was built, several by cards whose own `Touch` list held the design. Amended: reported in one line, exit 0. Coverage is checked against the file as it is.

**15. A done row that cited a removed heading failed for ever.** Amended: the check applies to rows that are not done.

**16. Coverage at the second heading level says little for the formats the design names.** `docs/design.md` has 30 second-level headings and its work does not follow them: `bin/card`, which one of those headings describes, is in the `Touch` list of 10 of the 25 cards. A Spec Kit specification puts its functional requirements in one list under one heading, and OpenSpec puts each requirement under a third-level heading. These two layouts are from the reviewer's knowledge of the formats and were not checked against current templates; the spike checks them. The design's risk table deferred this to "the first trial card", after the check was specified. Amended: the level is a key of the outline, and coverage is described as a net for a forgotten section, not a count of requirements.

**17. The outline's name came from the specification's file name.** Every Spec Kit specification is `spec.md`, in its own directory. The second one would have been refused. Amended: the name is the prefix.

**18. "Card matches row" was a check with no purpose.** Once a card exists nothing reads the row's title, size or dependencies. The check would have failed whenever a user edited a card. Amended: the card wins.

**19. A card written in its own pull request hides scope growth.** This is a cost of decision 1, and the quick lane has had it since 0.1. `docs/design.md` section 11 relies on a file added to `Touch` showing in the pull request's diff. That holds for a card that was on the base branch first. A card created on its branch is new from top to bottom in the diff, and the trial's central measure could not have been read. Amended: next-card commits the approved card alone, handoff prints the difference since that commit, and the stop hook stops counting commits that change only the cards directory (checked: `git rev-list --count HEAD --not main -- . ':(exclude)cards'` prints 0 after such a commit and 1 after a code commit).

### Moot after decision 1, recorded because they were real

**20. `pending` did not hold one pull request at a time.** It was defined by card files on a `plan/*` branch that the base branch lacks. A plan pull request that changed only the outline (the specification was accepted again, or the budget warning ended the first run before a card was written) held nothing `pending`, and a second run could start. Merged plan branches also stay: the permission template denies `git branch -d` and `-D`, so each run leaves a branch, and finding pending rows meant one `git ls-tree` per branch at about 17 ms each (finding 4), in a command the session-start hook runs.

**21. The plan skill created `plan/<name>-<time>` at step 3 and learned `<name>` from `card plan new` at step 4.**

**22. The plan reviewer was told to find the new cards with `git diff` against the merge base.** `card new` leaves them untracked, and the skill committed after the review. The diff would have been empty.

**23. The stated reason for creating the branch early was wrong.** "So the reading is measured": growth is the transcript's peak minus its first turn, whatever branch the session is on. The branch decides only whether the hook fires.

### Smaller corrections

**24. The design narrowed the approved scope twice.** It dropped the path that may come from a dependency's `(new)` entry, with a reason, and the split check of finding 11, without one. The scope and the design now agree.

**25. The list of changed files was incomplete.** `templates/workdeck.yml` gains a step (section 8 of the draft) and was not listed. `templates/claude-md-section.md` was listed with no word on what changes, and init leaves an existing section alone, so no 0.1 repository would have received it. The README, the reference, the changelog and the manifest were not listed either. Amended.

**26. One measure had no source.** "Findings the plan reviewer raised and the user accepted" was to be read from the plan pull request's body, which listed only the findings left open. Amended: the body lists every finding with what was done about it.

**27. The trial's logistics were not designed.** The planner under trial is unreleased, so the second repository cannot install it from the marketplace and its CI cannot fetch `card plan` at a tag. Amended: `--plugin-dir` from a checkout, CI on 0.1.2. And with the 0.3 design as the subject, the main branch holds 0.3 cards before 0.2 is tagged. Both settled in the third pass: design section 22, decisions 1 and 2.

**28. Trust.** Computing `pending` read file names from `plan/*` branches that anyone with push access can create; 0.1 reads one thing from a branch it is not on, whether a card there has a `## Blocked` section. Moot now. Still relevant: a prefix of `Q` would collide with quick cards, and a specification is an instruction to a session that may push and open pull requests. Amended: `Q` is refused, and the README says the second.

**29. "The output of Spec Kit or OpenSpec is already such a file" overstated it.** Both write several files, and both write their own task list. The planner reads one file. Amended: stated as out of scope.

**30. Every row had to cite a heading.** A migration or a CI job that no single heading asks for would have needed an invented citation. Amended: a row may have no `spec` item, and the plan reviewer looks at each.

**31. Late writing protected less than it claimed.** It made paths exist along dependency edges. Five sibling rows written in one run still described code that the others would change, and in this repository `bin/card` is in 10 of 25 cards. A rule that makes every dependency cost a wait also pushes a planner to leave dependencies out. The second half still applies to rows: design section 18, last row.

### What the reviewer looked for and did not find

- A way for an outline to break `card` 0.1.2. Its card index is a glob over the top level of the cards directory. Its `done` lookup greps the directory recursively on the base branch but keeps only paths that are cards. The claim holds, and the design now says which code makes it true.
- A configuration key that could be added safely. `budget.PLAN` passes 0.1.2's key pattern, but every budget key is also a card size.

### Not reviewed

- The deck, at the time of this review. The fourth pass covers it.
- The plan skill's prompt. The spike writes the first one.

## Third pass, 2026-10-09: the amendments and the open questions

The maintainer answered the four open points: lock the remaining choices after attacking them; settle the tag as needed; Claude Code writes the 0.3 design; the second repository is decided after the build. This pass is by the agent that wrote the amendments, so it is weaker evidence than the two above, and says so.

| Point | Attack | Locked |
|---|---|---|
| Tag from the main branch if what landed is "inert" | "Inert" is a judgment made by the person who wants to tag. A release branch with picked commits is a process a one-person project does not have. | A rule that can be read off the tree: no reachable command or skill of an unfinished 0.3 feature is merged before the tag. The branch is the fallback when the rule was broken, not the plan. |
| Claude Code writes the 0.3 design | The specification under trial is written by the same kind of agent that plans it, and knows it. Its sections may be cut to suit the planner, which flatters the result. | Accepted with the bias recorded: the two repositories' figures are kept apart, and the second specification was not written for the planner. |
| The second repository is decided later | Nested test names (finding 1) are the known weakness of `Tests` lines, and the design cannot be tuned for a language nobody has named. | Accepted. Nothing before the trial depends on it, and rewording of `Tests` lines is recorded either way. |
| Should `card plan` be a handoff gate | Without it, a card that adds a section to the specification passes handoff and fails only in CI, or at the next plan run. | No. A 0.1 `card` first on the PATH would stop every handoff with `unknown command`, and an outline fault does not make the card's work wrong. |
| The reviewer's new step fired on "a specification with headings named after it" | Not something an agent can decide the same way twice. | `card plan start` writes the comment as `(row <id>: ...)`, and the step fires on that. |
| The hard stop was read from "a plan pull request between the outline's and the card's" | A revision made because the specification changed looks the same. And when next-card gives up on a row it deletes the card file and leaves no trace. | A revising plan run writes its cause in the pull request body. |
| Two S and two M sessions among ten cards | The 0.3 outline may not hold them. | If not, the evidence page says goal 6 was not met. The trial is not extended for it. |
| Rows are read from the base branch and the working tree | "The working tree's copy wins" did not say whether rows are merged. A branch cut before a revision shows old rows. | Per file: the working tree's copy, or else the base branch's. Old rows on an old branch are the staleness cards already have, and next-card checks out the base branch first. |
| A revision may change only rows with no card and no branch | Nothing checks it. | Left as an instruction and a known limit. The pull request's diff shows it, and a check would need the outline as it was. |
| The quick lane has the hidden scope growth of finding 19 | The fix is one line in the skill now that the stop hook allows a card-only commit. | Not in 0.2, which is the planner. Added to `later.md`. |
| The plan skill's commands under init's permission entries | The template allows no `git checkout`, `git add` or `git commit`, for card branches either, and no run under exactly those entries has been recorded. | The hand run of the plan skill is made under them and the prompts are recorded. |
| The outline format is specified before any plan has been seen | The same streetlight as finding 4. | The format is the one part of the approved design the spike may change. Every card that parses an outline depends on the spike. |

## Fourth pass, 2026-10-09: the deck, and what writing it found in the design

The deck is cards P-01 to P-24 with P-02b, T-01 for the 0.3 design, and S-04 for the release of 0.1.3. This pass is by the agent that wrote the deck, with no second agent, so it is the weakest evidence in this record. What it measured is marked with how. The reviewer that handoff launches for PLAN-01 is the first independent reader of the deck.

### Faults in the design

| Point | Evidence | Outcome |
|---|---|---|
| The version was in item 9 of the build order, before the trial | Claude Code keeps an installed plugin at the version in `plugin.json` and replaces it when that string changes (`plugins/host-marketplace`, "Release a new version"; the changelog of this repository says the same). Merging the version on the main branch would have delivered 0.2 to every user before the trial that decides whether it is released. | The version is the last card, P-24, after the trial record, and carries the maintainer's decision as its question. Design sections 14, 19 (row 18) and 21. |
| The fallback of decision 1, a tag on a branch | The marketplace serves the plugin from the main branch. A tag on a branch changes what a CI workflow downloads and nothing a plugin user receives. | Decision 1 says so, and says the version is not changed on the main branch while it holds a reachable half of a feature. Scope note, "Decided". |
| The stop hook's command in section 13 | Run in a subdirectory, `-- . ':(exclude)cards'` printed 0 for a branch with one card commit and one code commit at the root; the hook would have passed where it should block. With `':(top)' ':(top,exclude)cards'` it printed 1 (git 2.54, a scratch repository). The hook does not change directory. | Section 13 has the anchored form. P-11 tests it from a subdirectory. |
| The same condition lets a card-only commit through | A session that commits only a `## Blocked` section, with no log, is no longer stopped. | Accepted and written into section 13. The approval commit needs the condition, and the blocked log is a reminder, not a gate. |
| The example path in sections 4.2 and 5 | `test_docs_have_one_design_file_and_a_development_folder` fails on any tracked file that names the old documentation directories, and the example was one of them. `make test` failed on the commit that added the design. | The example is `specs/auth.md`. The test is unchanged. |
| A row with no `spec` item had no comment form in section 7 | Section 5 allows the row; `card plan start` had nothing to write. | `(row <id>)`. It still starts with `(row `, so the reviewer's step fires and finds no heading to check. |

### Where the design and the repository's rules disagreed

| Point | Outcome |
|---|---|
| Section 17 has the 0.1.2 file "fetched from the release tag in CI". `cards/REVIEW.md` says a test touches no network. | A step of the CI workflow fetches the tag. The test reads the file with `git show v0.1.2:bin/card` and skips where the tag is absent (P-08). |
| Section 17 says "a fixture deck". The same rule says each test builds its own repository. | The deck is built in the case with the helpers (P-18). |
| `cards/REVIEW.md` forbade naming any other project outside one section of the README. The approved design and this record name two specification formats. | The rule gains an exception for a specification format named as the planner's input, in the 0.2 design and the development records. The README still names none (P-19). |
| `<id>: card as approved` inside a code span | `test_skills_name_only_card_commands_that_exist` reads it as the command `card as`. P-14 and P-15 carry the trap. |

### Choices made in the deck, each attacked

| Choice | Attack | Kept or changed |
|---|---|---|
| One prefix, `P`, for the whole deck | Easy to confuse with `PLAN`. | Kept. `card list` orders prefixes alphabetically, so one prefix is the only way the list follows the build order. |
| The 0.3 design card was `PLAN-02` | It sorted before `P-01`, so `card next` offered it first, and would have gone on offering it before every card of the deck. A design for 0.3 written before the spike is written against an outline format that may change. It may depend on no 0.2 card, so order is the only lever. | Changed to `T-01`, which sorts after the deck. It can still be started by id at any time. |
| P-22 depends on T-01 | The maintainer asked only that the trial card list the design under `Read`. | Kept. It is the mechanical form of "cannot start until it is on the base branch". T-01 depends on nothing. |
| `Tests` lines as words, as the 0.1 cards have them | Design section 10.2 asks a planned card for the name the test will have, in the style of the tests beside it. The deck should follow the rule it builds. | Changed to the function names, `test_<words>`. The gate compares letters and digits, so either form passes. |
| P-05 reuses `changed_files` | That function drops every path under the cards directory, so a card written on a plan branch would not have been seen (read in `bin/card`). | The card says to take the unfiltered list. |
| `card plan check` and an ignored file | Neither "tracked" nor "untracked". | A `(new)` path fails when anything is at that path. Any other `Touch` entry must match a file git would report, because the scope gate cannot see a change to an ignored file. |
| The trial as one card | It is not one session: plan runs and ten card sessions are the maintainer's own. | Two cards: P-22 records the setup and P-23 the result. Neither is one of the ten. |
| The hand runs of section 17 had no place in the build order | | P-21, in item 10. |
| T-01 at size M | PLAN-01 needed several sessions for the same four outputs. | Kept as one card, as asked. Its notes name the split. |
| The spike at size S | Two drafts, two plan runs, a second session and four claims. | Kept: the plan runs and the second session are sessions of their own, and the card's session writes the drafts and the record. If it does not fit, that is the first measured S. |

### Found by the handoff reviewer

The reviewer that handoff launched for PLAN-01 did not write the deck or this pass. It confirmed the pathspec result and the `changed_files` reading above, and found what follows. Three were must-fix.

| Finding | Evidence | Outcome |
|---|---|---|
| The baseline of every compatibility claim, `card` at the tag `v0.1.2`, cannot run in a WorkDeck repository | The project was renamed after that tag and the version was not changed. `git show v0.1.2:bin/card` reads `mergehand.conf` (line 91) and exits 2 where there is a `workdeck.conf`. The README's download line and every workflow init writes name that tag today. | Must-fix. The baseline is 0.1.3, the same code under the present name. Card S-04 releases it, outside the deck, and P-02, P-11 and P-12 depend on it so that no 0.2 code is in that release. Design section 8; the design, the scope and the deck say 0.1.3 where they said 0.1.2. The first three parts of this record are left as written. |
| A card named a specification format, and the rule's new exception covered only the design and the records | | Must-fix. The exception covers a card too, and the tool a claim was read through. |
| The scope's hard stop waited for "a change to the plan skill"; the design's for "the plan skill or the outline format" | | Must-fix. The scope has both. |
| "Change the tag" does not run `card plan` in CI: a workflow written by 0.1 has only the lint step | `templates/workdeck.yml` | The design, the scope and P-19 say to add the step. |
| The workflow template would have gained a step that fails until the release | The tag init writes has no `plan` command before P-24. | The template changes in P-24, with the version. Design section 21, items 8 and 11. |
| A new install takes the main branch whatever the version says | The marketplace source is the repository itself. | Accepted, as a row of design section 18. Not gated. |
| Splitting T-01 defeats P-22's dependency on it | A card with a file does not wait for a remainder. | T-01's notes say to move the dependency to the remainder in that handoff. |
| A specification path with a space | A `Read` entry ends at its first space, so `card plan check` would report half a path. | Refused. Design section 5, P-02 and P-04. |
| "Nothing existing is overwritten" beside "replaces the section on approval" | Design section 10.3. | The exception is stated. P-17. |
| "An id is never used again" was in no card | | P-13 and P-19. |
| P-02 had 21 tests at size M | The largest M card of 0.1 had 10. A split would have left eight cards on a half-built reader. | The id and size checks are P-02b. P-03 and P-06 keep 14 and 16: each is one change with many short cases. |

Left as they are: the scope note is longer than one printed page, and was approved at that length.

### Still open

- Which repository the second trial runs in. P-22 carries the question.
- Whether to release. P-24 carries the question.
- The tag `v0.1.3`, which the maintainer makes when S-04 merges.

## Fifth pass, 2026-10-09: what the spike asked for

The spike ([`spike-0.2.md`](spike-0.2.md)) ends with a list of changes for the deck. This pass attacked each before making it. It is by the agent that ran the spike, with no second reader, and the spike's own limits apply: two plan runs and one card, headless, on a model the maintainer does not use. Card Q-2610091341.

| The spike asked for | Attack | Outcome |
|---|---|---|
| Run the reviewer again after a must-fix finding is fixed | A reviewer told to assume the outline is wrong always finds something, so "again" has no end. The one run whose cost was recorded used 30,817 tokens (spike record). | Accepted with a bound: once more when a fix changed the outline, at most two runs each time before the user is asked, and what is left goes to the user. An edit by the user is reviewed under the same bound. Design section 10.1, step 7; P-13. |
| Put the `does` lines in the pull request body | The pull request changes one file and its diff is those lines. For a revision the diff shows what changed, which a full table hides. The draft failed its own instruction; the instruction was the fault. | Turned down. The body has a table of id, size, dependencies and title. Step 9 says why. |
| Show the readings chosen and the requirements left out | Shown in the conversation only, they are gone when the session ends, and the person who merges may not be the person who planned. | Accepted, and they go in the pull request body as well. Steps 8 and 9; P-13. |
| The skill forbids a commit trailer | A trailer is a setting of the user's Claude Code, and the plugin is used in other people's repositories. This repository's wish is its own. | Turned down. The skill gives the subject line and follows the project's history for the rest, as handoff does. The maintainer turns the trailer off in their own Claude Code settings. |
| Ask before planning a specification whose code is not in the repository | The scope supports a new project with no code. A stop on every such run is noise for exactly that user. | Accepted as one more sentence in the question the skill already asks. Step 5; P-13. |
| The reviewer looks for `does` lines that join statements, and for ones that describe a test | "And" does not always join two statements. A row whose work is tests may say so. A rule a script could apply would be wrong both ways. | Accepted as things the agent is told to look for. Neither is a must-fix finding by itself. Section 12.1, step 3; P-12. |
| The reviewer looks for a missing `not` line where two rows cite one heading | Could a script decide it? Only that the line is absent, not that it is needed. | Accepted, for the reviewer. Step 4; P-12. |
| The reviewer gives relative paths | None. | Accepted. |
| next-card leaves the `(row ...)` item alone | The session might have a better heading. But the reviewer checks the card against the headings that item names, so a session that edits it chooses what it is reviewed against. A script check would bring back "card matches row" (finding 18). | Accepted as an instruction with its reason. Section 10.2, step 3; P-14. |
| The scope says a row is "a few lines" | Rows of 7 to 15 items do part of the card's work early, and their lines name files no card has created, which is what goal 3 was written against. | Wording changed in the scope. No limit on a row: the lines are requirements, and `Touch` still comes from the code. The tension is a row of design section 18. |
| The hard stop of design section 14 was not met | One card, from one row with no dependency, says nothing about it either way. | No change. |

Found by the attack and not asked for by the spike:

- **The reviewer could not see what coverage could not see.** Its steps start from the headings a row cites. For an outline at level 4, the user stories, edge cases and success criteria of the sample were at other levels: outside coverage and outside the reviewer's procedure. Step 5 of section 12.1 now reads those parts. P-12.
- **Three of the four things the spike did not show** are now acceptance items of the hand runs, P-21: an interactive plan run, the maintainer's model, and a card written from a row that has a dependency. The fourth, a planner naming paths in code that exists, is left to the trial, which measures it (design section 14).
- **Design section 11.3 still said the spike would confirm two layouts.** It ran one, and found it other than assumed. The section now says what was seen, and lists what lies outside coverage.

The reviewer at this card's handoff, which did not write this pass, found no must-fix. It found that the bound on the reviewer did not say what follows an edit by the user, that the severity of the two new checks was stated three ways, that a note in P-14 turned a guess about a neighbouring row into the hard stop, and that the cost of a reviewer run was in no record. All four are fixed above and in the cards.

## Sixth pass, 2026-10-09: the reviews of P-03

P-03 built the checks Dependencies, Specification and Coverage. Two agents that did not write it reviewed it: the handoff reviewer, and a second one told to break it, which ran about 110 `card plan` commands in scratch repositories and 23 mutations of `bin/card` against the tests. The maintainer left the decisions to the session that held the card and asked that each be attacked. What changed in the design, sections 5, 11.1 and 11.3:

| Found | Decided | Why |
|---|---|---|
| A heading with no ASCII letter or digit compared as empty, so a specification in a non-Latin script was never required to be cited | A byte above 127 is kept; a heading with no letter or digit is compared as written | The rule of section 5 was written for test names, which are ASCII. |
| With every byte above 127 kept, `Phase 1 — Setup` no longer matched `Phase 1 - Setup` | The UTF-8 general punctuation and the Latin-1 signs are removed | It restores section 5 for dashes and curly quotes without making two CJK headings one. Case outside ASCII is not folded: the command runs bytewise. |
| An outline read from the base branch was checked against the working tree's specification: a branch cut before the plan merged failed with "is missing" | Specification and Coverage run only for an outline in the working tree | Reading the specification and the cards from the outline's ref was the other choice. It is a `git show` per file for a copy that was checked when it merged. |
| A closing fence indented by one space left the fence open to the end of the file, and every later heading outside coverage | Up to three spaces before a heading or a fence; a longer fence; a fence ends at its own mark | The first rule failed toward silence. What is still not recognized fails toward a finding (section 11.3). |
| An outline with a format finding got coverage findings for every heading a dropped row cited | No "cited by no row" finding for that outline | It cannot hide a fault: every format finding fails the run. The cost is a second run. |
| A cycle of cards alone is silent in `card plan` | Left to `card lint` | It is a fault of the cards, and lint reports it with the card's file. |
| The edges of base-only cards are not in the cycle check | Left | It needs a `git show` per card, for a card that is on the base branch and not in the tree. |
| A specification that is a link, a directory or unreadable, or whose hash git cannot make | Each fails with its own message | A link could point outside the repository; a failing hash was reported as a changed specification, with exit 0. |
| A byte-order mark hid a heading on line 1 | Skipped | |
| A card that cannot be read stopped awk, and the cards after it were lost | It is left out of the edges and still counts as a card | |
| `## C++` and `## C#` are one heading | Left, a known limit | It follows from the comparison rule. |

Not changed: the line for a changed specification goes to stdout, as a report (the conventions in `cards/REVIEW.md`). A 64-character `spec_blob` in a SHA-1 repository passes the format check of P-02 and is reported as changed on every run; `card plan accept` (P-04) writes the value, so a hand-written one is the only way to it. A specification under a directory that is itself a link is reported as untracked, which is true and fails. The second edition of the one true awk reads a regular expression as UTF-8 and may not match the punctuation bytes; then a dash is not removed and the comparison is stricter, never looser. It was not run: neither it, gawk nor mawk is on the machine the session ran on, and CI runs gawk and mawk.

## Seventh pass, 2026-10-09: the reviews of P-04

P-04 built `card plan new` and `card plan accept`. Two agents that did not write it reviewed it: the handoff reviewer, and a second one told to break it, which ran both commands against hostile arguments and hostile repository content in scratch repositories, and 17 mutations of `bin/card` against the tests, of which 14 passed unnoticed. The maintainer left the decisions to the session that held the card and asked that each be attacked. Neither review had a must-fix finding. What changed in the design is in sections 9 and 15.

| Found | Decided | Why |
|---|---|---|
| A malformed prefix or level was exit 2 with no usage line | It prints the usage line | The conventions in `cards/REVIEW.md` ask for it. |
| `card plan accept` added a newline to an outline that ended without one | The last line stays as it is | The card says no other line changes. |
| `<cards_dir>/plan` as a link to a directory outside the repository was followed, by both commands | Both exit 1 | A tracked link can arrive in a pull request (section 16). |
| `card plan accept` hashed any readable file the outline named, `.git/HEAD` among them, and the value is committed | The specification must be tracked, as in `card plan new` | An outline from someone else can name a file that is only on this machine. |
| A prefix of 40 characters made an outline that can hold no row; one of 300 failed with bash's own message | A prefix is at most 30 characters | A row id is at most 40, and it is the prefix, a hyphen and digits. |
| A NUL byte in an outline made the awk of macOS cut that line when `accept` wrote the file back | `accept` exits 1 for such a file | Reading a file with NUL bytes line by line is not portable; nothing puts one in an outline. |
| Fourteen mutations passed the tests: the checks of `accept` on `spec`, links, the body and CRLF, and the base-branch half of the prefix checks | Tests added for all but one | The branch for a specification that cannot be read is not tested: a test that removes read permission passes for root. |
| `card plan ""` ran the checks | Usage error, as before this card | |
| A tab or line break in the path was reported as a space | It gets the message for a path that is not inside the repository | |
| From a subdirectory, a path relative to it is reported as missing | The reference says the path is from the root | Every `card` path is from the root, and the outline stores it that way. |
| With two `spec_blob` lines `accept` sets the first and the reader uses the last | Left | `card plan` already fails that outline with "spec_blob appears twice". |
| With no closing `---` the whole file counts as front matter, so `accept` can set a line of the body | Left | `card plan` fails that outline, and `card done` reads a card the same way. |
| `accept` finds the outline by its file name and does not read `prefix` | Left | The file name follows from the prefix (section 5), and `card plan` reports a file where it does not. |
| An outline removed in the working tree and still on the base branch does not stop `card plan new` from writing that path | Left | The removal is in the same branch, and the pull request shows both. |
| A second `--level` replaces the first | Left | `--size` of `card new` does the same. |
| `accept` writes the outline in place, so an interrupt can cut it short | Left | `card done` does the same; the file is tracked, and a rename would lose its mode. |
| A failed `mkdir` or write prints the tool's own line before the `card:` line | Left | `card new` does the same. The prefix limit closes the easy way to it. |
| A `cards_dir` that is itself a link is followed | Left, for its own card | It is so for every command; the place for the check is `load_conf`. |

Not run: gawk and mawk are not on the machine the session ran on, and CI runs both.
