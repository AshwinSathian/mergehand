---
id: P-17
title: Init on a repository that is already set up
size: M
depends: P-16
done: false
---

## Read
- docs/design-0.2.md#103-workdeckinit
- docs/design-0.2.md#8-configuration-and-compatibility (the row "A 0.1 repository whose user wants the planner")
- docs/design-0.2.md#41-the-plugin (the line for skills/init/SKILL.md)
- docs/design.md#10-skills (section 10.1, the eight steps of 0.1)
- docs/development/review-0.2.md (question 3, and findings 3 and 25)
- skills/init/SKILL.md
- templates/settings-permissions.json
- templates/claude-md-section.md
- templates/REVIEW.md
- cards/REVIEW.md (what a rule that a reviewer can check looks like)
- test/cases/60-skills.sh (the three cases for init)

## Touch
- skills/init/SKILL.md
- test/cases/60-skills.sh

## Tests
- test_init_continues_when_workdeck_conf_exists
- test_init_asks_before_each_step_and_overwrites_nothing
- test_init_offers_the_permission_entries_that_are_missing
- test_init_offers_touch_ignore_entries_for_lockfiles_and_generated_files
- test_init_proposes_at_most_ten_review_rules_each_with_its_source
- test_init_replaces_a_protocol_section_that_differs_from_the_template
- test_init_no_longer_says_that_cards_are_not_written_from_a_specification

## Acceptance
- When `workdeck.conf` exists, init says so and continues with the four steps of section 10.3. It no longer stops.
- For a repository with no `workdeck.conf`, steps 2 to 8 of docs/design.md section 10.1 are unchanged, and the `touch_ignore` and review rules steps follow its step 7.
- Each of the four steps asks first and writes nothing without a yes. Nothing is committed. Nothing existing is overwritten, with one exception that the skill states: the protocol section is replaced after the user has seen the difference and said yes.
- Permission entries: init shows the entries the settings file lacks and merges them on approval.
- `touch_ignore`: init looks for tracked `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Cargo.lock`, `go.sum`, `*.snap`, and files a `.gitattributes` marks `linguist-generated`, shows the list, and adds the approved ones.
- Review rules: init reads `CLAUDE.md`, the contributing guide, linter configuration and CI workflows, and proposes at most ten rules, each one sentence a reviewer can check against a diff, each with the file it came from. Approved rules go under the existing headings. Rules already in the file are left as they are.
- Protocol section: when `CLAUDE.md` has a `## WorkDeck session protocol` section that differs from the template, init shows the difference and replaces the section on approval.
- The closing line no longer says that WorkDeck does not write cards from a specification. It names the plan skill as something the user types.
- test_init_names_only_templates_that_exist and test_init_tells_the_user_to_commit_before_the_next_command pass.

## Out of scope
- The templates. P-16 owns them.
- A codebase map. Cut on 2026-10-09 (review, question 3).
- A first card written from a description. docs/development/later.md has it.
- A new key in `workdeck.conf`. `touch_ignore` exists in 0.1.

## Notes
- SKILL-04 has the acceptance item "A second run stops at step 1". This card reverses it on purpose.
- `touch_ignore` is one line of comma-separated patterns in `workdeck.conf`. Init adds to the line that is there and does not write a second one: `card` 0.1.3 would read only one of them.
- The protocol section in an existing `CLAUDE.md` may have been edited by the project. That is why the step shows the difference and asks, where 0.1 left the section alone.
- test_init_names_only_templates_that_exist counts six templates. The count stays six unless this card names a new one.
- test_skills_never_tell_the_model_to_invoke_a_skill reads the closing line.
- From the second review of P-16 (`docs/development/review-0.2.md`, nineteenth pass): the protocol section names `cards/` and `cards/plan/`. Where `cards_dir` is not `cards`, init writes the configured directory in their place when it adds or replaces the section, and the difference it shows in step 4 is against that text. `templates/settings-permissions.json` is not parsed by any test: the merge of step 1 is where a fault in it shows, so say what init does when the template or the settings file is not valid JSON.
