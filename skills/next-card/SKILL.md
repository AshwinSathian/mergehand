---
name: next-card
description: Start the next ready Mergehand card, or the one named. Updates the base branch, creates the card's branch and implements the card up to the point of handoff.
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

1. **Check the state above.** If it is an error starting with `card:`, explain it and stop. With no `mergehand.conf`, the fix is `/mergehand:init`, which the user types.

2. **Review fixes come first.** Run `gh pr list --author @me --state open --json number,headRefName,reviewDecision`. If a pull request from a `card/` branch has `reviewDecision` `CHANGES_REQUESTED`, do not start a new card: check out that branch, read the comments with `gh pr view <number> --comments`, and address them by following the implementation steps below. Tell the user the outcome for handoff will be `review-fixes`. If `gh` is missing or not signed in, say so and continue with step 3.

3. **Clean tree.** Run `git status --porcelain`. If it prints anything, stop and ask the user what to do with the changes.

4. **Update the base branch.** Run `card conf base` for its name, check it out, and if the repository has a remote run `git pull --ff-only`. If the pull is not a fast-forward, stop: the local base branch has commits that are not on the remote, usually cards committed locally and never pushed, followed by a squash merge. Tell the user to push those commits or land them through a pull request, and not to start a card until the base branch matches the remote.

5. **Pick the card.** Use the requested id, or run `card next`. Run `card list` and find the card's state.
   - `ready`: continue with step 6.
   - `waiting`: name the dependency that is not done, and stop.
   - `active` or `blocked`: run `git branch --list "card/<id>*"`. If a local branch is listed, the card was started here: ask the user whether to resume it, check that branch out, and continue with step 6, skipping step 7. If no local branch is listed, the work is on someone else's branch: say so and stop.
   - `review`: a pull request is open for it. Say so and stop.

   Other people's open pull requests do not prevent a start; only an unmerged dependency does.

6. **Read the card** with `card show <id>`, and run `card lint`. If lint reports an error in this card (an empty `Touch`, `Tests` or `Acceptance` section is the usual one, in a card that `card new` created and nobody filled in), stop and show the user the errors: an unfinished card is not started. If the card has a `## Blocked` section, ask the user that question and wait for the answer before writing any code. Once it is answered, remove the `## Blocked` section from the card and put the answer under `Notes`; a card that keeps the section shows as blocked as soon as its branch exists.

7. **Create the branch.** Its name is `card/` followed by the card's file name without `.md`: the file `AUTH-03-token-refresh.md` gives `card/AUTH-03-token-refresh`. Take the name from the file in the cards directory (`card conf cards_dir`), not from the title. Only the `card/<id>` prefix matters to Mergehand; the rest is for people. Run `git checkout -b <branch>`.

8. **Implement.** Read `${CLAUDE_PLUGIN_ROOT}/reference/implement.md` and follow it step by step.

9. **Stop at handoff.** Tell the user the card is ready and that `/mergehand:handoff` is the next command for them to type. Do not run it, do not commit, and do not start a second card.
