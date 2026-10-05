#!/usr/bin/env bash
# shellcheck disable=SC2154

row() { printf '%s\n' "$OUT" | awk -v s="$1" '$1 == s { $1 = $1; print }'; }

test_stats_reports_median_and_maximum_per_size() {
  new_repo; mk_conf
  mk_log A-1 2026-10-01 1 done S 30000 false
  mk_log A-2 2026-10-01 1 done S 90000 true
  mk_log A-3 2026-10-02 1 done S 50000 false
  mk_log A-4 2026-10-02 1 done M 10000 false
  mk_log A-5 2026-10-02 1 done M 20000 false
  card stats
  assert_rc 0
  assert_contains "$OUT" 'size'
  assert_eq 'S 3 70000 50000 90000 33%' "$(row S)" 'odd count'
  assert_eq 'M 2 100000 15000 20000 0%' "$(row M)" 'even count'
  assert_eq 'XS 0 35000 - - -' "$(row XS)" 'no sessions'
}

test_stats_leaves_unknown_out_of_the_median() {
  new_repo; mk_conf
  mk_log A-1 2026-10-01 1 done S 30000 false
  mk_log A-2 2026-10-01 1 done S 50000 true
  mk_log A-3 2026-10-02 1 done S 1 false
  local k
  for k in baseline_tokens peak_tokens growth_tokens compacted; do edit log/2026-10-02-A-3-1.md "s/^$k:.*\$/$k: unknown/"; done
  card stats
  assert_eq 'S 3 70000 40000 50000 50%' "$(row S)" row
}

test_stats_orders_sizes_by_budget_and_includes_custom_ones() {
  new_repo; mk_conf 'budget.L = 150000' 'log_dir = work/log'
  LOG_DIR=work/log mk_log A-1 2026-10-01 1 done L 120000 false
  LOG_DIR=work/log mk_log A-2 2026-10-01 1 done OLD 5 false
  card stats
  assert_eq 'XS S M L OLD ' "$(printf '%s\n' "$OUT" | awk 'NR > 1 { printf "%s ", $1 }')" order
  assert_eq 'OLD 1 - 5 5 0%' "$(row OLD)" 'size without a budget'
}

test_stats_without_logs() {
  new_repo; mk_conf
  card stats
  assert_rc 0
  assert_contains "$OUT" 'no session logs in log'
}

test_stats_says_how_many_sessions_are_unmeasured() {
  new_repo; mk_conf
  mk_log A-1 2026-10-01 1 done S 30000 false; mk_log A-2 2026-10-01 1; mk_log A-3 2026-10-01 1
  local k
  for k in baseline_tokens peak_tokens growth_tokens; do edit log/2026-10-01-A-2-1.md "s/^$k:.*\$/$k: unknown/"; edit log/2026-10-01-A-3-1.md "s/^$k:.*\$/$k: unknown/"; done
  card stats
  assert_contains "$OUT" '2 of 3 sessions have no measurement'
  edit log/2026-10-01-A-2-1.md 's/^growth_tokens:.*$/growth_tokens: 5/'; edit log/2026-10-01-A-3-1.md 's/^growth_tokens:.*$/growth_tokens: 5/'
  card stats
  assert_not_contains "$OUT" 'no measurement'
}
