#!/usr/bin/env bash
# shellcheck disable=SC2154

TX="$FIX/transcripts"
# normal.jsonl grows by 84300 tokens: over the S budget (70000), under M (100000).
deck() { new_repo; mk_conf; mk_card A-1 "${1:-S}"; commit_all; git checkout -q -b card/A-1-thing; }
ptu() { hook post-tool-use "$(hook_input PostToolUse "${2:-abc-123}" "$TX/${1:-normal.jsonl}" "${3-}")"; }

test_post_tool_use_is_silent_without_config() {
  new_repo; git checkout -q -b card/A-1-thing
  ptu; assert_silent
  hook post-tool-use "$(cat "$FIX/hooks/post-tool-use.json")"; assert_silent
  mkdir "$T/plain" && cd "$T/plain" || exit 1
  ptu; assert_silent
  hook post-tool-use ''; assert_silent
}

test_post_tool_use_is_silent_off_a_card_branch() {
  deck; git checkout -q main
  ptu; assert_silent
  git checkout -q --detach
  ptu; assert_silent
  assert_no_file .git/workdeck
}

test_post_tool_use_is_silent_under_budget() {
  deck M
  ptu; assert_silent
  assert_no_file .git/workdeck/abc-123.warned
}

test_post_tool_use_warns_once_over_budget() {
  deck S
  ptu
  assert_rc 0
  assert_eq '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"WorkDeck: this session has grown by 84300 tokens, past the 70000-token budget of a size S card. Finish the current step, then stop and ask the user to run /workdeck:handoff split."}}' "$OUT" json
  assert_file .git/workdeck/abc-123.warned
  ptu; assert_silent
  ptu normal.jsonl another-session
  assert_contains "$OUT" 'additionalContext'
}

test_post_tool_use_ignores_subagent_calls() {
  deck S
  ptu normal.jsonl abc-123 '"agent_id":"agent-7","agent_type":"workdeck:reviewer"'
  assert_silent
  assert_no_file .git/workdeck/abc-123.warned
  ptu
  assert_contains "$OUT" 'additionalContext'
}

test_post_tool_use_is_silent_when_tokens_are_unknown() {
  deck S
  ptu garbage.jsonl; assert_silent
  ptu does-not-exist.jsonl; assert_silent
  hook post-tool-use 'not json'; assert_silent
  hook post-tool-use ''; assert_silent
  ptu normal.jsonl '../../escape'; assert_silent
  assert_no_file .git/workdeck
}

test_post_tool_use_is_silent_when_the_branch_has_no_card() {
  deck S; git checkout -q -b card/NOPE-9-thing
  ptu; assert_silent
}

test_post_tool_use_survives_a_broken_config() {
  deck S; echo 'not a setting' >> workdeck.conf
  ptu; assert_silent
}

test_post_tool_use_from_a_subdirectory_and_with_a_large_payload() {
  deck S; mkdir -p deep/er && cd deep/er || exit 1
  local big; big=$(awk 'BEGIN { for (i = 0; i < 20000; i++) printf "0123456789"; }')
  ptu normal.jsonl abc-123 "\"tool_result\":{\"type\":\"text\",\"text\":\"$big\"}"
  assert_contains "$OUT" 'grown by 84300'
}

test_post_tool_use_in_a_linked_worktree() {
  deck S; git checkout -q main
  git worktree add -q "$T/wt" card/A-1-thing 2>/dev/null || fail 'worktree add failed'
  cd "$T/wt" || exit 1
  ptu
  assert_contains "$OUT" 'additionalContext'
  assert_file "$T/repo/.git/worktrees/wt/workdeck/abc-123.warned"
  assert_no_file "$T/repo/.git/workdeck"
}

test_post_tool_use_marker_failure_never_repeats_the_warning() {
  deck S
  : > .git/workdeck
  ptu; assert_silent
}
