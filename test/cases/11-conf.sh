#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2016

conf_is() { card conf "$1"; assert_rc 0; assert_eq "$2" "$OUT" "conf $1"; }
conf_fails() { card conf check; assert_rc 2; assert_contains "$ERR" "card: mergehand.conf"; assert_contains "$ERR" "$1"; }

test_conf_defaults() {
  new_repo; mk_conf
  conf_is check true
  conf_is version 1
  conf_is base main
  conf_is cards_dir cards
  conf_is log_dir log
  conf_is budget.XS 35000
  conf_is budget.S 70000
  conf_is budget.M 100000
  conf_is touch_ignore ''
  conf_is status_max_chars 6000
  conf_is reviewer on
}

test_conf_comments_blanks_and_whitespace() {
  new_repo
  printf '# a comment\n\n   # indented comment\n  check   =   make check VAR=1  \nbase=trunk\r\n' > mergehand.conf
  conf_is check 'make check VAR=1'
  conf_is base trunk
}

test_conf_value_is_never_evaluated() {
  new_repo
  printf 'check = $(touch pwned) `touch pwned2` ; touch pwned3\n' > mergehand.conf
  conf_is check '$(touch pwned) `touch pwned2` ; touch pwned3'
  assert_no_file pwned; assert_no_file pwned2; assert_no_file pwned3
}

test_conf_custom_size() {
  new_repo; mk_conf 'budget.L = 150000'
  conf_is budget.L 150000
}

test_conf_unknown_version() {
  new_repo; mk_conf 'version = 2'
  conf_fails 'version'
}

test_conf_malformed_line_names_line_number() {
  new_repo; mk_conf 'this is not a setting'
  conf_fails 'mergehand.conf:2'
}

test_conf_unknown_key_in_file() {
  new_repo; mk_conf 'chek = make'
  conf_fails 'unknown key'
}

test_conf_unknown_key_requested() {
  new_repo; mk_conf
  card conf nosuch; assert_rc 2
  card conf budget.L; assert_rc 2
  card conf; assert_rc 2
}

test_conf_check_not_set() {
  new_repo; echo 'base = main' > mergehand.conf
  card conf check
  assert_rc 2
  assert_contains "$ERR" 'check is not set'
  conf_is base main
}

test_conf_rejects_unsafe_paths() {
  local v
  for v in '../outside' '/etc' 'cards/../..' '-rf' 'a b' 'cards;x'; do
    new_repo; mk_conf "cards_dir = $v"
    conf_fails 'cards_dir'
    mk_conf "log_dir = $v"
    conf_fails 'log_dir'
  done
}

test_conf_rejects_unsafe_base() {
  local v
  for v in '--upload-pack=x' 'a..b' 'has space' 'x~1'; do
    new_repo; mk_conf "base = $v"
    conf_fails 'base'
  done
}

test_conf_rejects_non_numeric_values() {
  new_repo; mk_conf 'budget.S = lots'; conf_fails 'budget.S'
  mk_conf 'status_max_chars = -1'; conf_fails 'status_max_chars'
  mk_conf 'reviewer = maybe'; conf_fails 'reviewer'
}

test_conf_works_from_a_subdirectory() {
  new_repo; mk_conf 'base = trunk'
  mkdir -p deep/er && cd deep/er || exit 1
  conf_is base trunk
}

test_conf_rejects_directory_forms_that_break_the_gates() {
  local v
  for v in 'cards/' './cards' 'cards//sub' '.' 'a/./b'; do
    new_repo; mk_conf "cards_dir = $v"
    conf_fails 'cards_dir'
  done
  new_repo; mk_conf 'cards_dir = work/cards' 'log_dir = .log'
  card conf cards_dir; assert_rc 0
}

test_conf_rejects_equal_cards_and_log_directories() {
  new_repo; mk_conf 'cards_dir = deck' 'log_dir = deck'
  conf_fails 'must differ'
}

test_conf_caps_status_max_chars() {
  new_repo; mk_conf 'status_max_chars = 10000'
  card conf status_max_chars; assert_rc 0
  mk_conf 'status_max_chars = 10001'; conf_fails 'status_max_chars'
  mk_conf 'status_max_chars = 99999999999999999999'; conf_fails 'status_max_chars'
}
