#!/usr/bin/env bash
# shellcheck disable=SC2154

O=cards/plan/auth.md

deck() { new_repo; mk_conf; mk_outline; }
plan_fails() {
  card plan
  assert_rc 1
  assert_contains "$ERR" "card: ${2:-$O}: "
  assert_contains "$ERR" "$1"
}

test_plan_with_no_outline_says_so_and_exits_zero() {
  new_repo; mk_conf; mk_card AUTH-03
  card plan
  assert_rc 0
  assert_eq 'no outline in cards/plan' "$OUT" stdout
  assert_empty "$ERR" stderr
}

test_plan_reads_the_working_tree_where_there_is_no_base_branch() {
  mkdir repo && cd repo && git init -q . && mk_conf
  card plan
  assert_rc 0
  assert_eq 'no outline in cards/plan' "$OUT" stdout
  mk_outline; edit "$O" '/^level:/d'
  plan_fails 'front matter has no level'
}

test_plan_reports_an_item_before_the_first_row_heading() {
  deck; edit "$O" 's/^## AUTH-01 /### AUTH-01 /'
  plan_fails 'line 9: an item before the first row heading'
}

test_plan_passes_a_well_formed_outline() {
  deck; mk_card AUTH-03
  card plan
  assert_silent
  card lint
  assert_silent
}

test_plan_passes_an_outline_with_no_not_planned_section() {
  deck; edit "$O" '/^## Not planned$/,$d'
  card plan
  assert_silent
}

test_plan_reports_a_missing_front_matter_key() { deck; edit "$O" '/^level:/d'; plan_fails 'front matter has no level'; }

test_plan_reports_an_unknown_front_matter_key() { deck; edit "$O" 's/^level: 2$/level: 2\
owner: me/'; plan_fails 'unknown front matter key owner'; }

test_plan_reports_a_spec_path_that_leaves_the_repository() {
  local s
  for s in ../auth.md specs/../../auth.md /etc/passwd; do
    deck; edit "$O" "s|^spec:.*\$|spec: $s|"
    plan_fails 'spec must be a relative path inside the repository'
  done
}

test_plan_reports_a_spec_path_with_a_space() {
  deck; edit "$O" 's|^spec:.*$|spec: specs/my auth.md|'
  plan_fails 'spec must be a relative path inside the repository'
}

test_plan_reports_a_level_that_is_not_a_digit_from_1_to_6() {
  local l
  for l in 0 7 12 two ''; do
    deck; edit "$O" "s/^level:.*\$/level: $l/"
    plan_fails 'level must be a digit from 1 to 6'
  done
}

test_plan_reports_a_file_name_that_is_not_the_prefix_in_lowercase() {
  deck; mv "$O" cards/plan/tokens.md
  plan_fails 'file name is not the prefix in lowercase (expected auth.md)' cards/plan/tokens.md
  mv cards/plan/tokens.md cards/plan/AUTH.md
  plan_fails 'file name is not the prefix in lowercase' cards/plan/AUTH.md
  mv cards/plan/AUTH.md 'cards/plan/my auth.md'
  plan_fails 'file name is not a prefix in lowercase' 'cards/plan/my?auth.md'
}

test_plan_reports_a_row_with_no_size() {
  deck; edit "$O" '/^- size:/d'
  plan_fails 'row AUTH-01 has no size'
  assert_contains "$ERR" 'row AUTH-02 has no size'
}

test_plan_reports_a_row_with_no_does() {
  deck; edit "$O" '/^- does: A refresh/d'; edit "$O" '/^- does: An expired/d'
  plan_fails 'row AUTH-02 has no does'
  assert_not_contains "$ERR" 'AUTH-01'
}

test_plan_reports_a_key_twice_that_may_appear_once() {
  deck; edit "$O" 's/^- depends: AUTH-01$/- depends: AUTH-01\
- depends: AUTH-01/'
  plan_fails 'depends appears twice in row AUTH-02'
  deck; edit "$O" 's/^- spec: Storage$/- size: M\
- spec: Storage/'
  plan_fails 'size appears twice in row AUTH-01'
}

test_plan_reports_an_unknown_row_key() { deck; edit "$O" 's/^- spec: Storage$/- owner: me/'; plan_fails 'unknown row key owner'; }

test_plan_reports_a_row_with_no_title() { deck; edit "$O" 's/^## AUTH-01 .*$/## AUTH-01/'; plan_fails 'row AUTH-01 has no title'; }

test_plan_reports_every_failure_with_its_file() {
  deck; mk_outline PAY
  edit "$O" '/^level:/d'; edit "$O" 's/^- spec: Storage$/- owner: me/'
  edit cards/plan/pay.md '/^- size:/d'
  card plan
  assert_rc 1
  assert_empty "$OUT" stdout
  assert_contains "$ERR" "card: $O: front matter has no level"
  assert_contains "$ERR" "card: $O: line 9: unknown row key owner"
  assert_contains "$ERR" 'card: cards/plan/pay.md: row PAY-01 has no size'
  assert_contains "$ERR" 'card: cards/plan/pay.md: row PAY-02 has no size'
  assert_eq 4 "$(printf '%s\n' "$ERR" | grep -c '^card: cards/plan/')" 'findings'
}

test_plan_reads_the_working_tree_copy_of_an_outline_before_the_base_branch_copy() {
  # A fault on the base branch that the working tree has fixed is not reported.
  deck; edit "$O" '/^level:/d'; commit_all
  mk_outline
  card plan
  assert_silent
  # A fault in the working tree is reported though the base branch is clean,
  # and the rows of the two copies are not merged: AUTH-02 is faulty on the
  # base branch and gone here.
  edit "$O" '/^- does: A refresh/d'; edit "$O" '/^- does: An expired/d'; commit_all
  edit "$O" '/^## AUTH-02 /,/^- not:/d'; edit "$O" '/^- size:/d'
  plan_fails 'row AUTH-01 has no size'
  assert_not_contains "$ERR" 'AUTH-02'
  # With no working tree copy, the base branch's is read.
  git checkout -q "$O"; edit "$O" '/^level:/d'; commit_all
  git checkout -q -b other; git rm -q "$O"; commit_all
  assert_no_file "$O"
  plan_fails 'front matter has no level'
}

test_plan_with_an_unknown_subcommand_is_a_usage_error() {
  deck
  card plan bogus
  assert_rc 2
  assert_contains "$ERR" 'usage: card plan'
  assert_empty "$OUT" stdout
  card plan --help
  assert_rc 0
  assert_contains "$OUT" 'usage: card plan'
  card help
  assert_contains "$OUT" '  plan  '
}
