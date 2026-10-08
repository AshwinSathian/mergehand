#!/usr/bin/env bash
# shellcheck disable=SC2154

pc() { hook pre-compact "$(hook_input PreCompact "${1-abc-123}" '' '"trigger":"auto","custom_instructions":""')"; }

test_pre_compact_is_silent_without_config() {
  new_repo
  pc; assert_silent
  hook pre-compact "$(cat "$FIX/hooks/pre-compact.json")"; assert_silent
  assert_no_file .git/workdeck
  mkdir "$T/plain" && cd "$T/plain" || exit 1
  pc; assert_silent
}

test_pre_compact_writes_the_marker() {
  new_repo; mk_conf; mkdir sub && cd sub || exit 1
  pc; assert_silent
  assert_file "$T/repo/.git/workdeck/abc-123.compacted"
  pc; assert_silent
}

test_pre_compact_marker_is_read_by_log_new() {
  new_repo; mk_conf; mk_card A-1
  pc
  WORKDECK_SESSION=abc-123 card log-new A-1 done
  assert_contains "$(cat "$OUT")" 'compacted: true'
}

test_pre_compact_rejects_a_hostile_session_id() {
  new_repo; mk_conf
  local s
  for s in '../../x' 'a b' 'a/b'; do
    pc "$s"; assert_silent
  done
  hook pre-compact ''; assert_silent
  hook pre-compact '{"session_id":"","hook_event_name":"PreCompact"}'; assert_silent
  hook pre-compact 'not json'; assert_silent
  assert_no_file .git/workdeck
  assert_no_file "$T/x.compacted"
}

test_pre_compact_in_a_linked_worktree() {
  new_repo; mk_conf; commit_all
  git worktree add -q "$T/wt" -b other 2>/dev/null || fail 'worktree add failed'
  cd "$T/wt" || exit 1
  pc; assert_silent
  assert_file "$T/repo/.git/worktrees/wt/workdeck/abc-123.compacted"
}

test_pre_compact_never_blocks_when_the_marker_cannot_be_written() {
  new_repo; mk_conf; : > .git/workdeck
  pc; assert_silent
}
