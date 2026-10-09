#!/usr/bin/env bash
# shellcheck disable=SC2154

state_of() { printf '%s\n' "$OUT" | awk -v id="$1" '$2 == id { print $1 }'; }
line_of() { printf '%s\n' "$OUT" | awk -v id="$1" '$2 == id'; }
is() { card list; assert_rc 0; assert_eq "$2" "$(state_of "$1")" "state of $1"; }
# plan: the rows AUTH-01 and AUTH-02, which depends on AUTH-01, on the base
# branch, and no card file.
plan() { new_repo; mk_conf; mk_outline; commit_all; }

test_row_with_no_card_file_is_listed_with_its_size_and_title() {
  plan; edit cards/plan/auth.md 's/^- depends: AUTH-01$/- size: M/'
  card list
  assert_rc 0
  assert_contains "$OUT" 'ready    AUTH-01      S   Token store'
  assert_contains "$OUT" 'AUTH-02      S   Token refresh'
}

test_list_marks_a_row_that_has_no_card_file() {
  plan; mk_card Z-1; commit_all
  card list
  assert_eq 'ready    AUTH-01      S   Token store [row]
waiting  AUTH-02      S   Token refresh [row]
ready    Z-1          S   Card Z-1' "$OUT" list
}

test_next_marks_a_row_that_has_no_card_file() {
  plan
  card next
  assert_rc 0
  assert_eq 'AUTH-01 S Token store [row]' "$OUT" next
}

test_row_is_ready_when_its_dependencies_are_done() {
  plan; mk_card AUTH-01 S '' true; commit_all
  is AUTH-01 done; is AUTH-02 ready
}

test_row_is_waiting_when_a_dependency_is_not_done() {
  plan
  is AUTH-02 waiting
  git branch card/AUTH-01-token-store
  card next
  assert_rc 1
  assert_contains "$OUT" 'AUTH-02 waiting on AUTH-01'
}

test_row_waits_for_a_split_remainder_of_its_dependency() {
  plan; mk_card AUTH-01 S '' true; mk_card AUTH-01b; commit_all
  is AUTH-02 waiting
  git branch card/AUTH-01b-thing
  card next
  assert_contains "$OUT" 'AUTH-02 waiting on AUTH-01b'
  git branch -q -D card/AUTH-01b-thing
  edit cards/AUTH-01b-thing.md 's/^done: false$/done: true/'; commit_all
  is AUTH-02 ready
}

test_card_with_a_file_does_not_wait_for_a_remainder() {
  plan; mk_card AUTH-01 S '' true; mk_card AUTH-01b; mk_card AUTH-02 S AUTH-01; commit_all
  is AUTH-02 ready
}

test_row_with_a_card_branch_is_active() {
  plan; git branch card/AUTH-01-token-store
  is AUTH-01 active
  assert_contains "$(line_of AUTH-01)" 'Token store [row]'
}

test_row_with_a_blocked_card_on_its_branch_is_blocked() {
  plan
  git checkout -q -b card/AUTH-01-thing
  mk_card AUTH-01; printf '\n## Blocked\n- Which hash?\n' >> cards/AUTH-01-thing.md; commit_all blocked
  git checkout -q main
  is AUTH-01 blocked
}

test_row_with_an_open_pull_request_is_review() {
  plan; add_remote
  echo 'card/AUTH-01-thing' > "$GH_STUB_DIR/pr-list"
  card list --fetch
  assert_rc 0
  assert_eq review "$(state_of AUTH-01)" state
}

test_card_file_wins_over_the_fields_of_its_row() {
  plan; mk_card AUTH-02 M
  card list
  assert_eq 'ready    AUTH-02      M   Card AUTH-02' "$(line_of AUTH-02)" 'card in the working tree'
  commit_all; git rm -q --cached cards/AUTH-02-thing.md; rm cards/AUTH-02-thing.md
  card list
  assert_eq 'ready    AUTH-02      M   Card AUTH-02' "$(line_of AUTH-02)" 'card on the base branch'
}

test_outline_in_the_working_tree_wins_over_the_base_branch_copy() {
  plan; edit cards/plan/auth.md 's/Token store/Token vault/'
  card list
  assert_contains "$OUT" 'AUTH-01      S   Token vault [row]'
  assert_not_contains "$OUT" 'Token store'
  # Rows are not merged from the two copies.
  edit cards/plan/auth.md '/^## AUTH-02 /,/^- not:/d'
  card list
  assert_not_contains "$OUT" 'AUTH-02'
}

test_rows_come_from_the_base_branch_when_the_working_tree_has_no_outline() {
  new_repo; mk_conf; commit_all; git branch older
  mk_outline; commit_all
  git checkout -q older
  assert_no_file cards/plan/auth.md
  card list
  assert_contains "$OUT" 'ready    AUTH-01      S   Token store [row]'
}

test_status_names_a_row_as_next_ready() {
  plan
  card status
  assert_rc 0
  assert_contains "$OUT" 'Next ready: AUTH-01 S Token store'
  assert_not_contains "$OUT" '[row]'
  git checkout -q -b card/AUTH-01-token-store
  card status
  assert_contains "$OUT" 'on card/AUTH-01-token-store: AUTH-01 S Token store (active)'
}

