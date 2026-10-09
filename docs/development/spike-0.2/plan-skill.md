---
name: plan
description: Plan a specification file as a WorkDeck outline, one row per card. Has an agent that did not write the outline review it, asks the user to approve it, and opens a pull request that changes nothing else.
argument-hint: "<spec path> [what to change]"
disable-model-invocation: true
allowed-tools: Bash("${CLAUDE_PLUGIN_ROOT}/bin/card" *) Bash(card *)
---

# Plan a specification

State of the deck, fetched just now:

```
!`"${CLAUDE_PLUGIN_ROOT}/bin/card" status --fetch 2>&1`
```

Arguments from the user, the specification's path and then, optionally, what to change: `$ARGUMENTS`

This is the spike draft. `card` has no `plan` command yet, so do not run one. Wherever a step says "by hand", you do what the command will do later.

Work through these steps in order. Stop where a step says stop. This session writes one outline file. It writes no card and no code.

1. **Check the state above, and the tree.** If the state is an error starting with `card:`, explain it and stop. Run `git status --porcelain`. If it prints anything, stop and ask the user what to do with the changes. Run `card conf base`, check that branch out, and if the repository has a remote run `git pull --ff-only`. If the pull is not a fast-forward, stop and say so.

2. **An open plan pull request comes first.** Run `gh pr list --author @me --state open --json number,headRefName`. If a pull request from a `plan/` branch is open, say so. If its branch is local, offer to check it out and address the comments on it (`gh pr view <number> --comments`), then continue with step 6. Otherwise stop. If `gh` is missing or not signed in, say so and continue with step 3.

3. **Find the specification and its outline.** The first argument is the path. Run `git ls-files --error-unmatch <path>`. If it fails, the path is not a tracked file: say so and stop. Look in `<cards_dir>/plan/` (`card conf cards_dir`) for an outline whose `spec` line is that path.

4. **Create the branch** `plan/<yymmddhhmm>`, with the time from `date +%y%m%d%H%M`. Run `git checkout -b <branch>`.

5. **Write or revise.**

   **No outline.**
   1. Read the specification.
   2. Get to know the code it concerns. Do not read the code yourself: launch the built-in Explore subagent with the questions you need answered (which parts of the specification the code already does, where the code for each part lives, how the tests are laid out and named), and wait for its answer. File contents stay out of this session that way.
   3. Propose a prefix and a heading level, and ask the user to confirm both. The prefix matches `[A-Z][A-Z0-9]*`, is not `Q`, and is used by no card and no other outline (`card list` shows the prefixes in use). The level is the heading level at which the specification's sections sit: the level whose headings, taken one by one, each ask for work or clearly ask for none.
   4. By hand: create `<cards_dir>/plan/<prefix in lowercase>.md` with the front matter below. `spec_blob` is what `git hash-object <spec path>` prints.
   5. Write the rows and the `Not planned` list, following "The outline" and "Cutting rows" below.

   **An outline exists.**
   1. By hand: compare `git hash-object <spec path>` with the outline's `spec_blob`. If they differ, show the user `git diff <spec_blob> HEAD:<spec path>` and propose the rows the change calls for.
   2. Apply what the user asked for after the path.
   3. Only a row with no card file and no `card/<id>` branch may be changed or removed (`card list`, and `git branch -a --list "*card/<id>*"`). For any other row the card is what gets edited: say so and leave the row alone. An id is never used again after its row is removed.
   4. By hand: set `spec_blob` to what `git hash-object <spec path>` prints now.

6. **Check the outline.** By hand: go through "What the script will check" below, item by item, against the file as it is. Fix what fails and check again.

7. **Review.** Launch the `workdeck:plan-reviewer` subagent with the outline's path and the base branch, and wait for it to finish. Fix every `must-fix` finding and go back to step 6. Keep every finding, with what was done about it.

8. **Ask the user.** Show the outline as a table: id, size, dependencies, title, and the `does` lines. Under it, show the `Not planned` list and each finding that was not fixed, with the reason. Ask for a yes, an edit or a no.
   - Yes: continue with step 9.
   - An edit: make it and go back to step 6.
   - No: delete the outline file if this run created it, or restore it with `git checkout -- <outline>` if it did not. Check out the base branch and stop.

