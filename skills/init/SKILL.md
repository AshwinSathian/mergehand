---
name: init
description: Set up WorkDeck in this repository. Writes workdeck.conf, the cards and log directories, review rules, a pull request template, a CLAUDE.md section and permission entries. On a repository that is already set up, offers what it lacks. Asks before each choice and commits nothing.
disable-model-invocation: true
---

# Set up WorkDeck in this repository

The files you copy are in `${CLAUDE_PLUGIN_ROOT}/templates/`. Never overwrite a file that exists: show the user what you would add and merge it in. There is one exception: the protocol section of `CLAUDE.md` is replaced after the user has seen the difference and said yes. Do not commit anything; the user reviews and commits the result.

Work through these steps in order.

1. **Already set up?** If this is not a git repository, say that WorkDeck needs one and stop. If `workdeck.conf` exists at the repository root, say so and continue: skip steps 2 to 9 and do the four steps under "A repository that is already set up" below. Otherwise do steps 2 to 10.

2. **Find the check command and the base branch, then confirm both with the user.**
   - Check command: look for the project's own entry point, in this order: a `check` or `test` target in a `Makefile`; a `test` script in `package.json`; `cargo test` for `Cargo.toml`; `go test ./...` for `go.mod`; `pytest` for a Python project with tests. It must be one command that exits non-zero on failure.
   - Base branch: `git symbolic-ref --short refs/remotes/origin/HEAD` without the `origin/` prefix, or the current branch when there is no remote.
   - Show both and ask the user to confirm or correct them. The check command will run whatever it says, with the same trust as a Makefile.

3. **Write the project files.**
   - `workdeck.conf` from `templates/workdeck.conf`, with `<check>` and `<base>` replaced by the confirmed values.
   - `cards/REVIEW.md` from `templates/REVIEW.md`. It has headings only; the project fills in its own rules.
   - Nothing for `log/`: the first `card log-new` creates it. But run `git check-ignore -q log`; if it succeeds, the project ignores `log/` and session logs would never be committed. In that case add `log_dir = cards/log` to `workdeck.conf` and tell the user why.
   - `.github/pull_request_template.md` from `templates/pull_request_template.md`, only if the project has no pull request template anywhere (`.github/`, `docs/` or the root, any letter case).

4. **Add the session protocol to `CLAUDE.md`.** Append the content of `templates/claude-md-section.md`, creating `CLAUDE.md` if needed. If the file already has a `## WorkDeck session protocol` heading, leave it alone. The template names the default directories. Where `card conf cards_dir` prints something other than `cards`, write that directory in place of `cards` in `cards/` and `cards/plan/`, and where `card conf log_dir` prints something other than `log`, write it in place of `log` in `log/`.

5. **Permission entries.** Take `templates/settings-permissions.json` and replace `<check>` with the check command. Show the user the entries as a diff against `.claude/settings.json` (create the file if needed, keep everything already in it, add only entries that are missing). Merge them in when the user approves. Tell the user plainly: the deny rules match commands as written and are not a security boundary, so the base branch should also be protected on the git host. If the template or `.claude/settings.json` does not parse as JSON, name the file, write nothing to the settings file and go on to the next step. A template that does not parse is a fault in the plugin, for the user to report. A settings file that does not parse is the user's to repair, and `/workdeck:init` typed again offers the entries then.

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

   Each teammate then runs `claude plugin install <plugin>@<marketplace> --scope project` once; the project settings turn the plugin on for them.

8. **Offer `touch_ignore` entries.** These are files that many cards change and that belong to no card's scope. Run `git ls-files -- '*package-lock.json' '*yarn.lock' '*pnpm-lock.yaml' '*Cargo.lock' '*go.sum' '*.snap'` for tracked lockfiles and snapshots at any depth, and `git ls-files -- '*.gitattributes'` for the attribute files, in which you look for patterns marked `linguist-generated` that match a tracked file. A pattern with `-linguist-generated` or `linguist-generated=false` is not marked. Leave out what `card conf touch_ignore` already covers. If nothing is left, say so and go on. Otherwise show the list and ask which to add. An entry is a shell pattern matched against the whole path: `*.snap` matches at any depth and a bare `go.sum` only at the root, so write a file below the root by its full path. Add the approved entries, separated by commas, to the `touch_ignore` line of `workdeck.conf`. If the file has such a line, add to it and never write a second one: `card` reads only one. If it has only the commented default, write one new line below it. Then run `card conf touch_ignore` and check that it prints every entry.

9. **Offer review rules.** The file is `REVIEW.md` in the cards directory, which `card conf cards_dir` prints. Read `CLAUDE.md`, the contributing guide, the linter configuration and the CI workflows, those the project has. Propose at most ten rules. Each rule is one sentence that a reviewer can check against a diff, and each is shown with the file it was taken from. "Follow best practices" cannot be checked against a diff; "No `console.log` in `src/`" can. Do not propose a rule the file already has, and with nothing to propose, say so and go on. Show the list and ask which to add. Add the approved ones as list items under the existing heading that fits best, without the name of the file they came from, and add no heading. Leave the rules already in the file as they are.

10. **Say what is next.** List the files written and changed. Nothing is committed, and the next skill stops on a dirty tree, so tell the user to review and commit these files on the base branch before the next command, and to push if the repository has a remote. Then give the next step: type `/workdeck:quick "<description>"` for a small change, or write a card with `card new <id> "<title>"`, fill in its sections, and commit and push it on the base branch before starting it. For work that a specification describes, type `/workdeck:plan <spec path>`: it cuts the specification into an outline of rows, and `/workdeck:next-card` writes the card for a row when it starts one.

## A repository that is already set up

Step 1 sends you here when `workdeck.conf` exists. These four steps give a repository that an earlier version set up what it lacks. Each one asks first and writes nothing without a yes. A step with nothing to offer says so in one line and changes nothing. Where step 5, 8 or 9 says to go on, go on to the next of these four, not to the step numbered after it.

1. **Permission entries that are missing.** Do step 5, with what `card conf check` prints as the check command. Show only the entries `.claude/settings.json` lacks.

2. **`touch_ignore`.** Do step 8.

3. **Review rules.** Do step 9. If the cards directory has no `REVIEW.md`, offer to copy `templates/REVIEW.md` there first.

4. **The protocol section.** Take `templates/claude-md-section.md`, with the directories replaced as step 4 says. In `CLAUDE.md`, the section runs from the `## WorkDeck session protocol` heading to the line before the next line that starts with `# ` or `## `, or to the end of the file. Blank lines at its end are not part of it, and neither is a difference in them. If the section is the same as the template, say so and change nothing. If it differs, show the difference as a diff, and say that a yes replaces the whole section, with any change the project made to it. Replace it on a yes, and leave every line outside the section as it is. If `CLAUDE.md` has no such section, or does not exist, offer to add the section as step 4 does.

Then do step 10. If none of the four steps wrote anything, say so in place of the list and the commit.
