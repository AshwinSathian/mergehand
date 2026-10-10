# Reference

Every `card` command, the card states, the outline format and the configuration keys. The [README](../README.md) covers the card format, the skills and the hooks.

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
  plan start <id>           create the card file for a row
  plan check <id>           check a card's paths against the working tree
  conf <key>                print one configuration value
  help, version

--fetch runs git fetch --prune and reads open pull requests with gh first.
card <command> --help prints that command's arguments.
Reports go to stdout; errors go to stderr and start with "card:".
Exit codes: 0 ok; 1 a check failed or nothing matched; 2 usage or
configuration error.
```

Nothing in `card` uses the network except `--fetch`. `card new` gives a card size `S` when `--size` is left out. The outcome for `card log-new` is `done`, `split`, `blocked` or `review-fixes`.

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

A row with no card file has the same states. It is a row of an outline whose id has no card file on the base branch or in the working tree, and it counts as a card with the row's title, size and dependencies. `card list` and `card next` print `[row]` after its title. `card show <id>` prints `row: no card file yet` and then the row as the outline has it. Once the card file exists, the row's fields are ignored and the card's are used.

One rule differs for a row, the remainder rule. A row is `ready` only when each dependency is done and every card whose id is that dependency's id plus a letter is done too. A split leaves the original card `done` and its unfinished part in `<id>b`, and a second split puts what is left in `<id>c`. So a row that depends on `AUTH-01` waits for `AUTH-01b` as well, and a row that depends on `AUTH-01b` waits for `AUTH-01c`. A card that has a file keeps the rule of the table.

## `card plan`

`card plan` and its four forms read and write outlines. An outline is one file per specification, in `<cards_dir>/plan`; its format is the next section. `card lint` does not read outlines, and no gate runs any of these commands. Every form exits 2 on a usage error: a missing argument, a prefix that does not match `[A-Z][A-Z0-9]*` or is longer than 30 characters, an id that is not a card id, or a `--level` that is not a digit from 1 to 6.

| Command | What it does | Exit codes |
|---|---|---|
| `card plan` | Checks every outline: its format, the ids, the sizes, the dependencies, the specification file and the coverage of its headings. On a `plan/*` branch it also checks that no file other than an outline differs from the point where the branch left the base branch. It prints each failure with the file. When a specification differs from `spec_blob` it prints one line that names the outline, and that is not a failure | Exit 0 when nothing failed, and when there is no outline, which it says in one line. Exit 1 on any failure. Exit 2 on a `plan/*` branch where there is no base branch, or none that shares history with it |
| `card plan new <spec path> <PREFIX> [--level N]` | Creates the outline `<cards_dir>/plan/<prefix in lowercase>.md` with its front matter filled in and no rows, and prints its path. The specification's path is taken from the root of the repository, whatever directory the command is run in. `--level` is the heading level at which the specification's sections sit, 2 when left out | Exit 0 when the file was created. Exit 1 when the prefix is one that an outline or a card already uses, or is `Q`; when the file exists; when the path has a character other than a letter, a digit, `.`, `_`, `-` or `/`, or a `..` or `./` segment; when the specification is missing, not a regular file, unreadable or not tracked; when it has no heading at that level, with the levels that have headings named; and when `<cards_dir>/plan` is a symbolic link |
| `card plan accept <PREFIX>` | Sets `spec_blob` in that prefix's outline to the hash of the specification as it is now, and changes no other byte of the file | Exit 0 when the line was set. Exit 1 when the working tree has no outline for the prefix, when its front matter has no `spec_blob` line, when its `spec` is not a tracked, regular file inside the repository, and when `<cards_dir>/plan` is a symbolic link. Exit 2 when the file cannot be written |
| `card plan start <id>` | Creates the card file for a row and prints its path. The front matter comes from the row's id, title, size and dependencies. `Read` gets one item, the specification's path with the comment `(row <id>: <heading>; <heading>)`, or `(row <id>)` for a row with no `spec` item. `Acceptance` gets the row's `does` lines and `Out of scope` its `not` lines. `Touch` and `Tests` are empty. It does not look at the row's state | Exit 0 when the file was created. Exit 1 when no row has the id, when the id already has a card file, when the row is in an outline with a format fault, and when the row has a title, a size or dependencies that a card cannot have. Exit 2 when the file cannot be written |
| `card plan check <id>` | Checks one card, planned or written by hand, against the working tree. Each `Read` entry names a file or directory, by a path that is not absolute and has no `..`. Each `Touch` entry not marked `(new)` matches at least one file that git does not ignore. Each `Touch` entry marked `(new)` is a full path, with no pattern character, at which nothing exists. `Out of scope` has an item. These stop being true as soon as the work starts, so run it once, when the card is written | Exit 0 when every rule holds. Exit 1 with one line per failure, and when the id has no card file. Exit 2 when the card file cannot be read or git cannot list the files |

## Outline format

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

The front matter is flat `key: value` lines, as in a card. `card plan new` writes it and `card plan accept` updates `spec_blob`.

| Key | Meaning |
|---|---|
| `spec` | Path of the specification from the root of the repository: letters, digits, `.`, `_`, `-` and `/` only, with no `..` and no `./` segment |
| `spec_blob` | What `git hash-object` prints for that file when the outline was written or last accepted |
| `prefix` | The prefix of every row's id. It matches `[A-Z][A-Z0-9]*` and is not `Q`, which the quick lane uses. The file's name is the prefix in lowercase |
| `level` | A digit from 1 to 6: the heading level at which the specification's sections sit |

A row is a second-level heading, `## <id> <title>`, followed by items, whatever the outline's `level` is. The id is the prefix, a hyphen and digits, with no letter after them. The title follows the rules of a card title. An item is `- <key>: <text>` on one line, and any key not in this table is an error.

| Row key | How often | Meaning |
|---|---|---|
| `size` | Once | A size that has a budget |
| `depends` | At most once | A comma-separated list of ids, of rows or of cards |
| `spec` | Any number of times | One heading of the specification at the outline's level. A row with none is allowed, for work no single heading asks for |
| `does` | At least once | A statement that is true or false when the card is finished |
| `not` | Any number of times | What a reader might expect in this row, and the row that owns it |

`## Not planned` lists the headings of the specification, at the outline's level, that produce no card. The section may be left out when nothing would be in it. Every heading at that level is cited by a row or listed there, and `card plan` reports one that is neither.

A heading is compared by its letters and digits only, with case ignored. Only `#` headings count, and a `#` line inside a code fence is not one.

The id of a removed row is never used again: a new row takes a number above every number the outline has had.

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
