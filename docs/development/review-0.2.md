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

## Eighth pass, 2026-10-09: the reviews of P-05

P-05 built the plan branch check of `card plan`. Two agents that did not write it reviewed it: the handoff reviewer, which left two should-fix findings and two nits open for the maintainer, and a second one told to break it and to attack the decision proposed for each. It ran the check in scratch repositories against hostile paths, odd branches and odd histories, and 28 mutations of `bin/card` against the tests, of which 7 passed unnoticed. The maintainer left the decisions to the session that held the card. Neither review had a must-fix finding. What changed in the design is in sections 11.1, 11.3 and 15.

| Found | Decided | Why |
|---|---|---|
| On a `plan/*` branch with no base branch the check passed and said nothing: a clone of the one branch, or a base branch that was deleted | `card plan` exits 2 with the message of `base_ref` | A check that cannot run has not passed. The session proposed exit 1; the reviewer argued for 2, because nothing was checked and found wrong, and because the case beside it, a branch with no shared history, already exits 2. |
| Any file under `<cards_dir>/plan/` passed: `cards/plan/src/app.ts`, a `.txt`, a `.md` in a directory below, `.hidden.md` | Only `<cards_dir>/plan/<name>.md`, with a name that does not start with a dot, passes | That is what the outline reader reads, and the risk row of section 18 says "anything but an outline". The row of 11.1 said "outside `<cards_dir>/plan/`" and is amended. |
| With that rule an editor's temporary file beside the outline is a finding | Accepted | The line names the file, and such a file anywhere else in the tree was a finding already. |
| The message said "changed on the plan branch" of a file that was not tracked before the branch was cut, and of a file committed on the branch the plan branch was cut from | The line is now `card: <file>: on a plan branch only an outline, <cards_dir>/plan/<name>.md, may differ from the base branch` | It is true of both, and it names no branch. |
| Seven mutations passed the tests: both ways out where there is no base branch, both where there is no shared history, a prefix matched anywhere in the path, and `sort -u` as `cat` and as `sort` | Tests added for all seven, and for four mutations of the new rule for a name | |
| With a detached HEAD, and so in a CI job for a pull request, and during a rebase, the check does not run | Left, and listed as a limit in section 11.3 | The check is for the plan run, which is on the branch by name. A check that guessed the branch of a detached HEAD would guess wrong for a card's pull request. |
| A file that is staged and then removed from the working tree is not seen | Left, for its own card, and listed as a limit | `git diff <commit>` reads the working tree. The fix is in the list that `card touched` shares, and this card may not change what `card touched` prints. |
| A specification edited on a plan branch is a finding | Left, and said under the table of 11.1 | Section 10.1 has the plan run report an ambiguity, not edit the specification. |
| `.hidden.md` in the plan directory of the base branch is read as an outline there and not in the working tree | Left, for its own card | It is in the reader of P-02. The rule for a name now keeps such a file out of a plan branch. |
| When git itself fails, the list of files is empty and the check passes | Left | `card touched` has always done so; there is no `pipefail` in `bin/card`. |
| After local and remote base branches diverge and both are merged into the plan branch, a file of the base branch is a finding | Left | A limit of `fork_point` that `card touched` shares. The fast-forward pull of the skills refuses a diverged base branch. |
| With `base = plan/main`, the check runs on the base branch itself | Left | A configuration nobody has. |
| `PLAN/x` is not a plan branch | Left | The plan skill makes `plan/<yymmddhhmm>`. |
| A file ignored through `.git/info/exclude` or a global excludes file passes | Left | As for `card touched`; it cannot be committed without force. |
| The findings go to stderr, though the conventions send what a gate found to stdout | Left | Every finding of `card plan` since P-02 is a `card:` line on stderr. |

Looked for and not found: a path with a space, a tab, a line break, a quote, an escape character or a leading hyphen gives one line and no raw control byte, since git quotes such a name; `cards/planning/x`, `cards/plan.md`, and `cards/plan` as a file or as a link are findings; a merge of the base branch into the plan branch does not make its files count; no hook writes a file into the working tree of a plan branch, and the stop hook asks for a log only on a `card/` branch; `card touched` and `card tests` print byte for byte what they printed on awkward inputs.

Not run: gawk and mawk are not on the machine the session ran on, and CI runs both. A checkout by GitHub Actions was imitated with local clones. Whether Claude Code writes a settings file into the working tree when a permission is approved during a plan run is for the hand run of P-21.

## Tenth pass, 2026-10-10: the reviews of P-07

P-07 made `card show` print a row that has no card file. Two agents that did not write it reviewed it: the handoff reviewer, which left one should-fix finding open for the maintainer, and a second one told to break it and to attack the decision proposed for each open item. It ran hostile outlines in scratch repositories, compared the output with that of the base branch for every id that has no row, and ran 38 mutations of `row_text` and `cmd_show` against the tests, of which 23 passed unnoticed. The maintainer left the decisions to the session that held the card. Neither review had a must-fix finding. The design did not change.

| Found | Decided | Why |
|---|---|---|
| With `BASE_REF` set in the environment, `base_ref` returned early and `BASE_REFS` was not set. `card show` of a card that is on the base branch only then printed its row, and `card list` printed "unbound variable" | `bin/card` empties `BASE_REF` and `BASE_REFS` before it uses them | The name is a common one in CI scripts. The fault was in 0.1; `card show` turned it into a wrong answer with no message. |
| 23 mutations passed the four tests of the card: the limit of 40, the match of an id against the card files and against a heading, the filter on the name of an outline, an outline read from the base branch, every character that is removed, the front matter, the first row of two, and what is printed of a row | Fifteen tests added | One failed on the code as it was, the one for `BASE_REF`. The others pin what was built. |
| `card show` of a card that is in the working tree made one `git ls-tree` for each base ref before it printed: 5 git calls where 0.1 makes 1 | The working tree is looked at first, and such a card needs no base branch | It is what 0.1 does, and `card show` runs at the start of every card. |
| With no base branch, `card show` of a row prints the "no card" message of 0.1 and exits 1, where `card list` exits 2 with "base branch not found" | Kept, and tested | The acceptance keeps the message and the exit code of 0.1 for an id with no card file. The message ends "run 'card list'", which gives the cause, and next-card runs `card next` first, which exits 2. |
| `row_text` runs with its error output discarded, so an outline that cannot be read gives the "no card" message | Kept | The message sends the user to `card list`, which prints the cause. Letting the line of `cat` through would break the rule that an error starts with `card:`. |
| Only the heading and the lines that start with `- ` are printed. A line of a `does` item that continues on the next line, and a line of prose in a row, are dropped | Kept for `card show`, and tested. The reader is for its own card | `card show` prints what the reader reads. `card plan` says nothing about such a line, and that is the fault: a card for the reader, which reports "text in row X that is not an item". |
| An item with an unknown key, or with no text, is printed, and `card plan` rejects both | Kept | The text is no less trusted than what follows `- does:`, and `card plan` fails that outline. |
| A card file whose first line is `row: no card file yet` would look like a row to next-card | Kept | `card lint` rejects a card that does not start with `---`. P-14 compares the whole first line. |
| A row id longer than 40 characters is not a row | Kept, and tested at 40 and at 41 | `card list` does not list it. |
| A tab is removed and not replaced, so two words join | Kept | The note on the card says control characters are removed, and the reader does the same. |
| A byte above 127 is printed, and a row has no limit on its size | Kept | `cat` of a card file has neither limit, and the ninth pass left the same for a title. |
| An outline whose name starts with a dot is read once it is on the base branch, and section 11.1 says it is not an outline | Left, for its own card | It is in `outline_files` of P-02. `card list` and `card show` agree on it. |
| With rows `AUTH-01` and `AUTH-02` only, `card show AUTH-06` says "no cards with prefix AUTH" | Kept | The acceptance keeps the text of 0.1. |

Looked for and not found: an id for which `card list` says `[row]` and `card show` prints no `row:` line, or the reverse, over outlines with control characters, a line ending of two bytes, a byte-order mark, no front matter or an open one, an empty file, odd file names, a link, and an outline on one of the two places only or different in the two; a byte of difference from the base branch in the output, the error output or the exit code for an id with no row; an escape, a tab or a NUL reaching the output; a second `row:` line or a `---` line forged from a row.

Not run: gawk and mawk are not on the machine the session ran on, and CI runs both. A bash later than 3.2 and GNU `sort -V` were not run either.

## Ninth pass, 2026-10-09: the reviews of P-06

