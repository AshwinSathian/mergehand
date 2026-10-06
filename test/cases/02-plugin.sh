#!/usr/bin/env bash
# shellcheck disable=SC2154
# Structural checks on the plugin files, with grep: no JSON tool is assumed.

test_hooks_json_names_existing_executable_scripts() {
  local f="$ROOT/hooks/hooks.json" s n=0
  [ -f "$f" ] || fail 'hooks/hooks.json is missing'
  for s in $(grep -o 'hooks/[a-z-]*\.sh' "$f"); do
    [ -x "$ROOT/$s" ] || fail "$s is named in hooks.json but is not an executable file"
    n=$((n + 1))
  done
  assert_eq 4 "$n" 'hook commands'
  for s in SessionStart PostToolUse Stop PreCompact; do
    grep -q "\"$s\"" "$f" || fail "hooks.json does not register $s"
  done
  assert_eq 4 "$(grep -c '"timeout": 10' "$f")" 'ten second timeouts'
  # An unquoted variable breaks on a path with a space and fails validate --strict.
  assert_eq 4 "$(grep -c '\\"${CLAUDE_PLUGIN_ROOT}\\"/hooks/' "$f")" 'quoted plugin root'
  grep -q '^  "hooks": {' "$f" || fail 'hooks.json has no top-level hooks key'
}

test_plugin_manifest_has_name_version_description_and_author() {
  local f="$ROOT/.claude-plugin/plugin.json" k
  [ -f "$f" ] || fail 'plugin.json is missing'
  for k in name version description author; do
    grep -q "\"$k\":" "$f" || fail "plugin.json has no $k"
  done
  grep -q '"name": "mergehand"' "$f" || fail 'the plugin is not named mergehand'
  grep -q '"name": "mergehand"' "$ROOT/.claude-plugin/marketplace.json" || fail 'the marketplace is not named mergehand'
}

# Runs only where Claude Code is installed. HOME is the test's temp directory,
# so nothing in the real ~/.claude is read or written.
test_plugin_validates_strictly() {
  if ! command -v claude >/dev/null 2>&1; then
    [ -z "${CI-}" ] || fail 'claude is required in CI'
    echo 'skip: claude not installed'
    return 0
  fi
  run claude plugin validate --strict "$ROOT"
  [ "$RC" -eq 0 ] || fail 'claude plugin validate --strict failed for the marketplace'
  run claude plugin validate --strict "$ROOT/.claude-plugin/plugin.json"
  [ "$RC" -eq 0 ] || fail 'claude plugin validate --strict failed for the plugin manifest'
  # Agents and skills are validated as component directories.
  local d
  for d in agents skills; do
    [ -d "$ROOT/$d" ] || continue
    run claude plugin validate --strict "$ROOT/$d"
    [ "$RC" -eq 0 ] || fail "claude plugin validate --strict failed for $d/"
  done
  RC=0
  [ "$RC" -eq 0 ] || fail 'claude plugin validate --strict failed'
}

test_template_conf_parses() {
  new_repo
  sed 's|<check>|make check VAR=1|; s|<base>|trunk|' "$ROOT/templates/mergehand.conf" > mergehand.conf
  card conf check; assert_rc 0; assert_eq 'make check VAR=1' "$OUT" check
  card conf base; assert_eq trunk "$OUT" base
  card conf budget.M; assert_eq 100000 "$OUT" 'default budget'
  # Unfilled, it must fail loudly, not run a placeholder.
  cp "$ROOT/templates/mergehand.conf" mergehand.conf
  card conf base; assert_rc 2
}

test_claude_md_section_is_short() {
  local f="$ROOT/templates/claude-md-section.md" n
  n=$(awk 'END { print NR }' "$f")
  [ "$n" -le 25 ] || fail "the CLAUDE.md section is $n lines; the spec says about 20"
  grep -q '^## Mergehand session protocol$' "$f" || fail 'section heading missing'
  grep -q '/mergehand:handoff' "$f" || fail 'the section does not point at handoff'
}

test_reviewer_agent_is_read_only() {
  local f="$ROOT/agents/reviewer.md"
  assert_eq 'name: reviewer' "$(sed -n 2p "$f")" 'agent name'
  assert_eq 'tools: Read, Grep, Glob, Bash' "$(grep '^tools:' "$f")" tools
  grep -q 'must-fix' "$f" || fail 'no must-fix severity in the reviewer'
  # Plugin agents ignore these fields; listing one would suggest it works.
  grep -Eq '^(hooks|mcpServers|permissionMode):' "$f" && fail 'field ignored for plugin agents'
  return 0
}

