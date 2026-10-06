#!/usr/bin/env bash
# shellcheck disable=SC2154

C=cards/AUTH-03-thing.md
L=log/2026-10-05-AUTH-03-1.md

deck() { new_repo; mk_conf; mk_card AUTH-03; }
lint_fails() {
  card lint
  assert_rc 1
  assert_contains "$ERR" "card: ${2:-$C}: "
  assert_contains "$ERR" "$1"
}

test_lint_clean_deck_is_silent() {
  deck; mk_card AUTH-04 M AUTH-03; mk_log AUTH-03
  card lint
  assert_rc 0
  assert_empty "$OUT" stdout
  assert_empty "$ERR" stderr
}

test_lint_empty_deck_passes() {
  new_repo; mk_conf
  card lint
  assert_rc 0
}

test_lint_needs_check() {
  deck; echo 'base = main' > mergehand.conf
  card lint
  assert_rc 2
  assert_contains "$ERR" 'check is not set'
}

test_lint_ignores_review_md() {
  deck; echo '# Rules' > cards/REVIEW.md
  card lint
  assert_rc 0
}

test_lint_file_name_without_id() {
  deck; cp "$C" cards/notes.md
  lint_fails 'does not start with a card id' cards/notes.md
}

test_lint_unknown_key() { deck; edit "$C" 's/^size: S$/size: S\
owner: me/'; lint_fails 'unknown front matter key owner'; }

test_lint_missing_key() { deck; edit "$C" '/^size:/d'; lint_fails 'front matter has no size'; }

test_lint_duplicate_key() { deck; edit "$C" 's/^size: S$/size: S\
size: M/'; lint_fails 'size appears twice'; }

test_lint_nested_value() { deck; edit "$C" 's/^depends:.*$/depends:\
  - AUTH-02/'; lint_fails 'flat key: value'; }

test_lint_quoted_value() { deck; edit "$C" 's/^title:.*$/title: "Quoted"/'; lint_fails 'quoted'; }

test_lint_quotes_inside_a_title_are_fine() {
  deck; edit "$C" 's/^title:.*$/title: Fix the "refresh" path/'
  card lint
  assert_rc 0
}

test_lint_multiline_value() { deck; edit "$C" 's/^title:.*$/title: |/'; lint_fails 'multi-line'; }

test_lint_missing_front_matter() { deck; edit "$C" '1d'; lint_fails 'does not start with'; }

test_lint_unclosed_front_matter() { deck; edit "$C" '7d'; lint_fails 'not closed'; }

test_lint_bad_id() { deck; edit "$C" 's/^id:.*$/id: auth-03/'; lint_fails 'id is not valid'; }

test_lint_id_differs_from_file_name() { deck; edit "$C" 's/^id:.*$/id: AUTH-04/'; lint_fails 'does not match the file name'; }

test_lint_long_title() {
  deck; edit "$C" 's/^title:.*$/title: 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 x/'
  lint_fails 'longer than 80'
}

test_lint_title_of_exactly_80_passes() {
  deck; edit "$C" 's/^title:.*$/title: 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 /'
  edit "$C" 's/^\(title: .*\) $/\1x/'
  card lint
  assert_rc 0
}

test_lint_control_character_in_title() {
  deck; edit "$C" "s/^title:.*\$/title: bell$(printf '\007')here/"
  lint_fails 'control character'
}

test_lint_empty_title() { deck; edit "$C" 's/^title:.*$/title:/'; lint_fails 'title is empty'; }

test_lint_size_without_budget() { deck; edit "$C" 's/^size:.*$/size: XL/'; lint_fails 'size XL has no budget'; }

test_lint_custom_size_with_budget_passes() {
  deck; edit "$C" 's/^size:.*$/size: XL/'; mk_conf 'budget.XL = 200000'
  card lint
  assert_rc 0
}

test_lint_done_value() { deck; edit "$C" 's/^done:.*$/done: yes/'; lint_fails 'done must be true or false'; }

test_lint_dependency_names_no_card() { deck; edit "$C" 's/^depends:.*$/depends: AUTH-99/'; lint_fails 'depends on AUTH-99, which is not a card'; }

test_lint_dependency_with_invalid_id() { deck; edit "$C" 's/^depends:.*$/depends: auth 2/'; lint_fails 'depends has an invalid id'; }

test_lint_dependency_list_with_spaces_passes() {
  deck; mk_card AUTH-01; mk_card AUTH-02; edit "$C" 's/^depends:.*$/depends: AUTH-01 , AUTH-02/'
  card lint
  assert_rc 0
}