P-06 put the rows of an outline into `card list`, `card next` and `card status`. Two agents that did not write it reviewed it: the handoff reviewer, which left one nit, and a second one told to break it and to attack the decision proposed for each open item. It ran hostile outlines in scratch repositories, compared the output with that of the base branch on nine decks that have no outline, and ran 36 mutations of `bin/card` against the tests, of which 10 passed unnoticed. The maintainer left the decisions to the session that held the card. Neither review had a must-fix finding. What changed in the design is in sections 6 and 16.

| Found | Decided | Why |
|---|---|---|
| A row with a letter in its id that depends on the id without it waited for itself, and no card became ready | A row does not wait for itself | `card plan` reports such a row, but the deck must not stop on it. |
| A row that depends on `AUTH-01b` did not wait for `AUTH-01c`, where handoff puts what a second split leaves | A dependency that ends in a letter stands for the id without it | The rule exists so that a row does not start on code a remainder has still to write. Section 6 says so. |
| A row that names a card and its remainder under `depends` got the remainder twice in `card next` | For a row, no id is printed twice, in either order | A card with a file still prints what 0.1 prints for `depends: A-1, A-1`. |
| `card next` prints the dependencies a row waits for, with no limit on their length, and the acceptance said id, size and title only | For a row, a dependency longer than 40 characters is `?`. Section 16 names what `card next` prints | 40 is the limit of a row id. A card's dependencies are printed as in 0.1. |
| Ten mutations passed the tests: the check of a row id and its anchors, the first row of two, the size limit at 8, every letter of a remainder but `b`, the mark on the lines of `card status` for work in progress, a row with a letter, and what `card next` prints with a dependency and its remainder both open | Nine tests added | Four of them failed on the code as it was. |
| `card status` prints no `[row]` | Kept, and pinned for every line of it | Sections 6 and 16 name `list` and `next`. Until P-07 a session cannot tell from status that the next card has no file; next-card runs `card next`, which says so. |
| When two rows share an id the first read counts, and "first" is the order of the paths, so a row in `aaa.md` wins over the one in `auth.md` | Kept, said in section 6, and tested | `card plan` fails that deck. Choosing by prefix would be a second rule for a deck that is already wrong. |
| A row whose id is not a card id is dropped and nothing says so | Kept | Printing it would put text that was not checked into a session. `card plan` reports it. |
| The rows of an outline with format faults are listed; one with no front matter gives none | Kept | A typo must not empty the deck in the session-start hook. |
| With no outline, one more `git ls-tree` for each base ref | Accepted | 6 calls became 7, and the output was byte for byte that of the base branch. |
| One `git show` for each outline that is on the base branch and not in the working tree: 37 git calls for 30 outlines | Left, for its own card | It is per outline and not per row, which is what the card asked. `git cat-file --batch` is the fix when a deck has that many. |
| An outline removed on one base ref is still read from the other | Left | `base_cards` does the same for a card file since 0.1. The fast-forward pull of the skills makes the two refs equal. |
| An outline that is a link is followed, and one that cannot be read prints the line of `cat` | Left, for its own card | Both are in the reader of P-02, and `card plan` reads the same way. |
| A card whose title ends in `[row]` looks like a row | Left | Nothing reads the mark but a person. |
| Removing the file of a done card brings its row back as ready | Left, for the README of P-19 | It follows from section 6. |
| A byte above 127 in a title is printed | Left | `META_AWK` does the same for a card. |
| `test/lib.sh` is under `Touch` and did not change; `state_of` is now in four case files | Left | `Touch` is a limit. Moving the helper is for the card that next needs it. |
| `sort -V` puts `AUTH-01` before `A-1` | Left | It is 0.1's order, and changing it would change a deck that has no outline. |

Looked for and not found: a tab, an escape character, `$(id)`, backticks or `SYSTEM:` text reaching `list` or `status` from a title, a size or `depends`; a forged row through the name of an outline file; a line ending of two bytes or an empty outline breaking the reader; a byte of difference from the base branch with no outline, with and without `--fetch`; `card status` longer than its limit; a git call per row.

Not run: gawk and mawk are not on the machine the session ran on, and CI runs both. GNU `sort -V` and a real `gh` were not run either.

## Eleventh pass, 2026-10-10: the reviews of P-08

P-08 added one test case that replays the 0.1 cases of `card list`, `card next` and `card status` with no outline and compares each call, byte for byte, with `card` 0.1.3. Two agents that did not write it reviewed it: the handoff reviewer, whose must-fix was that three case files were replayed where nine call the three commands, and a second one told to break it and to attack the decision proposed for each open item. It ran 96 mutations of `bin/card` that change the three commands with no outline, of which 24 passed the case, and 179 calls of both versions on decks the 0.1 cases do not build. The maintainer left the decisions to the session that held the card. The second review had one must-fix finding. `bin/card` and the design did not change.

| Found | Decided | Why |
|---|---|---|
| The wrapper looked at the first argument only, so `card --fetch list`, which a 0.1 case of 22-fetch makes, ran once and was not compared. A line added to the error output of that call passed the whole suite | The command is the first argument that is not `--fetch` | The acceptance says each call. 104 calls are now compared, and the mutation fails the case. |
| With `BASE_REF` in the environment the case failed: `card` 0.1.3 prints "unbound variable" from `card list`, and `bin/card` does not since the tenth pass. The log and the pull request said no difference was found | `setup_env` unsets `BASE_REF` and `BASE_REFS`. The log and the pull request name the difference | It is the one difference there is with no outline, it was made on purpose, and it is 0.1.3 that is wrong. A test must not depend on a variable of the shell that runs it. |
| The case passed with one call compared: a file taken off the list, or a helper that stops going through `card`, was not noticed | The case fails with fewer than 104 calls compared | The tag cannot gain cases, so the number only moves when a 0.1 case file is edited, and then it should be looked at. |
| In a clone made with `--filter=blob:none`, `git show` fetched the file from the remote | `old_card` sets `GIT_NO_LAZY_FETCH=1`, and the case skips there | A test touches no network. |
| The report of a difference put the next label on the line of an empty output | Each label has its own line | The acceptance asks for both outputs, and they have to be readable. |
| The skip said the clone has no tag when the cause was a tree with no `.git`, or a tag with no `bin/card` | It says that `v0.1.3:bin/card` cannot be read | It is what the helper knows. |
| With `--fetch`, 0.1.3 runs first and has fetched and pruned when `bin/card` runs. A `bin/card` that does not prune passes the comparison | Kept, and said in the comment on the wrapper | 22-fetch tests the fetch itself and catches it. Running `bin/card` first would hide the same fault in the other direction. |
| Only `list`, `next` and `status` are compared | Kept | The card names the three. `card new` writes a file and cannot run twice. |
| The nine files are a list in the case | Kept | At the tag no other case file calls the three commands, and the count of 104 guards the list. |
| Whole files are replayed: 114 cases, 40 of which compare nothing. The suite goes from 154 to 212 seconds on the session's machine; the case takes 20 seconds on Ubuntu and 52 on macOS in CI | Accepted | The 40 cost about 7 seconds. Choosing cases by their text would be a second parser of the case files. |
| The cases replayed are today's, not those of the tag | Kept | Eight of the nine files are the same bytes as at the tag, and 02-plugin gained two cases that call none of the three commands. A case that builds an outline fails the guard on `cards/plan`. |
| A skip is not seen in a run that passes, because `test/run.sh` prints nothing for a passing case | Left, for its own card | `test/run.sh` is not under `Touch`, and `test_plugin_validates_strictly` has the same fault. With `CI` set the case fails. It is in `later.md`. |
| 20 of the 24 mutations pass the ordinary suite too. They are states no 0.1 case builds: `status --fetch` with a pull request, a card branch whose id is not in the deck, `status_max_chars` at its edges, a log line of 200 characters, `log_dir` set | Left, for its own card | The acceptance is every 0.1 case. Both versions gave the same bytes on those decks when the reviewer ran them by hand. It is in `later.md`. |
| Nothing checks what the tag points at: with `v0.1.3` moved to HEAD the case compares `bin/card` with itself | Left | A person who moves a release tag has a larger problem, and CI fetches the tag from the remote. |
| On a fork's own Actions run, `origin` is the fork, and a fork without the tag fails at the fetch step | Left | The repository has no fork. A fork's pull request here fetches from this repository. |
| CONTRIBUTING.md says the suite takes about a minute | Left | It was 154 seconds before this card. The file is not under `Touch`. |

Looked for and not found: a byte of difference between 0.1.3 and `bin/card` other than with `BASE_REF` set, over decks with `cards_dir`, `log_dir` and `base` configured, a remote with an open pull request, cards with line endings of two bytes, two cards with one id, a detached HEAD, no base branch, an empty deck, a worktree, a subdirectory, and `cards/plan` as an empty directory or a file; a temporary directory left behind; a replayed case that is not a 0.1 case and compares something; a file either version writes besides the refs of `--fetch`.