test_templates_are_complete() {
  local f
  for f in REVIEW.md pull_request_template.md claude-md-section.md mergehand.conf mergehand.yml settings-permissions.json; do
    [ -s "$ROOT/templates/$f" ] || fail "templates/$f is missing or empty"
  done
  # The plugin ships no project rules: the REVIEW template has headings only.
  ! grep -q -v -E '^(#|<!--|$)' "$ROOT/templates/REVIEW.md" || fail 'templates/REVIEW.md carries rules'
}

# The allow rule for pushing card branches is a prefix match, so the deny
# list must close the refspec forms that would land a card branch elsewhere.
test_permission_template_denies_refspec_pushes() {
  local f="$ROOT/templates/settings-permissions.json" deny r
  deny=$(awk '/"deny"/ { on = 1 } on' "$f")
  for r in 'Bash(git push *:*)' 'Bash(git push origin card/* *)' 'Bash(git push -u origin card/* *)'; do
    assert_contains "$deny" "\"$r\""
  done
}

# rules <allow|deny>: the Bash(...) patterns of one list, one per line.
rules() {
  awk -v want="$1" '
    /"allow"/ { cur = "allow" } /"deny"/ { cur = "deny" }
    cur == want && match($0, /"Bash\(.*\)"/) { print substr($0, RSTART + 6, RLENGTH - 8) }' "$ROOT/templates/settings-permissions.json"
}
# matches <allow|deny> <command>: does any rule of the list match the whole
# command, with * standing for any text? (Claude Code also lets a single
# trailing " *" match the bare command; none of these cases depends on it.)
matches() {
  local pat
  while IFS= read -r pat; do
    # shellcheck disable=SC2254
    case $2 in $pat) return 0 ;; esac
  done <<RULES
$(rules "$1")
RULES
  return 1
}

test_permission_template_does_not_deny_the_handoff_push() {
  local c
  for c in 'git push -u origin card/AUTH-03-token-refresh' 'git push origin card/Q-2610061200' 'git push -u origin card/X-1-fix-foo'; do
    matches deny "$c" && fail "denied: $c"
    matches allow "$c" || fail "not allowed: $c"
  done
  matches deny 'gh pr create --base main --title x --body-file body.md' && fail 'gh pr create is denied'
  return 0
}

test_permission_template_denies_known_bad_pushes() {
  local c
  while IFS= read -r c; do
    matches deny "$c" || fail "not denied: $c"
  done <<'COMMANDS'
git push --force origin card/A-1-x
git push -f origin card/A-1-x
git push origin card/A-1-x --force
git push origin card/A-1-x -f
git push origin main -f
git push origin card/A-1-x:main
git push origin card/A-1-x main
git push -u origin card/A-1-x main
git push origin +card/A-1-x
git push origin --delete card/A-1-x
git push --delete origin card/A-1-x
git push -d origin card/A-1-x
git push origin -d card/A-1-x
git reset --hard HEAD~1
git branch -D card/A-1-x
gh pr merge 42
COMMANDS
}

test_permission_template_allows_what_next_card_runs() {
  local c
  for c in 'gh pr list --author @me --state open --json number,headRefName,reviewDecision' 'gh pr view 12 --comments' 'git branch --list card/A-1*' 'card status --fetch' 'date +%y%m%d%H%M'; do
    matches allow "$c" || fail "not allowed: $c"
    matches deny "$c" && fail "denied: $c"
  done
  return 0
}

test_repository_has_the_files_a_stranger_looks_for() {
  local f
  for f in .gitattributes .gitignore .editorconfig SECURITY.md CHANGELOG.md CONTRIBUTING.md Makefile; do
    [ -s "$ROOT/$f" ] || fail "$f is missing"
  done
  grep -q 'eol=lf' "$ROOT/.gitattributes" || fail '.gitattributes does not pin LF; card rejects CRLF'
  grep -q '^test:' "$ROOT/Makefile" || fail 'Makefile has no test target'
  grep -q '^lint:' "$ROOT/Makefile" || fail 'Makefile has no lint target'
  grep -q "$("$BASH" "$CARD" version | sed 's/^card //')" "$ROOT/CHANGELOG.md" || fail 'CHANGELOG has no entry for this version'
}

test_plugin_manifest_names_its_repository() {
  local f="$ROOT/.claude-plugin/plugin.json" k
  for k in displayName homepage repository; do
    grep -q "\"$k\":" "$f" || fail "plugin.json has no $k"
  done
  grep -q "$(sed -n 's/^  "repository": "\(.*\)",$/\1/p' "$f")" "$CARD" || fail 'the URL in bin/card differs from plugin.json'
}

