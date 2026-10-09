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

test_show_prints_a_row_that_has_no_card_file() {
  new_repo; mk_conf; mk_outline; commit_all
  printf '\n## AUTH-03 Count \033[31mrefreshes\n- size: XS\n- does: A \007count is kept\n' >> cards/plan/auth.md
  card show AUTH-02
  assert_rc 0
  assert_eq 'row: no card file yet
## AUTH-02 Token refresh
- size: S
- depends: AUTH-01
- spec: Refresh
- spec: Errors
- does: A refresh returns a new token and makes the old one invalid
- does: An expired token is refused with 401
- not: Counting refreshes (AUTH-03)' "$OUT" row
  # The working tree's copy of the outline wins, and control characters go.
  card show AUTH-03
  assert_rc 0
  assert_eq 'row: no card file yet
## AUTH-03 Count [31mrefreshes
- size: XS
- does: A count is kept' "$OUT" 'row in the working tree'
  # A row id longer than 40 characters is not a row, as in card list.
  local long=AUTH-0000000000000000000000000000000000000007
  printf '\n## %s Long\n- size: XS\n- does: Something\n' "$long" >> cards/plan/auth.md
  card show "$long"
  assert_rc 1
  assert_empty "$OUT" stdout
}

test_show_first_line_for_a_row_says_there_is_no_card_file_yet() {
  new_repo; mk_conf; mk_outline; commit_all
  card show AUTH-01
  assert_rc 0
  assert_eq 'row: no card file yet' "$(printf '%s\n' "$OUT" | head -n 1)" 'first line'
  assert_empty "$ERR" stderr
}

test_show_prints_the_card_once_its_file_exists() {
  new_repo; mk_conf; mk_outline; commit_all
  mk_card AUTH-01 S '' false token-store
  card show AUTH-01
  assert_rc 0
  assert_eq "$(cat cards/AUTH-01-token-store.md)" "$OUT" card
  assert_empty "$(printf '%s\n' "$OUT" | grep '^row:')" 'row: lines'
  # On the base branch and not in the working tree: the message of 0.1.
  commit_all; rm cards/AUTH-01-token-store.md
  card show AUTH-01
  assert_rc 1
  assert_eq "card: no card AUTH-01 in cards (no cards with prefix AUTH; run 'card list')" "$ERR" message
  assert_empty "$OUT" stdout
}

test_show_for_an_id_with_no_card_and_no_row_lists_the_same_prefix() {
  new_repo; mk_conf; mk_outline; mk_card AUTH-04; mk_card DB-01; commit_all
  card show AUTH-99
  assert_rc 1
  assert_eq 'card: no card AUTH-99 in cards; cards with prefix AUTH: AUTH-04' "$ERR" message
  assert_empty "$OUT" stdout
  card show DB-02
  assert_rc 1
  assert_contains "$ERR" 'card: no card DB-02 in cards; cards with prefix DB: DB-01'
}
