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
  grep -q '^## Workdeck session protocol$' "$f" || fail 'section heading missing'
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
