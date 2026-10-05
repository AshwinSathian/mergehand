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
  [ "$RC" -eq 0 ] || fail 'claude plugin validate --strict failed'
}
