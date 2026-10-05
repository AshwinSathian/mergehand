#!/usr/bin/env bash
# shellcheck disable=SC2154

test_harness_builds_repo() {
  new_repo
  assert_eq main "$(git symbolic-ref --short HEAD)" branch
  assert_eq 1 "$(git rev-list --count HEAD | tr -d ' ')" commits
}

test_harness_home_is_isolated() {
  case $HOME in "$T"/*) ;; *) fail "HOME is $HOME" ;; esac
  assert_eq /dev/null "$GIT_CONFIG_GLOBAL"
}

test_harness_remote_is_local() {
  new_repo
  add_remote
  assert_eq "$T/remote.git" "$(git remote get-url origin)"
  git rev-parse -q --verify origin/main >/dev/null || fail "origin/main missing"
}

test_stub_gh_is_first_on_path() {
  assert_eq "$ROOT/test/stubs/gh" "$(command -v gh)"
  echo 'card/AUTH-1-x' > "$GH_STUB_DIR/pr-list"
  run gh pr list --json headRefName
  assert_eq 'card/AUTH-1-x' "$OUT"
  assert_contains "$(cat "$GH_STUB_DIR/calls")" 'pr list'
}

# A harness whose assertions cannot fail would pass everything.
test_runner_reports_failure() {
  mkdir "$T/cases"
  printf 'test_bad() { assert_eq a b; }\n' > "$T/cases/a.sh"
  printf 'test_broken() { if; }\n' > "$T/cases/b.sh"
  CASES_DIR="$T/cases" run "$BASH" "$ROOT/test/run.sh"
  assert_rc 1
  assert_contains "$OUT" '0 passed, 2 failed'
}

test_runner_fails_when_nothing_ran() {
  mkdir "$T/cases"
  printf 'test_fine() { :; }\n' > "$T/cases/a.sh"
  CASES_DIR="$T/cases" run "$BASH" "$ROOT/test/run.sh" nosuchfilter
  assert_rc 1
  CASES_DIR="$T/cases" run "$BASH" "$ROOT/test/run.sh" fine
  assert_rc 0
  assert_contains "$OUT" '1 passed, 0 failed'
}
