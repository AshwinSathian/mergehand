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
  grep -q '"name": "workdeck"' "$f" || fail 'the plugin is not named workdeck'
  grep -q '"name": "workdeck"' "$ROOT/.claude-plugin/marketplace.json" || fail 'the marketplace is not named workdeck'
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
  sed 's|<check>|make check VAR=1|; s|<base>|trunk|' "$ROOT/templates/workdeck.conf" > workdeck.conf
  card conf check; assert_rc 0; assert_eq 'make check VAR=1' "$OUT" check
  card conf base; assert_eq trunk "$OUT" base
  card conf budget.M; assert_eq 100000 "$OUT" 'default budget'
  # Unfilled, it must fail loudly, not run a placeholder.
  cp "$ROOT/templates/workdeck.conf" workdeck.conf
  card conf base; assert_rc 2
}

test_claude_md_section_is_short() {
  local f="$ROOT/templates/claude-md-section.md" n
  n=$(awk 'END { print NR }' "$f")
  [ "$n" -le 25 ] || fail "the CLAUDE.md section is $n lines; the spec says about 20"
  grep -q '^## WorkDeck session protocol$' "$f" || fail 'section heading missing'
  grep -q '/workdeck:handoff' "$f" || fail 'the section does not point at handoff'
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

# Design 0.2, section 12.2: the review of a card body that next-card wrote
# from a row, by an agent that did not write it.
test_reviewer_checks_a_planned_card_against_its_specification_headings() {
  local f="$ROOT/agents/reviewer.md" s
  s=$(awk '/^## / { on = $0 == "## Procedure" } on && /^5\. /' "$f")
  assert_contains "$s" 'a `Read` item of the card has a comment that starts with `(row `'
  assert_contains "$s" 'the item is a specification and the comment names headings in it'
  assert_contains "$s" 'list each requirement under those headings that no `Acceptance` item covers and no `Out of scope` item excludes'
  assert_contains "$s" 'Each is a `should-fix` finding'
  # Every finding needs a file, a line and a failure: the step says which.
  assert_contains "$s" "the specification's path and the line of the requirement"
  # A row with no spec item gives `(row <id>)`: the step fires and has nothing to check.
  assert_contains "$s" 'names no heading'
  assert_contains "$s" 'For a card with no such item, skip this step'
  # The step is one line, and the rest of the agent is what it was in 0.1.
  assert_eq 5 "$(awk '/^## / { on = $0 == "## Procedure" } on && /^[0-9]+\. /' "$f" | grep -c .)" 'steps of the procedure'
  assert_eq '156200674 2751' "$(grep -v '^5\. ' "$f" | cksum)" 'the reviewer without the step'
}

PLAN_REVIEWER="$ROOT/agents/plan-reviewer.md"

# plan_reviewer_step <n>: the text of one numbered step of the procedure.
plan_reviewer_step() {
  awk -v n="$1." '/^[0-9]\. / { on = $1 == n } /^## / { on = 0 } on' "$PLAN_REVIEWER"
}

test_plan_reviewer_agent_is_read_only() {
  local f="$PLAN_REVIEWER"
  assert_eq 'name: plan-reviewer' "$(sed -n 2p "$f")" 'agent name'
  assert_eq 'tools: Read, Grep, Glob, Bash' "$(grep '^tools:' "$f")" tools
  # No field beyond these: one that plugin agents ignore would suggest it works,
  # and one such as background changes how the agent runs.
  assert_eq 'name description tools ' "$(awk '/^---$/ { n++; next } n == 1 { sub(/:.*/, ""); printf "%s ", $0 }' "$f")" 'front matter fields'
  # The description is in every session's context: one sentence, and short.
  assert_eq 1 "$(grep '^description: ' "$f" | grep -o '\. \|\.$' | grep -c .)" 'sentences in the description'
  [ "$(grep '^description: ' "$f" | wc -c)" -le 200 ] || fail 'the description is longer than 200 characters'
  grep -q 'do not edit, create or delete files' "$f" || fail 'the plan reviewer is not told to change nothing'
  grep -q 'do not commit, stash, check out, reset or push' "$f" || fail 'the plan reviewer is not told to leave git alone'
  # Bash is the one tool of the four that can write.
  grep -q 'never to change the repository' "$f" || fail 'Bash is not limited to reading'
}

test_plan_reviewer_is_told_to_assume_the_outline_is_wrong() {
  grep -q 'You did not write it\.' "$PLAN_REVIEWER" || fail 'the plan reviewer is not told it did not write the outline'
  grep -q 'Assume the outline is wrong' "$PLAN_REVIEWER" || fail 'the plan reviewer is not told to assume the outline is wrong'
}

test_plan_reviewer_reads_the_outline_from_the_working_tree() {
  local s
  grep -q "You are given the outline's path and a base branch" "$PLAN_REVIEWER" || fail 'the plan reviewer does not say what it is given'
  # The five steps of design section 12.1; the first is the reading step.
  assert_eq '1. 2. 3. 4. 5. ' "$(grep -o '^[0-9]\. ' "$PLAN_REVIEWER" | tr -d '\n')" 'steps of the procedure'
  s=$(plan_reviewer_step 1)
  assert_contains "$s" 'from the working tree'
  assert_contains "$s" 'not committed'
  assert_contains "$s" 'specification'
  s=$(plan_reviewer_step 2)
  assert_contains "$s" 'A requirement with no `does` line is a finding'
  assert_contains "$s" 'two rows both claim'
}

test_plan_reviewer_uses_the_severities_of_the_reviewer() {
  local s form='/^```$/ { on = !on; next } on { print $1 }'
  for s in must-fix should-fix nit; do
    grep -q "^- \`$s\`: " "$PLAN_REVIEWER" || fail "the plan reviewer does not define $s"
  done
  assert_eq "$(awk "$form" "$ROOT/agents/reviewer.md")" "$(awk "$form" "$PLAN_REVIEWER")" 'severities of the output form'
  grep -q 'the outline.s line and a failure scenario' "$PLAN_REVIEWER" || fail 'a finding does not need a line and a failure scenario'
  grep -q '`must-fix: none`' "$PLAN_REVIEWER" || fail 'no line for a category with no findings'
  # The closing lines are what tell "read and found nothing" from "not read".
  grep -q 'print nothing after them' "$PLAN_REVIEWER" || fail 'the report does not end at its closing lines'
  for s in 'searched:' 'no spec item:' 'outside the level:'; do
    grep -q "\`$s\`" "$PLAN_REVIEWER" || fail "no closing line '$s'"
  done
}

test_plan_reviewer_looks_for_joined_does_lines_and_lines_about_tests() {
  local s
  s=$(plan_reviewer_step 3)
  assert_contains "$s" 'joins two statements'
  assert_contains "$s" 'only says that tests exist'
  assert_contains "$s" 'Neither is a `must-fix` finding by itself'
  # "Neither" refers to the two bullets before it.
  assert_contains "$(printf '%s\n' "$s" | awk '/Neither is a/ { print prev } { prev = $0 }')" 'only says that tests exist'
  grep '^- `must-fix`: ' "$PLAN_REVIEWER" | grep -q '`does` line' && fail 'the must-fix definition names a does line'
  # One example of each, as the spike's reviewer raised neither.
  assert_eq 2 "$(printf '%s\n' "$s" | grep -c 'For example')" 'examples in step 3'
}

test_plan_reviewer_looks_for_a_missing_not_line_between_rows_of_one_heading() {
  local s
  s=$(plan_reviewer_step 4)
  assert_contains "$s" 'two rows cite one heading'
  assert_contains "$s" '`not` line'
  assert_contains "$s" 'what the other owns'
}

test_plan_reviewer_reads_what_lies_outside_the_level_of_the_outline() {
  local s
  s=$(plan_reviewer_step 5)
  assert_contains "$s" 'Not planned'
  assert_contains "$s" 'no `spec` item'
  assert_contains "$s" "under no heading at the outline's level"
  assert_contains "$s" 'work that no row does'
}

test_plan_reviewer_gives_paths_relative_to_the_repository() {
  grep -q 'Every path you print is relative to the repository' "$PLAN_REVIEWER" || fail 'the plan reviewer is not told to print relative paths'
  # The example findings show one.
  awk '/^```$/ { on = !on; next } on && $2 !~ /^cards\/plan\/[a-z0-9]*\.md:[0-9][0-9]*$/ { bad = 1 } END { exit bad }' "$PLAN_REVIEWER" || fail 'an example finding has no relative path'
}

test_templates_are_complete() {
  local f
  for f in REVIEW.md pull_request_template.md claude-md-section.md workdeck.conf workdeck.yml settings-permissions.json; do
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

# The tag v0.1.2 holds the former name. The entry is what tells a user of that
# tag why its card stops and what to change.
test_changelog_says_what_0_1_3_renames() {
  local e
  e=$(awk '/^## \[/ { on = index($0, "[0.1.3]") > 0 } on' "$ROOT/CHANGELOG.md")
  printf '%s\n' "$e" | grep -q '^## \[0\.1\.3\] - [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$' || fail 'CHANGELOG has no dated entry for 0.1.3'
  assert_contains "$e" 'The code of 0.1.2'
  assert_contains "$e" 'former name'
  assert_contains "$e" 'CI workflow'
  assert_contains "$e" 'WorkDeck'
  assert_contains "$e" '`workdeck.conf`'
  assert_contains "$e" '`/workdeck:*`'
  assert_contains "$e" '`v0.1.2`'
  assert_contains "$e" 'exits 2'
  assert_contains "$e" '`v0.1.3`'
  grep -q '^\[0\.1\.3\]: .*/releases/tag/v0\.1\.3$' "$ROOT/CHANGELOG.md" || fail 'CHANGELOG has no link for 0.1.3'
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

test_development_records_for_0_2_are_listed_and_exist() {
  local f idx="$ROOT/docs/development/README.md"
  for f in scope-0.2.md review-0.2.md ../design-0.2.md; do
    [ -s "$ROOT/docs/development/$f" ] || fail "docs/development/$f is missing"
    grep -q "^| \[\`$f\`\]($f) |" "$idx" || fail "docs/development/README.md has no row for $f"
  done
}

# The spike of design-0.2 section 21, item 1. The record is finished when no
# part of it still says it was not run.
test_spike_record_for_0_2_is_listed_and_answers_its_questions() {
  local d="$ROOT/docs/development" rec f h n
  rec="$d/spike-0.2.md"
  [ -s "$rec" ] || fail 'docs/development/spike-0.2.md is missing'
  grep -q '^| \[`spike-0.2.md`\](spike-0.2.md) |' "$d/README.md" || fail 'docs/development/README.md has no row for spike-0.2.md'
  for f in plan-skill.md plan-reviewer.md outline-design.md outline-sample.md; do
    [ -s "$d/spike-0.2/$f" ] || fail "docs/development/spike-0.2/$f is missing"
  done
  for h in 'What was run' 'Outline of docs/design.md' 'Outline of the Spec Kit sample' 'A card from one row' 'Heading levels' 'Growth of the plan runs' 'Claude Code behavior' 'Outline format'; do
    grep -q "^## $h\$" "$rec" || fail "the record has no section '$h'"
  done
  ! grep -n 'Not run yet' "$rec" || fail 'a part of the record was not run'
  # Each fault names the check of design section 11.1 that catches it, or none.
  assert_eq 2 "$(grep -c '^| Fault | Caught by |$' "$rec")" 'tables of faults with the check that catches each, one per outline'
  assert_eq 2 "$(grep -c '^growth [0-9][0-9]*$' "$rec")" 'growth figures as card tokens prints them'
  grep -Eq '^The outline format of design section 5 is (confirmed|changed)' "$rec" || fail 'the record does not say whether the outline format is confirmed'
  for n in 14 15 16 17; do
    grep -q "^| $n | .*[0-9]\.[0-9][0-9]*\.[0-9]" "$rec" || fail "the record has no result with a Claude Code version for row $n"
    grep "^| $n | " "$ROOT/docs/design-0.2.md" | grep -q 'spike-0\.2\.md' || fail "design section 19, row $n, does not give the spike's result"
  done
}

# The spike ends with a list of changes for the deck. Each is answered in the
# review record, accepted or turned down.
test_review_record_answers_what_the_spike_asked_for() {
  local d="$ROOT/docs/development" n
  grep -q '^## Fifth pass' "$d/review-0.2.md" || fail 'the review record has no fifth pass'
  grep -q 'fifth pass of \[`review-0.2.md`\](review-0.2.md)' "$d/spike-0.2.md" || fail 'the spike record does not point at the fifth pass'
  # Rows of the first table of that pass only.
  n=$(awk '/^## Fifth pass/ { on = 1 } on && /^Found by the attack/ { exit } on && /^\| / && $0 !~ /^\| (The spike asked for|---)/ { n++ } END { print n + 0 }' "$d/review-0.2.md")
  [ "$n" -eq 11 ] || fail "the fifth pass answers $n of the spike's requests"
}

test_nothing_claims_evals_that_do_not_exist() {
  cd "$ROOT" || exit 1
  [ -d evals ] && return 0
  ! git grep -n -i 'ships three plugin eval' -- docs/design.md || fail 'the design says eval cases ship'
  ! ls cards/DOC-03-* 2>/dev/null || fail 'the eval card is still in the deck'
}

test_reference_names_every_card_command() {
  local c
  for c in $("$BASH" "$CARD" help | awk '/^  [a-z]/ && $1 != "help," { print $1 }'); do
    grep -q "^  $c " "$ROOT/docs/reference.md" || fail "docs/reference.md does not list card $c"
  done
  for c in version check base cards_dir log_dir budget.XS touch_ignore status_max_chars reviewer; do
    grep -q "\`$c\`" "$ROOT/docs/reference.md" || fail "docs/reference.md does not document the $c setting"
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
  grep -q 'github.com/AshwinSathian/workdeck/pull/1' "$ROOT/docs/evidence.md" || fail 'evidence does not link pull request 1'
  # The figures on the page are the ones in the session log.
  for k in baseline_tokens peak_tokens growth_tokens; do
    v=$(sed -n "s/^$k: //p" "$log" | awk '{ printf "%d,%03d", $1 / 1000, $1 % 1000 }')
    grep -q "$v" "$ROOT/docs/evidence.md" || fail "evidence does not give $k as $v"
  done
  ! grep -q -i 'no pull requests\|none did' "$ROOT/README.md" || fail 'README still says no card went through the loop'
}