CI on the pull request ran the fetch step on a checkout of depth 1 on macOS and on Ubuntu, and the case passed with `CI` set in both awk runs, so it did not skip. Not run: gawk, mawk and a bash later than 3.2 on the session's machine, and a real fork.

## Twelfth pass, 2026-10-10: the reviews of P-09

P-09 added `card plan start`, which creates the card file for a row. Two agents that did not write it reviewed it: the handoff reviewer, whose must-fix was that a fault in a row came out with the messages of `card new` and exit 2, and a second one told to break it and to attack the decision proposed for each open item. It ran hostile outlines in scratch repositories, compared `card new` with that of the base branch over 96 sets of arguments, and ran 64 mutations of the new code against the two case files, of which 21 passed unnoticed. The maintainer left the decisions to the session that held the card. The second review had no must-fix finding. What changed in the design is in sections 9 and 15.

| Found | Decided | Why |
|---|---|---|
| A title longer than 80 characters was cut by the outline reader and the card was created with the cut title; of two `size` items the first was taken; a row with no `does` gave a card with an empty `Acceptance` | `card plan start` refuses a row whose outline has a finding of the reader, and names `card plan` | The card must be the row. The other checks of `card plan`, the specification and the headings, are still not run: the card's `Out of scope` keeps them out. |
| A title that starts with a quote, `[` or `{`, or is a multi-line marker, passes `card plan`, and the refusal said "run card plan" | The message says to change the title in the outline | `card plan` reports nothing for it. Teaching `card plan` the title rules is in `later.md`: it is the check of P-02 and not this card. |
| The row went to awk through the environment. A `does` line of 2 MB failed with "Argument list too long", left a card with empty sections, and the next run said the card exists | The row goes in on stdin, and a card whose body cannot be written is removed | The limit for one string is 128 KiB on Linux by reading. `write_card` has just refused an existing file, so the file removed is the one it made. |
| An outline with a byte-order mark or no closing `---` has no rows, and the message was only "no row" | The message names `card plan` when an outline has a finding | `card plan` says what is wrong with it. |
| The refusal of a symbolic link is in `write_card`, so `card new` changed, which the card did not ask | Kept, with a case in 30-new and a row in section 15 | A dangling link named like the card let a pull request create a file anywhere the user can write, with lines from a `does` item. On 96 sets of arguments it is the one difference from the base branch. |
| The link check looks at the file only: `cards` as a link to a directory outside is written through | Left, and the comment says so | The base branch does the same for `card new`, and `cards_dir` is the user's own configuration. |
| Exit 2 from `card plan start` when the directory or the file cannot be written | Kept | `card plan accept` and `card done` do the same. |
| The state of the row and its dependencies are not checked | Kept | The card's `Out of scope`: next-card picks a ready row. |
| The case for 0.1.3 compares the front matter keys with a list and does not run `card` 0.1.3 | Kept | The reviewer ran 0.1.3 `lint`, `list` and `show` on planned cards by hand and all passed. P-18 is the case for it. |
| 21 mutations passed: the size of the row, the first of two rows, the specification of the row's own outline, the `spec` check, `plan_refs`, `%` in an item, the last newline, the help lines, and the trimming and the empty items of `--depends` | Eight cases added, two of them in 30-new | 30-new was added to `Touch`: `cmd_new` was split by this card. |
| Three more passed: the title limit at 79 and 81, and a title that starts with `'` | Left, in `later.md` | They are `card new` as it was before this card. |
| No case makes the second write fail, so the removal of the card has no test | Left | It needs a disk that fills between two writes. |
| `- depends: AUTH-02,` is accepted, and `card plan` rejects it | Left, in `later.md` | `card new --depends` takes it too, and the card has the right ids. |
| On a file system that ignores case, `cards/auth-01-x.md` is written over; a card file name with an escape character is printed as it is | Left | Both are `card new` on the base branch. |
| The session went 2069 tokens over the budget of 70000 | Accepted, and in the log | The review fixes came after the card's tests passed. |

Looked for and not found: a forged section, front matter key, second item or second card from a title, `spec`, `does` or `not` line that holds `## Touch`, `---`, `done: true`, `- x`, `%s`, an escape, a tab or a line ending of two bytes; a row id of another shape reaching a file name; a difference in `card new` other than the link; a wrong result from a subdirectory, with `cards_dir` set, with no commit, on a detached HEAD, or with the outline or the card on one base ref only; a disagreement between the new card and `card list`, `card show`, `card next` or `card status`; a planned card that fails `card lint` or 0.1.3 `lint` once `Touch` and `Tests` are filled.

Not run: gawk, mawk, GNU sed and Linux are not on the machine the session ran on, and CI runs them. Two runs of `card plan start` at once were not tried.

## Thirteenth pass, 2026-10-10: the reviews of P-10

P-10 added `card plan check`. Two agents that did not write it reviewed it. The handoff reviewer had no must-fix and no should-fix finding, and four nits, one of which was fixed at once: a `(new)` entry with a backslash passed as a full path and matched an existing file. The second was told to break it and to attack the decision proposed for each open item. It ran hostile cards in scratch repositories, compared `card touched` with that of the base branch over 1584 runs, 24 values of `touch_ignore` by 67 entries, with no difference, and ran 78 mutations of the new code against the two case files, of which 19 passed unnoticed. It had no must-fix finding. The maintainer left the decisions to the session that held the card. What changed in the design is in sections 7, 9, 11.3 and 15.

| Found | Decided | Why |
|---|---|---|
| The fix for the backslash refused every backslash, so a new file under `app/[id]/` could not be marked `(new)` in any spelling: the escape `app/\[id\]/new.tsx` is the one spelling the scope gate matches that file with | The escape is read: a full path has no pattern character outside an escape, and the path with the escapes removed is the one tested on disk | Route files of Next.js, SvelteKit and Remix have such names. `src/a\.ts (new)` now says "exists" and not "is not a full path", which is the truer message. |
| With `src/a.ts` tracked and removed from the disk, `src/a.ts` and `src/a.ts (new)` both passed, in one card too | A `(new)` entry that matches a listed file fails, "is a tracked file". An entry not marked `(new)` still passes | The acceptance line says a `(new)` entry matches no file. For the other entry the scope gate does see a change to that path, and a test on disk would fail honest entries in a sparse checkout, which was not run. |
| A `(new)` path under an ignored directory, or one that matches `*.log`, passed: the scope gate will never see the file the card creates | `git check-ignore` is asked about a `(new)` path that is not there. Ignored fails, and so does a path git cannot answer for, such as one inside a submodule | It is the card's own reason for not counting an ignored file. One process for each `(new)` entry. A nested repository that is not a submodule is not caught; left. |
| `../zz (new)`, `src//b.ts (new)` and `src/./b.ts (new)` passed, and none is a path the scope gate prints | An empty, `.` or `..` segment makes a `(new)` entry not a full path | "Full path" is the card's word. One leading `/` or `./` is still dropped, as in `card touched`. |
| A `Read` entry of `/etc/hosts` or `../../.ssh/config` passed where the file exists | An absolute path and a `..` segment are refused, "is not a path inside the repository" | Section 16: a card can arrive in someone else's pull request and a session reads what `Read` names. `spec` has the same rule. It costs `../sibling/API.md`, which no other clone has anyway. Refusing only the absolute path was proposed and attacked as half a rule. A symbolic link that points outside is followed; left. |
| A file name that git quotes matches no `Touch` entry, a directory of such files is "matches no file", and an entry that starts with a quote can match the quoted line | Left, in `later.md` and section 11.3 | `card touched` reads the same list and would report that file as stray, so the check predicts the gate. The fix is `-z` in both, and `diff_files` also feeds the plan branch check; that is not this card. Fixing only the check was the one wrong option. |
| An unreadable card file gave three lines from awk and a finding about `Out of scope` | Exit 2, `cannot be read` | Messages start with `card:`. The other callers of `section_items` are in `later.md`. |
| `templates/* (new)` and the like, in four of this repository's own cards, are "not a full path" | Kept | The card settles it, after finding 13 of the second review: a pattern marked `(new)` checks nothing. The session lists the files it will create. |
| A tab before the comment is part of the entry | Kept | "Up to the first space", and `card touched` reads the entry the same way. |
| The check takes 4 s for 50,000 files and ten entries that match nothing | Kept | It runs once for a card. |
| 14 mutations passed that a case could catch: the exit after `card_path`, a section with no item, a second `#`, an entry that is only an anchor, the exit 2 when git cannot list, the spaces before `(new)`, `(new)` later in a comment, an entry that is `(new)`, an empty `(new)` pattern, a dangling link, the leading `/` of a `(new)` path, and the order of the two rules in `touch_patterns` | A case for each. With those for the decisions above, eleven cases were added, one of them in 32-touched | 32-touched was added to `Touch`: `touch_patterns` came out of `cmd_touched` in this card. |
| Five more passed and have no case | Left | Four change nothing a caller can see. The fifth is the wording of the help line after `<id>`. |
| The pull request said "None" above three findings left open | Corrected | It contradicted itself. |