test_plugin_manifest_names_the_license() {
  local id
  id=$(sed -n 's/^  "license": "\([^"]*\)",\{0,1\}$/\1/p' "$ROOT/.claude-plugin/plugin.json")
  assert_eq MIT "$id" 'license in plugin.json'
  assert_eq 'MIT License' "$(sed -n 1p "$ROOT/LICENSE")" 'first line of LICENSE'
  grep -q '^Copyright (c) [0-9][0-9][0-9][0-9] Ashwin Sathian$' "$ROOT/LICENSE" || fail 'LICENSE has no copyright line with a year'
  grep -q 'THE SOFTWARE IS PROVIDED "AS IS"' "$ROOT/LICENSE" || fail 'LICENSE is not the whole MIT text'
  sed -n 1,10p "$CARD" | grep -qx "# SPDX-License-Identifier: $id" || fail 'bin/card has no SPDX line in its header'
  grep -q "license-$id-" "$ROOT/README.md" || fail 'README has no license badge'
  grep -q "^\[$id\](LICENSE)" "$ROOT/README.md" || fail 'README does not link the license'
}

test_example_deck_lints_and_lists() {
  mkdir "$T/ex"
  cp -R "$ROOT/examples/hello-deck/." "$T/ex/" || fail 'no example deck'
  cd "$T/ex" || exit 1
  git init -q . && git symbolic-ref HEAD refs/heads/main && git add -A && git commit -q -m example
  card lint; assert_rc 0
  card list
  assert_contains "$OUT" 'done     GREET-01'
  assert_contains "$OUT" 'ready    GREET-02'
  card stats
  assert_contains "$OUT" '3417'
  # The output shown in the example README is real.
  card list
  assert_contains "$(cat README.md)" "$OUT"
}

test_docs_have_one_design_file_and_a_development_folder() {
  local f
  for f in docs/design.md docs/evidence.md docs/development/README.md docs/development/plan-0.1.md docs/development/findings.md docs/development/later.md; do
    [ -s "$ROOT/$f" ] || fail "$f is missing"
  done
  # No tracked file still points at the old locations.
  cd "$ROOT" || exit 1
  ! git grep -n -E 'docs/(specs|plans)/|docs/(findings|later)\.md' -- . ':!test/cases/02-plugin.sh' || fail 'a file names an old docs path'
}

test_nothing_claims_evals_that_do_not_exist() {
  cd "$ROOT" || exit 1
  [ -d evals ] && return 0
  ! git grep -n -i 'ships three plugin eval' -- docs/design.md || fail 'the design says eval cases ship'
  ! ls cards/DOC-03-* 2>/dev/null || fail 'the eval card is still in the deck'
}

test_readme_names_every_card_command() {
  local c
  for c in $("$BASH" "$CARD" help | awk '/^  [a-z]/ && $1 != "help," { print $1 }'); do
    grep -q "card $c" "$ROOT/README.md" || fail "README does not mention card $c"
  done
  for c in version check base cards_dir log_dir budget.XS touch_ignore status_max_chars reviewer; do
    grep -q "\`$c\`" "$ROOT/README.md" || fail "README does not document the $c setting"
  done
}

test_readme_install_line_matches_the_manifests() {
  local plugin market repo
  plugin=$(sed -n 's/^  "name": "\(.*\)",$/\1/p' "$ROOT/.claude-plugin/plugin.json" | head -1)
  market=$(sed -n 's/^  "name": "\(.*\)",$/\1/p' "$ROOT/.claude-plugin/marketplace.json" | head -1)
  repo=$(sed -n 's|^  "repository": "https://github.com/\(.*\)",$|\1|p' "$ROOT/.claude-plugin/plugin.json")
  grep -q "/plugin marketplace add $repo" "$ROOT/README.md" || fail "README does not add the marketplace $repo"
  grep -q "/plugin install $plugin@$market" "$ROOT/README.md" || fail "README does not install $plugin@$market"
  grep -q "raw.githubusercontent.com/$repo/v$("$BASH" "$CARD" version | sed 's/^card //')/bin/card" "$ROOT/README.md" || fail 'README download line does not name this version'
}

test_readme_links_resolve() {
  local l
  for l in $(grep -o '](\([^)#]*\)' "$ROOT/README.md" | sed 's/^](//' | grep -v '^http' | sort -u); do
    [ -e "$ROOT/$l" ] || fail "README links to $l, which does not exist"
  done
}

test_evidence_names_the_first_pull_request() {
  local log="$ROOT/log/2026-10-06-DOC-02-1.md" k v
  grep -q 'github.com/AshwinSathian/mergehand/pull/1' "$ROOT/docs/evidence.md" || fail 'evidence does not link pull request 1'
  # The figures on the page are the ones in the session log.
  for k in baseline_tokens peak_tokens growth_tokens; do
    v=$(sed -n "s/^$k: //p" "$log" | awk '{ printf "%d,%03d", $1 / 1000, $1 % 1000 }')
    grep -q "$v" "$ROOT/docs/evidence.md" || fail "evidence does not give $k as $v"
  done
  ! grep -q -i 'no pull requests\|none did' "$ROOT/README.md" || fail 'README still says no card went through the loop'
}
