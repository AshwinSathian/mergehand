# hello-deck: a two-card example

A tiny project set up the way `/workdeck:init` leaves one, with two cards. The first is done and has a session log; the second is ready. Copy the directory somewhere, run `git init` and commit, and every command below gives the output shown.

```
workdeck.conf                        check = sh test.sh, base = main
cards/GREET-01-fix-the-greeting.md   done
cards/GREET-02-add-a-farewell.md     ready, depends on GREET-01
log/2026-10-05-GREET-01-1.md         the session that did GREET-01
src/greet.sh  tests/greet.sh  test.sh
```

## The deck

```
$ card list
done     GREET-01     XS  Fix the greeting
ready    GREET-02     XS  Add a farewell

$ card next
GREET-02 XS Add a farewell
```

`GREET-02` is ready because the card it depends on is done on the base branch. Nothing but `done` is stored: the other states come from branches and pull requests.

## A card

`cards/GREET-02-add-a-farewell.md` is the whole contract for one session: what to read, which files may change, which tests must exist, and what must be true at the end.

## A session log

`log/2026-10-05-GREET-01-1.md` was written at handoff. The token fields are filled in by `card log-new` from the session transcript, not by the agent. These figures are from a real run of this card through `/workdeck:next-card` and `/workdeck:handoff`: the session started at 36,917 tokens of context and peaked at 40,334, so it grew by 3,417 against an XS budget of 35,000.

```
$ card stats
size   sessions   budget   median      max compacted
XS            1    35000     3417     3417        0%
S             0    70000        -        -         -
M             0   100000        -        -         -
```

## The gates catching something

Start the second card and make two mistakes: add the function without its test, and edit a file the card does not list.

```
git checkout -b card/GREET-02-add-a-farewell
printf 'bye() { echo "goodbye $1"; }\n' >> src/greet.sh
echo '# also tidied' >> test.sh
```

```
$ card status
Workdeck: on card/GREET-02-add-a-farewell: GREET-02 XS Add a farewell (active)
In progress:
  active   GREET-02     XS  Add a farewell
Next ready: none

$ card touched GREET-02
in Touch but not changed:
  tests/greet.sh
changed but not in Touch (revert it, or add it to Touch with a reason):
  test.sh

(exit 1)

$ card tests GREET-02
no test with this name on one line of the files changed (nested names are not joined: use the innermost name, or edit the card line):
  farewell says goodbye with the name

(exit 1)
```

The scope gate found `test.sh`, which the card does not list. There are two ways out, and both are visible to whoever reviews the pull request: revert the change, or add `test.sh` to the card's `Touch` list with a reason. The tests gate found that no test named for the card's `Tests` line exists yet. Add a test whose name contains `farewell says goodbye with the name` and both gates pass.