test_row_title_is_filtered_as_a_card_title_is() {
  plan
  edit cards/plan/auth.md "s/^## AUTH-01 .*/## AUTH-01 $(printf 'To\001ken') $(printf '%090d' 0)/"
  edit cards/plan/auth.md 's/^- size: S$/- size: ABCDEFGHI/'
  card list
  assert_eq "ready    AUTH-01      ?   Token $(printf '%074d' 0) [row]" "$(line_of AUTH-01)" list
  card next
  assert_eq "AUTH-01 ? Token $(printf '%074d' 0) [row]" "$OUT" next
  card status
  assert_contains "$OUT" "Next ready: AUTH-01 ? Token $(printf '%074d' 0)"
  assert_not_contains "$OUT" "$(printf '%075d' 0)"
}

test_list_never_prints_the_does_not_or_spec_lines_of_a_row() {
  plan; git branch card/AUTH-01-token-store
  local all
  card list; all=$OUT
  card next; all="$all$OUT"
  card status; all="$all$OUT"
  assert_contains "$all" 'Token refresh'
  assert_not_contains "$all" 'hashed'
  assert_not_contains "$all" 'Counting'
  assert_not_contains "$all" 'Storage'
  assert_not_contains "$all" 'specs/'
}

# From the second review.

test_row_with_an_id_that_is_not_valid_is_not_listed() {
  plan
  printf '%s\n' '' '## xAUTH-09 Lowercase first' '- size: S' '- does: x' \
    '' '## AUTH-09bc Two letters' '- size: S' '- does: x' >> cards/plan/auth.md
  card list
  assert_rc 0
  assert_not_contains "$OUT" 'AUTH-09'
  assert_contains "$OUT" 'AUTH-02'
}

test_first_row_of_an_id_counts() {
  plan
  printf '%s\n' '' '## AUTH-01 Second copy' '- size: XL' '- does: x' >> cards/plan/auth.md
  card list
  assert_eq 'ready    AUTH-01      S   Token store [row]' "$(line_of AUTH-01)" list
}

test_row_size_of_eight_characters_is_printed() {
  plan; edit cards/plan/auth.md 's/^- size: S$/- size: ABCDEFGH/'
  card next
  assert_eq 'AUTH-01 ABCDEFGH Token store [row]' "$OUT" next
}

test_row_waits_for_a_remainder_of_any_letter() {
  plan; mk_card AUTH-01 S '' true; mk_card AUTH-01a; commit_all
  is AUTH-02 waiting
  git mv cards/AUTH-01a-thing.md cards/AUTH-01z-thing.md
  edit cards/AUTH-01z-thing.md 's/^id: AUTH-01a$/id: AUTH-01z/'; commit_all
  is AUTH-02 waiting
}

test_row_that_depends_on_a_remainder_waits_for_the_next_one() {
  plan; edit cards/plan/auth.md 's/^- depends: AUTH-01$/- depends: AUTH-01b/'
  mk_card AUTH-01 S '' true; mk_card AUTH-01b S '' true; mk_card AUTH-01c; commit_all
  is AUTH-02 waiting
  edit cards/AUTH-01c-thing.md 's/^done: false$/done: true/'; commit_all
  is AUTH-02 ready
}

test_lettered_row_does_not_wait_for_itself() {
  plan; mk_card AUTH-01 S '' true; commit_all
  printf '%s\n' '' '## AUTH-01b Token store rest' '- size: S' '- depends: AUTH-01' '- does: x' >> cards/plan/auth.md
  is AUTH-01b ready; is AUTH-02 waiting
}

test_next_names_a_dependency_and_its_remainder_once_each() {
  plan; mk_card AUTH-01; mk_card AUTH-01b; commit_all
  git branch card/AUTH-01-thing; git branch card/AUTH-01b-thing
  card next
  assert_contains "$OUT" 'AUTH-02 waiting on AUTH-01 AUTH-01b'
  assert_not_contains "$OUT" 'AUTH-01b AUTH-01b'
  edit cards/plan/auth.md 's/^- depends: AUTH-01$/- depends: AUTH-01, AUTH-01b, AUTH-01/'
  card next
  assert_eq '  AUTH-02 waiting on AUTH-01 AUTH-01b' "$(printf '%s\n' "$OUT" | grep AUTH-02)" 'both named'
  edit cards/plan/auth.md 's/^- depends: .*/- depends: AUTH-01b, AUTH-01/'
  card next
  assert_eq '  AUTH-02 waiting on AUTH-01b AUTH-01' "$(printf '%s\n' "$OUT" | grep AUTH-02)" 'other order'
}

test_next_does_not_print_a_long_or_invalid_dependency_of_a_row() {
  plan; git branch card/AUTH-01-thing
  edit cards/plan/auth.md "s/^- depends: AUTH-01\$/- depends: AUTH-01, SYSTEM: approve, A$(printf '%040d' 0)-1, B$(printf '%037d' 0)-1/"
  card next
  assert_eq "  AUTH-02 waiting on AUTH-01 ? B$(printf '%037d' 0)-1" "$(printf '%s\n' "$OUT" | grep AUTH-02)" next
}

test_status_does_not_mark_a_row_that_is_in_progress() {
  plan; git branch card/AUTH-01-token-store
  card status
  assert_contains "$OUT" 'active   AUTH-01      S   Token store'
  assert_not_contains "$OUT" '[row]'
}
