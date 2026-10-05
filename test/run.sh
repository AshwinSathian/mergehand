#!/usr/bin/env bash
# Runs every test_* function in test/cases/*.sh, each in its own bash process.
# Usage: test/run.sh [filter...]   A case runs when "<file>:<function>" contains any filter.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd -P)
CASES_DIR=${CASES_DIR:-$ROOT/test/cases}
export ROOT
pass=0
fail=0

wanted() {
  [ "$#" -eq 1 ] && return 0
  local label=$1 f
  shift
  for f in "$@"; do
    case $label in *"$f"*) return 0 ;; esac
  done
  return 1
}

for file in "$CASES_DIR"/*.sh; do
  [ -f "$file" ] || continue
  base=$(basename "$file" .sh)
  if ! out=$("$BASH" -n "$file" 2>&1); then
    printf 'FAIL %s (does not parse)\n%s\n' "$base" "$out"
    fail=$((fail + 1))
    continue
  fi
  for name in $(sed -n 's/^\(test_[A-Za-z0-9_]*\)().*/\1/p' "$file"); do
    wanted "$base:$name" "$@" || continue
    # shellcheck disable=SC2016
    if out=$("$BASH" -c 'set -u; . "$ROOT/test/lib.sh"; . "$1"; setup_env; "$2"' _ "$file" "$name" 2>&1); then
      pass=$((pass + 1))
      printf 'ok   %s\n' "$name"
    else
      fail=$((fail + 1))
      printf 'FAIL %s\n%s\n' "$name" "$out"
    fi
  done
done

printf '%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] && [ "$pass" -gt 0 ]