test_lint_self_dependency() { deck; edit "$C" 's/^depends:.*$/depends: AUTH-03/'; lint_fails 'dependency cycle'; }

test_lint_two_card_cycle() {
  new_repo; mk_conf; mk_card A-1 S A-2; mk_card A-2 S A-1; mk_card A-3
  card lint
  assert_rc 1
  assert_contains "$ERR" 'card: cards/A-1-thing.md: '
  assert_contains "$ERR" 'card: cards/A-2-thing.md: '
  assert_not_contains "$ERR" 'A-3-thing.md'
}

test_lint_three_card_cycle() {
  new_repo; mk_conf; mk_card A-1 S A-3; mk_card A-2 S A-1; mk_card A-3 S A-2
  lint_fails 'dependency cycle' cards/A-3-thing.md
}

test_lint_duplicate_id() {
  deck; mk_card AUTH-03 S '' false other
  lint_fails 'is also used by' cards/AUTH-03-thing.md
}

test_lint_missing_section() {
  local s
  for s in Read Touch Tests Acceptance; do
    deck; edit "$C" "/^## $s\$/d"
    lint_fails "has no ## $s section"
  done
}

test_lint_empty_section() {
  deck; edit "$C" '/^- thing works$/d'
  lint_fails '## Tests has no items'
  lint_fails 'an item is a line that starts with "- "'
}

test_lint_xs_card_may_leave_read_empty() {
  deck; edit "$C" '/^- README.md$/d'
  lint_fails '## Read has no items'
  edit "$C" 's/^size:.*$/size: XS/'
  card lint
  assert_rc 0
}

test_lint_crlf_card() {
  deck; awk '{ printf "%s\r\n", $0 }' "$C" > "$C.tmp" && mv "$C.tmp" "$C"
  lint_fails 'CRLF'
}

test_lint_reports_every_problem_in_one_run() {
  deck; edit "$C" 's/^size:.*$/size: XL/'; edit "$C" 's/^done:.*$/done: yes/'
  card lint
  assert_contains "$ERR" 'size XL'
  assert_contains "$ERR" 'done must be'
}

test_lint_log_over_40_lines() {
  deck; mk_log AUTH-03
  local i=0
  while [ "$i" -lt 40 ]; do echo "- line $i" >> "$L"; i=$((i + 1)); done
  lint_fails 'longer than 40 lines' "$L"
}

test_lint_log_bad_outcome() { deck; mk_log AUTH-03; edit "$L" 's/^outcome:.*$/outcome: finished/'; lint_fails 'outcome must be' "$L"; }

test_lint_log_missing_key() { deck; mk_log AUTH-03; edit "$L" '/^growth_tokens:/d'; lint_fails 'front matter has no growth_tokens' "$L"; }

test_lint_log_unknown_measurements_pass() {
  deck; mk_log AUTH-03
  local k
  for k in baseline_tokens peak_tokens growth_tokens compacted; do edit "$L" "s/^$k:.*\$/$k: unknown/"; done
  card lint
  assert_rc 0
}

test_lint_log_bad_number() { deck; mk_log AUTH-03; edit "$L" 's/^peak_tokens:.*$/peak_tokens: lots/'; lint_fails 'peak_tokens must be' "$L"; }

test_lint_log_pr_is_optional() {
  deck; mk_log AUTH-03
  edit "$L" 's/^size: S$/size: S\
pr: 42/'
  card lint
  assert_rc 0
  edit "$L" 's/^pr: 42$/pr: forty-two/'
  lint_fails 'pr must be' "$L"
}

test_lint_log_name_must_match_front_matter() {
  deck; mk_log AUTH-03; edit "$L" 's/^card:.*$/card: AUTH-04/'
  lint_fails 'does not match the file name' "$L"
}

test_lint_log_bad_file_name() {
  deck; mk_log AUTH-03; mv "$L" log/notes.md
  lint_fails 'is not named <date>-<id>-<n>.md' log/notes.md
}

test_lint_log_missing_section() {
  deck; mk_log AUTH-03; edit "$L" '/^## Deviations$/d'
  lint_fails 'has no ## Deviations section' "$L"
}

test_lint_crlf_names_only_the_crlf_file() {
  new_repo; mk_conf; mk_card A-1; mk_card A-2; mk_card A-3
  awk '{ printf "%s\r\n", $0 }' cards/A-2-thing.md > x && mv x cards/A-2-thing.md
  card lint
  assert_rc 1
  assert_contains "$ERR" 'card: cards/A-2-thing.md: has CRLF'
  assert_not_contains "$ERR" 'A-1-thing.md'
  assert_not_contains "$ERR" 'A-3-thing.md'
}
