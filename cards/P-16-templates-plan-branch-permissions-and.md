---
id: P-16
title: Templates: plan branch permissions and protocol lines
size: S
depends: P-02
done: false
---

## Read
- docs/design-0.2.md#103-workdeckinit (step 1, and the last paragraph on the template's section)
- docs/design-0.2.md#41-the-plugin
- docs/design-0.2.md#19-claude-code-behavior-this-design-relies-on (row 12)
- docs/development/findings.md (finding 9)
- docs/development/review-0.2.md (finding 25)
- templates/settings-permissions.json
- templates/claude-md-section.md
- test/cases/02-plugin.sh (the cases for the permission template, with `rules` and `matches`)

## Touch
- templates/settings-permissions.json
- templates/claude-md-section.md
- test/cases/02-plugin.sh

## Tests
- test_permission_template_allows_the_plan_branch_push
- test_permission_template_denies_a_plan_branch_push_with_a_further_argument
- test_claude_md_section_names_plan_branches_and_the_card_for_a_row

## Acceptance
- templates/settings-permissions.json has `git push -u origin plan/*` and `git push origin plan/*` under `allow`, and under `deny` the same two patterns followed by a further argument, as it has for `card/*`.
- `git push -u origin plan/2610091200` is allowed and not denied. `git push origin plan/2610091200 main` and `git push origin plan/2610091200:main` are denied.
- templates/claude-md-section.md gains two lines: a `plan/*` branch changes only outlines, and next-card writes the card for a row and waits for a yes before any code.
- The section is still 25 lines or fewer, and test_claude_md_section_is_short passes.
- templates/workdeck.yml is unchanged.
- No key is added to templates/workdeck.conf.
- Every case for the permission template that existed passes unchanged.
- Row 12 of design section 19 was read again for this card. The session log gives the result.

## Out of scope
- The step for `card plan` in templates/workdeck.yml. P-24 owns it, with the version.
- The init skill, which merges these into a repository. P-17 owns it.
- Entries for `git checkout`, `git add` and `git commit`. The template has none for card branches either; P-21 records the prompts.
- This repository's own CLAUDE.md and settings. They are not tracked here.

## Notes
- Claims are read again on the pages of section 19, through Context7 (`/websites/code_claude`) as the design did. The session log gives the date and the result for each row. If a claim no longer holds, the card stops with a `## Blocked` section; it does not edit the design.
- Init writes the workflow with the plugin's version as the tag, and until P-24 that tag's `card` has no `plan` command. That is why the workflow template does not change here.
- The deny rules match a command as written and are not a security boundary. The README already says so.
- test/cases/02-plugin.sh has `matches allow` and `matches deny`. Use them; do not grep the JSON.
