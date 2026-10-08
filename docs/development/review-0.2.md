# Reviews of the 0.2 scope and design

Two adversarial reviews, each by an agent that did not write what it reviewed, and a third pass in which the second reviewer attacked its own amendments before they were locked. "The scope" is [`scope-0.2.md`](scope-0.2.md) and "the design" is [`../design-0.2.md`](../design-0.2.md).

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

- The deck. PLAN-01 has not produced it.
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