Looked for and not found: a command run from an entry of `Read`, `Touch` or `touch_ignore` holding `$(...)`, backticks, `;;`, `*)` or a leading `-`, `!`, `=` or `(`; a wrong result from line endings of two bytes, a name outside ASCII, an entry of 20,000 characters, a section twice, a heading with spaces after it, a card with no body or an empty file; from a subdirectory, with `cards_dir` set, with no commit, on a detached HEAD, in a bare repository, or with two cards of one id; from `--fetch`, `--help`, an extra argument or a malformed id; a difference in `card touched`.

Not run: Linux, bash 4 and 5, gawk, mawk and GNU sed are not on the machine the session ran on, and CI runs them. A sparse checkout, a linked worktree, a merge in progress and a file system that tells `A` from `a` were not tried.

## Fourteenth pass, 2026-10-10: the reviews of P-11

P-11 made the stop hook leave out commits that change only the cards directory. Two agents that did not write it reviewed it. The handoff reviewer had no must-fix and one should-fix, fixed at once: no case ran a card-only commit from a subdirectory. The second was told to break it and to attack the decision it proposed for each open item. It ran the hook of the branch and the hook of the base branch side by side in scratch repositories and ran 36 mutations of the new line against the case file, of which 17 passed unnoticed. It had no must-fix finding. The maintainer left the decisions to the session that held the card. What changed in the design is in section 13.

| Found | Decided | Why |
|---|---|---|
| The search for the session log, `-- "$log_dir"`, was not anchored. From a subdirectory a branch that had its log was blocked. The base branch does the same | Fixed here: `-- ":(top)$log_dir"`, and a case | The card anchors the count because the hook may start in a subdirectory, and the line six below it had the same fault. Same file, already in `Touch`. Attacked as scope growth: the card's acceptance names only the count. Kept, because the comment the card adds would otherwise be false for the file it sits in. The comparison with `card` 0.1.3 does not run the hooks. |
| With `GIT_LITERAL_PATHSPECS=1` in the environment, `:(top)` is a file name, the count is 0 and the guard is off without a word. The base branch blocks | `git --no-literal-pathspecs` on both commands, and a case | The one regression found against the base branch, in the direction nobody notices, for one flag. Leaving it was proposed and attacked on those grounds. A git too old for the flag fails, and that is the next row. |
| A git that rejects the pathspec leaves the guard off, where the base branch blocked | Left | `:(exclude)` is from git 1.9, of 2014; from memory, not checked against the release notes. Falling back to the old count was attacked: it would turn any failure of `rev-list` into a block, against "exit 0 on any internal error". No minimum git is stated anywhere; not added here. |
| Section 13 said one thing is given up. Ten sequences went from blocked to silent: a commit that only sets `done: true`, one under `plan/`, one to `REVIEW.md`, a card added, removed, renamed or with its mode changed, an empty commit, a code commit amended to empty, and a merge of the base into a branch with only card commits | The sentence in section 13 now says so. The code is as the card has it | All follow from "changes nothing outside the cards directory", which is the acceptance. Handoff commits `done: true` together with the log, so that one costs nothing in the normal run. Counting empty commits needs a second `rev-list`. |
| `git merge -s ours main` on a branch with only card commits is silent, while the branch undoes work of the base | Left | It takes a strategy no skill uses. The guard reminds a session to write its log; it is not what protects the base branch. |
| In a clone of depth 1 whose tip is a card-only commit, that commit is compared with the empty tree and counted | Left, in `later.md` | The base branch blocks there too. It is not the state next-card makes: its approval commit is new in the clone and has its parent. It is a session resumed in a fresh shallow clone of the card branch. Attacked: clones on the web and in CI are often shallow, and P-23 would meet it on every card if the trial resumed sessions that way. P-21 and P-23 are to say what kind of clone they ran in. |
| `cards_dir = Cards` over a directory `cards` on a file system that does not tell them apart: `card` works and the exclusion matches nothing | Left | A pathspec is compared exactly whatever `core.ignorecase` says. The approval commit then blocks, as on the base branch, and the configuration is wrong. |
| The header of the hook, two lines of the README, `docs/design.md` section 12 and step 6 of `reference/implement.md` describe the old condition | The header is corrected. A note on P-19 for the README and on P-14 for step 6. `docs/design.md` is left | The README describes the released version until P-19. Design section 10 already gives step 6 to P-14. `docs/design.md` is the design of 0.1. P-19 named neither README line before this. |
| Ten mutations passed that a case could catch: an exclude of `cards*`, of the first component of `cards_dir` and of `log_dir` as well, `--first-parent`, `--full-history`, `--no-merges`, and the exit, the value and the silence of the count when git fails | A case or an assertion for each: seven cases added with the two above, and one assertion in the `cards_dir` case | Proposed were the two cheap ones. The attack was that the merge cases guard what someone "fixing" history simplification would change, and it was right. Each was run against its mutation and fails. |
| Seven more passed and have no case | Left | Five change nothing a caller can see with the names `dir_ok` allows. Two are the `|| exit 0` after `card conf cards_dir`, which cannot fail once `card conf base` has passed. Removing `--` found no input that differs. |
| The pull request and the session log said the subdirectory case passes against the old hook. After the handoff review added a card-only stop to it, it fails | Both corrected | Three of the five cases named on the card fail against the base branch, not two. The log was written after that fix, so it was wrong when written and is corrected, not annotated. |

Looked for and not found: an exit other than 0 or 2, or output on a path that does not block; a code change hidden by a commit that touches card and code, a rename into or out of the cards directory, a code commit reachable only through a merge, a change made in the merge commit, a revert, a mode change; a wrong count on an orphan branch, in a linked worktree, with a submodule, from a subdirectory, from the cards directory, from `.git`, or with `GIT_DIR` and `GIT_WORK_TREE` set; `cards-old/`, `cardsx/`, `cards.md` or a file `src/cards` taken for the cards directory; `log_dir` inside `cards_dir` or the reverse; a value of `cards_dir` that becomes pathspec magic or an option, since configuration validation refuses every one tried.

Not run: a git older than 2.54, Linux, a file system that tells `A` from `a`, bash 4 and 5; CI runs Linux. A real Stop event, so the directory the hook starts in is still not known. A partial clone, a sparse checkout, a bare repository, a merge or rebase in progress.

## Fifteenth pass, 2026-10-10: the reviews of P-12

P-12 wrote the plan reviewer, `agents/plan-reviewer.md`. Two agents that did not write it reviewed it. The handoff reviewer had no must-fix and two should-fix, both fixed at once: the report had no place for what the agent read and found in order, and the session log had to give the result for each row of design section 19. The second was told to break it and to attack the decision it proposed for each open item. It ran 75 mutations of the file against the eight tests, of which 61 passed unnoticed, and ran the agent twice, headless, on the first outline of the spike in a copy of this repository: once with the file as committed and once with the closing lines it proposed. It had no must-fix finding. The maintainer left the decisions to the session that held the card. The design is not changed.

