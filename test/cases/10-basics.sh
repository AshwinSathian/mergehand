#!/usr/bin/env bash
# shellcheck disable=SC2154

test_basics_no_arguments_prints_usage() {
  new_repo; mk_conf
  card
  assert_rc 2
  assert_contains "$ERR" 'usage: card'
}

test_basics_help_exits_zero() {
  card help
  assert_rc 0
  assert_contains "$OUT" 'usage: card'
}

test_basics_unknown_command() {
  new_repo; mk_conf
  card frobnicate
  assert_rc 2
  assert_contains "$ERR" 'card: unknown command'
}

test_basics_outside_git_repository() {
  mkdir "$T/plain" && cd "$T/plain" || exit 1
  card list
  assert_rc 2
  assert_contains "$ERR" 'card: not a git repository'
  assert_empty "$OUT" stdout
}

test_basics_no_config_suggests_init() {
  new_repo
  card list
  assert_rc 2
  assert_contains "$ERR" 'card: no workdeck.conf'
  assert_contains "$ERR" '/workdeck:init'
}
