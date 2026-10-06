#!/usr/bin/env bash
# shellcheck disable=SC2154

state_of() { printf '%s\n' "$OUT" | awk -v id="$1" '$2 == id { print $1 }'; }
set_done() { edit "cards/$1-thing.md" 's/^done: false$/done: true/'; }


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

# done is read from both base refs: a merge made locally and not yet pushed
# counts, and so does one fetched from the remote while local base is behind.
test_base_done_on_local_base_counts_before_push() {
  new_repo; mk_conf; mk_card A-1; mk_card A-2 S A-1; commit_all; add_remote
  set_done A-1; commit_all 'merged locally, not pushed'
  card list
  assert_eq done "$(state_of A-1)" 'unpushed done'
  assert_eq ready "$(state_of A-2)" dependent
}

test_base_done_on_origin_counts_when_local_base_is_behind() {
  new_repo; mk_conf; mk_card A-1; mk_card A-2 S A-1; commit_all; add_remote
  set_done A-1; commit_all; git push -q origin main; git reset -q --hard HEAD~1
  card list
  assert_eq done "$(state_of A-1)" 'done on origin only'
  assert_eq ready "$(state_of A-2)" dependent
}

test_base_done_with_diverged_bases_is_the_union() {
  new_repo; mk_conf; mk_card A-1; mk_card A-2; mk_card A-3 S 'A-1, A-2'; commit_all; add_remote
  set_done A-1; commit_all; git push -q origin main; git reset -q --hard HEAD~1
  set_done A-2; commit_all 'local only'
  card list
  assert_eq done "$(state_of A-1)" 'origin side'
  assert_eq done "$(state_of A-2)" 'local side'
  assert_eq ready "$(state_of A-3)" dependent
}

test_next_does_not_offer_a_card_merged_locally() {
  new_repo; mk_conf; mk_card A-1; mk_card A-2; commit_all; add_remote
  git checkout -q -b card/A-1-thing; set_done A-1; echo x > f; commit_all work
  git checkout -q main; git merge -q --no-ff card/A-1-thing -m merge; git branch -q -d card/A-1-thing
  card next
  assert_eq 'A-2 S Card A-2' "$OUT" next
}

test_base_card_on_unpushed_local_base_is_not_branch_only() {
  new_repo; mk_conf; commit_all; add_remote
  mk_card B-1; mk_card B-2 S B-1; commit_all 'cards, not pushed'
  git checkout -q -b card/B-1-thing; set_done B-1
  card list
  assert_eq active "$(state_of B-1)" 'done only in the working tree'
  assert_eq waiting "$(state_of B-2)" dependent
}

test_base_done_tolerates_spaces_around_true() {
  new_repo; mk_conf; mk_card A-1; mk_card A-2 S A-1
  edit cards/A-1-thing.md 's/^done: false$/done:   true  /'; commit_all
  card lint; assert_rc 0
  card list
  assert_eq done "$(state_of A-1)" state
  assert_eq ready "$(state_of A-2)" dependent
}

# A card that exists only in the working tree (a quick card, or one not yet
# committed) has nowhere else to read done from. But once it has a branch or a
# pull request, done: true only means handoff ran: it is not merged.
test_base_branch_only_card_is_not_done_after_handoff() {
  new_repo; mk_conf; commit_all
  git checkout -q -b card/Q-1-thing
  mk_card Q-1 XS; mk_card Q-1b XS Q-1
  card list
  assert_eq active "$(state_of Q-1)" 'before handoff'
  set_done Q-1; commit_all handoff
  card list
  assert_eq active "$(state_of Q-1)" 'after handoff, not merged'
  assert_eq waiting "$(state_of Q-1b)" 'remainder waits for the merge'
}

test_base_working_tree_only_card_without_branch_uses_its_own_done() {
  new_repo; mk_conf; commit_all
  mk_card A-1; set_done A-1; mk_card A-2 S A-1
  card list
  assert_eq done "$(state_of A-1)" 'uncommitted card on the base branch'
  assert_eq ready "$(state_of A-2)" dependent
}
