---
name: handoff
description: Finish the current Workdeck card. Runs the check and the mechanical gates, gets an independent review, writes the session log, commits, pushes the branch and opens the pull request. A person merges.
argument-hint: "[split]"
disable-model-invocation: true
allowed-tools: Bash("${CLAUDE_PLUGIN_ROOT}/bin/card" *) Bash(card *)
---

# Hand off the card

State of the deck:

```
!`"${CLAUDE_PLUGIN_ROOT}/bin/card" status 2>&1`
```

Mode requested by the user (`split`, or empty for a finished card): `$ARGUMENTS`

The first line above names the current branch and its card. If the branch is not a `card/` branch, or the state is an error starting with `card:`, explain and stop. In the steps below `<id>` is that card's id and `<base>` is the output of `card conf base`.

Work through the steps in order. Each gate must pass before the next step starts.

1. **Check.** Run `card conf check` to get the project's check command, then run that command. Fix failures that belong to this card. If a failure was there before this card (it is in code the card did not touch and fails the same way on `<base>`), report it and stop; do not fix it here.

2. **Gates.** Run these in order and stop at the first that fails:
   - `card lint`. A card or log file is malformed. Fix the file.
   - `card touched <id>`. A changed file matches no `Touch` entry. Either revert that change, or add the file to the card's `Touch` list with the reason after the path. The addition shows in the pull request, so the scope growth is visible.
   - `card tests <id>`. A `Tests` line has no test with that name in the changed files. Either rename the test, or edit the card line to the name the test has. This checks presence only.

   After any fix, run the check and the gates again from the top.

3. **Review.** Run `card show <id>` and `card conf reviewer`. Skip this step only when the card's size is `XS` and reviewer is `off`. Otherwise launch the `workdeck:reviewer` subagent with this prompt: `Card <id>, base branch <base>.` Wait for its findings. Fix every `must-fix` finding, then run the check and the gates again. For each `should-fix` finding you do not fix, keep the finding and your reason for the pull request body.

4. **Split mode only.** Create the remainder card: `card new <id>b "<title of what remains>" --size <size> --depends <id>` (if `<id>` already ends in a letter, use the next letter). Move the unfinished `Touch`, `Tests` and `Acceptance` items into it. Edit the current card so its `Acceptance` and `Tests` describe only what is done. Run `card lint`.

5. **Mark it done.** Run `card done <id>`. This reaches `<base>` only when the pull request merges.

6. **Write the session log.** Run `card log-new <id> <outcome>`, where the outcome is `done`, `split`, or `review-fixes` for a session that addressed review comments. The command prints the file and fills in the measured fields; do not edit those. Fill in the four sections, 40 lines at most in total: `Done`, `Tests`, `Deviations` (anything that differs from the card), `Follow-ups`. Run `card lint`.

7. **Commit, push, open the pull request.**
   - `git add -A` and `git commit` with a message that names the card id, in the style the project's history uses.
   - If the repository has no remote, stop here and tell the user what remains: push the branch and open a pull request against `<base>`.
   - `git push -u origin <branch>`.
   - Fill in the project's pull request template (`.github/pull_request_template.md`, if there is one): the card, what changed, the tests, the review findings left open with reasons, and the measured tokens from the log. Write it to a file, run `gh pr create --base <base> --title "<id>: <title>" --body-file <file>`, then delete the file so the tree stays clean.
   - If `gh` is missing or not signed in, stop after the push and print the URL where the user can open the pull request by hand.

8. **Report and stop.** Give the user: the pull request URL; the findings left open; growth tokens against the budget and whether the session compacted, from the log; and the next ready card from `card next`. Then stop. A session does not start a second card, and a person merges the pull request.
