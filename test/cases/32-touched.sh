#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2016

# start <touch entry...>: a repo with card A-1 on base, on branch card/A-1-thing.
start() {
  new_repo; mk_conf; mk_card A-1; set_touch "$@"; commit_all
  git checkout -q -b card/A-1-thing
}
set_touch() {
  local e
  { awk '/^## Touch$/ { exit } { print }' cards/A-1-thing.md
    echo '## Touch'
    for e in "$@"; do printf -- '- %s\n' "$e"; done
    printf '\n## Tests\n- thing works\n\n## Acceptance\n- It works.\n'
  } > x.tmp && mv x.tmp cards/A-1-thing.md
}
change() { local f; for f in "$@"; do mkdir -p "$(dirname "$f")"; echo x >> "$f"; done; }
# verdict <entry> <file>: prints match or miss.
verdict() {
  start "$1"; change "$2"
  card touched A-1
  case $RC in 0) echo match ;; 1) echo miss ;; *) fail "unexpected exit $RC" ;; esac
}

test_touched_all_listed() {
  start 'src/a.ts (new)' 'src/b.ts'
  change src/a.ts src/b.ts; commit_all
  card touched A-1
  assert_rc 0
  assert_empty "$OUT" stdout
}

test_touched_unlisted_file_fails() {
  start 'src/a.ts'
  change src/a.ts src/stray.ts; commit_all
  card touched A-1
  assert_rc 1
  assert_contains "$OUT" 'changed but not in Touch'
  assert_contains "$OUT" '  src/stray.ts'
  assert_not_contains "$OUT" '  src/a.ts'
}

test_touched_listed_but_unchanged_is_reported_not_failed() {
  start 'src/a.ts' 'src/never.ts'
  change src/a.ts; commit_all
  card touched A-1
  assert_rc 0
  assert_contains "$OUT" 'in Touch but not changed'
  assert_contains "$OUT" '  src/never.ts'
}

test_touched_counts_uncommitted_and_untracked_but_not_ignored() {
  start 'src/a.ts'
  echo 'build/' > .gitignore; git add .gitignore; git commit -q -m ignore
  set_touch 'src/a.ts' '.gitignore'
  change src/a.ts; git add src/a.ts
  change src/untracked.ts build/out.js
  card touched A-1
  assert_rc 1
  assert_contains "$OUT" '  src/untracked.ts'
  assert_not_contains "$OUT" 'build/out.js'
  assert_not_contains "$OUT" '  src/a.ts'
}

test_touched_skips_cards_logs_and_touch_ignore() {
  start 'src/a.ts'
  mk_conf 'touch_ignore = package-lock.json, *.snap , gen/*'
  git add workdeck.conf; git commit -q -m conf; git checkout -q main; git merge -q card/A-1-thing; git checkout -q card/A-1-thing
  change src/a.ts package-lock.json src/deep/x.snap gen/a/b.ts
  mk_log A-1; mk_card A-2
  card done A-1
  card touched A-1
  assert_rc 0
  assert_empty "$OUT" stdout
}

test_touched_deleted_file_must_be_listed() {
  start 'src/a.ts'
  git rm -q README.md; commit_all
  card touched A-1
  assert_rc 1
  assert_contains "$OUT" '  README.md'
}

test_touched_rename_needs_both_paths() {
  start 'docs/NEW.md'
  mkdir docs; git mv README.md docs/NEW.md; commit_all
  card touched A-1
  assert_rc 1
  assert_contains "$OUT" '  README.md'
  assert_not_contains "$OUT" '  docs/NEW.md'
}

test_touched_non_ascii_file_name() {
  start 'src/café.ts'
  change 'src/café.ts' 'src/naïve.ts'; commit_all
  card touched A-1
  assert_rc 1
  assert_contains "$OUT" '  src/naïve.ts'
  assert_not_contains "$OUT" 'caf'
}

test_touched_path_with_a_space() {
  start 'src/my?file.ts'
  change 'src/my file.ts' 'src/other file.ts'
  card touched A-1
  assert_rc 1
  assert_contains "$OUT" '  src/other file.ts'
  assert_not_contains "$OUT" 'my file'
}

