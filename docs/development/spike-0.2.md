# Spike for 0.2: two specifications planned by hand

The first item of the build order in [`../design-0.2.md`](../design-0.2.md), section 21. A draft of the plan skill and of the plan reviewer were run before any `card plan` code existed, to see an outline before a script is written to check one. Card P-01.

Date: 2026-10-09

The drafts and the two outlines are in [`spike-0.2/`](spike-0.2/):

| File | What it is |
|---|---|
| [`spike-0.2/plan-skill.md`](spike-0.2/plan-skill.md) | The draft of `skills/plan/SKILL.md`. Where the design has a `card plan` command, the draft has the session do the same by hand. |
| [`spike-0.2/plan-reviewer.md`](spike-0.2/plan-reviewer.md) | The draft of `agents/plan-reviewer.md`. |
| [`spike-0.2/outline-design.md`](spike-0.2/outline-design.md) | The outline the draft wrote for `docs/design.md`, as written. |
| [`spike-0.2/outline-sample.md`](spike-0.2/outline-sample.md) | The outline the draft wrote for the Spec Kit sample, as written. |

## What was run

Claude Code 2.1.291, `card` 0.1.3, on macOS.

**The scratch plugin.** `git archive main` at `18bdb0b`, with the two drafts copied in as `skills/plan/SKILL.md` and `agents/plan-reviewer.md`. A second copy without the drafts was the comparison for rows 16 and 17. Both pass `claude plugin validate --strict` for `skills/` and `agents/`. Sessions loaded the plugin with `claude --plugin-dir <scratch plugin>`.

**The scratch project.** A clone of this repository at `18bdb0b` with the remote removed, so that nothing could be pushed. A plan of `docs/design.md` against the repository as it is would have found every section built, and the deck that built it in `cards/`. So the scratch project keeps `bin/card`, its tests, `workdeck.conf`, the `Makefile` and `docs/design.md`, and has everything else of 0.1 removed: `hooks/`, `skills/`, `agents/`, `templates/`, `reference/`, the manifests, the examples, the cards, the logs, the README, the changelog and every other document. That is close to where this repository stood when its own deck was written, and the hand-written cards that followed (TOK, HOOK, PLUG, SKILL and DOC) are what the outline can be compared with. One thing still tells the planner more than a real user's specification would: `docs/design.md` says `Status: implemented`, and its sections 19.1 and 19.2 list what the build changed.

**The Spec Kit sample.** `specs/010-pager/spec.md` of the public repository `pamburus/hl`, at commit `fbfb7f66915368dddafb6b05543e9a24a4bf4182`: 425 lines, 71 numbered functional requirements. It was copied to the same path in the scratch project and is not committed here. The scratch project holds none of the code that specification concerns, so its outline is judged on format, coverage and heading level, and not on whether its rows name the right code.

**The three sessions.** Each was a new session in the scratch project:

1. `/workdeck:plan docs/design.md`
2. `/workdeck:plan specs/010-pager/spec.md`
3. On the base branch, where no outline exists, the prompt below with one row of the first outline pasted in: the first row that has no `depends` item.

```
Below is one row of a WorkDeck outline. Its specification is docs/design.md.
Write the card file for it in cards/, as `card new` names it, and do not implement it.

- Front matter: id, title, size and depends from the row, and done: false.
- Read: first the specification's path with the comment (row <id>: <heading>; <heading>),
  then the files a session must read before it starts.
- Touch: full paths taken from the code as you read it, with (new) on a file the card creates.
- Tests: one item per test, written as the innermost name the test will have, in the
  style of the tests it will sit beside.
- Acceptance: the row's does lines. Out of scope: the row's not lines. Add to either
  only what the specification's headings call for.

Read only the headings the row cites and the code. Do not read cards/plan/ or any
plan/* branch. Run `card lint` and fix what it reports.

Then answer: was the row enough to write this card? List everything you had to guess.

<the row>
```

**Who ran them.** The maintainer asked the agent that holds this card to run the three sessions for them. Each was a headless session (`claude -p`, continued with `--resume` for each answer) with the scratch plugin as the only plugin loaded and no user settings, so the model was the default of that setup, `claude-sonnet-5-5`, and not the one the maintainer works with. The answers to the skill's questions were the agent's: yes to the proposed prefix and level, and yes to the outline as shown. No outline was edited by hand at any point. Run 2 was made in a second copy of the scratch project so that the two plan runs could not see each other's branch.

## Outline of docs/design.md

