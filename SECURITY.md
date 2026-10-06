# Security

## Reporting a problem

Please report a vulnerability privately through GitHub: on the repository page, open **Security**, then **Report a vulnerability**. Do not open a public issue for it. You should get a reply within a week.

## What Mergehand runs on your machine

Mergehand is a Claude Code plugin. While it is enabled it runs four hooks, in every project:

| Hook | When | What it does |
|---|---|---|
| `session-start.sh` | A session starts | Prints `card status` into the session and writes the transcript path and session id to `CLAUDE_ENV_FILE` |
| `post-tool-use.sh` | After every tool call | On a `card/` branch, measures context growth and prints one warning per session |
| `stop.sh` | A turn ends | On a `card/` branch with commits, a clean tree and no session log, blocks the end of the turn |
| `pre-compact.sh` | Before compaction | Writes an empty marker file under the git directory |

In a repository with no `mergehand.conf`, each hook exits at once and prints nothing. No hook makes a network call. In `card`, the only network access is `--fetch`, which runs `git fetch --prune` and `gh pr list`. The skills also use the network when you type them: next-card and quick pull the base branch, next-card reads your open pull requests with `gh`, and handoff pushes the card branch and opens the pull request with `gh`.

The `card` command is one bash file, `bin/card`. Read it before you trust it.

## What Mergehand trusts, and what it does not

Cards, session logs and `mergehand.conf` are files in your repository. In a shared repository they can arrive in someone else's pull request, and part of them is shown to the agent when a session starts. So:

- `mergehand.conf` and card files are parsed as text. They are never sourced or passed to `eval`.
- Every card id is checked against a fixed pattern before it is used in a file name, a branch name or a search pattern.
- `Touch` entries are used only as match patterns. Nothing in them is run.
- Directory settings must be relative paths inside the repository, and the base branch must be a plain branch name.
- `card status`, which the session-start hook prints into the agent's context, shows front matter fields and one section of one log, with control characters removed and a size cap. It prints a size only if it looks like a size, a dependency only if it is a valid id, and never the name of a branch other than the current one.

What Mergehand does trust:

- **The `check` command.** It is whatever `mergehand.conf` says and runs with your permissions, like a Makefile target. Review a change to it as you would review a change to a build script.
- **The agent.** The reviewer agent is told to be read-only; it still has a shell. Mergehand's gates check scope and test names, not intent.

## The permission entries are not a sandbox

`/mergehand:init` offers allow and deny rules for `.claude/settings.json`. The deny rules stop the forms of `git push --force`, branch deletion, `git reset --hard` and `gh pr merge` that an agent normally writes. Claude Code matches these rules against the command text, so a command written another way (`git -C . push ...`) is not matched. Protect your base branch on the git host: require pull requests and block force pushes there.

## Supported versions

Only the latest release gets fixes.
