---
name: quick
description: Make a small change that needs no plan (a bug fix, a rename, a small addition) as an XS WorkDeck card on its own branch. Keeps the check, the review and the pull request.
argument-hint: "\"<description>\""
disable-model-invocation: true
allowed-tools: Bash("${CLAUDE_PLUGIN_ROOT}/bin/card" *) Bash(card *)
---

# Quick change

State of the deck:

```
!`"${CLAUDE_PLUGIN_ROOT}/bin/card" status 2>&1`
```

What the user wants: `$ARGUMENTS`

Work through these steps in order. Stop where a step says stop.

1. **Check.** If the state above is an error starting with `card:`, explain it and stop. If the description is empty, ask for one. Run `git status --porcelain`; if it prints anything, stop and ask the user what to do with the changes.

2. **Start from the base branch.** Run `card conf base`, check that branch out, and if the repository has a remote run `git pull --ff-only`.

3. **Read the relevant code**, and only that: enough to know which files change and how the change will be tested.

4. **Create the card.** The id comes from the current time, so two people on separate branches cannot get the same one. Run `date +%y%m%d%H%M` as its own command, then use the digits it prints:

   ```
   card new Q-<digits> "<title, at most 80 characters>" --size XS
   ```

   The command prints the card's path. Fill in the file. In every section an item is a line that starts with `- `; the gates do not see any other line.
   - `Touch`: one item for each file that will change. Entries are shell patterns; write full paths.
   - `Tests`: one item per test, worded as the test will be named.
   - `Acceptance`: statements that are true or false, all of which must hold.
   - Leave `Read` empty.

   Then run `card lint` and fix what it reports.

5. **Show the card to the user** and ask for a yes or an edit. Do not write code before the answer. If the user says no, delete the card file and stop: an untracked card left on the base branch would stop the next card from starting.

6. **Create the branch.** Its name is `card/` followed by the card's file name without `.md`. Take it from the path `card new` printed, not from the title. Only the `card/<id>` prefix matters to WorkDeck; the rest is for people. Run `git checkout -b <branch>`.

7. **Implement.** Read `${CLAUDE_PLUGIN_ROOT}/reference/implement.md` and follow it step by step.

8. **Stop at handoff.** Tell the user the change is ready and that `/workdeck:handoff` is the next command for them to type. Do not commit and do not run it.

If the work turns out larger than this, two things say so: a budget warning when the session grows past the XS budget, and the scope gate at handoff when files beyond the card changed. In either case the user decides whether to split or to write a proper card.
