---
id: P-19
title: README, reference and design pointer for the planner
size: S
depends: P-13, P-14, P-15, P-17
done: false
---

## Read
- docs/design-0.2.md#1-what-02-adds
- docs/design-0.2.md#41-the-plugin
- docs/design-0.2.md#5-outline-format
- docs/design-0.2.md#8-configuration-and-compatibility
- docs/design-0.2.md#9-the-card-command
- docs/design-0.2.md#113-what-a-script-cannot-decide (the known limits)
- docs/design-0.2.md#16-trust-and-input-handling (the last item)
- README.md
- docs/reference.md
- docs/design.md (the lines at the top: date, status, scope)
- skills/plan/SKILL.md
- cards/DOC-01-readme.md (what the README card of 0.1 required)
- test/cases/02-plugin.sh (the cases that read the README and the reference)

## Touch
- README.md
- docs/reference.md
- docs/design.md (one pointer to docs/design-0.2.md at the top; no rule changes)
- test/cases/02-plugin.sh

## Tests
- test_readme_names_the_plan_skill_and_warns_about_an_untrusted_specification
- test_readme_says_a_0_1_repository_runs_init_again_to_plan
- test_reference_names_every_plan_subcommand
- test_reference_describes_the_outline_format
- test_design_points_to_the_0_2_design

## Acceptance
- The README's Skills table has a row for `/workdeck:plan <spec path> [what to change]`, and the rows for next-card, handoff and init say what changed.
- Beside the plan skill the README says that a specification from an untrusted source is an instruction to a session that may push a `plan/*` branch and open a pull request.
- The README's Known limits or FAQ says what a 0.1 user does to plan: run `/workdeck:init` again; and to run `card plan` in CI once 0.2 is released: change the tag in the workflow and add the step that runs it.
- The README's Known limits has the limits of section 11.3 that a user meets: coverage works at one heading level, only `#` headings count, and `card plan` is not a handoff gate.
- The README's Roadmap says 0.2 is built on the main branch and not yet released. The Skills row for the plan skill says the same.
- docs/reference.md lists `card plan`, `card plan new`, `card plan accept`, `card plan start` and `card plan check` with their arguments and exit codes, and describes the outline format: the front matter keys, the row keys, `Not planned`, and that the id of a removed row is not used again.
- docs/reference.md's Card states says a row with no card file has the same states, and gives the remainder rule.
- docs/design.md says at its top that docs/design-0.2.md adds to it. No section of docs/design.md changes.
- test_readme_links_resolve and test_reference_names_every_card_command pass.
- No project other than this one is named outside the README's "How it compares" section.

## Out of scope
- The changelog. P-20 owns it.
- The version, the download line of the README and its Upgrade section. P-24 owns them.
- docs/evidence.md and the README's Evidence section. P-21, P-22 and P-23 own the page; the README's summary of it follows the trial and is a quick card then.
- Any claim that the planner was shown to work. Nothing is measured before P-23.

## Notes
- cards/REVIEW.md, Conventions: no reference to any other project except in "How it compares". The design names two specification formats; the README says "a specification in one markdown file" and names neither outside that section.
- test_docs_have_one_design_file_and_a_development_folder fails on any tracked file, the README included, that names one of the old documentation directories; its pattern lists them.
- The one-line entries in docs/reference.md that P-02, P-04, P-09 and P-10 added are replaced here by the full text.