[`spike-0.2/outline-design.md`](spike-0.2/outline-design.md): prefix `WD`, level 2, 11 rows, 59 `does` lines and 11 `not` lines, with 11 headings under `Not planned`. The session read the specification, sent one search to Explore, proposed the prefix and the level and waited, wrote the outline, launched the reviewer, fixed what it found, and showed the table. After the yes it committed the one file and printed the pull request body.

The outline as committed passes every check of design section 11.1. That was read with a throwaway script, not committed: the front matter, the keys and their counts, the ids, the sizes, the dependencies, and all 20 second-level headings either cited or under `Not planned`. No script check would have failed on the first draft either. Everything wrong with it was found by the reviewer or by reading. The reviewer's steps are numbered here as design section 12.1 numbers them; the draft has no reading step, so its numbers are one lower.

| Fault | Caught by |
|---|---|
| The first draft put sections 14, 15 and 18 under `Not planned`. Each asks for work: the README's limits, handoff with no remote, the README's statement about 0.2. No row wrote the README at all. | None. Coverage passes, because a heading under `Not planned` is covered. The plan reviewer's step 5 found both, as must-fix. |
| A row registered hook scripts that two later rows create, and the repair of the Makefile sat in the last row, so three rows would have failed CI in their own pull requests. | None. The plan reviewer's step 4. |
| Four rows cite `10. Skills` and three cite `13. Hooks`. Coverage at level 2 cannot say whether each of the four skills has a row. | None. A limit of one level (section 11.3). The `not` lines carry it only in part: WD-02 names the other three, WD-03 names two, WD-04 names no skill row and WD-05 has no `not` line at all. The reviewer did not raise the missing ones. |
| 19 of the 59 `does` lines join two or more statements with "and", so a line can be half true. | None. The plan reviewer's step 3, which did not raise it. |
| Two rows end with a line like "Shell tests cover each of the above", which is not a statement about the product. | None. |
| The rows are long: 7 to 15 items each, 145 lines for 11 rows. Section 5 shows rows of four to seven lines, and the scope calls a row "a few lines". | None, and it may not be a fault: the second session wrote its card with little guessing because of them. |
| WD-01 repairs the Makefile for a tree that has no `hooks/` or `scripts/`. | Not a fault of the planner. It comes from the scratch project, where 0.1 was cut out around a Makefile that still names it. |

Faults of the draft skill, not of the outline:

- The pull request body left out the `does` lines and pointed at the file. Step 9 asks for the rows as the table of step 8.
- The commit carried a `Co-Authored-By` trailer, which the session adds by default. The skill says nothing about it.
- The reviewer's report gave one path as an absolute path into the scratch directory.

## Outline of the Spec Kit sample

[`spike-0.2/outline-sample.md`](spike-0.2/outline-sample.md): prefix `PGR`, level 4, 13 rows, 55 `does` lines and 21 `not` lines, and no `Not planned` section. Before it proposed anything, the session said that the repository holds none of the code the specification concerns and asked whether this was the right repository. It was told the file is a sample and went on.

The outline as committed passes every check of section 11.1 by the same reading, with one question about the format: it has no `## Not planned` section, because nothing would be in it. Section 5 did not say whether the section may be left out.

| Fault | Caught by |
|---|---|
| In the first draft the same requirement was claimed by two rows in two places and by three rows in a third (a raw command gets no added arguments; `never` means no pager; a failed write means the pager closed). | None. The plan reviewer's step 2, as must-fix. |
| No row built the default profiles that the default candidates name, and no row said how a legacy setting ranks. | None. The plan reviewer's step 2. |
| A row needed the profile builder of another row and did not depend on it. | None. The plan reviewer's step 4. |
| The specification contradicts itself in three places (the exit code after a broken pipe, an empty `HL_PAGER`, a bare profile name in a follow variable). The first draft picked one reading of each and said nothing. | None. The plan reviewer found them. The session then listed its choices for the user beside the outline, which the skill does not ask for and should. |
| Two requirements were dropped after the review as "not testable in one card": that the pager works on four platforms, and that all background work stops. They are in no row and in no list. | None. The session reported them as findings not fixed, so the user saw them. |
| The session fixed eight must-fix findings by rewriting most of the outline and did not launch the reviewer again. The outline that was approved was never reviewed. | None. The draft sends the session back to step 6 after a fix, not to step 7. |
| Coverage at level 4 sees eleven headings, all under `Functional Requirements`. The nine user stories, the edge cases, the entities and the success criteria sit at other levels and are invisible to it. | None. A limit of one level. See "Heading levels". |
| The table shown to the user wrote dependencies as `01` and `02, 04`. The file has the full ids. | Nothing to catch: the file is right. |

