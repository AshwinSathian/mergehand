#!/usr/bin/env bash
# shellcheck disable=SC2154

O=cards/plan/auth.md
C=cards/AUTH-02-token-refresh.md

# deck: a repository with the outline of mk_outline, committed.
deck() {
  new_repo; mk_conf; mk_outline; commit_all
}
refused() {
  assert_rc 1
  assert_contains "$ERR" "card: "
  assert_contains "$ERR" "$1"
  assert_empty "$OUT" stdout
}

test_plan_start_creates_the_card_file_from_the_row() {
  deck
  local head
  head=$(git rev-parse HEAD)
  card plan start AUTH-02
  assert_rc 0
  assert_eq '---
id: AUTH-02
title: Token refresh
size: S
depends: AUTH-01
done: false
---

## Read
- specs/auth.md (row AUTH-02: Refresh; Errors)

## Touch

## Tests

## Acceptance
- A refresh returns a new token and makes the old one invalid
- An expired token is refused with 401

## Out of scope
- Counting refreshes (AUTH-03)

## Notes' "$(cat "$C")" content
  # Written in the working tree, and nothing is committed or staged.
  assert_eq "$head" "$(git rev-parse HEAD)" 'HEAD'
  assert_eq "?? $C" "$(git status --porcelain)" 'status'
}

test_plan_start_writes_the_specification_and_its_headings_under_read() {
  deck
  card plan start AUTH-02
  assert_rc 0
  assert_eq '- specs/auth.md (row AUTH-02: Refresh; Errors)' "$(sed -n '/^## Read$/,/^## Touch$/p' "$C" | grep '^- ')" 'Read'
  # A heading is written as it is in the outline.
  edit "$O" 's/^- spec: Storage$/- spec: Storage; (hashed)/'
  card plan start AUTH-01
  assert_rc 0
  assert_contains "$(cat cards/AUTH-01-token-store.md)" '- specs/auth.md (row AUTH-01: Storage; (hashed))'
}

test_plan_start_writes_a_comment_with_no_headings_for_a_row_with_no_spec_item() {
  deck
  edit "$O" '/^- spec: Storage$/d'
  card plan start AUTH-01
  assert_rc 0
  assert_eq '- specs/auth.md (row AUTH-01)' "$(sed -n '/^## Read$/,/^## Touch$/p' "$OUT" | grep '^- ')" 'Read'
}

test_plan_start_copies_the_does_lines_to_acceptance() {
  deck
  card plan start AUTH-01
  assert_rc 0
  assert_eq '- A token is stored hashed, with its expiry
- A stored token can be looked up by its hash' "$(sed -n '/^## Acceptance$/,/^## Out of scope$/p' "$OUT" | grep '^- ')" 'Acceptance'
}

test_plan_start_copies_the_not_lines_to_out_of_scope() {
  deck
  edit "$O" 's/^- not: Counting.*/&\
- not: $(touch pwned) \&\& `x` \\n (AUTH-04)/'
  card plan start AUTH-02
  assert_rc 0
  # shellcheck disable=SC2016
  assert_eq '- Counting refreshes (AUTH-03)
- $(touch pwned) && `x` \n (AUTH-04)' "$(sed -n '/^## Out of scope$/,/^## Notes$/p' "$C" | grep '^- ')" 'Out of scope'
  assert_no_file pwned
  # A row with no not line leaves the section empty.
  card plan start AUTH-01
  assert_rc 0
  assert_empty "$(sed -n '/^## Out of scope$/,/^## Notes$/p' "$OUT" | grep '^- ')" 'Out of scope'
}

test_plan_start_prints_the_path_of_the_card() {
  deck
  card plan start AUTH-02
  assert_rc 0
  assert_eq "$C" "$OUT" 'printed path'
  assert_empty "$ERR" stderr
  # The name is the one card new gives for that id and title.
  rm "$C"
  card new AUTH-02 'Token refresh'
  assert_eq "$C" "$OUT" 'path of card new'
}

test_plan_start_refuses_an_id_with_no_row() {
  deck
  card plan start AUTH-09
  refused 'no row AUTH-09'
  assert_eq '' "$(git status --porcelain)" 'status'
  # With no outline at all.
  git rm -rq cards/plan; commit_all
  card plan start AUTH-01
  refused 'no row AUTH-01'
  assert_no_file cards
}

test_plan_start_refuses_an_id_that_has_a_card_file() {
  deck; mk_card AUTH-02
  card plan start AUTH-02
  refused 'cards/AUTH-02-thing.md: card AUTH-02 already exists'
  assert_no_file "$C"
  # A card that is only on the base branch counts.
  commit_all; git checkout -q -b work; git rm -q cards/AUTH-02-thing.md
  card plan start AUTH-02
  refused 'cards/AUTH-02-thing.md: card AUTH-02 already exists'
  assert_no_file "$C"
}

test_plan_start_refuses_a_row_with_a_fault_and_names_the_outline() {
  deck
  edit "$O" 's/^- depends: AUTH-01$/- depends: nope, AUTH-01/'
  card plan start AUTH-02
  refused "$O: row AUTH-02: depends is not a list of card ids"
  edit "$O" 's/^- depends: nope, AUTH-01$/- depends: AUTH-01/; s/^- size: S$/- size: XL/; s/^## AUTH-01 Token store$/## AUTH-01 "Token" store/'
  card plan start AUTH-02
  refused "$O: row AUTH-02 has no size that has a budget"
  card plan start AUTH-01
  refused "$O: row AUTH-01: the title starts with a quote"
  edit "$O" 's/^## AUTH-01 .*/## AUTH-01/'
  card plan start AUTH-01
  refused "$O: row AUTH-01: the title is empty"
  assert_eq " M $O" "$(git status --porcelain)" 'status'
}

test_plan_start_does_not_write_through_a_symbolic_link() {
  deck
  ln -s "$T/outside.md" "$C"
  card plan start AUTH-02
  refused "$C is a symbolic link"
  assert_no_file "$T/outside.md"
}

test_plan_start_rejects_a_malformed_id() {
  deck
  local id
  for id in auth-02 AUTH AUTH-02-x 'AUTH-02 x' '../AUTH-02' '' '--size'; do
    card plan start "$id"
    assert_rc 2
    assert_contains "$ERR" 'card: '
    assert_empty "$OUT" stdout
  done
  card plan start; assert_rc 2; assert_contains "$ERR" 'usage: card plan'
  card plan start AUTH-02 AUTH-01; assert_rc 2
  assert_eq '' "$(git status --porcelain)" 'status'
}

test_plan_start_card_has_no_front_matter_key_that_card_0_1_3_does_not_know() {
  deck
  card plan start AUTH-02
  assert_rc 0
  assert_eq 'id title size depends done ' "$(awk 'NR > 1 && $0 == "---" { exit } NR > 1 { sub(/:.*/, ""); printf "%s ", $0 }' "$C")" 'keys'
  assert_eq 'false' "$(sed -n 's/^done: //p' "$C")" 'done'
}
