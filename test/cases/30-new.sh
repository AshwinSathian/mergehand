#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2016

# fill <file>: put one item under each required section.
fill() {
  awk '{ print } /^## (Read|Touch|Tests|Acceptance)$/ { print "- item" }' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

test_new_creates_a_card_from_the_template() {
  new_repo; mk_conf
  card new AUTH-03 'Token refresh'
  assert_rc 0
  assert_eq cards/AUTH-03-token-refresh.md "$OUT" 'printed path'
  assert_eq '---
id: AUTH-03
title: Token refresh
size: S
depends:
done: false
---

## Read

## Touch

## Tests

## Acceptance

## Out of scope

## Notes' "$(cat cards/AUTH-03-token-refresh.md)" content
}

test_new_card_fails_lint_until_filled() {
  new_repo; mk_conf
  card new AUTH-03 'Token refresh'
  card lint
  assert_rc 1
  assert_contains "$ERR" '## Touch has no items'
  fill cards/AUTH-03-token-refresh.md
  card lint
  assert_rc 0
}

test_new_size_and_depends() {
  new_repo; mk_conf; mk_card AUTH-01; mk_card AUTH-02
  card new AUTH-03 --size M 'Token refresh' --depends AUTH-01,AUTH-02
  assert_rc 0
  assert_contains "$(cat "$OUT")" 'size: M'
  assert_contains "$(cat "$OUT")" 'depends: AUTH-01, AUTH-02'
  fill "$OUT"
  card lint
  assert_rc 0
}

test_new_rejects_size_without_budget() {
  new_repo; mk_conf
  card new AUTH-03 'Token refresh' --size XL
  assert_rc 2
  assert_contains "$ERR" 'size XL has no budget'
  assert_no_file cards
}

test_new_refuses_existing_id() {
  new_repo; mk_conf; mk_card AUTH-03
  card new AUTH-03 'Another one'
  assert_rc 1
  assert_contains "$ERR" 'cards/AUTH-03-thing.md'
  assert_no_file cards/AUTH-03-another-one.md
}

test_new_rejects_bad_arguments() {
  new_repo; mk_conf
  card new auth-03 'Title'; assert_rc 2
  card new AUTH-03; assert_rc 2
  card new AUTH-03 ''; assert_rc 2
  card new AUTH-03 'a' 'b'; assert_rc 2
  card new AUTH-03 'Title' --size; assert_rc 2
  card new AUTH-03 'Title' --depends 'auth-1'; assert_rc 2
  card new AUTH-03 'Title' --frob; assert_rc 2
  card new AUTH-03 "$(printf '%0100d' 0)"; assert_rc 2; assert_contains "$ERR" '80'
  card new AUTH-03 "two
lines"; assert_rc 2
  card new AUTH-03 '"Quoted"'; assert_rc 2
  assert_no_file cards
}

test_new_title_is_literal_and_slug_is_safe() {
  new_repo; mk_conf
  card new AUTH-03 'Fix: $(touch pwned) & "quotes" / ../x'
  assert_rc 0
  assert_eq cards/AUTH-03-fix-touch-pwned-quotes-x.md "$OUT" path
  assert_contains "$(cat "$OUT")" 'title: Fix: $(touch pwned) & "quotes" / ../x'
  assert_no_file pwned
}

test_new_title_without_letters_or_digits() {
  new_repo; mk_conf
  card new AUTH-03 '???'
  assert_rc 0
  assert_eq cards/AUTH-03.md "$OUT" path
}

test_new_long_title_gets_a_short_slug() {
  new_repo; mk_conf
  card new AUTH-03 'A very long title that goes on and on and on and on until the very end ok'
  assert_rc 0
  [ "${#OUT}" -le 60 ] || fail "path is ${#OUT} characters: $OUT"
  case $OUT in *-.md) fail "slug ends with a hyphen: $OUT" ;; esac
}

test_new_quick_id_and_custom_dir() {
  new_repo; mk_conf 'cards_dir = work/cards'
  card new Q-2610051432 'Fix typo' --size XS
  assert_rc 0
  assert_eq work/cards/Q-2610051432-fix-typo.md "$OUT" path
}
