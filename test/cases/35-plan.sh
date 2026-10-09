#!/usr/bin/env bash
# shellcheck disable=SC2154

O=cards/plan/auth.md
S=specs/auth.md

deck() { new_repo; mk_conf; mk_outline; }
# spec <line...>: adds lines to the specification. accept: records its hash.
spec() { printf '%s\n' "$@" >> "$S"; }
accept() { edit "$O" "s/^spec_blob:.*/spec_blob: $(git hash-object "$S")/"; }
# cite <heading>: one more spec item in row AUTH-02.
cite() { edit "$O" "s/^- spec: Errors\$/- spec: Errors\\
- spec: $1/"; }
findings() { printf '%s\n' "$ERR" | grep -c '^card: '; }
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
  deck; edit "$O" '/^## Not planned$/,$d'; printf -- '- spec: Overview\n- spec: Non-goals\n' >> "$O"
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

# --- ids and sizes ---

test_plan_reports_a_malformed_row_id() {
  local id
  for id in auth-01 AUTH01 AUTH-1x2 AUTH-; do
    deck; edit "$O" "s/^## AUTH-01 /## $id /"
    plan_fails "row id $id is not valid (expected something like AUTH-03)"
  done
  # An id of any length would reach the session that reads the findings.
  id=AUTH-0000000000000000000000000000000000000001
  deck; edit "$O" "s/^## AUTH-02 /## $id /"
  plan_fails 'line 14: a row id is longer than 40 characters'
  assert_not_contains "$ERR" "$id"
  assert_eq 1 "$(printf '%s\n' "$ERR" | grep -c '^card: ')" 'findings'
}

test_plan_reports_a_row_id_that_carries_a_letter() {
  deck; edit "$O" 's/^## AUTH-02 /## AUTH-02b /'
  plan_fails 'row id AUTH-02b carries a letter'
  assert_not_contains "$ERR" 'is not valid'
  # Two faults in one id are both reported.
  deck; edit "$O" 's/^## AUTH-02 /## PAY-02b /'
  plan_fails 'row id PAY-02b carries a letter'
  assert_contains "$ERR" 'row id PAY-02b does not start with the prefix AUTH'
}

test_plan_reports_a_row_id_with_another_prefix() {
  deck; edit "$O" 's/^## AUTH-02 /## PAY-02 /'
  plan_fails 'row id PAY-02 does not start with the prefix AUTH'
  assert_not_contains "$ERR" 'AUTH-01'
  # A prefix the format check refused is not held against the rows.
  deck; edit "$O" 's/^prefix: AUTH$/prefix: auth/'
  plan_fails 'prefix is not valid'
  assert_eq 1 "$(printf '%s\n' "$ERR" | grep -c '^card: ')" 'findings'
}

test_plan_reports_an_id_in_two_rows() {
  deck; edit "$O" 's/^## AUTH-02 /## AUTH-01 /'
  plan_fails 'id AUTH-01 is in two rows'
  assert_eq 1 "$(printf '%s\n' "$ERR" | grep -c '^card: ')" 'findings'
  # Once for an id, however many rows have it.
  deck; edit "$O" 's/^## AUTH-02 /## AUTH-01 /'; printf '\n## AUTH-01 Third\n- size: S\n- does: A thing\n' >> "$O"
  plan_fails 'id AUTH-01 is in two rows'
  assert_eq 1 "$(printf '%s\n' "$ERR" | grep -c '^card: ')" 'findings'
  # Ids are one set across outlines.
  deck; sed 's/^prefix: AUTH$/prefix: PAY/' "$O" > cards/plan/pay.md
  plan_fails "id AUTH-01 is in two rows (the other is in $O)" cards/plan/pay.md
  assert_contains "$ERR" 'card: cards/plan/pay.md: id AUTH-02 is in two rows'
  assert_not_contains "$ERR" "card: $O: "
}

test_plan_reports_two_outlines_that_share_a_prefix() {
  # Only an outline that also breaks the file name rule can share a prefix.
  deck; sed 's/-0\([12]\)/-1\1/' "$O" > cards/plan/tokens.md
  plan_fails "prefix AUTH is also the prefix of $O" cards/plan/tokens.md
  assert_contains "$ERR" 'card: cards/plan/tokens.md: file name is not the prefix in lowercase (expected auth.md)'
  assert_not_contains "$ERR" "card: $O: "
}

test_plan_reports_the_prefix_q() {
  new_repo; mk_conf; mk_outline Q
  plan_fails 'prefix Q is the prefix of the quick lane' cards/plan/q.md
}

test_plan_reports_a_size_with_no_budget() {
  deck; edit "$O" '1,/^- size: S$/s/^- size: S$/- size: L/'
  plan_fails 'row AUTH-01: size L has no budget in workdeck.conf'
  assert_not_contains "$ERR" 'AUTH-02'
  # A size of any length that has a budget passes.
  new_repo; mk_conf 'budget.EXTRALARGE = 200000'; mk_outline; edit "$O" 's/^- size: S$/- size: EXTRALARGE/'
  card plan
  assert_silent
  # A size that is not a size at all is reported too. The order is the
  # format check, then the ids, then the sizes.
  deck; edit "$O" 's/^## AUTH-02 /## AUTH-01 /'; edit "$O" 's/^- size: S$/- size: big one/'; edit "$O" '/^level:/d'
  plan_fails 'row AUTH-01: size is not a size (capitals and digits, like S)'
  assert_eq 'format,two rows,size,size' "$(printf '%s\n' "$ERR" | sed -e 's/.*has no level.*/format/' -e 's/.*two rows.*/two rows/' -e 's/.*is not a size.*/size/' | paste -sd, -)" 'order'
  new_repo; mk_conf 'budget.L = 150000'; mk_outline; edit "$O" 's/^- size: S$/- size: L/'
  card plan
  assert_silent
}

# --- dependencies, specification and coverage ---

test_plan_reports_a_dependency_that_is_neither_a_row_nor_a_card() {
  deck; edit "$O" 's/^- depends: AUTH-01$/- depends: AUTH-01, PAY-09/'
  plan_fails 'row AUTH-02: depends on PAY-09, which is neither a row nor a card'
  assert_eq 1 "$(findings)" 'findings'
  # What is not an id is not printed.
  deck; edit "$O" 's/^- depends: AUTH-01$/- depends: AUTH-01, the store/'
  plan_fails 'row AUTH-02: depends has an invalid id'
  assert_not_contains "$ERR" 'the store'
  deck; edit "$O" 's/^- depends: AUTH-01$/- depends: PAY-00000000000000000000000000000000000009/'
  plan_fails 'row AUTH-02: depends has an invalid id'
  assert_not_contains "$ERR" 'PAY-0'
  # The order is dependencies, then specifications, then coverage.
  deck; edit "$O" 's/^- depends: AUTH-01$/- depends: AUTH-01, PAY-09/'; cite Gone
  mk_outline PAY; git rm -q -f specs/pay.md
  card plan
  assert_eq 'dependency,specification,coverage' "$(printf '%s\n' "$ERR" | sed -e 's/.*neither a row.*/dependency/' -e 's/.*is missing$/specification/' -e 's/.*cites the heading.*/coverage/' | paste -sd, -)" 'order'
}

test_plan_accepts_a_dependency_on_a_card_that_has_a_file() {
  deck; mk_card PAY-09; edit "$O" 's/^- depends: AUTH-01$/- depends: AUTH-01, PAY-09/'
  card plan
  assert_silent
  # A card that is only on the base branch is a card.
  commit_all; git checkout -q -b other; git rm -q cards/PAY-09-thing.md
  card plan
  assert_silent
  # So is one that cannot be read, and the cards after it are still read.
  git checkout -q cards/PAY-09-thing.md 2>/dev/null || git checkout -q main -- cards/PAY-09-thing.md
  mk_card AAA-01; chmod 000 cards/AAA-01-thing.md
  edit "$O" 's/^- depends: AUTH-01, PAY-09$/- depends: AUTH-01, PAY-09, AAA-01/'
  card plan
  assert_silent
}

test_plan_reports_a_cycle_through_rows_and_cards() {
  # AUTH-01 -> PAY-09 (a card) -> AUTH-02 -> AUTH-01.
  deck; edit "$O" 's/^- spec: Storage$/- depends: PAY-09\
- spec: Storage/'
  mk_card PAY-09
  card plan
  assert_silent
  mk_card PAY-09 S AUTH-02
  plan_fails 'row AUTH-01 is in, or depends on, a dependency cycle'
  assert_contains "$ERR" 'row AUTH-02 is in, or depends on, a dependency cycle'
  assert_eq 2 "$(findings)" 'findings'
  # Rows alone.
  deck; edit "$O" 's/^- spec: Storage$/- depends: AUTH-02\
- spec: Storage/'
  plan_fails 'row AUTH-01 is in, or depends on, a dependency cycle'
  # Of an id in two rows the first is the node, and it is said once.
  deck; edit "$O" 's/^- spec: Storage$/- depends: AUTH-01\
- spec: Storage/'; edit "$O" 's/^## AUTH-02 /## AUTH-01 /'
  plan_fails 'row AUTH-01 is in, or depends on, a dependency cycle'
  assert_eq 1 "$(printf '%s\n' "$ERR" | grep -c 'dependency cycle')" 'cycle findings'
}

test_plan_reports_a_specification_that_is_missing() {
  deck; git rm -q -f "$S"
  plan_fails "the specification $S is missing"
  # Coverage has nothing to read, and says nothing.
  assert_eq 1 "$(findings)" 'findings'
  # A link could point outside the repository.
  deck; rm "$S"; ln -s ../README.md "$S"; git add "$S"
  plan_fails "the specification $S is not a regular file"
  rm "$S"; deck; chmod 000 "$S"
  # Root reads any file.
  [ -r "$S" ] && return 0
  plan_fails "the specification $S cannot be read"
  assert_eq 1 "$(findings)" 'findings'
}

test_plan_reads_no_specification_for_an_outline_that_is_only_on_the_base_branch() {
  # A branch cut before the plan merged has neither file, and one that is
  # behind has an older specification.
  new_repo; mk_conf; commit_all; git checkout -q -b card/X-01-thing
  git checkout -q main; mk_outline; commit_all; git checkout -q card/X-01-thing
  assert_no_file "$O"; assert_no_file "$S"
  card plan
  assert_silent
  mkdir specs; echo '## Other' > "$S"; git add "$S"
  card plan
  assert_silent
}

test_plan_reports_a_specification_that_is_untracked() {
  deck; git rm -q --cached "$S"
  plan_fails "the specification $S is not tracked by git"
  assert_eq 1 "$(findings)" 'findings'
}

test_plan_reports_a_heading_that_no_row_cites() {
  deck; spec '' '## Limits' '## Limits'
  plan_fails "the heading \"Limits\" of $S is cited by no row and is not under Not planned"
  assert_eq 1 "$(findings)" 'findings'
  # A heading with no ASCII letter or digit is a heading too, and two of
  # them are not one.
  deck; spec '' '## 概要' '## 制限' '## ???'; echo '- 概要' >> "$O"
  plan_fails "the heading \"制限\" of $S is cited by no row"
  assert_contains "$ERR" 'the heading "???"'
  assert_eq 2 "$(findings)" 'findings'
  # No control character of a heading is printed, and no more than 80 bytes.
  deck; printf '\n## Li\033[31mmits\302\233 and %0100d\n' 7 >> "$S"
  plan_fails 'the heading "Li[31mmits and 0000'
  assert_eq 1 "$(findings)" 'findings'
  assert_eq 1 "$(printf '%s\n' "$ERR" | grep -c '^.\{1,200\}$')" 'short lines'
}

test_plan_accepts_a_heading_listed_under_not_planned() {
  deck; spec '' '## Limits'; accept; echo '- Limits' >> "$O"
  card plan
  assert_silent
}

test_plan_checks_coverage_of_an_outline_with_no_not_planned_section() {
  deck; edit "$O" '/^## Not planned$/,$d'
  plan_fails "the heading \"Overview\" of $S is cited by no row and is not under Not planned"
  assert_contains "$ERR" 'the heading "Non-goals"'
  assert_eq 2 "$(findings)" 'findings'
  printf -- '- spec: Overview\n- spec: Non-goals\n' >> "$O"
  card plan
  assert_silent
}

test_plan_ignores_a_heading_inside_a_code_fence() {
  # A fence ends at the mark that opened it, at least as long, with no
  # text after it.
  deck; spec '' '```sh' '## In a fence' '```' '~~~' '## In tildes' '```' '## Still in tildes' '~~~'
  spec '````' '```' '## In four' '```' '```sh' '## Still in four' '````'
  # A line with text after the mark does not end a fence, and a fence may be
  # indented by up to three spaces.
  spec '```' '``` sh' '## After text' '```' '   ```' '## Indented fence' ' ```'; accept
  card plan
  assert_silent
  cite 'In a fence'
  plan_fails 'row AUTH-02 cites the heading "In a fence"'
  # A heading after an indented closing fence is seen again.
  deck; spec '' '```' 'x' '  ```' '## After'
  plan_fails 'the heading "After"'
}

test_plan_reports_a_row_that_cites_a_heading_the_specification_lacks() {
  deck; cite Gone
  plan_fails "row AUTH-02 cites the heading \"Gone\", which $S does not have at level 2"
  assert_eq 1 "$(findings)" 'findings'
}

test_plan_lets_a_done_row_cite_a_heading_that_is_gone() {
  # Done is read from the base branch.
  deck; cite Gone; mk_card AUTH-02 S '' true
  plan_fails 'row AUTH-02 cites the heading "Gone"'
  commit_all
  card plan
  assert_silent
}

test_plan_reports_a_not_planned_heading_the_specification_lacks() {
  deck; echo '- Gone' >> "$O"
  plan_fails "Not planned lists the heading \"Gone\", which $S does not have at level 2"
  assert_eq 1 "$(findings)" 'findings'
}

test_plan_compares_headings_without_case_or_punctuation() {
  deck; edit "$S" 's/^## Refresh$/## Re-fresh: ##/'; accept
  edit "$O" 's/^- spec: Storage$/- spec: storage!/'; edit "$O" 's/^- Non-goals$/- NON GOALS/'
  card plan
  assert_silent
  # Dashes and curly quotes are punctuation; a heading with no letter or
  # digit is compared less its spaces.
  deck; spec '' '## Phase 1 — Setup' "## User’s guide" '## ? ? ?'; accept
  printf '%s\n' '- Phase 1 - Setup' "- User's guide" '- ???' >> "$O"
  card plan
  assert_silent
  # Line ends of another system, and a byte-order mark.
  deck; printf '\357\273\277## Overview\r\n## Storage\r\n## Refresh\r\n## Errors\r\n```\r\n## In a fence\r\n```\r\n   ## Non-goals\r\n' > "$S"; accept
  card plan
  assert_silent
}

test_plan_checks_only_headings_at_the_level_of_the_outline() {
  # "# Tokens" is in the specification from the start.
  deck; spec '' '### Detail' '##No space' '' 'Underlined' '----------'; accept
  card plan
  assert_silent
  cite Detail
  plan_fails "row AUTH-02 cites the heading \"Detail\", which $S does not have at level 2"
  deck; spec '' '### Detail'; accept; edit "$O" 's/^level: 2$/level: 3/'
  plan_fails "the heading \"Detail\" of $S is cited by no row"
  assert_contains "$ERR" "row AUTH-01 cites the heading \"Storage\", which $S does not have at level 3"
  assert_contains "$ERR" 'Not planned lists the heading "Overview"'
}

test_plan_says_the_specification_changed_and_exits_zero() {
  deck; spec '' 'A sentence more.'
  card plan
  assert_rc 0
  assert_eq "$O: the specification $S differs from spec_blob" "$OUT" stdout
  assert_empty "$ERR" stderr
  # It is said beside the findings too.
  cite Gone
  card plan
  assert_rc 1
  assert_contains "$OUT" 'differs from spec_blob'
  # A spec_blob the format check refused is not compared.
  deck; edit "$O" 's/^spec_blob:.*/spec_blob: none/'
  plan_fails 'spec_blob is not what git hash-object prints'
  assert_empty "$OUT" stdout
  # A hash that git cannot make is not a change.
  deck; echo 'specs/*.md filter=boom' > .gitattributes
  git config filter.boom.clean false; git config filter.boom.required true
  plan_fails "the specification $S cannot be read"
  assert_empty "$OUT" stdout
}
