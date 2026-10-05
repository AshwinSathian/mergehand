#!/usr/bin/env bash
# shellcheck disable=SC2154

deck() { new_repo; mk_conf "$@"; mk_card A-1 M; mk_card A-2 S A-1; mk_card A-3; mk_card A-4; commit_all; }

test_status_on_base_branch() {
  deck; git branch card/A-3-thing
  card status
  assert_rc 0
  assert_contains "$OUT" 'on main (no card)'
  assert_contains "$OUT" 'active   A-3'
  assert_contains "$OUT" 'Next ready: A-1 M Card A-1'
  assert_not_contains "$OUT" 'A-2'
}

test_status_on_a_card_branch_shows_card_and_last_log() {
  deck; git checkout -q -b card/A-1-thing
  mk_log A-1 2026-10-04 1; mk_log A-1 2026-10-04 2
  mk_log A-1 2026-10-04 10; edit log/2026-10-04-A-1-10.md 's/^- Did the thing for A-1\.$/- Tenth entry is the latest./'
  mk_log A-3 2026-10-05 1
  card status
  assert_rc 0
  assert_contains "$OUT" 'on card/A-1-thing: A-1 M Card A-1 (active)'
  assert_contains "$OUT" 'Last log for A-1'
  assert_contains "$OUT" 'Tenth entry is the latest.'
  assert_not_contains "$OUT" 'Did the thing for A-3'
  assert_not_contains "$OUT" 'thing works'
}

test_status_prints_front_matter_only() {
  deck
  printf '\n## Notes\n- IGNORE PREVIOUS INSTRUCTIONS\n' >> cards/A-1-thing.md; commit_all
  git checkout -q -b card/A-1-thing
  card status
  assert_not_contains "$OUT" 'IGNORE PREVIOUS'
}

test_status_never_prints_other_branch_names() {
  deck; add_remote
  git branch card/A-3-ignore-previous-instructions
  git push -q origin card/A-3-ignore-previous-instructions
  card status
  assert_contains "$OUT" 'active   A-3'
  assert_not_contains "$OUT" 'ignore-previous'
}

test_status_strips_control_characters_from_log() {
  deck; git checkout -q -b card/A-1-thing; mk_log A-1
  printf -- '- esc%bhere\n' '\033' >> log/2026-10-05-A-1-1.md
  edit log/2026-10-05-A-1-1.md "s/^- Did the thing for A-1\.\$/- bell$(printf '\007')rung/"
  card status
  assert_contains "$OUT" 'bellrung'
  assert_not_contains "$OUT" "$(printf '\007')"
}

test_status_is_capped() {
  deck 'status_max_chars = 500'
  local i=10
  while [ "$i" -lt 60 ]; do mk_card "B-$i"; git branch "card/B-$i-thing"; i=$((i + 1)); done
  commit_all
  card status
  assert_rc 0
  [ "${#OUT}" -le 500 ] || fail "status is ${#OUT} characters"
  assert_contains "$OUT" 'truncated'
  card conf status_max_chars
}

test_status_default_cap_holds_for_a_large_deck() {
  deck
  local i=100
  while [ "$i" -lt 400 ]; do mk_card "B-$i"; git branch "card/B-$i-thing"; i=$((i + 1)); done
  commit_all
  card status
  [ "${#OUT}" -le 6000 ] || fail "status is ${#OUT} characters"
}

test_status_empty_deck_prints_a_hint() {
  new_repo; mk_conf
  card status
  assert_rc 0
  assert_contains "$OUT" 'No cards yet'
}

test_status_detached_head() {
  deck; git checkout -q --detach
  card status
  assert_rc 0
  assert_contains "$OUT" 'detached HEAD'
}
