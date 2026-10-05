#!/usr/bin/env bash
# shellcheck disable=SC2154

test_show_prints_the_card() {
  new_repo; mk_conf; mk_card AUTH-03 M '' false token-refresh
  card show AUTH-03
  assert_rc 0
  assert_eq "$(cat cards/AUTH-03-token-refresh.md)" "$OUT" card
}

test_show_respects_cards_dir() {
  new_repo; mk_conf 'cards_dir = work/cards'
  CARDS_DIR=work/cards mk_card AUTH-03
  card show AUTH-03
  assert_rc 0
  assert_contains "$OUT" 'id: AUTH-03'
}

test_show_rejects_malformed_ids_before_touching_files() {
  new_repo; mk_conf; mk_card AUTH-03
  local id
  for id in auth-03 '../x' 'A-1;rm' 'AUTH-' 'AUTH-03bb' '-x' 'AUTH-03 ' '*'; do
    card show "$id"
    assert_rc 2
    assert_contains "$ERR" 'card: '
    assert_empty "$OUT" stdout
  done
  card show
  assert_rc 2
}

test_show_unknown_id_lists_same_prefix() {
  new_repo; mk_conf; mk_card AUTH-01; mk_card AUTH-02; mk_card DB-01
  card show AUTH-99
  assert_rc 1
  assert_contains "$ERR" 'card: no card AUTH-99 in cards'
  assert_contains "$ERR" 'AUTH-01 AUTH-02'
  assert_not_contains "$ERR" 'DB-01'
}

test_show_refuses_a_duplicated_id() {
  new_repo; mk_conf
  mk_card AUTH-03 S '' false one; mk_card AUTH-03 S '' false two
  card show AUTH-03
  assert_rc 1
  assert_contains "$ERR" 'cards/AUTH-03-one.md'
  assert_contains "$ERR" 'cards/AUTH-03-two.md'
}

test_show_does_not_confuse_neighbouring_ids() {
  new_repo; mk_conf
  mk_card AUTH-1 S '' false a; mk_card AUTH-10 S '' false b; mk_card AUTH-1b S '' false c
  card show AUTH-1
  assert_rc 0
  assert_contains "$OUT" 'id: AUTH-1'
  assert_not_contains "$OUT" 'AUTH-10'
  assert_not_contains "$OUT" 'AUTH-1b'
}

test_show_unknown_prefix_has_no_dangling_colon() {
  new_repo; mk_conf; mk_card DB-01
  card show AUTH-99
  assert_rc 1
  assert_eq "card: no card AUTH-99 in cards (no cards with prefix AUTH; run 'card list')" "$ERR" message
}
