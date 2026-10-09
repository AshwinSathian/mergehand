# Reference

Every `card` command, the card states and the configuration keys. The [README](../README.md) covers the card format, the skills and the hooks.

## The `card` command

This is the output of `card --help`:

```
usage: card <command> [arguments]

  next [--fetch]            print the first ready card
  show <id>                 print one card
  list [--fetch]            one line per card: state, id, size, title
  status [--fetch]          current card, open work, next ready card
  new <id> <title> [--size XS|S|M] [--depends ID,ID]
                            create a card file
  done <id>                 set done: true in the card file
  lint                      check every card and log file
  touched <id>              compare changed files with the card's Touch list
  tests <id>                check that each Tests line names a test that exists
  tokens [transcript]       baseline, peak and growth for a session transcript
  log-new <id> <outcome>    create a session log entry
  stats                     growth per card size across session logs
  plan                      check every outline in <cards_dir>/plan
  plan new <spec path> <PREFIX> [--level N]
                            create an outline with no rows
  plan accept <PREFIX>      set spec_blob to the specification's hash
  conf <key>                print one configuration value
  help, version

--fetch runs git fetch --prune and reads open pull requests with gh first.
card <command> --help prints that command's arguments.
Reports go to stdout; errors go to stderr and start with "card:".
Exit codes: 0 ok; 1 a check failed or nothing matched; 2 usage or
configuration error.
```

Nothing in `card` uses the network except `--fetch`. `card new` gives a card size `S` when `--size` is left out. `card plan new` takes the specification's path from the root of the repository, whatever directory it is run in. The outcome for `card log-new` is `done`, `split`, `blocked` or `review-fixes`.

## Card states

`card` works out each card's state when asked. Only `done` is stored in the file.

| State | Means |
|---|---|
| `done` | `done: true` on the base branch, local or remote |
| `review` | an open pull request from the card's branch (needs `--fetch`) |
| `blocked` | the card's branch exists and the card has a `## Blocked` section |
| `active` | the card's branch exists |
| `ready` | no branch, and every dependency is done |
| `waiting` | no branch, and a dependency is not done |

A card's branch is `card/<id>` or `card/<id>-<slug>`. Deleting the branch releases the card.

## Configuration

`workdeck.conf` is `key = value` lines. It is parsed, never run.

| Key | Default | Meaning |
|---|---|---|
| `version` | `1` | Format version of the config, card and log files |
| `check` | required | Command that must pass before handoff |
| `base` | `main` | Branch that cards start from and pull requests target |
| `cards_dir` | `cards` | Where card files are |
| `log_dir` | `log` | Where session logs are. It must differ from `cards_dir` |
| `budget.XS` | `35000` | Context growth, in tokens, allowed for an XS card |
| `budget.S` | `70000` | The same for S |
| `budget.M` | `100000` | The same for M |
| `touch_ignore` | empty | Comma-separated patterns the scope gate ignores, such as lockfiles |
| `status_max_chars` | `6000` | Cap on the status text shown at session start, at most 10000 |
| `reviewer` | `on` | `off` skips the reviewer for XS cards only |

Add a size by adding a budget: `budget.L = 150000`.

A budget limits growth: the largest context size in the session minus its size at the first turn. The first turn already holds the system prompt, tool definitions and plugins, and that differs between machines, so an absolute limit would mean something different for everyone. `card stats` shows the growth your own sessions had, per size, so you can set budgets from your own numbers.

The XS default may be low for a session that carries other plugins. The one measured session of that kind used 25,982 of the 35,000 tokens on a card that added a license file; see [`evidence.md`](evidence.md).
