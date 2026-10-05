# Evidence

What has been measured, where the numbers come from, and what has not been shown. Each item can be checked.

## Tests

`make test` runs more than 300 cases in about a minute. They cover every `card` command, every lint rule, every card state (with a local bare repository as the remote and a stub `gh`), the token parser against fixture transcripts, and each hook with fixture input. `make lint` is shellcheck with no findings. On macOS the suite runs under bash 3.2. CI repeats it on Ubuntu with `awk` as mawk and as gawk.

One case, `test_runner_reports_failure`, checks that the test runner itself reports a failing case and a case file that does not parse, so a broken assertion helper cannot make everything pass.

## Context growth, measured in a real session

The card in `examples/hello-deck/` was run through `/workdeck:next-card` and `/workdeck:handoff` in a scratch repository with only this plugin loaded:

| | Tokens |
|---|---|
| Context at the first turn (baseline) | 36,917 |
| Largest context in the session (peak) | 40,334 |
| Growth | 3,417 |
| Budget for an XS card | 35,000 |

The session did not compact. This run is also what showed that the reviewer agent launches under its plugin name, and that the session-start hook passes the transcript path to later commands (`development/findings.md`, finding 10).

## What the repository's own logs do not show

Workdeck 0.1 was built card by card: each card on its own branch, through `card lint`, `card touched` and `card tests`, with a session log. But the cards were driven by hand inside one long agent session, without the plugin loaded, so the seventeen logs from the build record `unknown` for the token fields and `card stats` has nothing to summarize for them. One session's growth does not describe any single card, and writing it into each log would have been false.

Logs written after the first release, by sessions that run a card through the plugin, carry real figures.

## Cost of the hooks

`make bench` measures the post-tool-use hook, which runs after every tool call. On an Apple silicon Mac, 50 runs per path:

| Path | Median | 95th percentile |
|---|---|---|
| Not a Workdeck project | 2 ms | 2 ms |
| Workdeck project, not on a card branch | 2 ms | 2 ms |
| Card branch, warning already given | 4 ms | 5 ms |
| Card branch, under budget, 2 MB transcript | 45 ms | 51 ms |
| Card branch, under budget, 20 MB transcript | 127 ms | 151 ms |

A project that does not use Workdeck pays 2 ms per tool call for having the plugin enabled.

## What the gates catch, and what they miss

`examples/hello-deck/README.md` shows both gates failing on a real change and what resolves each.

The tests gate is a check that a name is present, nothing more. Tried on sixteen test declarations in Go, Python, TypeScript and Rust, it was right on seven, gave seven false failures (a name split across a `describe` block, a class, a module or a line break, or reworded by one small word) and passed two it should not have (a one-word line, and a name that appeared only in a comment). The table is in `development/findings.md`, finding 1, and each row is a test in `test/cases/33-tests.sh`.

## Not yet shown

- The pull request path against a real host: `git push`, `gh pr create`, and the `review` state. Tests use a stub `gh`.
- A handoff under the permission entries that init writes.
- Any session that compacted.