| Found | Decided | Why |
|---|---|---|
| The closing sentence, "End with these lines, one each", was not followed. The run of the file as committed ended with 24 lines in four blocks and then a line with an absolute path, the fault of the draft that the log called answered | Fixed here: three lines, each with a label (`searched:`, `no spec item:`, `outside the level:`), `none` where there is nothing, and "print nothing after them" | The run with this text gave three lines, nothing after them and no absolute path. Attacked: nobody parses the labels, and one run of each is not proof. Kept, because the labels are what tell "read and found nothing" from "not read". |
| The log said every fault of the draft is answered, with none left. The agent named 8 of the spike's 19 joined `does` lines in one run and 9 in the other | The log is corrected. The file is left | The sentence was true of the text and read as true of the agent. A sentence asking for every such line, one finding for a row, was tried in the second run and changed nothing, so it is not added. The lines about tests and the missing `not` lines of the rows that cite `10. Skills` were raised in both runs. |
| Design section 19, row 14, was not run with the new file, and the log said the scoped name is not in the documentation | Run: the Agent tool accepted `workdeck:plan-reviewer` in both runs, Claude Code 2.1.291. The log is corrected | The `plugin-evals` page now gives the namespaced name for the Agent tool. The design's row can cite it; this card does not edit the design. 2.1.291 is the spike's version, so this says nothing of a later one. |
| Growth was logged as 69,096 against the S budget of 70,000. After the second review the transcript measures more | Measured again after the last fix, in the log and the pull request | As for P-09: over the budget, accepted, and in the log. `card stats` reads the field, and the plan reviewer compares sizes with it. |
| Any extra field in the front matter passed the test and `claude plugin validate --strict`: `background: true`, `model`, and `hooks` or `permissionMode` in another spelling | A test: the fields are `name`, `description` and `tools`, and no other | It is the acceptance item as written. Attacked: it stops a later `model:` or `maxTurns:`. Intended; such a change should have to edit the test. |
| Mutations that passed and that a line could catch: the closing sentence removed; "never to change the repository" and the git verbs removed; a `does` line added to the `must-fix` definition; the "Neither" bullet moved away from the two it refers to; an example path with no line number; a description of 750 characters in one sentence | An assertion for each | Each fix made in a review has something that guards it. The cap on the description is 200 characters, against 142 now; the number is arbitrary, and so was one sentence. |
| 45 more mutations passed: negations, bullets removed from steps 3 and 4, both examples emptied, a sixth step as an unnumbered paragraph | Left | A test with grep checks that words are there, not what they mean. Catching these is a second copy of the file. What the agent does is seen in a run, and P-21 owns the runs. |
| Severity is not stable: two `must-fix` in one run and none in the other, on one outline. One was noise, from "two rows claim the same work" read wider than step 2 | Left, with a note on P-21 | Narrowing it to "the same requirement" was proposed and attacked: it is the only clause that makes two rows changing one piece of code a `must-fix`. The copy had every section built, which the spike's project had not, and the spike found the definition sound in ten of ten. |
| Kept from the draft beyond the words of section 12.1: "unless the code already does it" in step 2 and its like in step 5 and in the `must-fix` definition, the check of each `not` line, and the dependency that is not needed | Left. The log's list is made whole | Without the first, both runs would have reported most of a built specification as `must-fix`. The dependency check gave a real finding in both runs. |
| Added beyond section 12.1: a specification that contradicts itself where the outline took one reading without saying so | Left | Design section 10.1 has the skill show the user each such place, and the reviewer is the one other reader of the whole specification. Not exercised: `docs/design.md` produced none. |
| The draft's last step, what a session writing the card would have to guess, is gone | Left | It survives as the test for severity in step 3 and the reason in step 4, and both runs wrote their failure scenarios in those terms. |
| Row 7 names four supported fields and the page lists fourteen | Left, and no `## Blocked` | The design relies on the three fields the file uses working and on three being ignored. Both hold. |
| The base branch is given and used for nothing but to say the outline is not on it | Left | Sections 10.1 and 12.1 pass it. The sentence stops the agent reading the outline from the base branch. |
| Smaller things seen in the runs: a finding of six sentences where one is asked, the report inside a code fence copied from the example, and third-level sections listed as outside a level-2 outline | Left | `agents/reviewer.md` has the same wording and fence, and that file is P-15's. The third errs toward reading more. |

Looked for and not found: an acceptance item the file does not meet; a `card` command named that does not exist; a contradiction between the `must-fix` definition and "Neither is a `must-fix` finding by itself"; a write by the agent, whose every Bash command was a read; a permission prompt that stalled the headless run.

Not run: the Spec Kit sample, which is the case step 5 grew for; a second run of either wording, so whether the absolute path comes back is one of one; the maintainer's model, an interactive session, a background launch, a Claude Code newer than 2.1.291, and the agent beside the user's other plugins. The model was `claude-sonnet-5-5`, as in the spike. A reviewer run cost 42,062 and 49,907 tokens.

## Sixteenth pass, 2026-10-10: the reviews of P-13

P-13 wrote the plan skill, `skills/plan/SKILL.md`. Two agents that did not write it reviewed it. The handoff reviewer had no must-fix and four should-fix, all fixed at once: a resumed pull request reached `gh pr create`, a path `card plan new` refuses passed step 3, a run with nothing to revise had no stop, and one assertion matched the wrong step. The second was told to break it and to attack the decision proposed for each open item. It ran the commands the skill names in scratch repositories, 98 mutations of the file against the tests, of which 75 passed unnoticed, and read `gh pr edit --help`. It started no Claude session: a run of the skill is P-21's. It had no must-fix finding. The maintainer left the decisions to the session that held the card. What changed in the design is in sections 10.1 and 15.

| Found | Decided | Why |
|---|---|---|
| `gh pr edit --body-file` replaces the body. The fix of the first review said "add what this run did to its body" | Fixed here: the file holds the body as it is, then what this run did, and the title is set again | A resumed run would have erased the first run's findings and figures, which design section 14 reads from that body. Attacked: the session may already have the body from `gh pr view --comments`. Not established, so the skill names the command. |
| Step 3 stopped on a space only. From a subdirectory `git ls-files --error-unmatch` prints a path relative to it; for a directory it prints several lines; a name with a byte above 127 comes back quoted. `card plan new` refuses each, after the branch exists | Fixed here: `--full-name`, a stop on more than one line, and the characters `card plan new` allows | It is the reason the step gave for itself. A tracked symbolic link still passes and is refused later: left, it needs a second command for one case. |
| On the way from step 2 to step 6, what the user typed after the path was never applied, and a declined offer had no next step | Fixed here, and in design section 10.1, step 2 | Section 15 already says "offers to resume it, or stops". |
| `git branch -a --list "*card/<id>*"` listed `origin/card/AUTH-12-refresh` for the row `AUTH-1`. Proposed: leave it, since next-card has the same match | Turned down. The command is gone: `card list` shows such a row as `ready` or `waiting` with `[row]` | `card` maps a branch to an id exactly, local or remote, and the two skills did not agree anyway. next-card's match is a fault of its own, in `later.md`; that file is P-14's. |
| The early `card plan` of step 3 is not in the design. Attacked: it exits 1 on the faults of other outlines, with nothing said about them | Kept, with one sentence: anything else it reports waits for step 6. The design now has the run | An old `card` and a run with nothing to plan both end before a branch exists. The line it prints for a changed specification names its outline, so it is not taken for another's. |
| The stop for nothing to plan ignored a fault `card plan` reports for this outline | Fixed here: it also asks that `card plan` reported nothing for it | A dependency that is no longer a row is a reason to revise. |
| Design section 10.1 had the gaps the reviews found in the skill. Proposed: amend it | Amended once, with all of the above: steps 2, 3 and 9, and one row in section 15 | P-19 writes the reference from that section and P-21 runs by hand from it. Left as it was, both would follow `gh pr create` for a resumed pull request. |
| `git diff <spec_blob> HEAD:<spec path>` prints `bad object` when the blob is not in the clone: `card plan accept` hashes without writing, so a blob accepted over an uncommitted file is nowhere | One sentence: say so and read the specification as it is | Not seen in a shallow clone; inferred there. |
| Smaller: a resumed run with nothing changed fails at `git commit`; the body file stayed when `gh` is missing, and an untracked file on a `plan/` branch fails `card plan`; "nothing for this outline" skips the plan branch finding, which names another file | A sentence each | Each was run in a scratch repository. |
| The log gave "not read again" for row 14 of design section 19, and `unknown` for the measured fields | Row 14 was read: `plugins/components` gives the form `<plugin>:<name>`; that the Agent tool accepts it is still only from runs. The transcript was found and measured after the last fix | The acceptance item asks for a result for each row. As for P-12: growth is over the M budget, accepted, and in the log. |
| The rows of section 19 name pages that have moved | The table is left. The corrections are in `later.md` | The card's notes say it does not edit the design for these; the claims hold. |
| Mutations that passed and that a line could catch: the dirty-tree stop removed or negated; an untracked path that goes on; a no that keeps the outline; the stop with no remote; "may not be changed"; "Do not run `card plan accept`"; an edit that skips step 7; a quoted `context` key, a `model` key, a wider `allowed-tools` | An assertion for each, 28 in all. The four that checked one word check the sentence | 35 more of the mutations are caught with them. |
| 39 more passed: sentences removed from "No outline" and "Cutting rows", "Do not wait for the answer" after the question, "Then start implementing the first row", `card conf budget.L` | Left | As for P-12: grep checks that words are there. P-21 owns the runs. |
| `card plan new` refusals with no sentence in the skill (a prefix in use, a lowercase prefix, `Q`); a second outline for one specification under another prefix is accepted; a no in step 8 leaves an empty `plan/` branch each time; a revision has no instruction to use Explore | Left, with a note on P-21 | The messages say what is wrong. The design accepts the branch ("Plans in flight") and has the same silence on Explore. A run shows whether any of it matters. |
| A row title with `$(` in it passes `card plan` and `card list`, and `git commit -m` with it in double quotes runs it | Left, in `later.md` | The skill's subject line holds the prefix and a count, no title. Handoff has the same exposure, and `git commit` is prompted. |

