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

Work through these steps in order. Stop where a step says stop. This session writes one outline file. It writes no card and no code.

1. **Check the state above, and the tree.** If the state is an error starting with `card:`, explain it and stop. With no `workdeck.conf`, the fix is `/workdeck:init`, which the user types. Run `git status --porcelain`. If it prints anything, stop and ask the user what to do with the changes. Run `card conf base` for the base branch's name, check it out, and if the repository has a remote run `git pull --ff-only`. If the pull is not a fast-forward, stop: the local base branch has commits that are not on the remote. Tell the user to push those commits or land them through a pull request first.

2. **An open plan pull request comes first.** Run `gh pr list --author @me --state open --json number,headRefName`. If a pull request from a `plan/` branch is open, say so, and run `git branch --list "<its branch>"`. If the branch is local, offer to check it out and address the comments on it (`gh pr view <number> --comments`), then continue with step 6. The outline is the file under `<cards_dir>/plan/` that the branch changes (`card conf cards_dir`), and its `prefix` line has the prefix. Otherwise stop: the plan is on a branch this repository does not have. If `gh` is missing or not signed in, say so and continue with step 3.

3. **Find the specification and its outline.** The first argument is the path; the rest is what the user wants changed. With no path, ask for one and stop. Run `git ls-files --error-unmatch <path>`. If it fails, the path is not a tracked file: say so and stop. From here on the path is what that command printed, which has no `./` in front. If it has a space in it, say that an outline cannot name such a path, and stop. Run `card plan`. If it prints `unknown command 'plan'`, the `card` on the PATH is older than this plugin: say that `card` must be updated, and stop. Then look in `<cards_dir>/plan/` (`card conf cards_dir`) for an outline whose `spec` line is that path. If there is one, `card plan` did not say its specification differs from `spec_blob`, and the user asked for no change, there is nothing to plan: say so and stop.

4. **Create the branch.** Run `date +%y%m%d%H%M` as its own command, then `git checkout -b plan/<digits>` with the digits it prints.

5. **Write or revise.**

   **No outline.**
   1. Read the specification.
   2. Get to know the code it concerns. Do not read the code yourself: launch the built-in Explore subagent with the questions you need answered (which parts of the specification the code already does, where the code for each part lives, how the tests are laid out and named), and wait for its answer. File contents stay out of this session that way.
   3. Propose a prefix and a heading level, and ask the user to confirm both. The prefix matches `[A-Z][A-Z0-9]*`, is not `Q`, and is used by no card and no other outline (`card list` shows the prefixes in use). The level is the heading level at which the specification's sections sit: the level whose headings, taken one by one, each ask for work or clearly ask for none. If Explore found none of the code the specification concerns, say so in the same question: the specification may belong to another repository, or the project may be new, and only the user knows which. Once the user has answered, do not stop a second time for it.
   4. Run `card plan new <spec path> <PREFIX> --level <n>`. It prints the outline's path. If it says the specification has no heading at that level, it names the levels that have headings: propose one of those.
   5. Write the rows and the `Not planned` list, following "The outline" and "Cutting rows" below.

   **An outline exists.**
   1. Run `card plan`. If it says the specification differs from `spec_blob`, show the user `git diff <spec_blob> HEAD:<spec path>`, with the value from the outline's front matter, and propose the rows the change calls for.
   2. Apply what the user asked for after the path.
   3. Only a row with no card file and no `card/<id>` branch may be changed or removed (`card list`, and `git branch -a --list "*card/<id>*"`). For any other row the card is what gets edited: say so and leave the row alone.
   4. The id of a removed row is never given to another row. A new row takes a number above every number the outline has had; `git log -p -- <outline>` shows the rows it had before.
   5. Run `card plan accept <PREFIX>`.

6. **Check the outline.** Run `card plan`. Fix what it reports and run it again, until it reports nothing for this outline.

7. **Review.** Launch the `workdeck:plan-reviewer` subagent with the outline's path and the base branch, and wait for it to finish. Fix every `must-fix` finding and run step 6 again. If a fix changed the outline, launch the reviewer once more: the outline the user approves must be one the reviewer has read. The reviewer runs at most twice each time before the user is asked. What the second run finds and you do not fix goes to the user in step 8. An outline the user edited in step 8 comes back here and is reviewed again under the same bound. Keep every finding of both runs, with what was done about it.

