# Later

Ideas that came up while building 0.1 and are outside it. Nothing here is built.

- Remove old marker files from `<git-dir>/workdeck/`. They are empty and never cleaned up.
- `card show <id>` for a card that exists on the base branch but not in the working tree. `card list` shows it; `show` says there is no such card.
- A cache of open pull requests so `card status` can show `review` without `--fetch`.
- Run test cases in parallel. The suite takes about 50 seconds on macOS, nearly all of it git process start-up.
- A single Go binary with the same commands, which would also lift the native Windows limit (spec section 3).
- A tests gate that matches the words of a `Tests` line within a window of lines, for nested test names (see `docs/findings.md`, finding 1).
- Treat a `Touch` entry ending in `/` as a directory (finding 2).
- Show which cards have a branch with no recent commits, so abandoned branches are noticed (finding 3).
- A first card written by init from a one-paragraph description (spec section 20, question 2).
- Read `done` from the local base branch when it is ahead of `origin/<base>` (finding 3).
