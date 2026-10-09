---
id: P-01
title: Spike: plan two specifications by hand before any check is built
size: S
depends:
done: false
---

## Read
- docs/design-0.2.md#21-build-order (item 1: what the spike records)
- docs/design-0.2.md#5-outline-format (the format under test)
- docs/design-0.2.md#101-workdeckplan-spec-path-what-to-change (the steps the draft follows)
- docs/design-0.2.md#121-plan-reviewer
- docs/design-0.2.md#19-claude-code-behavior-this-design-relies-on (rows 14 to 17)
- docs/design-0.2.md#14-trial-and-release (the paragraph "Before the build")
- docs/development/review-0.2.md (findings 4, 5 and 16, and the last row of the third pass)
- docs/design.md (the first specification the draft is run on)
- skills/next-card/SKILL.md (the form of a skill in this plugin)
- agents/reviewer.md (the form of an agent in this plugin)

## Touch
- docs/development/spike-0.2.md (new)
- docs/development/spike-0.2/plan-skill.md (new)
- docs/development/spike-0.2/plan-reviewer.md (new)
- docs/development/spike-0.2/outline-design.md (new)
- docs/development/spike-0.2/outline-sample.md (new)
- docs/development/README.md
- docs/design-0.2.md (section 5 if the format changes, and the status column of rows 14 to 17 in section 19)
- test/cases/02-plugin.sh

## Tests
- test_spike_record_for_0_2_is_listed_and_answers_its_questions

## Acceptance
- A draft of the plan skill and a draft of the plan reviewer exist under docs/development/spike-0.2/. Neither is under skills/ or agents/.
- The plan draft was run by hand, with no `card plan`, on docs/design.md and on one Spec Kit sample specification. Both outlines are kept as written, with no correction.
- The record lists what is wrong with each outline, and for each fault says which check of design section 11.1 would catch it, or that none would.
- A second session that had only one row and the code wrote a card from it. The record says whether the row was enough, and what the session had to guess.
- The record gives the heading level at which the sections of each of the two files sit, and whether coverage at one level is a useful net for each.
- The record gives the growth of each plan run as `card tokens` prints it.
- Rows 14, 15, 16 and 17 of design section 19 each have a result in the record: what was run, what was seen, and the Claude Code version. Their status in the design is updated to match.
- The record says in one line that the outline format of design section 5 is confirmed, or lists each change. A change is made in design section 5 in this card and the maintainer approved it before handoff.
- If section 5 changed, every card of the deck whose `Tests` or `Acceptance` names a changed key or rule is amended in this card, and the record lists those cards.
- No file under bin/, hooks/, skills/, agents/, templates/ or reference/ changed.
- docs/development/README.md has a row for the record.

## Out of scope
- Any `card` code, and any parser of an outline. P-02 owns the first.
- skills/plan/SKILL.md and agents/plan-reviewer.md as shipped files. P-13 and P-12 write them from these drafts.
- Fixing what the outlines get wrong by adding checks. The record names the fault; the deck's cards are amended by the maintainer if a check is missing.
- The trial of design section 14, "After the build". P-22 and P-23 own it.

## Notes
- The plan runs and the second session are separate sessions in a scratch copy of the repository. This card's session writes the drafts, tells the maintainer what to run, and writes the record from what comes back.
- Rows 14 and 17 need the draft agent loaded as a plugin agent. Use a scratch copy of the plugin that holds the drafts as skills/plan/SKILL.md and agents/plan-reviewer.md, loaded with `--plugin-dir`. Row 16 is read from `claude plugin details` with and without the draft skill.
- Leave no outline under cards/plan/ in this repository. From P-02 on, `card plan` would check it.
- The design does not say where the drafts and the two outlines are kept. This card keeps them under docs/development/spike-0.2/. The maintainer may move them.
- The Spec Kit sample is not committed. The record names where it came from and at which commit. cards/REVIEW.md allows a development record to name a specification format the planner is run on.
- test_docs_have_one_design_file_and_a_development_folder fails on any tracked file that names one of the old documentation directories; its pattern lists them. Do not use one as an example path.
- Every card that parses an outline depends on this one. Cards are under cards/, which the scope gate skips, so amending them needs no `Touch` entry.
