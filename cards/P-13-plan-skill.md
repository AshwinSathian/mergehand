---
id: P-13
title: Plan skill
size: M
depends: P-01, P-03, P-04, P-05, P-12
done: false
---

## Read
- docs/design-0.2.md#101-workdeckplan-spec-path-what-to-change
- docs/design-0.2.md#3-decisions-already-made (the rows Form of the planner, Landing and Plans in flight)
- docs/design-0.2.md#15-errors
- docs/design-0.2.md#16-trust-and-input-handling (the last item)
- docs/design-0.2.md#19-claude-code-behavior-this-design-relies-on (rows 1 to 6, 10, 11, 14, 15 and 16)
- docs/development/spike-0.2.md (what the draft got wrong, and rows 14 to 16)
- docs/development/spike-0.2/plan-skill.md (the draft)
- docs/development/review-0.2.md (findings 7, 8, 9 and 21 to 23)
- skills/next-card/SKILL.md (steps 2 to 4, which this skill repeats)
- skills/quick/SKILL.md (the time-based name)
- skills/handoff/SKILL.md (step 7: where handoff stops with no remote or no `gh`)
- agents/plan-reviewer.md
- test/cases/60-skills.sh

## Touch
- skills/plan/SKILL.md (new)
- test/cases/60-skills.sh

## Tests
- test_plan_skill_is_typed_by_the_user_and_does_not_fork
- test_plan_skill_runs_the_check_the_review_and_the_approval_in_that_order
- test_plan_skill_names_the_plan_reviewer_by_its_scoped_name
- test_plan_skill_delegates_the_search_to_explore
- test_plan_skill_creates_a_plan_branch_named_by_the_time
- test_plan_skill_offers_to_resume_an_open_plan_pull_request
- test_plan_skill_stops_when_card_has_no_plan_command
- test_plan_skill_puts_every_finding_in_the_pull_request_body
- test_plan_skill_writes_no_card_and_no_code

## Acceptance
- skills/plan/SKILL.md has `name: plan`, `disable-model-invocation: true`, an `argument-hint` for the path and the request, and no `context: fork`.
- Its steps are the ten of section 10.1, in that order.
- It stops on a dirty tree, on a path that is not a tracked file, and when `card plan` prints `unknown command`; in the last case it says to update `card`.
- With an open pull request from a `plan/` branch by this user, it says so; it offers to resume when the branch is local and stops otherwise. Without `gh` it goes on.
- The branch is `plan/<yymmddhhmm>`, from `date +%y%m%d%H%M`.
- With no outline it proposes a prefix and a heading level, asks the user to confirm both, and runs `card plan new`. It delegates the search of the code to the Explore subagent.
- With an outline it runs `card plan`, shows a changed specification with `git diff <spec_blob> HEAD:<spec>`, changes or removes only a row with no card file and no `card/<id>` branch, and runs `card plan accept`.
- `card plan` runs before the reviewer, the reviewer before the user is asked, and the user's yes before the commit.
- The pull request body has the rows, the `Not planned` list, every reviewer finding with what was done about it, the figures of `card tokens`, and for a revision its cause.
- After a no it restores or deletes the outline file, checks out the base branch and stops.
- It says the session writes no card and no code.
- Every `card` command it names exists, and it does not tell the model to invoke a skill.
- Rows 1 to 6, 10, 11, 14, 15 and 16 of design section 19 were read again for this card. The session log gives the result for each.

## Out of scope
- The plan reviewer's text. P-12 owns it.
- The `card plan` commands. P-02 to P-05 own them.
- The permission entries for `plan/*`. P-16 owns the template.
- The README's line on an untrusted specification. P-19 owns it.
- A run of the skill by hand. P-21 owns it.
- A budget warning for a plan run. Section 13 says there is none.

## Notes
- Claims are read again on the pages of section 19, through Context7 (`/websites/code_claude`) as the design did. The session log gives the date and the result for each row. If a claim no longer holds, the card stops with a `## Blocked` section; it does not edit the design.
- Row 15 is the weak one: the documentation says Claude chooses when to delegate. Use the wording the spike found to work, and say in the log if it found none.
- test_skills_disable_model_invocation and test_skills_name_only_card_commands_that_exist loop over every skill. They cover this one with no change, once `plan` is a command.
- test_skills_do_not_use_command_substitution: give each command on its own, as the other skills do.
- test_docs_have_one_design_file_and_a_development_folder fails on any tracked file that names one of the old documentation directories; its pattern lists them. Use another example path.
- The template allows no `git checkout`, `git add` or `git commit` (review, third pass). The skill still names them; P-21 records the prompts they raise.
