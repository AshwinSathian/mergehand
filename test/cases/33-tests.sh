#!/usr/bin/env bash
# shellcheck disable=SC2154

# start <tests line...>: card A-1 on base with those Tests lines; on its branch.
start() {
  local l
  new_repo; mk_conf; mk_card A-1
  { awk '/^## Tests$/ { exit } { print }' cards/A-1-thing.md
    echo '## Tests'
    for l in "$@"; do printf -- '- %s\n' "$l"; done
    printf '\n## Acceptance\n- It works.\n'
  } > x.tmp && mv x.tmp cards/A-1-thing.md
  commit_all
  git checkout -q -b card/A-1-thing
}
# gate <fixture> <tests line>: prints found or missing.
gate() {
  start "$2"; cp "$FIX/lang/$1" .
  card tests A-1
  case $RC in 0) echo found ;; 1) echo missing ;; *) fail "unexpected exit $RC" ;; esac
}

test_gate_matches_snake_camel_and_string_names() {
  start 'refresh rotates the token'
  echo 'def test_refresh_rotates_the_token(): pass' > a.py
  card tests A-1; assert_rc 0; assert_empty "$OUT" stdout
  rm a.py; echo 'func TestRefreshRotatesTheToken(t *testing.T) {}' > a_test.go
  card tests A-1; assert_rc 0
  rm a_test.go; echo "it('refresh rotates the token', () => {})" > a.test.ts
  card tests A-1; assert_rc 0
}

test_gate_lists_each_missing_line() {
  start 'refresh rotates the token' 'expired refresh token is rejected' 'third thing happens'
  echo 'def test_refresh_rotates_the_token(): pass' > a.py; commit_all
  card tests A-1
  assert_rc 1
  assert_contains "$OUT" '  expired refresh token is rejected'
  assert_contains "$OUT" '  third thing happens'
  assert_contains "$OUT" 'innermost'
  assert_not_contains "$OUT" '  refresh rotates'
}

test_gate_searches_only_files_changed_on_the_branch() {
  new_repo; echo 'def test_thing_works(): pass' > old_test.py; commit_all
  mk_conf; mk_card A-1; commit_all; git checkout -q -b card/A-1-thing
  card tests A-1
  assert_rc 1
  echo '# touched' >> old_test.py
  card tests A-1
  assert_rc 0
}

test_gate_card_and_log_do_not_satisfy_themselves() {
  start 'thing works'
  mk_log A-1; echo '- thing works' >> cards/A-1-thing.md
  card tests A-1
  assert_rc 1
}

test_gate_line_without_letters_or_digits() {
  start '???'
  echo x > a.py
  card tests A-1
  assert_rc 1
  assert_contains "$OUT" 'no letters or digits'
}

test_gate_card_without_tests_items() {
  start
  card tests A-1
  assert_rc 1
  assert_contains "$ERR" 'card: cards/A-1-thing.md: '
}

test_gate_ignores_deleted_files_and_handles_spaces() {
  start 'thing works'
  git rm -q README.md
  echo 'def test_thing_works(): pass' > 'my test.py'
  card tests A-1
  assert_rc 0
}

test_gate_bad_arguments() {
  start 'thing works'
  card tests; assert_rc 2
  card tests a-1; assert_rc 2
  card tests A-9; assert_rc 1
}

# Challenge: does the gate produce false failures on real test files?
# "found" rows are the gate working; "missing" rows are false failures, where
# the test exists but its name is split across a nesting level or reworded.
# docs/development/findings.md has the evidence table.

test_lang_go_function_name() { assert_eq found "$(gate refresh_test.go 'refresh rotates the token')"; }
test_lang_go_subtest_string() { assert_eq found "$(gate refresh_test.go 'expired refresh token is rejected')"; }
test_lang_go_table_driven_case_is_a_false_failure() { assert_eq missing "$(gate refresh_test.go 'refresh keeps the session')"; }
test_lang_python_function_name() { assert_eq found "$(gate test_refresh.py 'refresh rotates the token')"; }
test_lang_python_parametrize_id() { assert_eq found "$(gate test_refresh.py 'zero ttl is rejected')"; }
test_lang_python_class_method_is_a_false_failure() { assert_eq missing "$(gate test_refresh.py 'refresh keeps the session')"; }
test_lang_python_contraction_is_a_false_failure() { assert_eq missing "$(gate test_refresh.py "doesn't leak the token")"; }
test_lang_typescript_it_string() { assert_eq found "$(gate refresh.test.ts 'refresh rejects an expired token')"; }
test_lang_typescript_template_string_with_number() { assert_eq found "$(gate refresh.test.ts 'refresh returns 401 on a revoked token')"; }
test_lang_typescript_describe_plus_it_is_a_false_failure() { assert_eq missing "$(gate refresh.test.ts 'refresh rotates the token')"; }
test_lang_typescript_wrapped_name_is_a_false_failure() { assert_eq missing "$(gate refresh.test.ts 'keeps the session alive when the access token is renewed')"; }
test_lang_rust_function_name() { assert_eq found "$(gate refresh.rs 'refresh rejects an expired token')"; }
test_lang_rust_module_plus_function_is_a_false_failure() { assert_eq missing "$(gate refresh.rs 'refresh rotates the token')"; }
test_lang_dropped_article_is_a_false_failure() { assert_eq missing "$(gate refresh.rs 'refresh rejects expired token')"; }
# The gate also passes when it should not: it is a presence check on text.
test_lang_short_line_is_a_false_pass() { assert_eq found "$(gate refresh.test.ts 'works')"; }
test_lang_comment_is_a_false_pass() { assert_eq found "$(gate refresh.test.ts 'revokes every session on logout')"; }

test_gate_heading_with_trailing_space() {
  start 'thing works'
  edit cards/A-1-thing.md 's/^## Tests$/## Tests  /'; edit cards/A-1-thing.md 's/^## Touch$/## Touch /'
  card lint; assert_rc 0
  echo 'def test_thing_works(): pass' > a.py
  card tests A-1; assert_rc 0
  mkdir -p src; echo x > src/thing.txt; git rm -q --cached a.py 2>/dev/null; rm -f a.py
  card touched A-1; assert_rc 0
}

# awk would read an operand like n=0 as a variable assignment and skip the file.
test_gate_file_named_like_an_awk_assignment() {
  start 'thing works'
  echo 'nothing relevant' > 'n=0'
  card tests A-1
  assert_rc 1
  echo 'def test_thing_works(): pass' > 'n=0'
  card tests A-1
  assert_rc 0
}
