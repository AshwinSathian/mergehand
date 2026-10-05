#!/usr/bin/env bash
# shellcheck disable=SC2154

state_of() { printf '%s\n' "$OUT" | awk -v id="$1" '$2 == id { print $1 }'; }
set_done() { edit "cards/$1-thing.md" 's/^done: false$/done: true/'; }

test_base_done_comes_from_origin_not_local_base() {
  new_repo; mk_conf; mk_card A-1; mk_card A-2 S A-1; commit_all; add_remote
  set_done A-1; commit_all 'local only'
  card list
  assert_eq ready "$(state_of A-1)" 'unpushed done is not done'
  assert_eq waiting "$(state_of A-2)" dependent
  git push -q origin main
  card list
  assert_eq done "$(state_of A-1)" 'pushed done'
  assert_eq ready "$(state_of A-2)" dependent
}

test_base_without_remote_uses_local_base() {
  new_repo; mk_conf; mk_card A-1; set_done A-1; commit_all
  card list
  assert_eq done "$(state_of A-1)" state
}

test_base_working_tree_done_on_a_card_branch_is_not_done() {
  new_repo; mk_conf; mk_card A-1; mk_card A-2 S A-1; commit_all
  git checkout -q -b card/A-1-thing
  set_done A-1; commit_all handoff
  card list
  [ "$(state_of A-1)" != done ] || fail 'A-1 is done before its branch merged'
  assert_eq waiting "$(state_of A-2)" dependent
}

test_base_card_only_on_this_branch_uses_working_tree() {
  new_repo; mk_conf; commit_all
  git checkout -q -b card/Q-1-thing
  mk_card Q-1 XS; set_done Q-1
  card list
  assert_eq done "$(state_of Q-1)" 'untracked card'
}

test_base_card_only_on_base_still_listed() {
  new_repo; mk_conf; mk_card A-1 M; commit_all
  git checkout -q -b other
  git rm -q cards/A-1-thing.md; commit_all removed
  card list
  assert_contains "$OUT" 'A-1'
  assert_contains "$OUT" 'Card A-1'
}

test_base_done_in_card_body_does_not_count() {
  new_repo; mk_conf; mk_card A-1
  printf '\n---\ndone: true\n---\n' >> cards/A-1-thing.md
  commit_all
  card list
  assert_eq ready "$(state_of A-1)" state
}

test_base_configured_base_branch() {
  new_repo; git branch -q -m trunk; mk_conf 'base = trunk'; mk_card A-1; set_done A-1; commit_all
  card list
  assert_eq done "$(state_of A-1)" state
}

test_base_missing_base_branch() {
  new_repo; mk_conf 'base = trunk'; mk_card A-1; commit_all
  card list
  assert_rc 2
  assert_contains "$ERR" "card: base branch 'trunk' not found"
}

test_base_repository_without_commits() {
  mkdir "$T/empty" && cd "$T/empty" || exit 1
  git init -q . && git symbolic-ref HEAD refs/heads/main
  mk_conf; mk_card A-1
  card list
  assert_rc 2
  assert_contains "$ERR" "card: base branch 'main' not found"
  card lint
  assert_rc 0
}

test_base_detached_head() {
  new_repo; mk_conf; mk_card A-1; commit_all
  git checkout -q --detach
  card list
  assert_rc 0
  assert_eq ready "$(state_of A-1)" state
}

test_base_done_ignores_user_grep_config() {
  new_repo; mk_conf; mk_card A-1; set_done A-1; commit_all
  git config grep.patternType fixed; git config grep.column true; git config grep.lineNumber false
  card list
  assert_eq done "$(state_of A-1)" state
}
