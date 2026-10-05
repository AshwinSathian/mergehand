#!/usr/bin/env bash
# shellcheck disable=SC2154

test_done_sets_only_the_front_matter_line() {
  new_repo; mk_conf; mk_card AUTH-03
  printf '\n## Notes\ndone: false\n' >> cards/AUTH-03-thing.md
  cp cards/AUTH-03-thing.md before
  card done AUTH-03
  assert_rc 0
  assert_eq '6c6
< done: false
---
> done: true' "$(diff before cards/AUTH-03-thing.md)" diff
}

test_done_twice_is_a_no_op() {
  new_repo; mk_conf; mk_card AUTH-03
  card done AUTH-03; cp cards/AUTH-03-thing.md once
  card done AUTH-03
  assert_rc 0
  assert_empty "$(diff once cards/AUTH-03-thing.md)" diff
}

test_done_makes_the_card_done_once_on_base() {
  new_repo; mk_conf; mk_card AUTH-03; commit_all
  card done AUTH-03; commit_all
  card list
  assert_contains "$OUT" 'done     AUTH-03'
}

test_done_keeps_crlf_and_file_mode() {
  new_repo; mk_conf; mk_card AUTH-03
  awk '{ printf "%s\r\n", $0 }' cards/AUTH-03-thing.md > x && mv x cards/AUTH-03-thing.md
  chmod 600 cards/AUTH-03-thing.md
  card done AUTH-03
  assert_rc 0
  assert_eq "$(printf 'done: true\r')" "$(sed -n 6p cards/AUTH-03-thing.md)" 'line 6'
  assert_eq '-rw-------' "$(find cards/AUTH-03-thing.md -prune -exec ls -l {} + | cut -c1-10)" mode
  assert_eq 1 "$(find cards -type f | wc -l | tr -d ' ')" 'no stray files'
}

test_done_refuses_bad_or_unknown_or_duplicated_ids() {
  new_repo; mk_conf; mk_card AUTH-03 S '' false one; mk_card AUTH-03 S '' false two; mk_card AUTH-04
  card done; assert_rc 2
  card done auth-03; assert_rc 2
  card done AUTH-99; assert_rc 1
  card done AUTH-03; assert_rc 1
  assert_contains "$ERR" 'two cards have the id'
  assert_contains "$(cat cards/AUTH-03-one.md)" 'done: false'
}

test_done_without_a_done_line() {
  new_repo; mk_conf; mk_card AUTH-03; edit cards/AUTH-03-thing.md '/^done:/d'
  card done AUTH-03
  assert_rc 1
  assert_contains "$ERR" 'card: cards/AUTH-03-thing.md: '
}
