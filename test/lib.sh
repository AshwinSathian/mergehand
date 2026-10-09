#!/usr/bin/env bash
# Test helpers: an isolated temporary repository per case, and assertions.
# Sourced by test/run.sh with ROOT set. Scripts under test run as "$BASH" <script>
# so macOS exercises them with /bin/bash 3.2.
# shellcheck disable=SC2034

CARD="$ROOT/bin/card"
FIX="$ROOT/test/fixtures"

setup_env() {
  T=$(mktemp -d) || exit 1
  T=$(cd "$T" && pwd -P)
  trap 'cd /; rm -rf "$T"' EXIT
  export HOME="$T/home" GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
  export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.invalid
  export GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.invalid
  export GH_STUB_DIR="$T/gh" PATH="$ROOT/test/stubs:$PATH"
  unset WORKDECK_TRANSCRIPT WORKDECK_SESSION CLAUDE_ENV_FILE CLAUDE_PROJECT_DIR CLAUDE_PLUGIN_ROOT
  mkdir -p "$HOME" "$GH_STUB_DIR"
  cd "$T" || exit 1
}

# new_repo: a repository at $T/repo with one commit on main; cd into it.
new_repo() {
  mkdir -p "$T/repo" && cd "$T/repo" || exit 1
  git init -q . && git symbolic-ref HEAD refs/heads/main
  echo seed > README.md
  git add README.md && git commit -q -m seed
}

# add_remote: a bare repository at $T/remote.git as origin, with main pushed.
add_remote() {
  git init -q --bare "$T/remote.git"
  git --git-dir="$T/remote.git" symbolic-ref HEAD refs/heads/main
  git remote add origin "$T/remote.git"
  git push -q -u origin main 2>/dev/null
}

# mk_conf [line...]: workdeck.conf with a passing check plus the given lines.
mk_conf() {
  local l
  echo 'check = true' > workdeck.conf
  for l in "$@"; do printf '%s\n' "$l" >> workdeck.conf; done
}

# mk_card <id> [size] [depends] [done] [slug]: a valid card in cards/.
mk_card() {
  local id=$1 size=${2:-S} dep=${3:-} done=${4:-false} slug=${5:-thing}
  mkdir -p "${CARDS_DIR:-cards}"
  cat > "${CARDS_DIR:-cards}/$id-$slug.md" <<CARD
---
id: $id
title: Card $id
size: $size
depends: $dep
done: $done
---

## Read
- README.md

## Touch
- src/$slug.txt (new)

## Tests
- $slug works

## Acceptance
- It works.
CARD
}

# mk_outline [prefix]: a valid outline in cards/plan/, two rows and a
# Not planned section, and its specification in specs/, staged and not
# committed.
mk_outline() {
  local p=${1:-AUTH} lower
  lower=$(printf '%s' "${1:-AUTH}" | tr '[:upper:]' '[:lower:]')
  mkdir -p "${CARDS_DIR:-cards}/plan" specs
  printf '%s\n' '# Tokens' '' '## Overview' '' '## Storage' '' '## Refresh' '' '## Errors' '' '## Non-goals' > "specs/$lower.md"
  git add "specs/$lower.md"
  cat > "${CARDS_DIR:-cards}/plan/$lower.md" <<OUTLINE
---
spec: specs/$lower.md
spec_blob: $(git hash-object "specs/$lower.md")
prefix: $p
level: 2
---

## $p-01 Token store
- size: S
- spec: Storage
- does: A token is stored hashed, with its expiry
- does: A stored token can be looked up by its hash

## $p-02 Token refresh
- size: S
- depends: $p-01
- spec: Refresh
- spec: Errors
- does: A refresh returns a new token and makes the old one invalid
- does: An expired token is refused with 401
- not: Counting refreshes ($p-03)

## Not planned
- Overview
- Non-goals
OUTLINE
}

commit_all() { git add -A && git commit -q -m "${1:-change}"; }

# run <cmd...>: sets OUT, ERR, RC.
run() {
  OUT=$("$@" 2>"$T/stderr")
  RC=$?
  ERR=$(cat "$T/stderr")
}

card() { run "$BASH" "$CARD" "$@"; }

fail() {
  printf '  %s\n' "$1"
  printf '  rc=%s\n  stdout: %s\n  stderr: %s\n' "${RC-}" "${OUT-}" "${ERR-}"
  exit 1
}

assert_rc() { [ "$RC" -eq "$1" ] || fail "expected exit $1, got $RC"; }
assert_eq() { [ "$1" = "$2" ] || fail "${3:-values differ}: expected [$1], got [$2]"; }
assert_contains() { case $1 in *"$2"*) ;; *) fail "expected to find [$2]" ;; esac; }
assert_not_contains() { case $1 in *"$2"*) fail "did not expect [$2]" ;; esac; }
assert_empty() { [ -z "$1" ] || fail "${2:-value} should be empty, got [$1]"; }
assert_file() { [ -e "$1" ] || fail "missing file $1"; }
assert_no_file() { [ ! -e "$1" ] || fail "unexpected file $1"; }

# mk_log <id> [date] [n] [outcome] [size] [growth] [compacted]: a valid log entry in log/.
mk_log() {
  local id=$1 date=${2:-2026-10-05} n=${3:-1} outcome=${4:-done} size=${5:-S} growth=${6:-1000} compacted=${7:-false}
  mkdir -p "${LOG_DIR:-log}"
  cat > "${LOG_DIR:-log}/$date-$id-$n.md" <<LOG
---
card: $id
date: $date
outcome: $outcome
branch: card/$id-thing
size: $size
budget_tokens: 70000
baseline_tokens: 50000
peak_tokens: $((50000 + growth))
growth_tokens: $growth
compacted: $compacted
---

## Done
- Did the thing for $id.

## Tests
- thing works

## Deviations

## Follow-ups
LOG
}

# edit <file> <sed expression>: portable in-place edit.
edit() {
  sed "$2" "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

# hook <name> [json]: runs hooks/<name>.sh with the JSON on stdin; sets OUT, ERR, RC.
hook() {
  printf '%s' "${2-}" > "$T/stdin"
  OUT=$("$BASH" "$ROOT/hooks/$1.sh" < "$T/stdin" 2>"$T/stderr")
  RC=$?
  ERR=$(cat "$T/stderr")
}

# hook_input <event> [session] [transcript] [extra fields]: hook JSON in the
# documented shape, common fields first.
hook_input() {
  printf '{"session_id":"%s","transcript_path":"%s","cwd":"%s","permission_mode":"default","hook_event_name":"%s"%s}' \
    "${2:-abc-123}" "${3:-$T/transcript.jsonl}" "$PWD" "$1" "${4:+,$4}"
}

assert_silent() {
  assert_rc 0
  assert_empty "$OUT" stdout
  assert_empty "$ERR" stderr
}