Looked for and not found: an acceptance item other than the last that the file does not meet; a `card` command or `card conf` key named that does not exist; a command the permission template denies, `git push -u origin plan/<digits>` among them; a command substitution, an instruction to invoke a skill, or an old documentation path; wording of `card plan` the skill quotes that differs from the real message; a `spec_blob` that carries an option into `git diff`, which `card plan` refuses unless it is 40 or 64 hex digits; an assertion that matches the wrong line, with steps swapped in seven ways.

Not run: the skill itself, or any Claude session; `gh pr edit`, `gh pr create` or any call to the network; the permission template inside Claude Code, so "prompted" and "not denied" are read from its patterns; whether Claude Code honors a quoted front matter key; a shallow clone for the `bad object` case.

## Seventeenth pass, 2026-10-10: the reviews of P-14

P-14 gave next-card the steps that write a card from a row. Two agents that did not write it reviewed it. The handoff reviewer had no must-fix and two should-fix, both fixed at once: the six steps named each other by numbers the outer list also uses, and the reading of rows 10 and 11 of design section 19 was not yet in a log. The second was told to break it and to give a verdict on each decision the pull request had taken. It ran every command the new steps name in scratch repositories, and 44 mutations of the skill and the reference against the tests, of which 23 passed unnoticed. It started no Claude session: a run of the skill is P-21's. It had no must-fix finding. The maintainer left the decisions to the session that held the card. The design is not amended.

| Found | Decided | Why |
|---|---|---|
| A session that ends between `card plan start` and the yes leaves an untracked card. The next session sees a card with a file, skips the six steps, never runs `card plan check`, and makes no approval commit. The same when the session ends between `git checkout -b` and the commit: step 5 resumes "skipping step 7" | Fixed here, in steps 6 and 7: a card file git does not track is a card nobody approved. It gets the check, the question and the commit, on a resumed branch too | Run in a scratch repository. Step 3 stops on the untracked file first, but a user who says "go on" got code on an unapproved card. Steps 1 to 5 could not change, so step 5 still says "skipping step 7" and step 7 says which part is not skipped. |
| "Fix what they report" after `card lint`, which reads the whole deck: the session edited another card, and handoff's `git add -A` put that edit in this pull request | Fixed here: what they report about this card. Another file is shown to the user and the session stops | Run. The scope gate does not see it: `card touched` exits 0. |
| After an edit nothing said to show the card again, so a card changed by the edit and by the fixes after it was committed as approved | Fixed here: show it and ask again; only a yes goes on | Reasoned, not run. |
| test_next_card_lints_the_card_before_it_starts took the first `card lint` in the file, which is now inside the steps for a row. Removing the lint of a card with a file passed every test | Fixed here: the test names the sentence | A test this card weakened without saying so. |
| No instruction for an approval commit that fails: a hook, a signature, a refused permission | One sentence: show the error and stop before step 8 | The permission template allows neither `git add` nor `git commit`. Noted on P-16, which owns it. |
| "handoff shows what changed in it since" is not true until P-15 | The clause is gone | P-15 writes that step and can say so in handoff. |
| The new sentence in reference/implement.md reads as leave to commit a change to the card | Four words: a later change to the card included | The stop hook allows such a commit; the reference does not ask for one. |
| The order of the six steps was tested by number only; "with nothing else staged", "on the base branch", the stop on a failed `card plan start`, step 9's wording and the commit's message in the reference could each be removed | An assertion for each, the order by line. `git add --all` and `git commit -a` are refused beside `git add -A` | Twelve of the 23 mutations. |
| The test for "steps 1 to 5 are unchanged" counted five lines without two words | Replaced by the `cksum` of those steps | It caught nothing. A card that changes one of the steps changes the sum, and says so by doing it. |
| The `## Blocked` rule can move an answer into `Notes` after the yes and before the commit | Left | The card is the user's own answer plus what they approved. A card just written from a row has the section only if the user's edit added it. |
| `templates/claude-md-section.md` says "Do not commit", which the approval commit contradicts | Left, with a note on P-16 | The template is P-16's, and design section 10.3 does not amend the line. |
| Step 9's wording, the exception in the command test, and the two additions to section 10.2 (a failed `card plan start` stops; the checks run again after an edit) | Kept. Each verdict was "right" | The exception removes only the literal `: card as approved`; a `card bogus` on the same line is still caught. |
| 11 more mutations pass: "in any order", a no that keeps the file "unless the user may want it", "if the card is small, go on without waiting", a wider reading of `row:` | Left | As for P-12 and P-13: grep checks that words are there. P-21 owns the runs. |

Held when run: after a no the tree is clean, no branch exists and the row shows as `[row]` again; the approval commit carries one file; `hooks/stop.sh` exits 0 before and after it; `card plan check` exits 0 straight after the commit; steps 1 to 5 are byte for byte those of the base branch.

Not run: the skill itself, or any Claude session; anything with a remote; a `cards_dir` other than `cards`. The second reviewer did not read the measured figures against the transcript.

## Eighteenth pass, 2026-10-10: the reviews of P-15

P-15 gave the reviewer its step for a planned card and handoff the part of the pull request body that shows what changed in a card since it was approved. Two agents that did not write it reviewed it. The handoff reviewer had no must-fix and one should-fix, fixed at once: `git log --grep` reads every line of a message, so a later commit that quotes the approval line gives a second hash. The second was told to break it and to give a verdict on each decision the pull request had taken. It ran the commands of the new line in scratch repositories and 42 mutations of the two new lines against the two tests, of which 37 passed unnoticed. It started no Claude session: a run of the skill is P-21's. It had no must-fix finding. The maintainer left the decisions to the session that held the card, the six it listed as his included. The design is amended in sections 10.4 and 12.2, which the card's `Touch` gained with this record.

| Found | Decided | Why |
|---|---|---|
| A `git log` that fails reads as "no approval commit": with `grep.patternType=fixed` in the git configuration it prints nothing for a branch that has the commit, and with no local base branch it exits 128 with nothing on stdout | Fixed here: `--basic-regexp` on the command, and a failure is shown and stops handoff | Run. The part is the trial's central measure, and it was dropped without a word. |
| The reviewer's step did not say what a requirement is, though the plan reviewer does | Fixed here, in the plan reviewer's words | Two runs on one card would count different things. The third pass made the same objection to the outline's first form. |
| A name in the comment that matches no heading gives no finding, which reads as full coverage. A heading that holds `; ` is written by `card plan start` as it stands, and reads as two | Fixed here: such a name is a `should-fix` finding, and the comment is matched against the specification's headings before it is split | Run for what `card plan start` writes. `card plan` refusing `; ` in a `spec` item is in `later.md`. |
| The step contradicts "do not suggest work beyond the card", a line the test holds by its sum | One sentence in the step: these findings are about the card | Reasoned. An agent that obeyed the older line printed none of them. |
| A requirement under a heading that two rows cite, built by the card this one depends on, is a finding the pull request has to answer | Fixed here, and section 12.2 amended: one that the code on the base branch already meets is left out, and the reviewer says where | The plan reviewer has the same exception. Without it the trial's bodies fill with findings whose answer is "the other card did it". |
| The tests asserted pieces of the two lines: the anchors of the pattern, `--format=%H`, "gains", the reviewer's "When" and the order of its steps could each change | Each line is held sentence by sentence and then whole. The reviewer's steps are read in order, and handoff's line is the one after the commit | 37 of 42 mutations. A sentence added to either line now fails as well. |
| With no remote, and with no `gh`, handoff stops before the body is written and the part is never made | Fixed here, and section 10.4 amended: the line follows the commit, and where the step stops short of a pull request handoff prints the part | The first review left this open as a nit. Nothing in the line needed the push. |
| `<card file>` was not defined, and a pattern for it also matches the remainder card of a split | It is the path the approval commit added, from `git show --name-only` | Run. |
| An approval commit that a squash folded later work into still matches, and the part says "None" | One sentence: more than one path from `git show` means the commit is not the approval alone, and the part says so | It takes a rewrite of history that no skill makes. The check costs nothing once `git show` is run. |
| Every hunk header of a card's diff carries `done: false`, and the first hunk is left with no change in it | The two lines are named, and a hunk that then holds no change is left out | Run. A session that filtered on the word lost two of three headers. |
| A diff that adds a fence line ends a code block of three backticks | Four backticks | Run for the diff, reasoned for the rendering. |
| "The card had a file before this branch" is not true of a quick card | "The card was not written from a row on this branch" | |
| A review-fixes session runs handoff on a branch whose pull request is open, and step 7 has only `gh pr create`: a `Touch` line added then never reaches the body | Left for 0.2. A note on P-23, which reads the measure, and a line in `later.md` | As in 0.1. The plan skill's `gh pr edit` path is more than one addition to step 7. |
| A card file renamed after approval shows as a file removed | Left, in `later.md` | No skill renames a card. |
| The `cksum` of each file without its new line fails with two numbers when a later card changes another line | Kept | No card from P-16 to P-24 lists either file. A card that changes one changes the sum, and says so by doing it. |
| Verdicts on the first decisions: the finding's line is the requirement's, `(row <id>)` leaves nothing to check, "None" when only the `done` line changed, the last hash printed | Kept. Each verdict was "right" | The place of the line, after the push, was "arguable, leaning wrong", and it moved. |

