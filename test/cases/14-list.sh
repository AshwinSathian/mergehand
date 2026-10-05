#!/usr/bin/env bash
# shellcheck disable=SC2154

ids() { printf '%s\n' "$OUT" | awk '{ print $2 }' | tr '\n' ' '; }

test_list_one_line_per_card() {
  new_repo; mk_conf; mk_card AUTH-03 M; commit_all
  card list
  assert_rc 0
  assert_eq 'ready    AUTH-03      M   Card AUTH-03' "$OUT" line
}

test_list_natural_order() {
  new_repo; mk_conf
  mk_card AUTH-10; mk_card Q-2610051432 XS; mk_card AUTH-2; mk_card AUTH-03b; mk_card AUTH-03; mk_card DB-1
  commit_all
  card list
  assert_eq 'AUTH-2 AUTH-03 AUTH-03b AUTH-10 DB-1 Q-2610051432 ' "$(ids)" order
}

test_list_empty_deck() {
  new_repo; mk_conf
  card list
  assert_rc 0
  assert_empty "$OUT" stdout
}

test_list_strips_control_characters_and_caps_titles() {
  new_repo; mk_conf; mk_card AUTH-03
  edit cards/AUTH-03-thing.md "s/^title:.*\$/title: a$(printf '\033')[31mb$(printf '\007')c/"
  commit_all
  card list
  assert_contains "$OUT" 'a[31mbc'
  edit cards/AUTH-03-thing.md "s/^title:.*\$/title: $(printf '%0200d' 0)/"
  commit_all
  card list
  assert_eq 80 "$(printf '%s' "$OUT" | awk '{ print length($4) }')" 'title length'
}

test_list_reads_front_matter_only() {
  new_repo; mk_conf; mk_card AUTH-03
  printf '\ndone: true\ntitle: Not this\n' >> cards/AUTH-03-thing.md
  commit_all
  card list
  assert_contains "$OUT" 'ready'
  assert_contains "$OUT" 'Card AUTH-03'
}

test_list_tolerates_crlf() {
  new_repo; mk_conf; mk_card AUTH-03 M
  awk '{ printf "%s\r\n", $0 }' cards/AUTH-03-thing.md > x && mv x cards/AUTH-03-thing.md
  commit_all
  card list
  assert_eq 'ready    AUTH-03      M   Card AUTH-03' "$OUT" line
}
