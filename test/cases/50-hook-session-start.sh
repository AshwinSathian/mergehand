#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2016,SC1091

IN="$FIX/hooks/session-start.json"
deck() { new_repo; mk_conf; mk_card A-1 M; mk_card A-2; commit_all; }

test_session_start_is_silent_without_config() {
  new_repo
  export CLAUDE_ENV_FILE="$T/env"
  hook session-start "$(cat "$IN")"; assert_silent
  assert_no_file "$T/env"
  mkdir "$T/plain" && cd "$T/plain" || exit 1
  hook session-start "$(cat "$IN")"; assert_silent
  hook session-start ''; assert_silent
}

test_session_start_prints_card_status() {
  deck; git checkout -q -b card/A-1-thing; mk_log A-1
  card status; local want=$OUT
  hook session-start "$(hook_input SessionStart)"
  assert_rc 0
  assert_eq "$want" "$OUT" 'status text'
  assert_contains "$OUT" 'on card/A-1-thing: A-1 M Card A-1 (active)'
  assert_no_file "$GH_STUB_DIR/calls"
}

test_session_start_exports_transcript_and_session() {
  deck
  export CLAUDE_ENV_FILE="$T/env"
  echo 'export KEEP=1' > "$T/env"
  hook session-start "$(hook_input SessionStart abc-123 "$T/t.jsonl")"
  assert_rc 0
  assert_contains "$(cat "$T/env")" 'export KEEP=1'
  assert_eq "$T/t.jsonl|abc-123|1" "$(. "$T/env"; echo "$MERGEHAND_TRANSCRIPT|$MERGEHAND_SESSION|$KEEP")" 'sourced values'
}

test_session_start_writes_hostile_values_literally() {
  deck
  export CLAUDE_ENV_FILE="$T/env"
  local p="$T/it's \$(touch pwned) \`touch pwned2\`; touch pwned3.jsonl"
  hook session-start "$(hook_input SessionStart 'x; touch pwned4' "$p")"
  assert_rc 0
  assert_eq "$p|unset" "$(. "$T/env"; echo "$MERGEHAND_TRANSCRIPT|${MERGEHAND_SESSION-unset}")" 'sourced values'
  assert_no_file pwned; assert_no_file pwned2; assert_no_file pwned3; assert_no_file pwned4
}

test_session_start_without_env_file_still_prints_status() {
  deck
  hook session-start "$(hook_input SessionStart)"
  assert_rc 0
  assert_contains "$OUT" 'Next ready: A-1'
  hook session-start 'not json'
  assert_rc 0
  assert_contains "$OUT" 'Next ready: A-1'
}

test_session_start_survives_a_broken_config() {
  deck; echo 'this is not a setting' >> mergehand.conf
  hook session-start "$(hook_input SessionStart)"; assert_silent
  mk_conf 'base = nosuchbranch'
  hook session-start "$(hook_input SessionStart)"; assert_silent
}

test_session_start_from_a_subdirectory() {
  deck; mkdir -p deep/er && cd deep/er || exit 1
  hook session-start "$(hook_input SessionStart)"
  assert_rc 0
  assert_contains "$OUT" 'Next ready: A-1'
}
