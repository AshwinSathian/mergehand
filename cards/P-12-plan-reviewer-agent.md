---
id: P-12
title: Plan reviewer agent
size: S
depends: P-01
done: false
---

## Read
- docs/design-0.2.md#121-plan-reviewer
- docs/design-0.2.md#113-what-a-script-cannot-decide (what goes to the plan reviewer)
- docs/design-0.2.md#5-outline-format (rows with no `spec` item, and `Not planned`)
- docs/design-0.2.md#19-claude-code-behavior-this-design-relies-on (rows 7, 8, 9, 14 and 17)
- docs/development/spike-0.2.md (what the draft reviewer found and missed)
- docs/development/spike-0.2/plan-reviewer.md (the draft)
- agents/reviewer.md (the output form to match)
- test/cases/02-plugin.sh (test_reviewer_agent_is_read_only)

## Touch
- agents/plan-reviewer.md (new)
- test/cases/02-plugin.sh

## Tests
- test_plan_reviewer_agent_is_read_only
- test_plan_reviewer_is_told_to_assume_the_outline_is_wrong
- test_plan_reviewer_reads_the_outline_from_the_working_tree
- test_plan_reviewer_uses_the_severities_of_the_reviewer

## Acceptance
- agents/plan-reviewer.md has `name: plan-reviewer`, a description, and `tools: Read, Grep, Glob, Bash`. It has no `hooks`, `mcpServers` or `permissionMode` field.
- It receives the outline's path and the base branch, and reads the outline from the working tree.
- It says the agent did not write the outline and is to assume the outline is wrong.
- Its procedure has the five steps of section 12.1, in that order.
- Its output is in the form agents/reviewer.md uses: `must-fix`, `should-fix` or `nit`, the outline's line, the problem in one sentence, and how it goes wrong.
- Every `card` command it names exists.
- `claude plugin validate --strict agents` passes.
- Rows 7, 8, 9 and 14 of design section 19 were read again for this card, and row 17's cost for this agent was measured with `claude plugin details`. The session log gives the result for each.
- What the spike's record says the draft got wrong is answered in the file, or listed in the session log as not answered.

## Out of scope
- The skill that launches the agent. P-13 owns it.
- The new step of agents/reviewer.md. P-15 owns it.
- A script check for anything in section 11.3. Those stay with this agent.

## Notes
- Claims are read again on the pages of section 19, through Context7 (`/websites/code_claude`) as the design did. The session log gives the date and the result for each row. If a claim no longer holds, the card stops with a `## Blocked` section; it does not edit the design.
- The agent is addressed as `workdeck:plan-reviewer`.
- test_skills_name_only_card_commands_that_exist reads agents/*.md. A `card` word in a code span has to be a real command.
- Row 17 is an always-on cost paid by every session of every user. Keep the description to one sentence.
