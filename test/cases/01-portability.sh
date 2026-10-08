#!/usr/bin/env bash
# shellcheck disable=SC2154

shipped_scripts() {
  local f
  for f in "$ROOT/bin/card" "$ROOT"/hooks/*.sh "$ROOT"/scripts/*.sh; do
    [ -f "$f" ] && printf '%s\n' "$f"
  done
}

# bash 4 features, non-portable tool flags and banned tools. Linux CI runs
# bash 5 and GNU tools, so only this check and the macOS run catch them there.
test_no_forbidden_constructs() {
  local f hits pat
  pat='declare -[A-Za-z]*[Ag]|mapfile|readarray|local -n|\$\{[A-Za-z_]+(,,|\^\^)|;&|\|&|&>>|coproc'
  pat="$pat|sed -i|grep -[A-Za-z]*P|readlink -f"
  pat="$pat|(^|[;&|(\`[:space:]])(eval|jq|python3?|node|source)[[:space:]]"
  for f in $(shipped_scripts); do
    hits=$(grep -nE "$pat" "$f" | grep -vE '^[0-9]+:[[:space:]]*#')
    [ -z "$hits" ] || fail "forbidden construct in $f: $hits"
  done
}

test_shellcheck() {
  if ! command -v shellcheck >/dev/null 2>&1; then
    [ -z "${CI-}" ] || fail "shellcheck is required in CI"
    echo "skip: shellcheck not installed"
    return 0
  fi
  # shellcheck disable=SC2046
  run shellcheck -x -s bash $(shipped_scripts) "$ROOT"/test/*.sh "$ROOT"/test/cases/*.sh "$ROOT"/test/stubs/*
  [ "$RC" -eq 0 ] || fail "shellcheck found problems"
}

# This repository runs on its own cards from stage 4 on.
test_own_deck_lints() {
  cd "$ROOT" || exit 1
  [ -f workdeck.conf ] || fail 'workdeck.conf is missing'
  card lint
  assert_rc 0
}

# gawk processes escapes in -v values and warns about "\." on every call.
test_conf_keys_pattern_has_no_backslash() {
  local line
  line=$(grep -n "^CONF_KEYS=" "$CARD")
  case $line in *\\*) fail "CONF_KEYS has a backslash: $line" ;; esac
  ! grep -n -E 'awk .*-v [a-z]+="[^"]*\\\\[^$"]' "$CARD" || fail 'a backslash escape is passed through awk -v'
}

# Comments are read by strangers: no marker from another tool, no skeleton text.
test_card_file_carries_no_persona_markers() {
  local f
  for f in $(shipped_scripts); do
    ! grep -n -i -E 'ponytail|not implemented yet|TODO|FIXME|XXX' "$f" || fail "leftover marker in $f"
  done
}
