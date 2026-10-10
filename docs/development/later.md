# Later

Ideas that came up while building 0.1 and are outside it. Nothing here is built. "The spec" is [`../design.md`](../design.md).

- Remove old marker files from `<git-dir>/workdeck/`. They are empty and never cleaned up; cleaning would need `find`.
- `card show <id>` for a card that exists on the base branch but not in the working tree. `card list` shows it; `show` says there is no such card. In the skill flow the base branch is checked out first, so it only happens on a stale branch.
- A cache of open pull requests so `card status` can show `review` without `--fetch`.
- Run test cases in parallel. The suite takes about a minute on macOS, nearly all of it git process start-up.
- A single Go binary with the same commands, which would also lift the native Windows limit (spec section 3).
- A tests gate that matches the words of a `Tests` line within a window of lines, for nested test names (finding 1). Rejected for 0.1: it trades false failures for false passes.
- If the post-tool-use hook's 45 ms is ever felt (finding 6): let `card` skip `git rev-parse` when it is run from a directory that holds `.git` and `workdeck.conf`, and have the hook change to the root first. Needs no new interface. After that, an offset into the transcript.
- A first card written by init from a one-paragraph description (spec section 20, question 2).
- A card file renamed between the local and the remote base branch is looked up under both names.
- Plugin eval cases for the skills. Cut from 0.1: `claude plugin eval` is built for skills the model chooses to invoke, and these four are typed by the user. Worth one probe case if the tool gains a way to run a typed skill.
- Rename commands for consistency (`card log`, `card config`, `card check scope`), keeping the old names as aliases; a man page, shell completions and `--json`.
- An approval commit for a quick card, as 0.2 makes for a planned one (design-0.2 section 10.4). A quick card is new in its own pull request, so a file added to `Touch` after the user approved the card does not show in the diff.
- `test/run.sh` prints the `skip:` lines of a case that passes. Today a case that skips looks like one that ran: `test_plugin_validates_strictly` without Claude Code, and the comparison with `card` 0.1.3 in a clone without the tag (the eleventh pass of `review-0.2.md`).
- A second case for the comparison with `card` 0.1.3, on decks no 0.1 case builds: `status --fetch` with an open pull request, a card branch whose id is not in the deck, `status_max_chars` of 0 and at the length of its note, a log line of 200 characters, and `log_dir` set. Twenty mutations of `bin/card` pass the suite there.
- `card plan` applies the title rules of a card to a row: a title that starts with a quote, `[` or `{`, or is a multi-line marker, passes `card plan` today and is refused by `card plan start` (the twelfth pass of `review-0.2.md`). The same for a `depends` that ends in a comma, which `card plan` rejects and `card plan start` accepts.
- Cases for `card new` that no test has: a title of 80 and of 81 characters, and one that starts with `'`.
- Read file names from git with `-z`, in `diff_files` and in `card plan check` together. Today a name that git quotes, one with a `"`, a backslash or a control character, matches no `Touch` entry in `card touched` or in `card plan check`, and an entry that starts with a quote can match the quoted line (the thirteenth pass of `review-0.2.md`). Changing one of the two would make the check disagree with the gate it predicts.
- `section_items` on a card file that cannot be read prints awk's own message. `card plan check` tests for it first; `card touched`, `card tests` and `card show` do not.
- The stop hook in a shallow clone whose boundary commit is on the card branch: that commit is compared with the empty tree, so a card-only commit there is counted and the turn is blocked (the fourteenth pass of `review-0.2.md`). 0.1.3 blocks there too.