The second reviewer then attacked these amendments in the working tree. All 42 of its mutations were caught, and 4 of 25 new ones passed. It had no must-fix finding.

| Found | Decided | Why |
|---|---|---|
| `<card file>` is "the path `git show` prints", and the same line allows for more than one path: with a squashed approval commit the diff took in a source file | Fixed: the path in the cards directory | Run. |
| "Matches no heading" has no rule of comparison, while `card plan` compares by letters and digits with case ignored: `- spec: REFRESH!` passes it and is written into the comment as it stands | Fixed in the step and in section 12.2: compared as section 5 compares | Run for the comment. A reviewer that compared as written reported a false finding. |
| Section 12.2 cited section 12.1 for the meaning of a requirement and for the exception; both are only in the plan reviewer's step 2 | The sentence names that step | |
| Each `cksum` leaves lines out by a pattern, so a second line that fits the pattern, anywhere in the file, was seen by no assertion | Each test counts the lines that fit: one | Two of the four mutations that passed. The other two delete an assertion from a test. |
| "A card this one depends on built it" reads as a condition | "Usually" | Code that met the requirement before any card is left out too. |
| The stop on a failed lookup comes after the commit and before the push, for every card. A second handoff has nothing to commit | The sentence says what remains: the push and the pull request | Run for git: no local base branch exits 128 while `card touched` exits 0. |
| The reviewer's "already met, and where" lines are not findings, so they do not reach the pull request body and a wrong one is seen only by the session | Left. A note on P-21, whose hand run reports each | The plan reviewer has the same exposure. Carrying them is a change to handoff's step 3. |
| A specification with the headings `Limits: burst; steady (v2)`, `Limits: burst` and `steady (v2)` | Left | The line in `later.md` covers it. |

Held when run: one hash with `grep.patternType` fixed and extended, and with no remote; `git show --name-only --format=` prints the card's path alone, also with `color.ui=always`; split mode with `cards_dir = deck/c` leaves the remainder card out of the diff; a diff that adds a fence of three backticks has no line of four; with only the `done` line changed, what is left is four header lines; the base branch merged into the card's branch, and the branch rebased, each give one hash; an id that is the start of another matches only its own commit.

Not run: the reviewer agent, the handoff skill, or any Claude session, so what an agent does with "matches" and "already meets" is reasoned; anything with `gh`; a signed approval commit. Neither reviewer read the measured figures against the transcript.

## Nineteenth pass, 2026-10-10: the reviews of P-16

P-16 gave the permission template its entries for `plan/*` branches and the protocol section its two lines. Two agents that did not write it reviewed it. The handoff reviewer's must-fix was that the session log must give the reading of row 12, which it does. Of its two should-fix findings one was fixed at once: the section did not say that the plan skill commits, pushes and opens a pull request with no handoff. The other was left open: a comment in the tests says a trailing ` *` matches the bare command, so the new deny rules might refuse the plain push. The second reviewer was told to break it, to settle that question from the `permissions` page, and to list what it would leave to the maintainer. It ran 57 mutations of the two templates against `test/cases/02-plugin.sh`, of which 25 passed unnoticed, and a matcher written from the page against every command of the plan skill. It started no Claude session. It had no must-fix finding. The maintainer left its eight decisions to the session that held the card.

| Found | Decided | Why |
|---|---|---|
| The open finding does not apply. The page: a trailing ` *` matches the bare command "only when the trailing `*` is the rule's only wildcard". `git push origin plan/* *` has two | Closed. The comment in the tests says so, and row 12 of design section 19 gains the sentence and the date | Read on the page the row cites, which five Context7 queries in the card's session did not return. The question cost one review. |
| A redirect after the branch name, `git push -u origin plan/x 2>&1`, matches the deny rule if a redirect is part of the matched text. The page says compound commands are split and wrappers stripped, and says nothing of redirects | A note on P-21, whose runs say what the push was as written. No change to the skills here | Not known, and the failure is a refusal, not a wrong push. The fix, if one is needed, is a clause in two skills that P-16 does not list, one held by a `cksum` and the other by assertions on its step 9. Dropping the two rules reopens finding 9. |
| The test for the section held six fragments: 21 of 30 mutations passed, among them "a card is implemented on it", a second line "A `plan/*` branch may change any file", either line moved, and the line "Do not commit" deleted | Each line is held whole and by its place, and the rest of the section by a `cksum` of the 0.1 text | As the eighteenth pass decided for P-15. |
| The section grew by 68 words, and it is in every session's context. "No card is implemented on it" repeats "changes only outlines" | The shorter wording, 10 words fewer. "On a card's branch" stays in the second line | The plan skill's commit is on another branch, and the first reviewer's finding was that the line read as forbidding it. |
| `git push origin main --delete` and `git push origin main -d` are prompted and not denied: `git push * --delete *` has two wildcards, so no bare match | Two deny rules, `git push * --delete` and `git push * -d`, and the two commands in the list of known bad pushes | `git push * -f` has its bare twin already. The cases that existed are unchanged. |
| An allow entry for `git push origin *`, `git commit *` or `git add *` passed every test | Three commands that the template must not allow, and after the second pass the whole list of push rules | The card's `Out of scope` decided there is no entry for `git add` or `git commit`, and nothing held it. |
| A trailing comma in the template passes every test | Left. A note on P-17, whose merge reads the file | The tests assume no JSON tool. |
| The section names `cards/` and `cards/plan/`, wrong where `cards_dir` is not `cards` | Left. A note on P-17: init writes the configured directory | The section's first line had the fault in 0.1. |
| A 0.1 repository keeps its old section | Nothing to decide: design section 10.3, step 4, replaces it, and P-17 builds that | The reviewer read the 0.1 init skill. |
| The section's first line says the user types next-card and quick, and does not name `/workdeck:plan` | Left | The skill has `disable-model-invocation: true`. Words in every session for nothing a session acts on. |
| The README's "they match commands as written" | A note on P-19, after P-21 | |
| Verdicts on the first decisions: no entry for `git add` or `git commit`, the approval commit named in the new line, the plan skill's own commit named | Kept. Each verdict was "right" | "Do not commit, push or open a pull request" unchanged was "arguable, leaning right", and the `cksum` now holds the line. |

Held when run: under a matcher with the bare-command rule of the page, every command in the permission tests keeps its outcome; git refuses `plan/../main` and `card/../main` as invalid refspecs; a tag named `plan/t` is pushed as a tag by the allowed command, as one named `card/t` would be (reasoned, not run); no settings file on the maintainer's machine carries the `card/* *` rule, so the 28 pushes of handoff say nothing about it.

Not run: any Claude session, so every outcome of allow, prompt and deny is from the page and a shell model. The redirect is the one that matters.

The second reviewer then attacked these amendments in the working tree. Of its 57 mutations 56 were now caught, the one left being the trailing comma. Of 33 new ones 15 passed. It had no must-fix finding, and nothing left for the maintainer but to confirm that the design row was his to delegate, which his instruction to take each decision here covers.

| Found | Decided | Why |
|---|---|---|
| The three refused commands are samples: an allow entry for `git push -u origin *`, `git push`, `git push origin HEAD`, `git commit`, `git add -A`, `git commit:*`, `git add:*` or a bare `Bash` passed | Fixed: the allow rules for a push are held as a list of four, no rule starts with `git add` or `git commit`, and a bare `Bash` entry fails | Eight of the 15. `rules` reads only `Bash(...)` entries, and `matches` reads `:*` as written. |
| `git push * -d` changed to `git push *-d` or `git push *d` refuses the push of a branch whose name ends in `d`, and no branch in the tests does | One more branch in the cases for the handoff push: `card/X-2-add-d` | Two of the 15. |
| `*--delete`, `* -d*` and `* -*` in place of the two new rules pass | Left | Each denies more and loses no push that a skill writes. |
| An allow entry for `git checkout *` or `gh pr merge *` passes | Left | The first is outside the card, and deny wins over the second. |
| In this record: "20 words fewer" was 10 by `wc -w`; the first test held six fragments, not five; only handoff's line is held by a `cksum`; the `card/t` tag was reasoned | Corrected above | |
| Row 12 cited two headings of the page, and the order of deny and allow is under a third, "Manage permissions". The table's first line says the rows were read through Context7 | The row names the three headings and says it was read on the page itself | |
| The notes on P-17, P-19 and P-21 put the name of the pass inside the backticks | Moved, as the earlier notes have it | |