9. **Commit and open the pull request.** Run `git status --porcelain` and confirm the outline is the only file that changed. If anything else changed, revert it first. Commit the outline with the message `plan: <PREFIX>, <n> rows`. If the repository has no remote, stop here and print the body below. Otherwise push with `git push -u origin <branch>` and run `gh pr create`. If `gh` is missing or not signed in, stop after the push and print the URL for opening the pull request by hand. The body has:
   - the rows, as the table of step 8, and the `Not planned` list;
   - every reviewer finding with what was done about it;
   - the three lines `card tokens` prints;
   - for a run that revised an outline, what the user asked for or which change to the specification caused it.

10. **Report** the pull request URL, or what remains to be done by hand, and stop.

## The outline

```
---
spec: specs/auth.md
spec_blob: 3b18e512dba79e4c8300dd08aeb37f8e728b8dad
prefix: AUTH
level: 2
---

## AUTH-01 Token store
- size: S
- spec: Storage
- does: A token is stored hashed, with its expiry
- does: A stored token can be looked up by its hash

## AUTH-02 Token refresh
- size: S
- depends: AUTH-01
- spec: Refresh
- spec: Errors
- does: A refresh returns a new token and makes the old one invalid
- does: An expired token is refused with 401
- not: Counting refreshes (AUTH-03)

## Not planned
- Overview
- Non-goals
```

- The front matter is flat `key: value` lines: `spec`, `spec_blob`, `prefix`, `level`, and no other key. `spec` has no `..` and no space. `level` is a digit from 1 to 6.
- A row is a second-level heading, `## <id> <title>`, followed by items. The id is the prefix, a hyphen and digits, with no letter after them. The title is at most 80 characters.
- An item is `- <key>: <text>` on one line. `size` appears once. `depends` appears at most once and is a comma-separated list of ids. `spec` appears any number of times, each naming one heading of the specification at the outline's level, written as the specification writes it. `does` appears at least once. `not` appears any number of times. There is no other key.
- `## Not planned` lists the headings of the specification, at the outline's level, that produce no card.
- Headings are compared lowercased, with every character that is not a letter or a digit removed.

## Cutting rows

- **A row is one session's work.** The size is a guess at how much a session has to read and change: `XS`, `S` or `M`, whose budgets `card conf budget.XS`, `budget.S` and `budget.M` print. Work that would not fit `M` is two rows.
- **Plan only what the code does not do yet.** A heading whose work is already in the code produces no row and goes under `Not planned`. Where part of a heading is done, the row's `does` lines name only the part that is not.
- **A `does` line is a statement that is true or false when the card is finished.** "Token refresh works" is not one. "An expired token is refused with 401" is. Together, the `does` lines of all rows that cite a heading cover every requirement under it.
- **A `not` line names what a reader might expect in this row, and the row that owns it.** Write one wherever two rows cite the same heading, or a title promises more than the row does.
- **A dependency is written only where a row needs code that another row creates.** A dependency costs a wait, and one that is missing sends a session to code that is not there.
- **A row with no `spec` item** is allowed for work no single heading asks for, such as a migration or a CI job. The reviewer looks at each.
- The writing of a card from a row happens later, in a session that has not seen this one. It has the row, the headings the row cites and the code. Write the row for that reader.

## What the script will check

`card plan` will run these. Until it exists, check each by reading.

| Check | Fails when |
|---|---|
| Outline format | the front matter has a missing, unknown or malformed key; the file name is not the prefix in lowercase; a row has no `size`, no `does`, a key twice that may appear once, or an unknown key |
| Ids | a row's id is malformed, carries a letter, does not start with the prefix, or appears in two rows; two outlines share a prefix; the prefix is `Q` |
| Sizes | a row's size has no budget |
| Dependencies | a dependency names neither a row nor a card; the rows and cards together contain a cycle |
| Specification | the `spec` file is missing or untracked |
| Coverage | a heading of the specification at the outline's level, outside a code fence, is cited by no row and is not under `Not planned`; a row or the `Not planned` list cites a heading the specification does not have at that level |
| Plan branch | a file outside `<cards_dir>/plan/` differs from the point where this branch left the base branch |
