# Scope of WorkDeck 0.2

Date: 2026-10-06, amended 2026-10-09
Status: approved by the maintainer on 2026-10-06 after one adversarial review, and again on 2026-10-09 as amended by a second one, which read the scope and the design against the code. The maintainer decided the four questions that review raised (lifecycle, trial specification, init extras, release gate) and had the remaining points attacked once more and locked. The reviews are in [`review-0.2.md`](review-0.2.md).

## What 0.2 is

WorkDeck 0.1 runs cards that a person wrote. 0.2 plans them. A planner reads a specification and the code it concerns and writes an outline: one row per card for the whole specification. A script checks the outline, a separate agent reviews it, and it reaches the base branch through one pull request that a person merges. After that a row is a card without a body. `/workdeck:next-card` writes the body when the row's turn comes, against the code as it then is, shows it to the user, and implements it in the same session. Init also learns to prepare a repository that is already set up.

## Who it is for

One person with an existing codebase and a written specification. The first two users are the maintainer on this repository and on one other. A new project with no code is supported but is not what the design is tuned for. Teams stay in 0.3.

## In 0.2

- **A plan skill**, `/workdeck:plan <spec path>`, typed by the user like the other four. The specification is one markdown file committed in the repository. The skill writes an outline and nothing else: no card and no code.
- **A row carries the cut, not only a title.** Each row has an id, a title, a provisional size, its dependencies, the specification headings it comes from, one or more lines saying what it does and, where another row owns something a reader might expect, a line saying what it does not do. The session that writes the card is not the session that planned it, and these lines are all it inherits.
- **Landing by pull request.** A plan run works on a `plan/*` branch and opens a pull request that changes only the outline. Merging it is the approval. A later run that revises the outline lands the same way. Hand-written cards may still be committed on the base branch, as now.
- **Rows are cards without a body.** `card list`, `card next` and `card status` show a row with the states a card has. A row is ready when every card it depends on is done, and so is every split remainder of those cards.
- **Bodies are written just in time.** When next-card starts a row, it creates the card file from the row, fills in `Read`, `Touch` and `Tests` from the code that exists, checks the paths with a script, and asks the user for a yes before any code. The approved card is the first commit on the card's branch, so every later change to it shows in the pull request's commits.
- **A `card plan` command.** `card plan` checks every outline: format, ids, sizes, dependencies and cycles, that each heading of the specification at the outline's level is cited by a row or listed as not planned, and that a `plan/*` branch changes nothing outside the outlines. `card plan check <id>` checks one card against the tree before work starts: every `Read` path exists, every `Touch` entry matches a file or is marked `(new)`, a `(new)` path does not exist yet, and `Out of scope` has an item. `card lint` is unchanged.
- **A plan reviewer agent** that did not write the outline. It reviews the outline before the user is asked to approve it: whether each requirement under a cited heading belongs to some row, whether the cut and the sizes are plausible, and whether two rows that change the same code should be ordered.
- **Init on a repository that is already set up.** Today init stops when `workdeck.conf` exists. In 0.2 it goes on to offer what is missing, asking before each: the permission entries for `plan/*` branches, suggested `touch_ignore` entries, rules proposed as additions to `cards/REVIEW.md`, and the changed protocol section in `CLAUDE.md`. It still overwrites nothing.
- **New files stay out of the way of 0.1.** Outlines live in one subdirectory of the cards directory. Nothing new is written at the top level of the cards directory or in the log directory, and cards gain no front matter key.

## Out of 0.2

- Specifications from an issue, a URL or a typed paragraph. The quick lane covers the paragraph.
- A specification in several files. Spec Kit and OpenSpec write several; the planner takes one, and a card may cite the others under `Read`.
- A codebase map written by init. Cut on 2026-10-09: the session that writes a card now reads the code itself.
- Claiming, worktrees and parallel sessions (0.3), and with them a script check that orders cards touching the same file, and more than one person planning at a time.
- A planner that implements, or that replans by itself. The user runs the plan skill again to revise an outline.
- A changed tests gate and new default budgets. 0.2 measures first.
- Everything else in `later.md`.