Held when run: with the bare-command rule of the page written into `matches`, all 37 cases of `test/cases/02-plugin.sh` pass, so the comment's "none of these cases depends on it" is true; the two pushes the skills write, `git push -u origin <branch>` in the plan skill and in handoff, are allowed and not denied, for a branch whose name ends in `-d` or `d` too; the two new deny rules have no trailing ` *`, so each matches only a command that ends in the flag; the `cksum` in the section test is that of the section on the base branch.

Not run: any Claude session, `make lint` by the reviewer, the measured figures against the transcript.

## Twentieth pass, 2026-10-10: the reviews of P-17

P-17 made init continue on a repository that has a `workdeck.conf`, with the four steps of design section 10.3, and gave a new repository the `touch_ignore` and review rules steps. Two agents that did not write it reviewed it. The handoff reviewer had no must-fix. Its two should-fix findings were fixed before the pull request was opened: the protocol section ended only at the next `## ` heading, so text under a later `# ` heading went with it, and "go on to the next step" in step 5 led a repository that is already set up to step 6. The second reviewer was told to break it, to read the skill as the model that follows it in three repositories (new, set up by 0.1 with its own directories, and up to date), and to list what it would leave to the maintainer. It ran 50 mutations of the skill against `test/cases/60-skills.sh` in a copy, of which 41 passed unnoticed. It started no Claude session. It had no must-fix finding. The maintainer left its nine decisions to the session that held the card.

| Found | Decided | Why |
|---|---|---|
| 41 of 50 mutations passed, among them "Add every entry without asking", "or replace the settings file with the template" and "Do not commit anything unless the user is away". The tests held about thirty fragments | Steps 4, 5, 8, 9 and 10 and the section for a repository that is already set up are held whole by a `cksum`, and the description's last sentence by an assertion | As the eighteenth and nineteenth passes decided. The pull request's reason for leaving this out, that the tests held the sentences added to steps 4 and 5, was false. |
| No step says what to do when `card conf` fails. A `workdeck.conf` with no `check`, or with a key `card` does not know, makes it exit 2 | One sentence: show the message and stop | Each of the four steps runs it, and the model would otherwise guess a check command or repair the file unasked. |
| Init typed on a card branch writes `workdeck.conf`, `CLAUDE.md` and the settings file there, the card's scope gate fails on them, and step 10 says to commit on the base branch | The section asks before its first step when the current branch is not the base branch | 0.1 never met this: it stopped. |
| Step 8 had the model read every `.gitattributes` and apply their patterns and precedence itself. A root `*.js -linguist-generated` with `sub/.gitattributes` `gen.js linguist-generated` marks `sub/gen.js`, and a model that reads the root file gets it wrong | `git ls-files \| git check-attr --stdin linguist-generated`: a line that ends in `set` or `true` names a file | git does it. Within the design's words, "files a `.gitattributes` marks". |
| Where the settings file does not parse, step 5 writes nothing and step 7 then adds to the same file | Step 5 names step 7 | |
| Step 9 had no case for a `REVIEW.md` with no heading, and step 3 of the four none for a no to the template copy | One sentence each | The first review's nit, left open then. Two stuck cases for two sentences. |
| Step 9 reads `CLAUDE.md`, which holds the protocol section, and would propose its lines as rules | "The WorkDeck section of `CLAUDE.md` is not a source" | In a new repository step 4 wrote it minutes earlier. |
| An entry is a pattern: `apps/[slug]/package-lock.json` does not match itself, and a path with a comma cannot be written. Step 8 checked the line with `card conf touch_ignore` and did not say what to do when the check fails | `?` in place of `[`, `]` or a comma, and the step shows the line and corrects it | |
| With `log_dir = cards/log` and `cards_dir` not `cards`, replacing `log/` and then `cards/` changes the path twice | "Each replacement is made in the template's text" | Reasoned, not run. |
| A no is not remembered: a declined lockfile or rule is offered at each run, so a repository that is up to date does not always get four lines | Left. A note on P-21 | Remembering needs a key or a file, and the cost is one question. |
| `CLAUDE.md` with changes that are not committed: after a yes the replaced text is in no commit | Step 4 of the four runs `git status --porcelain CLAUDE.md` and says so before it asks | The one overwrite in the skill. |
| The section's end is also a line that starts with `# ` inside a code block the project added, and a heading underlined with `---` does not end it | Left. A note on P-21 | The difference shown holds every line a yes removes, and the template has no code block. |
| Whether an approved rule is written with the file it came from | As built: the source is in the proposal only | The reviewer reads every rule at each handoff, this repository's `cards/REVIEW.md` has no sources, and the design's "each with the file it was taken from" is about the proposal. |
| The check command changed since 0.1: the entry for the old one stays and one for the new is added | Left. A note on P-21 | Init cannot tell which entry was the check, and removing one breaks "nothing existing is overwritten". |
| A first run interrupted after `workdeck.conf` was written is never offered the pull request template, the CI workflow or the settings for teammates | Left, as design section 10.3 has it. A note on P-19 | |
| The README describes init as a first run only | A note on P-19, which owns the README | |
| `templates/workdeck.conf` shows a `touch_ignore` line under "Defaults" that is not the default, and the check command is put into JSON with no escaping | `docs/development/later.md`, both | The templates are P-16's, and the second is as in 0.1. |
| Verdicts on what the pull request listed: `log_dir` replaced with `cards_dir`, sentences added to steps 4 and 5, an offer of a section or a `REVIEW.md` that is not there, `old-yarn.lock` offered as a lockfile | Kept. Each verdict was "right" | |

Held when run: with the skill of the base branch in the copy, the seven tests of the card fail and the two older tests for init pass; the `cksum` of steps 2, 3, 6 and 7 is that of the base branch; `card conf touch_ignore` prints an empty line where the file has only the commented line, and the last value where it has two lines, so "`card` reads only one" is true; `card conf cards_dir`, `log_dir` and `check` work in a repository with no commit, straight after `workdeck.conf` is written; the pathspecs of step 8 match lockfiles and `.snap` files at the root and below, and `old-yarn.lock`; `git check-attr` prints `set` or `true` for a marked file, `false` for `=false` and `unspecified` otherwise.

Not run: any Claude session, so the three repositories are a reading of the text; the whole suite and `make lint` by the reviewer.

The second reviewer then attacked these amendments in the working tree. It reran 42 of its 50 mutations, the other eight having no text left to change, and 27 new ones aimed at the new sentences: 11 passed, all in the lines above step 2. Of eight mutations of the tests, five that delete one assertion passed, as in the eighteenth pass, and one was equivalent. It had no must-fix finding, overturned no decision, and left nothing for the maintainer.

| Found | Decided | Why |
|---|---|---|
| The `git check-attr` command, which the reviewer itself had proposed, prints one line for every tracked file, marked or not: 211 lines here with none marked | The command ends in `grep -E ': (set\|true)$'`, and each line it prints names a file | The whole file list would be in the session's context at every run of init. |
| No sum held the description, the opening paragraph or step 1. "Do not commit anything unless the user is away", which the first row above names, still passed, with nine more | The second `cksum` starts at the first line of the file, so each byte is under one of the two sums. The assertion on the description goes | The first row is true only with this. |
| The question about the branch had no outcome for a no | "After a no, stop." | The model could go on to step 10. |
| `git status --porcelain CLAUDE.md` prints nothing for a file that is ignored, the one case where it is in no commit at all | `--ignored` | Some projects ignore `CLAUDE.md`. |
| A marked file with a letter outside ASCII is printed in quotes with escapes, and the lockfile command lists every `.snap` file | Left. The note on P-21 gains both | |
| "If a `card conf` command fails" gives the wrong reason where `card` is not on the PATH | Left | The message shown says which. |

Held when run: with `touch_ignore = apps/?slug?/package-lock.json, x?y.snap`, `card touched` exits 0, and with the names as written it lists both files and exits 1; the question about the branch is in the section only, is asked once, and is asked on a detached HEAD; `card conf base` is the first `card conf` of the four steps, so a `workdeck.conf` that cannot be read stops init before anything is offered; `git status --porcelain CLAUDE.md` prints nothing for a file that is absent, clean or ignored; the filter prints only the marked files; `card lint`, `card touched P-17` and `card tests P-17` exit 0 on a copy.

Not run: any Claude session; the whole suite and `make lint` by the reviewer; `git check-attr` on a large repository; the replacement of both directories.
