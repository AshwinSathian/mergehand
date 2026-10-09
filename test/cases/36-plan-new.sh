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
  printf -- '---\nspec: %s\nspec_blob: %s\nprefix: AUTH\nlevel: 2\n---\n' "$S" "$(git hash-object "$S")" > "$T/want"
  cmp -s "$T/want" "$O" || fail "content differs: $(cat "$O")"
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
  # An outline that is only on the base branch counts.
  commit_all; git checkout -q -b work; git rm -q cards/plan/other.md
  card plan new "$S" AUTH
  refused 'prefix AUTH is the prefix of cards/plan/other.md'
}

test_plan_new_refuses_a_prefix_that_a_card_uses() {
  deck; mk_card AUTH-03
  card plan new "$S" AUTH
  refused 'card AUTH-03 has the prefix AUTH'
  assert_no_file cards/plan
  # A card that is only on the base branch counts.
  commit_all; git checkout -q -b work; git rm -q cards/AUTH-03-thing.md
  card plan new "$S" AUTH
  refused 'card AUTH-03 has the prefix AUTH'
  # The start of another prefix is not that prefix.
  card plan new "$S" AU
  assert_rc 0
}

test_plan_new_refuses_the_prefix_q() {
  deck
  card plan new "$S" Q
  refused 'prefix Q is the prefix of the quick lane'
  card plan new "$S" auth; assert_rc 2; assert_contains "$ERR" 'not a prefix'; assert_contains "$ERR" 'usage: card plan'
  card plan new "$S" AUTH-01; assert_rc 2
  card plan new "$S" "A$(printf '%030d' 0)"; assert_rc 2; assert_contains "$ERR" '30 characters'
  card plan ''; assert_rc 2
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
  rm cards/plan; mkdir cards/plan; ln -s "$T/out/auth.md" "$O"
  card plan new "$S" AUTH
  refused "$O already exists"
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
  card plan new "specs/auth.md$(printf '\t')" AUTH
  refused 'a relative path inside the repository'
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

test_plan_accept_changes_no_other_byte() {
  new_repo; mk_conf; mk_outline; chmod 755 "$O"
  # CRLF, and a line in the body that looks like the front matter's.
  printf -- '- not: x\nspec_blob: zz\n' >> "$O"
  sed "s/\$/$(printf '\r')/" "$O" > "$T/crlf" && cat "$T/crlf" > "$O"
  echo 'More text.' >> "$S"
  sed "s/^spec_blob: [0-9a-f]\\{40\\}/spec_blob: $(git hash-object "$S")/" "$O" > "$T/want"
  card plan accept AUTH
  assert_silent
  cmp -s "$T/want" "$O" || fail "bytes differ: $(diff "$T/want" "$O")"
  [ -x "$O" ] || fail 'the mode changed'
}

test_plan_accept_refuses_what_it_should_not_hash_or_write() {
  new_repo; mk_conf; mk_outline; cp "$O" "$T/good"
  local v
  # A spec that leaves the repository, is not tracked, or is a link.
  echo x > "$T/x"; echo y > untracked.md; ln -s auth.md specs/link.md; git add specs/link.md
  for v in ../x "$T/x" untracked.md .git/HEAD specs/link.md specs/none.md; do
    sed "s|^spec: .*|spec: $v|" "$T/good" > "$O"; cp "$O" "$T/before"
    card plan accept AUTH
    refused "$O: "
    cmp -s "$T/before" "$O" || fail "the outline changed for spec: $v"
  done
  sed '/^spec_blob:/d' "$T/good" > "$O"; echo 'spec_blob: body' >> "$O"; cp "$O" "$T/before"
  card plan accept AUTH
  refused 'front matter has no spec_blob line'
  cmp -s "$T/before" "$O" || fail 'the outline changed'
  { cat "$T/good"; printf 'a\0b tail\n'; } > "$O"
  card plan accept AUTH
  refused 'has a NUL byte'
  # Neither the outline nor its directory is followed as a link.
  mkdir "$T/out"; cp "$T/good" "$T/out/auth.md"; rm "$O"; ln -s "$T/out/auth.md" "$O"
  echo 'More text.' >> "$S"
  card plan accept AUTH
  refused 'no outline for the prefix AUTH'
  rm -r cards/plan; ln -s "$T/out" cards/plan
  card plan accept AUTH
  refused 'cards/plan is a symbolic link'
  cmp -s "$T/good" "$T/out/auth.md" || fail 'a file outside the repository changed'
}

test_plan_accept_refuses_a_prefix_with_no_outline() {
  deck
  card plan accept AUTH
  refused 'no outline for the prefix AUTH'
  card plan accept; assert_rc 2; assert_contains "$ERR" 'usage: card plan'
  card plan accept auth; assert_rc 2
  card plan accept AUTH extra; assert_rc 2
}
