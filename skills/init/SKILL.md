---
name: init
description: Set up Workdeck in this repository. Writes workdeck.conf, the cards and log directories, review rules, a pull request template, a CLAUDE.md section and permission entries. Asks before each choice and commits nothing.
disable-model-invocation: true
---

# Set up Workdeck in this repository

The files you copy are in `${CLAUDE_PLUGIN_ROOT}/templates/`. Never overwrite a file that exists: show the user what you would add and merge it in. Do not commit anything; the user reviews and commits the result.

Work through these steps in order.

1. **Already set up?** If `workdeck.conf` exists at the repository root, say so and stop. If this is not a git repository, say that Workdeck needs one and stop.

2. **Find the check command and the base branch, then confirm both with the user.**
   - Check command: look for the project's own entry point, in this order: a `check` or `test` target in a `Makefile`; a `test` script in `package.json`; `cargo test` for `Cargo.toml`; `go test ./...` for `go.mod`; `pytest` for a Python project with tests. It must be one command that exits non-zero on failure.
   - Base branch: `git symbolic-ref --short refs/remotes/origin/HEAD` without the `origin/` prefix, or the current branch when there is no remote.
   - Show both and ask the user to confirm or correct them. The check command will run whatever it says, with the same trust as a Makefile.

3. **Write the project files.**
   - `workdeck.conf` from `templates/workdeck.conf`, with `<check>` and `<base>` replaced by the confirmed values.
   - `cards/REVIEW.md` from `templates/REVIEW.md`. It has headings only; the project fills in its own rules.
   - The `cards/` and `log/` directories. Put an empty `.gitkeep` in `log/` so git keeps it.
   - `.github/pull_request_template.md` from `templates/pull_request_template.md`, only if the project has no pull request template anywhere (`.github/`, `docs/` or the root, any letter case).

4. **Add the session protocol to `CLAUDE.md`.** Append the content of `templates/claude-md-section.md`, creating `CLAUDE.md` if needed. If the file already has a `## Workdeck session protocol` heading, leave it alone.

5. **Permission entries.** Take `templates/settings-permissions.json` and replace `<check>` with the check command. Show the user the entries as a diff against `.claude/settings.json` (create the file if needed, keep everything already in it, add only entries that are missing). Merge them in when the user approves. Tell the user plainly: the deny rules match commands as written and are not a security boundary, so the base branch should also be protected on the git host.

6. **Offer the CI workflow.** It runs `card lint` on pull requests. Copy `templates/workdeck.yml` to `.github/workflows/workdeck.yml` and replace `<tag>` with `v` plus the `version` in `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`, and `<repo>` with the `owner/repo` the plugin was installed from (the `repository` field of that file if it has one; otherwise ask the user). If the repository is not known, skip this step and say why.

7. **Offer to share the plugin with teammates.** With the user's approval, add to `.claude/settings.json`, using the same `owner/repo`:

   ```json
   {
     "extraKnownMarketplaces": {
       "workdeck": { "source": { "source": "github", "repo": "<owner>/<repo>" } }
     },
     "enabledPlugins": { "workdeck@workdeck": true }
   }
   ```

   People who open the repository then get the marketplace and the plugin from the project settings.

8. **Say what is next.** List the files written and changed, remind the user that nothing is committed, and give the next step: write a card with `card new <id> "<title>"` and fill in its sections, or type `/workdeck:quick "<description>"` for a small change. Workdeck 0.1 runs cards; it does not write them from a specification.
