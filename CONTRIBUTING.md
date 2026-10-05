# Contributing

## Run the tests

```
make test          # the whole suite, about a minute
make lint          # shellcheck
/bin/bash test/run.sh lint tokens     # only the cases whose name contains a word
```

You need bash, git, awk, sed, grep and sort. `make lint` needs [shellcheck](https://www.shellcheck.net/). On macOS the suite runs under `/bin/bash`, which is 3.2, so a bash 4 feature fails there.

There is no test framework. `test/run.sh` runs every function named `test_*` in `test/cases/*.sh`, each in its own bash process. `test/lib.sh` gives each case a temporary git repository, a stub `gh`, and a few assertions. A case never touches the network or your real `~/.claude`.

Case files are numbered by area:

| Files | Area |
|---|---|
| `00` to `02` | the harness itself, portability, the plugin's files |
| `10` to `14` | reading: config, cards, lint, list |
| `20` to `23` | state: base branch, branches, `--fetch`, status |
| `30` to `34` | writing and the gates: new, done, touched, tests, logs |
| `40`, `41` | token measurement and stats |
| `50` to `53` | the four hooks |
| `60` | the skills' mechanics |

Write the test first and watch it fail.

## Rules the code keeps

These are checked in review; the full list is in `cards/REVIEW.md`.

- `bin/card` stays one file and runs on bash 3.2: no associative arrays, `mapfile`, `${var,,}` or `local -n`.
- awk code must work in mawk, gawk and the awk on macOS: no interval expressions, no POSIX classes, no `gensub`.
- No `sed -i`, no `grep -P`, no jq, python or node.
- Nothing from `workdeck.conf` or a card file is ever sourced or evaluated.
- A hook exits 0 at once without `workdeck.conf`, and exits 0 on any internal error.

## How this repository is worked on

Workdeck is developed with itself. Work is a card in `cards/`, done on a branch named `card/<id>-<slug>`, and handed off with a session log in `log/`. `card list` shows the deck. If you would rather send a plain pull request, that is fine: say what it changes and how you tested it.

Design notes are in `docs/`. `docs/development/findings.md` records what went wrong while building and what was decided about it.
