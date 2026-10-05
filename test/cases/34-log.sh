#!/usr/bin/env bash
# shellcheck disable=SC2154

today() { date +%Y-%m-%d; }
field() { awk -v k="$1:" 'index($0, k) == 1 { sub(/^[^:]*: */, ""); print; exit }' "$2"; }

test_log_new_creates_the_entry() {
  new_repo; mk_conf; mk_card AUTH-03 M; commit_all; git checkout -q -b card/AUTH-03-thing
  card log-new AUTH-03 done
  assert_rc 0
  local f; f="log/$(today)-AUTH-03-1.md"
  assert_eq "$f" "$OUT" 'printed path'
  assert_eq "---
card: AUTH-03
date: $(today)
outcome: done
branch: card/AUTH-03-thing
size: M
budget_tokens: 100000
baseline_tokens: unknown
peak_tokens: unknown
growth_tokens: unknown
compacted: unknown
---

## Done

## Tests

## Deviations

## Follow-ups" "$(cat "$f")" content
  card lint
  assert_rc 0
}

test_log_new_takes_the_next_free_number() {
  new_repo; mk_conf; mk_card AUTH-03
  card log-new AUTH-03 blocked
  card log-new AUTH-03 review-fixes
  assert_eq "log/$(today)-AUTH-03-2.md" "$OUT" second
  mk_log AUTH-03 "$(today)" 9
  card log-new AUTH-03 split
  assert_eq "log/$(today)-AUTH-03-3.md" "$OUT" 'fills the first gap'
  assert_eq split "$(field outcome "$OUT")" outcome
}

test_log_new_respects_log_dir_and_custom_budget() {
  new_repo; mk_conf 'log_dir = work/log' 'budget.S = 12345'; mk_card AUTH-03
  card log-new AUTH-03 done
  assert_rc 0
  assert_eq "work/log/$(today)-AUTH-03-1.md" "$OUT" path
  assert_eq 12345 "$(field budget_tokens "$OUT")" budget
}

test_log_new_rejects_bad_arguments() {
  new_repo; mk_conf; mk_card AUTH-03
  card log-new; assert_rc 2
  card log-new AUTH-03; assert_rc 2
  card log-new AUTH-03 finished; assert_rc 2
  assert_contains "$ERR" 'done, split, blocked or review-fixes'
  card log-new auth-03 done; assert_rc 2
  card log-new AUTH-99 done; assert_rc 1
  assert_no_file log
}

test_log_new_on_detached_head() {
  new_repo; mk_conf; mk_card AUTH-03; commit_all; git checkout -q --detach
  card log-new AUTH-03 done
  assert_rc 0
  card lint
  assert_rc 0
}
