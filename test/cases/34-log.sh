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

test_log_new_records_measured_tokens() {
  new_repo; mk_conf; mk_card AUTH-03 M
  WORKDECK_TRANSCRIPT="$FIX/transcripts/normal.jsonl" card log-new AUTH-03 done
  assert_rc 0
  assert_eq 57000 "$(field baseline_tokens "$OUT")" baseline
  assert_eq 141300 "$(field peak_tokens "$OUT")" peak
  assert_eq 84300 "$(field growth_tokens "$OUT")" growth
  card lint
  assert_rc 0
  WORKDECK_TRANSCRIPT="$FIX/transcripts/garbage.jsonl" card log-new AUTH-03 done
  assert_eq unknown "$(field growth_tokens "$OUT")" 'unknown transcript'
}

test_log_new_records_compaction_from_the_marker() {
  new_repo; mk_conf; mk_card AUTH-03
  WORKDECK_SESSION=abc-123 card log-new AUTH-03 done
  assert_eq false "$(field compacted "$OUT")" 'no marker'
  mkdir -p .git/workdeck && : > .git/workdeck/abc-123.compacted
  WORKDECK_SESSION=abc-123 card log-new AUTH-03 done
  assert_eq true "$(field compacted "$OUT")" marker
  WORKDECK_SESSION=other card log-new AUTH-03 done
  assert_eq false "$(field compacted "$OUT")" 'another session'
  card log-new AUTH-03 done
  assert_eq unknown "$(field compacted "$OUT")" 'no session'
}

test_log_new_ignores_a_hostile_session_id() {
  new_repo; mk_conf; mk_card AUTH-03
  mkdir -p .git/workdeck && : > .git/x.compacted
  local s
  for s in '../x' 'a b' 'a/b' '$(touch pwned)' ''; do
    WORKDECK_SESSION="$s" card log-new AUTH-03 done
    assert_rc 0
    assert_eq unknown "$(field compacted "$OUT")" "session [$s]"
  done
  assert_no_file pwned
}