The rows name no code that exists, so nothing here says whether a planner picks the right files. The trial has to show that.

## What the reviewer was worth

Across the two runs the draft reviewer raised ten must-fix findings, fourteen should-fix findings and five nits. Every must-fix was real on reading: a requirement with no row, a requirement in two rows, or a row that needs code it does not depend on. None could have been found by a check of section 11.1. The script checks would have passed both first drafts.

What the draft reviewer missed, by reading the outlines afterwards: the compound `does` lines, and the lines that describe tests instead of behavior.

## A card from one row

A new session on the base branch of the scratch project, where no outline exists, was given the prompt above with row `WD-01` pasted in. It wrote `cards/WD-01-plugin-manifests-and-makefile.md`, and `card lint` passed. Its growth was 13,239 tokens against the S budget of 70,000, before any implementation.

The row was enough. The front matter, `Acceptance` and `Out of scope` came from the row unchanged. The session chose five files for `Read`, four for `Touch` (three of them marked `(new)`) and five test names in the style of `test/cases/`, one per `does` line. Read against the rules of design section 7, the card would pass `card plan check`: every `Read` path exists, the one `Touch` entry that is not new matches a file, no `(new)` path exists, and `Out of scope` has an item.

What it said it had to guess:

- Where the tests go and what they are called. It took the pattern from the tests beside them.
- How to test "`make lint` passes in a tree with only the manifests". It wrote the test name and said it had not worked out the fixture.
- That the `validate` target should drop `agents` and `skills`. The row says to remove files that do not exist and names neither.
- What other rows will do. It assumed later rows put those two back, and could not check, because it was told not to read the outline.

What it found in the code that the row did not have: an existing test that fixes the shape of the version line in `plugin.json`, and a second place where the `bench` target is named. Both went into `Notes`. This is the case for writing bodies just in time: the plan run did not know either.

Two things for the cards that build this:

- The session cited a third-level heading, `4.1`, in the `(row ...)` comment beside the row's own heading, and put an anchor on the path. `card plan start` writes that item (P-09), so a session will not be writing it, but next-card must be told to leave it alone (P-14).
- The guess about sibling rows is the weak point. A session that writes a card from a row cannot see what the next row owns except through the `not` lines. The 32 `not` lines in the two outlines are what make that work, and they are not all there: of the four rows that cite `10. Skills`, one has none. The plan reviewer should look for the ones that are missing.

## Heading levels

Counted with awk, a line starting with three backticks or tildes toggling a code fence.

| File | Level 1 | Level 2 | Level 3 | Level 4 | `#` lines inside code fences |
|---|---|---|---|---|---|
| `docs/design.md` | 1 | 20 | 8 | 0 | 10, all at level 2 |
| the Spec Kit sample | 1 | 6 | 16 | 11 | 0 |

`docs/design.md` puts its sections at level 2. The eight third-level headings divide sections 4, 10 and 19.

The Spec Kit sample puts six sections at level 2: Clarifications, User Scenarios & Testing, Requirements, Success Criteria, Assumptions and Dependencies. Its work is one level and two levels down: nine user stories at level 3, and the 71 functional requirements in lists under eleven fourth-level headings, all inside `### Functional Requirements`. The review's finding 16 said a Spec Kit file keeps its requirements in one list under one heading. In this sample the list is divided by subject at level 4.

Whether coverage at one level is a useful net:

- For `docs/design.md`, at level 2: a weak one. It would catch a section nobody planned. It did not catch the three sections of the first draft that were listed as not planned and asked for work, and it says nothing inside `10. Skills`, which four rows cite.
- For the Spec Kit sample: the session chose level 4, which neither the design nor the review expected. There the net is exact for the functional requirements, eleven headings and thirteen rows, and blind to everything else in the file. At level 2 it would have been one heading, `Requirements`, for the whole of the work. A per-outline level is what made a useful choice possible; a fixed level 2 would have been useless for this file.
- For neither file does coverage say that a requirement has a row. In both runs that came from the reviewer.

## Growth of the plan runs

`card tokens <transcript>` for the two plan sessions, the first for `docs/design.md` (443 lines) and the second for the sample (425 lines):

```
baseline 31774
peak 69857
growth 38083
```

```
baseline 31786
peak 72072
growth 40286
```

