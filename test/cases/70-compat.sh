#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2034
# Goal 5 of docs/design-0.2.md: in a repository with no outline, list, next and
# status print what card 0.1.3 prints.

# card <args...>: for list, next and status, with or without --fetch before
# the command, runs card 0.1.3 and then this card, and fails unless stdout,
# stderr and the exit code are the same. Any other command runs once, as in
# lib.sh. With --fetch, 0.1.3 has fetched and pruned by the time this card
# runs, so the comparison cannot tell whether this card does either:
# 22-fetch.sh is what tests that.
card() {
  local cmd=${1-}
  [ "$cmd" != --fetch ] || cmd=${2-}
  case $cmd in
    list | next | status) ;;
    *) run "$BASH" "$CARD" "$@"; return ;;
  esac
  [ ! -e cards/plan ] || fail 'the comparison is for a repository with no outline'
  local old_rc
  "$BASH" "$OLD_CARD" "$@" > "$T/old.out" 2> "$T/old.err"
  old_rc=$?
  "$BASH" "$CARD" "$@" > "$T/new.out" 2> "$T/new.err"
  RC=$?
  OUT=$(cat "$T/new.out")
  ERR=$(cat "$T/new.err")
  echo "$*" >> "$COMPARED"
  if [ "$old_rc" -ne "$RC" ] || ! cmp -s "$T/old.out" "$T/new.out" || ! cmp -s "$T/old.err" "$T/new.err"; then
    printf '  card %s differs from card 0.1.3\n' "$*"
    # The files are printed as they are: $(...) would drop a trailing newline
    # that is the whole difference.
    printf '  0.1.3: rc=%s\n  stdout:\n' "$old_rc"; cat "$T/old.out"
    printf '  stderr:\n'; cat "$T/old.err"
    printf '  now:   rc=%s\n  stdout:\n' "$RC"; cat "$T/new.out"
    printf '  stderr:\n'; cat "$T/new.err"
    exit 1
  fi
}

test_list_next_and_status_match_card_0_1_3_when_there_is_no_outline() {
  if ! old_card; then
    [ -z "${CI-}" ] || fail 'the v0.1.3 tag is required in CI'
    echo 'skip: v0.1.3:bin/card cannot be read from this repository'
    return 0
  fi
  COMPARED="$T/compared"
  local file name
  # Every case file of 0.1 that calls list, next or status. Each in its own
  # subshell: they define helpers of the same name.
  for file in 02-plugin 10-basics 14-list 20-base 21-state 22-fetch 23-status 31-done 50-hook-session-start; do
    (
      # shellcheck disable=SC1090
      . "$ROOT/test/cases/$file.sh"
      for name in $(sed -n 's/^\(test_[A-Za-z0-9_]*\)().*/\1/p' "$ROOT/test/cases/$file.sh"); do
        ( setup_env; "$name" ) || { printf '  in %s:%s\n' "$file" "$name"; exit 1; }
      done
    ) || exit 1
  done
  # The 0.1 cases make 104 such calls. Fewer means a case stopped going
  # through card(), or a file left the list above.
  local n
  n=$(grep -c '' "$COMPARED" 2>/dev/null)
  [ "${n:-0}" -ge 104 ] || fail "${n:-0} calls were compared, and the 0.1 cases make 104"
}
