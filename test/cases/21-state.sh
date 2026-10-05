#!/usr/bin/env bash
# shellcheck disable=SC2154

state_of() { printf '%s\n' "$OUT" | awk -v id="$1" '$2 == id { print $1 }'; }
set_done() { edit "cards/$1-thing.md" 's/^done: false$/done: true/'; }
deck() { new_repo; mk_conf; mk_card A-1; mk_card A-2 S A-1; mk_card A-3; commit_all; }
is() { card list; assert_rc 0; assert_eq "$2" "$(state_of "$1")" "state of $1"; }

test_state_ready_and_waiting() {
  deck
  is A-1 ready; is A-2 waiting; is A-3 ready
}

test_state_done() {
  deck; set_done A-1; commit_all
  is A-1 done; is A-2 ready
}

test_state_active_from_local_branch() {
  deck; git branch card/A-1-thing
  is A-1 active; is A-2 waiting; is A-3 ready
}

test_state_active_from_remote_only_branch() {
  deck; add_remote
  git branch card/A-3-thing && git push -q origin card/A-3-thing && git branch -q -D card/A-3-thing
  is A-3 active
}

test_state_blocked_on_another_branch() {
  deck
  git checkout -q -b card/A-1-thing
  printf '\n## Blocked\n- Which token lifetime?\n' >> cards/A-1-thing.md; commit_all blocked
  git checkout -q main
  is A-1 blocked
}

test_state_blocked_on_current_branch_before_commit() {
  deck
  git checkout -q -b card/A-1-thing
  printf '\n## Blocked\n- Which token lifetime?\n' >> cards/A-1-thing.md
  is A-1 blocked
}

test_state_blocked_section_without_branch_is_ready() {
  deck; printf '\n## Blocked\n- Question\n' >> cards/A-1-thing.md; commit_all
  is A-1 ready
}

test_state_done_beats_branch() {
  deck; set_done A-1; commit_all; git branch card/A-1-thing
  is A-1 done
}

test_state_branch_beats_waiting() {
  deck; git branch card/A-2-thing
  is A-2 active
}

test_state_neighbouring_ids_do_not_match() {
  new_repo; mk_conf; mk_card A-1; mk_card A-10; mk_card A-1b; mk_card A-2; commit_all
  git branch card/A-10-thing; git branch card/A-1b-thing; git branch card/A-2; git branch feature/A-2-x
  card list
  assert_eq ready "$(state_of A-1)" 'A-1'
  assert_eq active "$(state_of A-10)" 'A-10'
  assert_eq active "$(state_of A-1b)" 'A-1b'
  assert_eq ready "$(state_of A-2)" 'branch without slug or outside card/'
}

test_next_prints_first_ready_in_natural_order() {
  new_repo; mk_conf; mk_card A-10; mk_card A-2 M; mk_card A-1; commit_all
  set_done A-1; commit_all
  card next
  assert_rc 0
  assert_eq 'A-2 M Card A-2' "$OUT" next
}

test_next_skips_active_and_waiting() {
  deck; git branch card/A-1-thing
  card next
  assert_eq 'A-3 S Card A-3' "$OUT" next
}

test_next_none_ready_says_why() {
  new_repo; mk_conf; mk_card A-1; mk_card A-2 S A-1; mk_card A-3 S 'A-1, A-2'; commit_all
  git branch card/A-1-thing
  card next
  assert_rc 1
  assert_contains "$OUT" 'no card is ready'
  assert_contains "$OUT" 'A-1 active'
  assert_contains "$OUT" 'A-2 waiting on A-1'
  assert_contains "$OUT" 'A-3 waiting on A-1 A-2'
}

test_next_all_done() {
  new_repo; mk_conf; mk_card A-1; set_done A-1; commit_all
  card next
  assert_rc 1
  assert_contains "$OUT" 'every card is done'
}

test_next_empty_deck() {
  new_repo; mk_conf
  card next
  assert_rc 1
  assert_contains "$OUT" 'no cards in cards'
}

# Challenge cases: does deriving state from branches survive squash merges and
# deleted branches? Results are recorded in docs/findings.md.

test_squash_merged_with_local_branch_left_behind_is_done() {
  deck
  git checkout -q -b card/A-1-thing; set_done A-1; echo x > f; commit_all work
  git checkout -q main; git merge -q --squash card/A-1-thing; git commit -q -m 'A-1 (squash)'
  is A-1 done; is A-2 ready
}

test_branch_deleted_without_merge_is_ready_again() {
  deck
  git checkout -q -b card/A-1-thing; echo x > f; commit_all work
  is A-1 active
  git checkout -q main; git branch -q -D card/A-1-thing
  is A-1 ready
}

test_squash_merged_remotely_stays_active_until_fetch() {
  deck; add_remote
  git checkout -q -b card/A-1-thing; set_done A-1; commit_all work; git push -q origin card/A-1-thing
  git clone -q "$T/remote.git" "$T/other" 2>/dev/null
  ( cd "$T/other" && git merge -q --squash origin/card/A-1-thing && git commit -q -m squash &&
    git push -q origin main && git push -q origin --delete card/A-1-thing ) || fail 'remote merge failed'
  is A-1 active
  git fetch -q --prune
  is A-1 done
}