8. **Ask the user.** Show the outline as a table: id, size, dependencies as full ids, title, and the `does` lines. Under it, show:
   - the `Not planned` list;
   - each finding that was not fixed, with the reason;
   - each place where the specification can be read two ways, and which reading the rows follow;
   - each requirement that is in no row, with the reason.

   Ask for a yes, an edit or a no.
   - Yes: continue with step 9.
   - An edit: make it and go back to step 6.
   - No: delete the outline file if this run created it, or restore it with `git checkout -- <outline>` if it did not. Check out the base branch and stop.

9. **Commit and open the pull request.** Run `git status --porcelain` and confirm the outline is the only file that changed. If anything else changed, revert it first. Run `git add <outline>` and `git commit`. The subject is `plan: <PREFIX>, <n> rows`; the rest of the message follows the style the project's history uses. If the repository has no remote, stop here and tell the user what remains: merge the branch into the base branch, or add a remote, push and open a pull request. Print the body below for them. Otherwise run `git push -u origin <branch>`. Write the body to a file, run `gh pr create --base <base> --title "plan: <PREFIX>, <n> rows" --body-file <file>`, then delete the file so the tree stays clean. For a pull request resumed in step 2, do not open a second one: add what this run did to its body with `gh pr edit <number> --body-file <file>`. If `gh` is missing or not signed in, stop after the push and print the URL where the user can open the pull request by hand, and the body. The body has:
   - the rows, as a table of id, size, dependencies and title;
   - the `Not planned` list;
   - every reviewer finding of both runs, with what was done about it;
   - the readings chosen and the requirements left out, as shown in step 8;
   - the three figures `card tokens` prints;
   - for a run that revised an outline, what the user asked for or which change to the specification caused it.

   Do not copy the `does` and `not` lines into the body: the pull request changes one file, and its diff is those lines.

10. **Report** the pull request URL, or what remains to be done by hand, and stop. The session writes no card and no code: a row becomes a card when the user starts it with `/workdeck:next-card`, after the pull request is merged.

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

- `card plan new` writes the front matter and `card plan accept` updates `spec_blob`. Do not edit the front matter by hand.
- A row is a second-level heading, `## <id> <title>`, followed by items, whatever the outline's `level` is. The id is the prefix, a hyphen and digits, with no letter after them. The title is at most 80 characters.
- An item is `- <key>: <text>` on one line. `size` appears once. `depends` appears at most once and is a comma-separated list of ids. `spec` appears any number of times, each naming one heading of the specification at the outline's level, written as the specification writes it. `does` appears at least once. `not` appears any number of times. There is no other key.
- `## Not planned` lists the headings of the specification, at the outline's level, that produce no card. Leave the section out when nothing would be in it.
- Every heading of the specification at the outline's level is cited by a row or listed under `Not planned`. `card plan` reports one that is neither.

## Cutting rows

- **A row is one session's work.** The size is a guess at how much a session has to read and change: `XS`, `S` or `M`, whose budgets `card conf budget.XS`, `card conf budget.S` and `card conf budget.M` print. Work that would not fit `M` is two rows.
- **Plan only what the code does not do yet.** A heading whose work is already in the code produces no row and goes under `Not planned`. Where part of a heading is done, the row's `does` lines name only the part that is not. A heading goes under `Not planned` only when it asks for no work at all, or the code does all of it.
- **A `does` line is one statement about the product that is true or false when the card is finished.** "Token refresh works" is not one. "An expired token is refused with 401" is. Two statements are two lines, so that neither can be half true. A line that only says tests exist is not a statement about the product. Together, the `does` lines of all rows that cite a heading cover every requirement under it, and no requirement is in two rows.
- **A `not` line names what a reader might expect in this row, and the row that owns it.** Write one in each row wherever two rows cite the same heading, or a title promises more than the row does.
- **A dependency is written only where a row needs code that another row creates.** A dependency costs a wait, and one that is missing sends a session to code that is not there.
- **A row with no `spec` item** is allowed for work no single heading asks for, such as a migration or a CI job. The reviewer looks at each.
- **Where the specification can be read two ways,** choose one reading, write the rows for it, and keep a note of the place and the choice for step 8. Do the same for a requirement you put in no row.
- The writing of a card from a row happens later, in a session that has not seen this one. It has the row, the headings the row cites and the code. Write the row for that reader.
