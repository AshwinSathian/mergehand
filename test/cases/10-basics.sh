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
  assert_contains "$ERR" 'card: no mergehand.conf'
  assert_contains "$ERR" '/mergehand:init'
}

test_basics_version_matches_the_plugin_manifest() {
  local want
  want=$(sed -n 's/^  "version": "\(.*\)",$/\1/p' "$ROOT/.claude-plugin/plugin.json")
  [ -n "$want" ] || fail 'no version in plugin.json'
  card --version; assert_rc 0; assert_eq "card $want" "$OUT" '--version'
  card -V; assert_eq "card $want" "$OUT" '-V'
  card version; assert_eq "card $want" "$OUT" version
  card help; assert_contains "$OUT" "card $want"
}

test_basics_help_for_one_command() {
  local c
  for c in next show list status new done lint touched tests tokens log-new stats conf; do
    card "$c" --help
    assert_rc 0
    assert_contains "$OUT" "usage: card $c"
    card "$c" -h
    assert_rc 0
  done
}

test_basics_surplus_arguments_are_rejected() {
  new_repo; mk_conf; mk_card A-1; commit_all
  card list extra; assert_rc 2; assert_contains "$ERR" 'usage: card list'; assert_empty "$OUT" stdout
  card list --json; assert_rc 2
  card show A-1 extra; assert_rc 2; assert_contains "$ERR" 'usage: card show <id>'
  card status now; assert_rc 2
  card lint cards; assert_rc 2
  card stats S; assert_rc 2
  card next A-1; assert_rc 2
  card tokens a b; assert_rc 2
  card log-new A-1 done extra; assert_rc 2
  card list --fetch; assert_rc 0
  assert_not_contains "$ERR" 'card: usage'
}
