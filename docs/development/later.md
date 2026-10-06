# Later

Ideas that came up while building 0.1 and are outside it. Nothing here is built.

- Remove old marker files from `<git-dir>/mergehand/`. They are empty and never cleaned up; cleaning would need `find`.
- `card show <id>` for a card that exists on the base branch but not in the working tree. `card list` shows it; `show` says there is no such card. In the skill flow the base branch is checked out first, so it only happens on a stale branch.
- A cache of open pull requests so `card status` can show `review` without `--fetch`.
- Run test cases in parallel. The suite takes about a minute on macOS, nearly all of it git process start-up.
- A single Go binary with the same commands, which would also lift the native Windows limit (spec section 3).
- A tests gate that matches the words of a `Tests` line within a window of lines, for nested test names (finding 1). Rejected for 0.1: it trades false failures for false passes.
- If the post-tool-use hook's 45 ms is ever felt (finding 6): let `card` skip `git rev-parse` when it is run from a directory that holds `.git` and `mergehand.conf`, and have the hook change to the root first. Needs no new interface. After that, an offset into the transcript.
- A first card written by init from a one-paragraph description (spec section 20, question 2).
- A card file renamed between the local and the remote base branch is looked up under both names.
- `card new` cuts the slug at 40 characters, mid-word. Cosmetic.
- Plugin eval cases for the skills. Cut from 0.1: `claude plugin eval` is built for skills the model chooses to invoke, and these four are typed by the user. Worth one probe case if the tool gains a way to run a typed skill.
- Rename commands for consistency (`card log`, `card config`, `card check scope`), keeping the old names as aliases; a man page, shell completions and `--json`.
