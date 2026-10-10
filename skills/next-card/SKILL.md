---
name: next-card
description: Start the next ready WorkDeck card, or the one named. Updates the base branch, creates the card's branch and implements the card up to the point of handoff.
argument-hint: "[card id]"
disable-model-invocation: true
allowed-tools: Bash("${CLAUDE_PLUGIN_ROOT}/bin/card" *) Bash(card *)
---

# Start a card

State of the deck, fetched just now:

```
!`"${CLAUDE_PLUGIN_ROOT}/bin/card" status --fetch 2>&1`
```

Card requested by the user (empty means the next ready card): `$ARGUMENTS`

Work through these steps in order. Stop where a step says stop.

1. **Check the state above.** If it is an error starting with `card:`, explain it and stop. With no `workdeck.conf`, the fix is `/workdeck:init`, which the user types.

2. **Review fixes come first.** Run `gh pr list --author @me --state open --json number,headRefName,reviewDecision`. If a pull request from a `card/` branch has `reviewDecision` `CHANGES_REQUESTED`, do not start a new card: check out that branch, read the comments with `gh pr view <number> --comments`, and address them by following the implementation steps below. Tell the user the outcome for handoff will be `review-fixes`. If `gh` is missing or not signed in, say so and continue with step 3.

3. **Clean tree.** Run `git status --porcelain`. If it prints anything, stop and ask the user what to do with the changes.

4. **Update the base branch.** Run `card conf base` for its name, check it out, and if the repository has a remote run `git pull --ff-only`. If the pull is not a fast-forward, stop: the local base branch has commits that are not on the remote, usually cards committed locally and never pushed, followed by a squash merge. Tell the user to push those commits or land them through a pull request, and not to start a card until the base branch matches the remote.

5. **Pick the card.** Use the requested id, or run `card next`. Run `card list` and find the card's state.
   - `ready`: continue with step 6.
   - `waiting`: name the dependency that is not done, and stop.
   - `active` or `blocked`: run `git branch --list "card/<id>*"`. If a local branch is listed, the card was started here: ask the user whether to resume it, check that branch out, and continue with step 6, skipping step 7. If no local branch is listed, the work is on someone else's branch: say so and stop.
   - `review`: a pull request is open for it. Say so and stop.

   Other people's open pull requests do not prevent a start; only an unmerged dependency does.

6. **Read the card** with `card show <id>`. If the output starts with `row:`, the card has no file yet: it is a row of an outline, and this session writes its card. Do these six steps in order, on the base branch (on the card's branch only if step 5 resumed it), and then go on with the rest of this step. For a card that has a file, skip them.

   1. Run `card plan start <id>`. It prints the path of the card file it created. If it fails, explain the error and stop.
   2. Read the specification headings the card lists in its first `Read` item, and the code the work concerns.
   3. Fill in the card. In every section an item is a line that starts with `- `.
      - `Touch`: full paths taken from the code as read, with `(new)` on a file the card creates.
      - `Tests`: one item per test, written as the innermost name the test will have, in the style of the tests it will sit beside.
      - `Read`: the files a session must read first, after the specification. The first `Read` item, with its `(row ...)` comment, stays as `card plan start` wrote it, with no heading added and no anchor on the path: the reviewer checks the card against the headings it names, so the session that wrote the card must not be the one that chooses them.
      - `Acceptance` and `Out of scope` start as the row's lines. Keep them unless they are wrong, and add to them.
      - Change `size` if the row's guess no longer holds.
      - Where you have to guess what a neighbouring row owns, write the guess under `Notes` and say it to the user with the card. A guess is not a reason for the fourth of these steps.
   4. If the row cannot be done as it was cut (it needs code that no finished card provides, or it overlaps another row), delete the card file, tell the user to revise the outline with `/workdeck:plan <spec path>`, which the user types, and stop. Only these two cases end here.
   5. Run `card lint` and `card plan check <id>`. Fix what they report about this card. If `card lint` reports another file, show the user and stop: that file is not this card's to change.
   6. Show the card to the user and ask for a yes or an edit. Do not write code before the answer. After an edit, make it, run `card lint` and `card plan check <id>` again, then show the card and ask again: only a yes goes on. After a no, delete the card file and stop: nothing was committed and no branch exists.

   The file is untracked until the yes, as a quick card is, so a no leaves nothing behind.

   A card file that exists and that git does not track (`git ls-files --error-unmatch <card file>` fails) was written from a row by a session that ended before the yes, or before the commit of step 7. Nobody has approved it. Do the fifth and sixth of these steps on it, and after the yes make the commit of step 7, also on a branch that step 5 resumed.

   For every card, run `card lint`. If lint reports an error in this card (an empty `Touch`, `Tests` or `Acceptance` section is the usual one, in a card that `card new` created and nobody filled in), stop and show the user the errors: an unfinished card is not started. If the card has a `## Blocked` section, ask the user that question and wait for the answer before writing any code. Once it is answered, remove the `## Blocked` section from the card and put the answer under `Notes`; a card that keeps the section shows as blocked as soon as its branch exists.

7. **Create the branch.** Its name is `card/` followed by the card's file name without `.md`: the file `AUTH-03-token-refresh.md` gives `card/AUTH-03-token-refresh`. Take the name from the file in the cards directory (`card conf cards_dir`), not from the title. Only the `card/<id>` prefix matters to WorkDeck; the rest is for people. Run `git checkout -b <branch>`.

   For a card this session wrote from a row, and for a card file that git did not track (step 6), commit the card file alone, before step 8: run `git add <card file>` and `git commit -m "<id>: card as approved"`, with nothing else staged. Do this on a resumed branch too, where the rest of this step is skipped. That commit is the card the user approved. If the commit fails, show the error and stop: do not start step 8. Make no such commit for a card that had a file git tracks.

8. **Implement.** Read `${CLAUDE_PLUGIN_ROOT}/reference/implement.md` and follow it step by step.

9. **Stop at handoff.** Tell the user the card is ready and that `/workdeck:handoff` is the next command for them to type. Do not run it, do not commit anything after step 7, and do not start a second card.
