# Evidence

What has been measured, where the numbers come from, and what has not been shown. Each item can be checked.

## Tests

`make test` runs more than 300 cases in about a minute. They cover every `card` command, every lint rule, every card state (with a local bare repository as the remote and a stub `gh`), the token parser against fixture transcripts, and each hook with fixture input. `make lint` is shellcheck with no findings. On macOS the suite runs under bash 3.2. CI repeats it on Ubuntu with `awk` as mawk and as gawk.

One case, `test_runner_reports_failure`, checks that the test runner itself reports a failing case and a case file that does not parse, so a broken assertion helper cannot make everything pass.

## A card through the whole loop, against the hosted repository

Card DOC-02 (add the license, size XS) was run by the maintainer with the plugin loaded: `/mergehand:next-card DOC-02`, then `/mergehand:handoff`. The result is [pull request 1](https://github.com/AshwinSathian/mergehand/pull/1) and the log `log/2026-10-06-DOC-02-1.md`.

| | Tokens |
|---|---|
| Context at the first turn (baseline) | 53,055 |
| Largest context in the session (peak) | 79,037 |
| Growth | 25,982 |
| Budget for an XS card | 35,000 |

The session did not compact. What this run showed that no shell test can:

- Handoff ran the check, the three gates and the reviewer, wrote the log with figures taken from the transcript, committed, pushed the branch and opened the pull request with the card, the changes, the tests, the review and the token figures in its body.
- CI ran on the pull request and passed on macOS and Ubuntu before the merge.
- The scope gate failed on real work: the card needed `README.md` and `bin/card`, which it did not list, and both were added to its `Touch` list in the same pull request.
- The reviewer found nothing that had to be fixed and left five small notes, which are in the pull request body.

The baseline is 16,138 tokens higher than in the scratch run below, because this session had the maintainer's other plugins loaded as well. That difference is why a budget limits growth and not total size. The growth also includes a first attempt in the same session that the permission mode refused, so 25,982 overstates what the card alone needed. It is still three quarters of the XS budget for a card that adds a license file, which suggests the XS default is on the tight side once a session carries other plugins.

## Context growth with only this plugin loaded

Before that, the card in `examples/hello-deck/` was run through `/mergehand:next-card` and `/mergehand:handoff` in a scratch repository with only this plugin loaded:

| | Tokens |
|---|---|
| Context at the first turn (baseline) | 36,917 |
| Largest context in the session (peak) | 40,334 |
| Growth | 3,417 |
| Budget for an XS card | 35,000 |

The session did not compact. This run is also what showed that the reviewer agent launches under its plugin name, and that the session-start hook passes the transcript path to later commands ([`development/findings.md`](development/findings.md), finding 10).

## A quick card in a new repository, installed from the marketplace

On 2026-10-06 the maintainer installed 0.1.1 with `/plugin marketplace add AshwinSathian/mergehand` in a new private repository holding one shell function and a `test.sh`. `/mergehand:init`, `/mergehand:quick` and `/mergehand:handoff` followed, in that order. The repository is private, so the figures below are from its session log and cannot be checked from outside.

| | Tokens |
|---|---|
| Context at the first turn (baseline) | 53,350 |
| Largest context in the session (peak) | 68,465 |
| Growth | 15,115 |
| Budget for an XS card | 35,000 |

The session did not compact. Its baseline is within 300 tokens of the DOC-02 session's, which had the maintainer's other plugins loaded. What the run showed:

- Init wrote `mergehand.conf`, `cards/REVIEW.md`, the pull request template, the permission entries, the project settings that turn the plugin on, and the CI workflow. The workflow downloaded `card` at `v0.1.1` and its `lint` job passed on the pull request.
- Handoff ran the check, the gates and the reviewer, and opened the pull request. With it open, `card list --fetch` printed `review` for the card. After the maintainer merged it and pulled, `card list` printed `done`.
- The reviewer left one nit and nothing to fix.

Two things went wrong, and both are in the card's log under Deviations. Quick wrote the `Touch` entries as bare lines, which are not items, so the scope gate did not match them until they were rewritten with `- ` ([`development/findings.md`](development/findings.md), finding 16). The `Tests` line also had to be reworded to match the name the test ended up with.

## What the repository's own logs do not show

Mergehand 0.1 was built card by card: each card on its own branch, through `card lint`, `card touched` and `card tests`, with a session log. All the cards before DOC-02, and E-01 after it, were driven by hand inside one long agent session without the plugin loaded. Their logs record `unknown` for the token fields. One session's growth does not describe any single card, and writing it into each log would have been false. `card stats` says so itself: it prints how many sessions have no measurement.

Logs from sessions that run a card through the plugin carry real figures. DOC-02 is the first.

## Cost of the hooks

`make bench` measures the post-tool-use hook, which runs after every tool call. On an Apple silicon Mac, 50 runs per path:

| Path | Median | 95th percentile |
|---|---|---|
| Not a Mergehand project | 2 ms | 2 ms |
| Mergehand project, not on a card branch | 2 ms | 2 ms |
| Card branch, warning already given | 4 ms | 5 ms |
| Card branch, under budget, 2 MB transcript | 45 ms | 51 ms |
| Card branch, under budget, 20 MB transcript | 127 ms | 151 ms |

A project that does not use Mergehand pays 2 ms per tool call for having the plugin enabled.

## What the gates catch, and what they miss

[`examples/hello-deck/README.md`](../examples/hello-deck/README.md) shows both gates failing on a real change and what resolves each.

The tests gate checks only that a name is present. Tried on sixteen test declarations in Go, Python, TypeScript and Rust, it was right on seven. It gave seven false failures: a name split across a `describe` block, a class, a module or a line break, or reworded by one small word. It passed two it should not have: a one-word line, and a name that appeared only in a comment. The table is in `development/findings.md`, finding 1, and each row is a test in `test/cases/33-tests.sh`.

## Not yet shown

- `/mergehand:init` in someone else's repository. The run above was the maintainer's.
- The `review` state for a card that is on the base branch. It was seen for a card that exists only on its branch: with [pull request 2](https://github.com/AshwinSathian/mergehand/pull/2) open, `card list --fetch` printed `review   E-01`.
- A handoff under exactly the permission entries that init writes. The DOC-02 session ran under the maintainer's own settings. The quick-card session had init's entries, but the maintainer's own settings applied too and the prompts it raised were not recorded.
- Any session that compacted.
