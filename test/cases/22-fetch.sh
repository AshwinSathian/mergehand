#!/usr/bin/env bash
# shellcheck disable=SC2154

state_of() { printf '%s\n' "$OUT" | awk -v id="$1" '$2 == id { print $1 }'; }
deck() { new_repo; mk_conf; mk_card A-1; mk_card A-2; commit_all; add_remote; }
other_clone() { git clone -q "$T/remote.git" "$T/other" 2>/dev/null; }

test_fetch_sees_branches_pushed_by_others() {
  deck; other_clone
  ( cd "$T/other" && git branch card/A-1-thing && git push -q origin card/A-1-thing ) || fail setup
  card list
  assert_eq ready "$(state_of A-1)" 'before fetch'
  card list --fetch
  assert_rc 0
  assert_eq active "$(state_of A-1)" 'after fetch'
  ( cd "$T/other" && git push -q origin --delete card/A-1-thing ) || fail setup
  card list --fetch
  assert_eq ready "$(state_of A-1)" 'after prune'
}

test_fetch_flag_position_does_not_matter() {
  deck; other_clone
  ( cd "$T/other" && git branch card/A-1-thing && git push -q origin card/A-1-thing ) || fail setup
  card --fetch list
  assert_eq active "$(state_of A-1)" state
}

test_fetch_open_pull_request_is_review() {
  deck; git branch card/A-1-thing
  echo 'card/A-1-thing' > "$GH_STUB_DIR/pr-list"
  card list --fetch
  assert_rc 0
  assert_eq review "$(state_of A-1)" state
  assert_empty "$ERR" stderr
  assert_contains "$(cat "$GH_STUB_DIR/calls")" '--limit 500'
}

test_fetch_review_needs_no_local_branch_and_beats_blocked() {
  deck
  git checkout -q -b card/A-2-thing; printf '\n## Blocked\n- q\n' >> cards/A-2-thing.md; commit_all; git checkout -q main
  printf 'card/A-1-thing\ncard/A-2-thing\nfeature/unrelated\n' > "$GH_STUB_DIR/pr-list"
  card list --fetch
  assert_eq review "$(state_of A-1)" 'no local branch'
  assert_eq review "$(state_of A-2)" 'blocked branch'
}

test_fetch_done_beats_review() {
  deck; edit cards/A-1-thing.md 's/^done: false$/done: true/'; commit_all; git push -q origin main
  echo 'card/A-1-thing' > "$GH_STUB_DIR/pr-list"
  card list --fetch
  assert_eq done "$(state_of A-1)" state
}

test_without_fetch_review_is_active_and_silent() {
  deck; git branch card/A-1-thing
  echo 'card/A-1-thing' > "$GH_STUB_DIR/pr-list"
  card list
  assert_eq active "$(state_of A-1)" state
  assert_empty "$ERR" stderr
  assert_no_file "$GH_STUB_DIR/calls"
}

test_without_fetch_remote_is_not_contacted() {
  deck; other_clone
  ( cd "$T/other" && git branch card/A-1-thing && git push -q origin card/A-1-thing ) || fail setup
  card status
  card next
  card list
  assert_eq ready "$(state_of A-1)" 'still unaware of the remote branch'
}

test_fetch_without_working_gh_reports_review_unavailable() {
  local rc
  for rc in 1 4 127; do
    deck; git branch card/A-1-thing
    echo "$rc" > "$GH_STUB_DIR/rc"
    card list --fetch
    assert_rc 0
    assert_eq active "$(state_of A-1)" state
    assert_contains "$ERR" 'card: '
    assert_contains "$ERR" 'review'
  done
}

test_fetch_without_remote_is_fine() {
  new_repo; mk_conf; mk_card A-1; commit_all
  card list --fetch
  assert_rc 0
  assert_eq ready "$(state_of A-1)" state
  assert_no_file "$GH_STUB_DIR/calls"
}

test_fetch_unreachable_remote_falls_back_to_local_refs() {
  deck; git remote set-url origin "$T/gone.git"
  card list --fetch
  assert_rc 0
  assert_eq ready "$(state_of A-1)" state
  assert_contains "$ERR" 'card: git fetch failed'
}

test_next_reports_review() {
  new_repo; mk_conf; mk_card A-1; commit_all; add_remote
  echo 'card/A-1-thing' > "$GH_STUB_DIR/pr-list"
  card next --fetch
  assert_rc 1
  assert_contains "$OUT" 'A-1 review'
}

test_fetch_branch_only_card_with_open_pull_request_is_review() {
  new_repo; mk_conf; commit_all; add_remote
  git checkout -q -b card/Q-1-thing; mk_card Q-1 XS; edit cards/Q-1-thing.md 's/^done: false$/done: true/'; commit_all handoff
  echo 'card/Q-1-thing' > "$GH_STUB_DIR/pr-list"
  card list --fetch
  assert_eq review "$(state_of Q-1)" 'handed off, pull request open'
}
