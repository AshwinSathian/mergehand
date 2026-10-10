#!/usr/bin/env bash
# shellcheck disable=SC2154

deck() { new_repo; mk_conf; mk_card A-1; mk_card A-2; commit_all; git checkout -q -b card/A-1-thing; }
work() { echo x >> src.txt; commit_all work; }
stop() { hook stop "$(hook_input Stop abc-123 '' "\"stop_hook_active\":${1:-false},\"last_assistant_message\":\"Done.\"")"; }
assert_blocked() {
  assert_rc 2
  assert_empty "$OUT" stdout
  assert_contains "$ERR" '/workdeck:handoff'
  assert_contains "$ERR" 'A-1'
}

test_stop_is_silent_without_config() {
  new_repo; git checkout -q -b card/A-1-thing; echo x > f; commit_all
  stop; assert_silent
  hook stop "$(cat "$FIX/hooks/stop.json")"; assert_silent
  mkdir "$T/plain" && cd "$T/plain" || exit 1
  stop; assert_silent
}

test_stop_blocks_when_commits_have_no_log() {
  deck; work
  stop
  assert_blocked
  assert_contains "$ERR" 'blocked'
}

test_stop_passes_when_stop_hook_active() {
  deck; work
  stop true; assert_silent
  hook stop '{"hook_event_name":"Stop", "stop_hook_active" : true}'; assert_silent
}

test_stop_passes_off_a_card_branch() {
  deck; work; git checkout -q -b feature/x
  stop; assert_silent
  git checkout -q main; stop; assert_silent
  git checkout -q --detach; stop; assert_silent
}

test_stop_passes_without_commits_on_the_branch() {
  deck
  stop; assert_silent
}

test_stop_passes_with_a_dirty_tree() {
  deck; work
  echo y >> src.txt; stop; assert_silent
  git checkout -q src.txt; echo z > untracked.txt; stop; assert_silent
}

test_stop_passes_once_a_log_for_the_card_exists() {
  deck; work; mk_log A-1; commit_all handoff
  stop; assert_silent
  echo x >> src.txt; commit_all 'review fixes'
  stop; assert_silent
}

test_stop_log_for_another_card_does_not_count() {
  deck; work; mk_log A-2; mk_log A-10; commit_all
  stop; assert_blocked
}

test_stop_log_from_before_the_branch_does_not_count() {
  new_repo; mk_conf; mk_card A-1; mk_log A-1 2026-10-01; commit_all
  git checkout -q -b card/A-1-thing; work
  stop; assert_blocked
}

test_stop_respects_log_dir_and_base() {
  new_repo; git branch -q -m trunk; mk_conf 'base = trunk' 'log_dir = work/log'; mk_card A-1; commit_all
  git checkout -q -b card/A-1-thing; work
  stop; assert_blocked
  LOG_DIR=work/log mk_log A-1; commit_all
  stop; assert_silent
}

test_stop_ignores_unpushed_base_commits() {
  new_repo; mk_conf; mk_card A-1; commit_all; add_remote
  echo local > other.txt; commit_all 'merged locally, not pushed'
  git checkout -q -b card/A-1-thing
  stop; assert_silent
}

test_stop_exits_zero_on_bad_input_or_config() {
  deck; work
  hook stop ''; assert_silent
  hook stop 'not json'; assert_silent
  echo 'not a setting' >> workdeck.conf; git add -A; git commit -q -m conf
  stop; assert_silent
}

test_stop_blocks_on_a_branch_without_slug() {
  new_repo; mk_conf; mk_card A-1; commit_all; git checkout -q -b card/A-1; work
  stop; assert_blocked
  git checkout -q -b card/A-1xy; stop; assert_silent
}

test_stop_passes_after_a_commit_that_changes_only_the_cards_directory() {
  deck; echo note >> cards/A-1-thing.md; commit_all 'approve the card'
  stop; assert_silent
}

test_stop_blocks_after_a_card_only_commit_and_a_code_commit() {
  deck; echo note >> cards/A-1-thing.md; commit_all 'approve the card'; work
  stop; assert_blocked
}

test_stop_card_only_commit_respects_cards_dir() {
  new_repo; mk_conf 'cards_dir = work/cards'; CARDS_DIR=work/cards mk_card A-1; commit_all
  git checkout -q -b card/A-1-thing
  echo note >> work/cards/A-1-thing.md; commit_all 'approve the card'
  stop; assert_silent
  mkdir cards; echo x > cards/a.md; commit_all 'not the cards directory'
  stop; assert_blocked
}

test_stop_counts_commits_from_the_root_when_run_in_a_subdirectory() {
  new_repo; mk_conf; mk_card A-1; mkdir sub; echo keep > sub/keep.txt; commit_all
  git checkout -q -b card/A-1-thing
  echo note >> cards/A-1-thing.md; commit_all 'approve the card'
  cd sub || exit 1
  stop; assert_silent
  cd .. || exit 1
  work
  cd sub || exit 1
  stop; assert_blocked
}

test_stop_counts_a_nested_directory_named_like_the_cards_directory() {
  deck; mkdir -p src/cards; echo x > src/cards/a.md; commit_all 'code under src/cards'
  stop; assert_blocked
}
