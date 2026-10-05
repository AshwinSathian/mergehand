#!/usr/bin/env bash
# shellcheck disable=SC2154
# The transcript format is not a documented interface. These fixtures pin the
# shape card tokens understands; a format change shows up here.

TX="$FIX/transcripts"
deck() { new_repo; mk_conf; mk_card AUTH-03 M; commit_all; }

test_tokens_prints_baseline_peak_and_growth() {
  deck
  card tokens "$TX/normal.jsonl"
  assert_rc 0
  assert_eq 'baseline 57000
peak 141300
growth 84300' "$OUT" figures
}

test_tokens_defaults_to_the_session_transcript() {
  deck
  WORKDECK_TRANSCRIPT="$TX/normal.jsonl" card tokens
  assert_rc 0
  assert_contains "$OUT" 'growth 84300'
}

test_tokens_keeps_the_peak_after_compaction() {
  deck
  card tokens "$TX/compacted.jsonl"
  assert_eq 'baseline 50000
peak 150000
growth 100000' "$OUT" figures
}

test_tokens_ignores_sidechain_and_zero_usage_lines() {
  deck
  card tokens "$TX/sidechain.jsonl"
  assert_eq 'baseline 5000
peak 7000
growth 2000' "$OUT" figures
}

test_tokens_ignores_the_nested_iterations_copy() {
  deck
  card tokens "$TX/iterations-only.jsonl"
  assert_eq 'baseline 5000
peak 6000
growth 1000' "$OUT" figures
}

test_tokens_ignores_usage_inside_tool_results() {
  deck
  card tokens "$TX/tool-result-usage.jsonl"
  assert_eq 'baseline 5000
peak 6000
growth 1000' "$OUT" figures
}

test_tokens_prints_unknown_for_unrecognized_shapes() {
  deck
  local f
  for f in no-usage.jsonl garbage.jsonl empty.jsonl does-not-exist.jsonl; do
    card tokens "$TX/$f"
    assert_rc 0
    assert_eq unknown "$OUT" "$f"
    assert_empty "$ERR" "stderr for $f"
  done
  card tokens
  assert_rc 0
  assert_eq unknown "$OUT" 'no transcript given'
  card tokens "$T"
  assert_rc 0
  assert_eq unknown "$OUT" 'a directory'
}

test_tokens_prints_the_budget_on_a_card_branch() {
  deck; git checkout -q -b card/AUTH-03-thing
  card tokens "$TX/normal.jsonl"
  assert_eq 'baseline 57000
peak 141300
growth 84300
budget 100000 M' "$OUT" figures
  card tokens "$TX/empty.jsonl"
  assert_eq 'unknown
budget 100000 M' "$OUT" 'unknown still shows the budget'
  git checkout -q -b card/NOPE-1-thing
  card tokens "$TX/normal.jsonl"
  assert_rc 0
  assert_not_contains "$OUT" budget
}
