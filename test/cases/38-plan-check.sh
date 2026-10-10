#!/usr/bin/env bash
# shellcheck disable=SC2154

C=cards/A-1-thing.md

# deck: a repository with card A-1 and the files its entries name, committed.
deck() {
  new_repo; mk_conf; mk_card A-1
  mkdir -p src docs
  echo x > src/a.ts; echo x > docs/design.md
  commit_all
}
# body <section> <entry...>: gives the card that section with those entries.
# Read, Touch and Out of scope start as one entry each that passes.
body() {
  local s=$1 e
  shift
  [ -n "${READ+x}" ] || { READ='- README.md'; TOUCH='- src/a.ts'; SCOPE='- Anything else.'; }
  e=$(for e in "$@"; do printf -- '- %s\n' "$e"; done)
  case $s in Read) READ=$e ;; Touch) TOUCH=$e ;; 'Out of scope') SCOPE=$e ;; esac
  { awk '/^## Read$/ { exit } { print }' "$C"
    printf '## Read\n%s\n\n## Touch\n%s\n\n## Tests\n- thing works\n\n## Acceptance\n- It works.\n\n## Out of scope\n%s\n' "$READ" "$TOUCH" "$SCOPE"
  } > x.tmp && mv x.tmp "$C"
}
passes() {
  assert_rc 0
  assert_empty "$OUT" stdout
  assert_empty "$ERR" stderr
}
# finding <text>: exit 1 and a line on stderr that names the card file.
finding() {
  assert_rc 1
  assert_contains "$ERR" "card: $C: $1"
  assert_empty "$OUT" stdout
}

test_plan_check_passes_a_card_whose_paths_exist() {
  deck
  body Read 'README.md' 'docs/design.md'
  body Touch 'src/a.ts' 'src/b.ts (new)' 'docs/' '*.md (the wording)'
  card plan check A-1
  passes
}

test_plan_check_reports_a_read_path_that_does_not_exist() {
  deck; body Read 'README.md' 'docs/gone.md'
  card plan check A-1
  finding 'Read: docs/gone.md does not exist'
  assert_not_contains "$ERR" 'README.md'
}

test_plan_check_ignores_the_anchor_and_the_comment_of_a_read_entry() {
  deck
  body Read 'docs/design.md#7-planned-cards (the three rules)' 'README.md (row A-1: Storage; no such file.md)' './src/a.ts#L10'
  card plan check A-1
  passes
  body Read 'docs/gone.md#7-planned-cards (the three rules)'
  card plan check A-1
  finding 'Read: docs/gone.md does not exist'
}

test_plan_check_accepts_a_read_entry_that_names_a_directory() {
  deck; body Read 'src' 'docs/'
  card plan check A-1
  passes
}

test_plan_check_reports_a_touch_entry_that_matches_no_file() {
  deck; body Touch 'src/a.ts' 'src/gone.ts' 'lib/'
  card plan check A-1
  finding 'Touch: src/gone.ts matches no file'
  assert_contains "$ERR" "card: $C: Touch: lib/ matches no file"
  assert_not_contains "$ERR" 'src/a.ts'
}

test_plan_check_accepts_a_touch_entry_that_matches_an_untracked_file() {
  deck; body Touch 'src/fresh.ts' 'gen/'
  mkdir gen; echo x > src/fresh.ts; echo x > gen/out.ts
  card plan check A-1
  passes
}

test_plan_check_reports_a_new_path_that_exists() {
  deck; body Touch 'src/a.ts (new)' './docs/design.md (new) the design' 'src (new)'
  card plan check A-1
  finding 'Touch: src/a.ts is marked (new) and exists'
  assert_contains "$ERR" "card: $C: Touch: ./docs/design.md is marked (new) and exists"
  assert_contains "$ERR" "card: $C: Touch: src is marked (new) and exists"
}

test_plan_check_reports_a_new_path_that_is_an_ignored_file() {
  deck
  echo 'build/' > .gitignore; commit_all ignore
  mkdir build; echo x > build/out.js
  body Touch 'build/out.js (new)'
  card plan check A-1
  finding 'Touch: build/out.js is marked (new) and exists'
}

test_plan_check_does_not_count_an_ignored_file_for_a_touch_entry() {
  deck
  echo 'build/' > .gitignore; commit_all ignore
  mkdir build; echo x > build/out.js
  body Touch 'build/out.js' 'build/'
  card plan check A-1
  finding 'Touch: build/out.js matches no file'
  assert_contains "$ERR" "card: $C: Touch: build/ matches no file"
}

test_plan_check_reports_a_new_entry_that_is_not_a_full_path() {
  local e
  deck
  for e in 'src/*.ts' 'lib/' 'src/[cd].ts' 'src/?.go' "src/b.ts\\" '/' './' '../b.ts' 'src/../b.ts' 'src//b.ts' 'src/./b.ts' 'src/..'; do
    body Touch "$e (new)"
    card plan check A-1
    finding "Touch: $e is marked (new) and is not a full path"
  done
}

test_plan_check_reports_an_out_of_scope_section_with_no_item() {
  deck; body 'Out of scope'
  card plan check A-1
  finding 'Out of scope has no item'
  # The same with no such section at all.
  mk_card A-1
  card plan check A-1
  finding 'Out of scope has no item'
}