## Compatibility

"`card` 0.1.3" below is the last release of 0.1: the code of 0.1.2 under the project's present name. The tag `v0.1.2` holds it under the former name and reads another configuration file.

The config, card and log formats stay at `version = 1`, and 0.2 adds no configuration key, because `card` 0.1 exits 2 on a key it does not know and CI workflows pin `card` to a tag. A deck that passes `card lint` 0.1.3 still passes, with or without an outline beside it. `card` 0.1.3 does not see rows; a card exists for it once its file does.

A 0.1 user updates the plugin and nothing changes until they plan. To plan, they run init again for the permission entries and the changed `CLAUDE.md` section. To run `card plan` in CI they move the workflow's tag and add the step that runs it.

## How we will know it works

Before any check is built, the plan prompt is run by hand on two specifications. What it gets wrong decides what the checks have to catch, and settles the open claims about Claude Code that the design depends on.

Then the planner is run on two specifications, the 0.3 design in this repository and one in the maintainer's other repository, until ten planned cards have been implemented, at least two of them S and two M. The trial runs from the main branch with `--plugin-dir`; the trial repositories' CI stays on `card` 0.1.3, which tests the compatibility claim as a side effect.

For each card the evidence page records: whether the row had to be cut again before its card could be written; what changed in the card after the approval commit (files added to `Touch`, `Tests` lines reworded); whether the size changed when the body was written; a split; growth against budget. The baseline is beside them: by the same measure, 9 of the 24 hand-written cards of 0.1 had a file added to `Touch` after the card was first committed.

Ten cards cannot carry a numeric threshold. With ten, a planner that misses a file on half its cards passes a "more than half" test six times in ten. The maintainer reads the record and decides whether to tag. One result stops the release whatever the rest says: a row whose card could not be written without changing the outline first. The release then waits for a change to the plan skill or the outline format, or for the maintainer's written reason why not.

## Open risks

1. **The session that writes a card also implements it.** The card is no longer written by someone else. What remains: the row was reviewed and approved before, the user approves the card before any code, and later changes to the card show as commits. The quick lane already works this way.
2. **Writing the body uses the card's budget.** Sizes are still guesses: the repository's logs hold one measured session, and two more were measured elsewhere, all XS. The trial gives the first S and M figures, and they now include the writing.
3. **A row is a few lines.** If the cut cannot be carried in that little, the writing session will cut it again in its own way. The release gate above is aimed at this.
4. **`Tests` lines are still written before the tests,** though now by the session that writes them next. Finding 1 gave seven false failures in sixteen.
5. **The plan run has no budget.** It writes one file, so its growth is reading. A specification too large to plan in one session has to be split by the user.
6. **The planner cannot be tested by a script.** It is a prompt. `card plan` checks its output, and the spike and the trial are the rest of the evidence.
7. **Specifications change while they are built.** 0.1's design was amended 35 times during its build. The outline records the version it was made from and `card plan` says when the file differs; it does not fail, because a card's own pull request may be what changed it.
8. **The trial builds part of 0.3 before 0.2 is tagged.** See the first decision below.
9. **The 0.3 design is written by an agent that knows it will be planned.** It may suit the planner better than a specification written for people. The second repository's specification is the check on that, and the two sets of figures are kept apart.

## Decided on 2026-10-09

- **Where 0.2.0 is tagged from.** The main branch. A trial card that adds a reachable command or skill of 0.3 is not merged before the tag unless its feature is complete. If the main branch holds a reachable half of a feature at that moment, the tag goes on a branch cut at the last 0.2 commit with the planner's fixes picked onto it. The plugin itself reaches users from the main branch when its version changes there, so the version is the last commit before the tag and is not changed while the main branch holds such a half.
- **The 0.3 design** is written by Claude Code, as its own card outside the 0.2 deck. It can be written while 0.2 is built, and the trial waits for it.

## Deferred

- Which other repository the second trial runs in, its language, and whether its tests nest (finding 1). Decided after the build; nothing before the trial waits for it.