test_touched_entries_are_patterns_never_code() {
  start '$(touch pwned)' '`touch pwned2`' '*) touch pwned3 ;;' 'src/a.ts'
  change src/a.ts
  card touched A-1
  assert_no_file pwned; assert_no_file pwned2; assert_no_file pwned3
  assert_contains "$OUT" '  $(touch'
}

# With a remote, a card branch cut from a local base that is ahead of
# origin/<base> must not be blamed for the unpushed commits.
test_touched_ignores_unpushed_base_commits() {
  new_repo; mk_conf; mk_card A-1; set_touch 'src/a.ts'; commit_all; add_remote
  change other-card.ts; commit_all 'merged locally, not pushed'
  git checkout -q -b card/A-1-thing
  change src/a.ts; commit_all
  card touched A-1
  assert_rc 0
  assert_not_contains "$OUT" 'other-card.ts'
}

test_touched_after_base_moved_on() {
  start 'src/a.ts'
  change src/a.ts; commit_all
  git checkout -q main; change unrelated.ts; commit_all 'someone else'; git checkout -q card/A-1-thing
  card touched A-1
  assert_rc 0
}

test_touched_bad_arguments() {
  start 'src/a.ts'
  card touched; assert_rc 2
  card touched a-1; assert_rc 2
  card touched A-9; assert_rc 1
}

# Challenge: how do shell case patterns differ from what a gitignore user
# expects? These pin the actual behavior; docs/findings.md discusses it.
test_touch_pattern_directory_entry_covers_the_directory() { assert_eq match "$(verdict 'src/' src/a.ts)"; }
test_touch_pattern_directory_entry_covers_nested_files() { assert_eq match "$(verdict 'src/' src/x/y.ts)"; }
test_touch_pattern_directory_entry_is_not_a_prefix() { assert_eq miss "$(verdict 'src/' srcx/a.ts)"; }
test_touch_pattern_star_crosses_directories() { assert_eq match "$(verdict 'src/*.ts' src/x/y.ts)"; }
test_touch_pattern_double_star_needs_a_directory() { assert_eq miss "$(verdict '**/a.ts' a.ts)"; }
test_touch_pattern_double_star_in_a_directory() { assert_eq match "$(verdict '**/a.ts' src/x/a.ts)"; }
test_touch_pattern_leading_slash_is_ignored() { assert_eq match "$(verdict '/src/a.ts' src/a.ts)"; }
test_touch_pattern_leading_dot_slash_is_ignored() { assert_eq match "$(verdict './src/a.ts' src/a.ts)"; }
test_touch_pattern_negation_is_literal() { assert_eq miss "$(verdict '!src/gen.ts' src/gen.ts)"; }
test_touch_pattern_bare_extension_matches_any_depth() { assert_eq match "$(verdict '*.ts' src/x/y.ts)"; }
test_touch_pattern_directory_star() { assert_eq match "$(verdict 'src/*' src/x/y.ts)"; }
test_touch_pattern_bare_name_is_not_a_basename_match() { assert_eq miss "$(verdict 'a.ts' src/a.ts)"; }
test_touch_pattern_character_class() { assert_eq match "$(verdict 'src/[ab].ts' src/b.ts)"; }

test_touch_ignore_directory_entry() {
  start 'src/a.ts'
  mk_conf 'touch_ignore = dist/, ./gen/'
  git add workdeck.conf; git commit -q -m conf; git checkout -q main; git merge -q card/A-1-thing; git checkout -q card/A-1-thing
  change src/a.ts dist/x.js dist/deep/y.js gen/z.ts
  card touched A-1
  assert_rc 0
  assert_empty "$OUT" stdout
}

test_touched_reports_the_normalised_unused_entry() {
  start 'src/a.ts' 'lib/'
  change src/a.ts
  card touched A-1
  assert_rc 0
  assert_contains "$OUT" '  lib/*'
}