test_plan_check_reports_every_failure() {
  deck
  body Read 'docs/gone.md'
  body Touch 'src/gone.ts' 'src/a.ts (new)' 'src/* (new)'
  body 'Out of scope'
  card plan check A-1
  assert_rc 1
  assert_eq "card: $C: Read: docs/gone.md does not exist
card: $C: Touch: src/gone.ts matches no file
card: $C: Touch: src/a.ts is marked (new) and exists
card: $C: Touch: src/* is marked (new) and is not a full path
card: $C: Out of scope has no item" "$ERR" stderr
  assert_empty "$OUT" stdout
}

test_plan_check_refuses_an_id_with_no_card_file() {
  deck; mk_outline; commit_all
  card plan check A-9
  assert_rc 1
  assert_eq 'card: no card A-9 in cards; cards with prefix A: A-1' "$ERR" stderr
  # A row is not a card file.
  card plan check AUTH-01
  assert_rc 1
  assert_contains "$ERR" 'card: no card AUTH-01 in cards'
  card plan check; assert_rc 2; assert_contains "$ERR" 'check <id>'
  card plan check A-1 A-2; assert_rc 2
  card plan check a-1; assert_rc 2
  card help; assert_contains "$OUT" '  plan check <id> '
}

test_plan_check_entries_are_patterns_never_code() {
  deck
  body Read '$(touch pwned)' '`touch pwned2`'
  body Touch '$(touch pwned3)' '*) touch pwned4 ;; (new)'
  card plan check A-1
  assert_rc 1
  assert_no_file pwned; assert_no_file pwned2; assert_no_file pwned3; assert_no_file pwned4
}

test_plan_check_is_not_run_by_lint_or_by_card_plan() {
  deck; body Read 'docs/gone.md'; commit_all
  card lint
  assert_rc 0
  card plan
  assert_rc 0
  assert_not_contains "$ERR" 'gone.md'
}

# A section with no item is not a finding of this command: card lint has
# the rule for an empty Touch.
test_plan_check_passes_a_card_with_no_read_and_no_touch_item() {
  deck; body Read; body Touch
  card plan check A-1
  passes
}

test_plan_check_removes_every_anchor_of_a_read_entry() {
  deck; body Read 'docs/design.md#a#b' '#anchor'
  card plan check A-1
  assert_rc 1
  assert_eq "card: $C: Read: #anchor does not exist" "$ERR" stderr
}

# A card can arrive in someone else's pull request, and a session reads what
# Read names.
test_plan_check_reports_a_read_path_that_leaves_the_repository() {
  local e
  deck; mkdir -p "$T/out"; echo x > "$T/out.md"
  for e in '/etc' "$T/out.md" '../out.md' 'docs/../../out.md' '..'; do
    body Read "$e (a note)"
    card plan check A-1
    finding "Read: $e is not a path inside the repository"
  done
  # Two dots in a name are not a segment.
  echo x > 'docs/a..b.md'; body Read 'docs/a..b.md'
  card plan check A-1
  passes
}

test_plan_check_reads_the_new_mark_at_the_start_of_the_comment() {
  deck
  body Touch 'src/b.ts  (new)' 'src/c.ts (new), with the cases'
  card plan check A-1
  passes
  body Touch 'src/gone.ts (not (new) here)' '(new)'
  card plan check A-1
  assert_rc 1
  assert_eq "card: $C: Touch: src/gone.ts matches no file
card: $C: Touch: (new) matches no file" "$ERR" stderr
}

test_plan_check_tests_a_new_path_on_disk_without_its_leading_slash() {
  deck; ln -s nowhere dangling
  body Touch '/src/a.ts (new)' 'dangling (new)'
  card plan check A-1
  finding 'Touch: /src/a.ts is marked (new) and exists'
  assert_contains "$ERR" "card: $C: Touch: dangling is marked (new) and exists"
}

# The escape is the one spelling the scope gate matches such a file with.
test_plan_check_accepts_a_new_path_with_an_escaped_pattern_character() {
  deck; mkdir -p 'app/[id]'; echo x > 'app/[id]/page.tsx'; commit_all
  body Touch 'app/\[id\]/new.tsx (new)' 'app/\[id\]/page.tsx' '\src/\b.ts (new)'
  card plan check A-1
  passes
  body Touch 'app/\[id\]/page.tsx (new)' 'src/a\.ts (new)' 'app/[id]/new.tsx (new)'
  card plan check A-1
  assert_rc 1
  assert_eq "card: $C: Touch: app/\\[id\\]/page.tsx is marked (new) and exists
card: $C: Touch: src/a\\.ts is marked (new) and exists
card: $C: Touch: app/[id]/new.tsx is marked (new) and is not a full path" "$ERR" stderr
}

# The scope gate still lists a tracked file that is gone from the disk.
test_plan_check_reports_a_new_path_that_is_a_tracked_file_removed_from_disk() {
  deck; rm src/a.ts
  body Touch 'src/a.ts (new)'
  card plan check A-1
  finding 'Touch: src/a.ts is marked (new) and is a tracked file'
  body Touch 'src/a.ts'
  card plan check A-1
  passes
}

test_plan_check_reports_a_new_path_that_git_would_ignore() {
  deck
  printf '%s\n' 'build/' '*.log' > .gitignore; commit_all ignore
  body Touch 'build/out.js (new)' 'src/run.log (new)' 'src/run.ts (new)'
  card plan check A-1
  assert_rc 1
  assert_eq "card: $C: Touch: build/out.js is marked (new) and git ignores it
card: $C: Touch: src/run.log is marked (new) and git ignores it" "$ERR" stderr
}

test_plan_check_exits_2_when_the_files_cannot_be_listed() {
  deck; echo garbage > .git/index
  card plan check A-1
  assert_rc 2
  assert_contains "$ERR" 'card: cannot list the files of the repository'
}

test_plan_check_exits_2_for_a_card_file_that_cannot_be_read() {
  deck; chmod 000 "$C"
  [ ! -r "$C" ] || return 0 # root reads it anyway
  card plan check A-1
  assert_rc 2
  assert_eq "card: $C: cannot be read" "$ERR" stderr
}