Each run read its specification once in the main session and sent the code search to Explore. A plan run of a specification of this length costs a little more than half an S budget, and it has no budget of its own (design section 13). The baseline is the scratch plugin alone, with none of the maintainer's other plugins.

## Claude Code behavior

Rows 14 to 17 of design section 19.

| # | What was run | What was seen | Claude Code |
|---|---|---|---|
| 14 | Both plan sessions launched the draft reviewer through the Agent tool with `subagent_type` `workdeck:plan-reviewer`, as the skill names it. | Accepted both times, and the agent returned findings in the form asked for. The claim holds. | 2.1.291 |
| 15 | The same two sessions, read from their transcripts: every Agent call, whether it ran in the background, and what the session did before the result came back. | Followed in both. Each session sent one search to Explore before proposing anything and read no code file itself. Explore was launched in the background both times ("Async agent launched"); the session did nothing further until the result arrived, though one tried a `sleep` first, which the harness refused. The reviewer ran in the foreground in one session, which set `run_in_background` to false, and in the background in the other, which waited for it the same way. Two runs, both headless, on `claude-sonnet-5-5`: the claim held, and it is still an instruction a model follows, not a guarantee. In an interactive session a user could type while a background agent runs. | 2.1.291 |
| 16 | `claude plugin details workdeck` with each scratch plugin. Then one `claude -p` session with each, asked to list every `workdeck:` skill and agent type in its context without calling a tool, and `card tokens` on both transcripts. | `plugin details` projects about 70 always-on tokens for `plan`, as it does for each of the four skills, and about 471 for the plugin against about 340 without the drafts. The sessions disagree with it. Neither listed any `workdeck:` skill: the names it saw were inside a hook's output and the agents' descriptions. The first turn was 48,592 tokens without the drafts and 48,675 with them, 83 more for one skill and one agent together. The documentation is right and the projection is not: a skill with `disable-model-invocation: true` adds nothing to a session's context. One session each, so the 83 is a single reading. | 2.1.291 |
| 17 | The same two sessions. | `workdeck:plan-reviewer` was listed as an agent type beside `workdeck:reviewer`, so its description is in every session's context. `plugin details` projects about 60 tokens for it. The measured 83 is the upper bound, and all of it is the agent's if row 16 holds. | 2.1.291 |

The README's figure of about 335 always-on tokens for 0.1.1 attributes them to the four skills and the agent. By this reading only the agent's share is paid. The README is not in this card's `Touch` list; P-19 owns it.

## Outline format

The outline format of design section 5 is confirmed, with one sentence added: the `## Not planned` section may be left out when nothing would be in it. The second outline left it out, and the section did not say whether that is an error. The maintainer approved that sentence on 2026-10-09, before this card was handed off.

Nothing else in the format gave trouble in either run: the front matter, a level other than 2, several `spec` items in a row, a heading written with its number (`4. Repository layout`), and rows of up to fifteen items all fit it.

Cards amended for the added sentence: P-02 and P-03, which each gain an acceptance item and a test for an outline with no `Not planned` section, the first for the format check and the second for coverage; and P-19, whose item on the reference now says the section may be left out.

One more card was amended, for rows 16 and 17 and not for the format: P-19 gains an acceptance item that corrects the README's attribution of the always-on tokens.

## What this means for the deck

Not done in this card, which names faults and leaves these to the maintainer:

- **P-13, the plan skill.** After a must-fix finding is fixed, the reviewer runs again; the draft goes back only to the hand check. The pull request body carries the `does` lines, not a pointer to the file. The session lists, beside the outline, each place where it chose between two readings of the specification, and each requirement it left in no row. The skill says what the commit message is and that it has no trailer. For a specification whose code is not in the repository, the session asks before it plans, as the draft did unprompted.
- **P-12, the plan reviewer.** Its step 3 names two things to look for: a `does` line that joins statements, and one that describes a test and not the product. It looks for a missing `not` line where two rows cite one heading. It gives paths relative to the repository.
- **P-14, next-card.** The `(row ...)` item under `Read` is left as `card plan start` wrote it.
- **Design section 5 and the scope.** A row is not "a few lines". The rows that worked were 7 to 15 items. Nothing needs to change in the format; the wording in the scope's risk 3 undersells what a row has to hold.
- **The hard stop of design section 14.** It was not met here: one row, one card, no second cut. One card is not evidence, and the row had no dependency.

What the spike did not show: a row with dependencies written into a card after its dependencies were built; a planner naming paths in code that exists, for a specification the code does not already satisfy in part; an interactive session; and the model the maintainer uses.
