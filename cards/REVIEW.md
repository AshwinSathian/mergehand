# Review rules for this repository

The reviewer checks every rule here against the diff.

## Portability

- `bin/card` and `hooks/*.sh` run on bash 3.2: no associative arrays, `mapfile`, `readarray`, `${var,,}`, `local -n`, `;&`, `|&`, `&>>`.
- awk code avoids interval expressions (`{n}`), POSIX classes (`[[:alpha:]]`), `gensub` and `length(array)`: Ubuntu's awk is mawk and macOS ships the one true awk.
- No `sed -i`, `grep -P`, `readlink -f`, `stat`, jq, python or node. `gh` is used only for `--fetch`.

## Trust

- `workdeck.conf` and card content are never sourced or passed to `eval`.
- Every id is checked with `need_id` or `valid_id` before it reaches a branch name, a file name or a pattern.
- Text that reaches an agent's context (`card status`, hook output) carries front matter fields and one log section only, with control characters removed. No branch name other than the current one.

## Hooks

- A hook's first action is to exit 0 silently when the repository has no `workdeck.conf`.
- A hook exits 0 on any internal error. The stop hook's log guard is the only exit 2.
- A hook makes no network call.

## Conventions

- Error messages go to stderr, start with `card:` and name the file. Reports, including what a gate found, go to stdout. A usage error prints `usage:` and the command's arguments. Exit codes: 0 ok, 1 a check failed or nothing matched, 2 usage or configuration error.
- Each test builds its own temporary repository through `test/lib.sh` and touches neither the network nor the real `~/.claude`.
- `bin/card` stays one file.
- No reference to any other project, except in the "How it compares" section of `README.md`, and except where `docs/design-0.2.md` or a record under `docs/development/` names a specification format as an input the planner is run on.
