#!/usr/bin/env bash
# shellcheck disable=SC2154

O=cards/plan/auth.md
S=specs/auth.md

# deck: a repository with a tracked specification and no outline.
deck() {
  new_repo; mk_conf; mkdir specs
  printf '%s\n' '# Tokens' '' '## Storage' '' '## Refresh' > "$S"
  git add "$S"
}
refused() {
  assert_rc 1
  assert_contains "$ERR" "card: "
  assert_contains "$ERR" "$1"
  assert_empty "$OUT" stdout
}

test_plan_new_writes_the_front_matter_and_no_rows() {
  deck
  card plan new "$S" AUTH
  assert_rc 0
  assert_eq "$O" "$OUT" 'printed path'
  assert_eq "---
spec: $S
spec_blob: $(git hash-object "$S")
prefix: AUTH
level: 2
---" "$(cat "$O")" content
}

test_plan_new_defaults_the_level_to_2() {
  deck
  card plan new "$S" AUTH
  assert_rc 0
  assert_eq 2 "$(sed -n 's/^level: //p' "$O")" level
}

test_plan_new_takes_a_level() {
  deck
  card plan new --level 1 "$S" AUTH
  assert_rc 0
  assert_eq 1 "$(sed -n 's/^level: //p' "$O")" level
  rm "$O"
  card plan new "$S" AUTH --level 7; assert_rc 2
  card plan new "$S" AUTH --level; assert_rc 2
  card plan new "$S" AUTH --level two; assert_rc 2
  assert_no_file "$O"
}

test_plan_new_refuses_a_prefix_that_an_outline_uses() {
  new_repo; mk_conf; mk_outline; mv "$O" cards/plan/other.md
  card plan new "$S" AUTH
  refused 'prefix AUTH is the prefix of cards/plan/other.md'
  assert_no_file "$O"
}

test_plan_new_refuses_a_prefix_that_a_card_uses() {
  deck; mk_card AUTH-03
  card plan new "$S" AUTH
  refused 'card AUTH-03 has the prefix AUTH'
  assert_no_file cards/plan
}

test_plan_new_refuses_the_prefix_q() {
  deck
  card plan new "$S" Q
  refused 'prefix Q is the prefix of the quick lane'
  card plan new "$S" auth; assert_rc 2; assert_contains "$ERR" 'not a prefix'; assert_contains "$ERR" 'usage: card plan'
  card plan new "$S" AUTH-01; assert_rc 2
  card plan new "$S"; assert_rc 2; assert_contains "$ERR" 'usage: card plan'
  card plan new "$S" AUTH extra; assert_rc 2
  card plan new "$S" AUTH --frob; assert_rc 2
  assert_no_file cards
}

test_plan_new_refuses_a_file_that_exists() {
  deck; mkdir -p cards/plan; echo kept > "$O"
  card plan new "$S" AUTH
  refused "$O already exists"
  assert_eq kept "$(cat "$O")" content
  rm -r cards/plan; mkdir "$T/out"; ln -s "$T/out" cards/plan
  card plan new "$S" AUTH
  refused 'cards/plan is a symbolic link'
  assert_no_file "$T/out/auth.md"
}

test_plan_new_refuses_a_specification_that_is_not_tracked() {
  deck; echo '## One' > specs/new.md
  card plan new specs/new.md AUTH
  refused 'specs/new.md is not tracked by git'
  card plan new specs/none.md AUTH
  refused 'specs/none.md is missing'
  ln -s auth.md specs/link.md; git add specs/link.md
  card plan new specs/link.md AUTH
  refused 'specs/link.md is not a regular file'
  assert_no_file cards
}

test_plan_new_refuses_a_path_that_leaves_the_repository() {
  deck
  local p
  for p in ../auth.md specs/../../auth.md /etc/passwd "$PWD/$S" ./specs/auth.md; do
    card plan new "$p" AUTH
    refused 'a relative path inside the repository'
  done
  assert_no_file cards
}

test_plan_new_refuses_a_path_with_a_space() {
  deck; cp "$S" 'specs/my spec.md'; git add 'specs/my spec.md'
  card plan new 'specs/my spec.md' AUTH
  refused 'has a space'
  assert_no_file cards
}

test_plan_new_names_the_levels_that_have_headings() {
  deck
  card plan new "$S" AUTH --level 3
  refused "$S has no heading at level 3; levels with headings: 1, 2"
  printf 'no headings\n' > specs/flat.md; git add specs/flat.md
  card plan new specs/flat.md AUTH
  refused 'specs/flat.md has no heading at level 2; it has no headings'
  assert_no_file cards
}

test_plan_accept_sets_spec_blob_to_the_current_value() {
  new_repo; mk_conf; mk_outline
  echo 'More text.' >> "$S"
  card plan
  assert_rc 0
  assert_contains "$OUT" 'differs from spec_blob'
  cp "$O" "$T/before"
  card plan accept AUTH
  assert_silent
  assert_eq "$(git hash-object "$S")" "$(sed -n 's/^spec_blob: //p' "$O")" spec_blob
  assert_eq "$(grep -v '^spec_blob:' "$T/before")" "$(grep -v '^spec_blob:' "$O")" 'the other lines'
  assert_eq "$(wc -l < "$T/before")" "$(wc -l < "$O")" 'line count'
  card plan
  assert_silent
  # A last line with no newline stays as it is.
  printf '%s' "$(cat "$O")" > "$O"; echo 'Again.' >> "$S"; cp "$O" "$T/before"
  card plan accept AUTH
  assert_silent
  assert_eq 1 "$(diff "$T/before" "$O" | grep -c '^>')" 'changed lines'
  assert_eq 0 "$(tail -c 1 "$O" | wc -l | tr -d ' ')" 'final newline'
}

test_plan_accept_refuses_a_prefix_with_no_outline() {
  deck
  card plan accept AUTH
  refused 'no outline for the prefix AUTH'
  card plan accept; assert_rc 2; assert_contains "$ERR" 'usage: card plan'
  card plan accept auth; assert_rc 2
  card plan accept AUTH extra; assert_rc 2
}
