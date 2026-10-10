#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2034
# Goal 5 of docs/design-0.2.md: in a repository with no outline, list, next and
# status print what card 0.1.3 prints. And section 8: card 0.1.3 works on a
# deck that this version planned.

# card <args...>: for list, next and status, with or without --fetch before
# the command, runs card 0.1.3 and then this card, and fails unless stdout,
# stderr and the exit code are the same. Any other command runs once, as in
# lib.sh. With --fetch, 0.1.3 has fetched and pruned by the time this card
# runs, so the comparison cannot tell whether this card does either:
# 22-fetch.sh is what tests that.
card() {
  local cmd=${1-}
  [ "$cmd" != --fetch ] || cmd=${2-}
  case $cmd in
    list | next | status) ;;
    *) run "$BASH" "$CARD" "$@"; return ;;
  esac
  [ ! -e cards/plan ] || fail 'the comparison is for a repository with no outline'
  local old_rc
  "$BASH" "$OLD_CARD" "$@" > "$T/old.out" 2> "$T/old.err"
  old_rc=$?
  "$BASH" "$CARD" "$@" > "$T/new.out" 2> "$T/new.err"
  RC=$?
  OUT=$(cat "$T/new.out")
  ERR=$(cat "$T/new.err")
  echo "$*" >> "$COMPARED"
  if [ "$old_rc" -ne "$RC" ] || ! cmp -s "$T/old.out" "$T/new.out" || ! cmp -s "$T/old.err" "$T/new.err"; then
    printf '  card %s differs from card 0.1.3\n' "$*"
    # The files are printed as they are: $(...) would drop a trailing newline
    # that is the whole difference.
    printf '  0.1.3: rc=%s\n  stdout:\n' "$old_rc"; cat "$T/old.out"
    printf '  stderr:\n'; cat "$T/old.err"
    printf '  now:   rc=%s\n  stdout:\n' "$RC"; cat "$T/new.out"
    printf '  stderr:\n'; cat "$T/new.err"
    exit 1
  fi
}

test_list_next_and_status_match_card_0_1_3_when_there_is_no_outline() {
  need_old_card || return 0
  COMPARED="$T/compared"
  local file name
  # Every case file of 0.1 that calls list, next or status. Each in its own
  # subshell: they define helpers of the same name.
  for file in 02-plugin 10-basics 14-list 20-base 21-state 22-fetch 23-status 31-done 50-hook-session-start; do
    (
      # shellcheck disable=SC1090
      . "$ROOT/test/cases/$file.sh"
      for name in $(sed -n 's/^\(test_[A-Za-z0-9_]*\)().*/\1/p' "$ROOT/test/cases/$file.sh"); do
        ( setup_env; "$name" ) || { printf '  in %s:%s\n' "$file" "$name"; exit 1; }
      done
    ) || exit 1
  done
  # The 0.1 cases make 104 such calls. Fewer means a case stopped going
  # through card(), or a file left the list above.
  local n
  n=$(grep -c '' "$COMPARED" 2>/dev/null)
  [ "${n:-0}" -ge 104 ] || fail "${n:-0} calls were compared, and the 0.1 cases make 104"
}

# old <args...>: card 0.1.3, run once. new <args...>: this card, run once, for
# the commands card() above compares.
old() { run "$BASH" "$OLD_CARD" "$@"; }
new() { run "$BASH" "$CARD" "$@"; }

# fill <file> <section> <item>: one item under a section that has none. Not
# for an item with a |, an & or a backslash, which sed would read.
fill() {
  edit "$1" "s|^## $2\$|&\\
- $3|"
}

R=cards/AUTH-01b-token-store-rest.md
P=cards/AUTH-02-token-refresh.md

# planned_deck: on the base branch, the outline of mk_outline with a third
# row; AUTH-01 done, with its log; the remainder AUTH-01b as card new of this
# version writes it for a split, filled in; Z-2, written by hand, which
# depends on the remainder; and AUTH-02 as card plan start of this version
# writes it, with Touch and Tests filled in. AUTH-03 is a row with no card
# file.
planned_deck() {
  new_repo; mk_conf; mk_outline
  edit cards/plan/auth.md 's/^## Not planned$/## AUTH-03 Refresh count\
- size: S\
- depends: AUTH-02\
- does: Refreshes are counted for each token\
\
&/'
  mk_card AUTH-01 S '' true token-store
  mk_log AUTH-01
  assert_file log/2026-10-05-AUTH-01-1.md
  new new AUTH-01b 'Token store rest' --size S --depends AUTH-01
  assert_rc 0
  assert_eq 'depends: AUTH-01' "$(grep '^depends:' "$R")" 'depends of the remainder'
  fill "$R" Read README.md
  fill "$R" Touch 'src/lookup.txt (new)'
  fill "$R" Tests 'lookup finds a stored token'
  fill "$R" Acceptance 'A stored token can be looked up by its hash'
  mk_card Z-2 S AUTH-01b false after-the-rest
  commit_all
  new plan start AUTH-02
  assert_rc 0
  fill "$P" Touch 'src/refresh.txt (new)'
  fill "$P" Tests 'refresh rotates the token'
  commit_all
}

test_card_0_1_3_lint_passes_a_deck_with_an_outline_a_planned_card_and_a_split_remainder() {
  need_old_card || return 0
  planned_deck
  assert_file cards/plan/auth.md
  assert_file "$R"
  assert_contains "$(cat "$P")" '- specs/auth.md (row AUTH-02: Refresh; Errors)'
  assert_eq 'depends: AUTH-01' "$(grep '^depends:' "$P")" 'depends of the planned card'
  old lint
  assert_rc 0
  assert_empty "$ERR" stderr
}

test_card_0_1_3_next_offers_only_cards_that_have_a_file() {
  need_old_card || return 0
  local f
  planned_deck
  # The row is there for this version to see, so its absence below is 0.1.3's.
  new list
  assert_contains "$OUT" 'AUTH-03      S   Refresh count [row]'
  old list
  assert_rc 0
  assert_eq 'done     AUTH-01      S   Card AUTH-01
ready    AUTH-01b     S   Token store rest
ready    AUTH-02      S   Token refresh
waiting  Z-2          S   Card Z-2' "$OUT" 'list of 0.1.3'
  old next
  assert_rc 0
  assert_eq 'AUTH-01b S Token store rest' "$OUT" 'next of 0.1.3'
  # With the remainder done, 0.1.3 takes Z-2's dependency on it as met.
  edit "$R" 's/^done: false$/done: true/'
  commit_all
  old next
  assert_eq 'AUTH-02 S Token refresh' "$OUT" 'next of 0.1.3, the remainder done'
  old list
  assert_contains "$OUT" 'ready    Z-2 '
  # With every card done, the row is all that is left, and 0.1.3 offers nothing.
  for f in "$P" cards/Z-2-after-the-rest.md; do
    edit "$f" 's/^done: false$/done: true/'
  done
  commit_all
  new next
  assert_contains "$OUT" 'AUTH-03'
  old next
  assert_rc 1
  assert_eq 'every card is done' "$OUT$ERR" 'next of 0.1.3, nothing left'
}

test_card_0_1_3_lint_fails_a_card_that_depends_on_a_row_with_no_file() {
  need_old_card || return 0
  planned_deck
  mk_card Z-1 S AUTH-03
  # AUTH-03 is a row here, not an id that nothing has.
  new list
  assert_contains "$OUT" 'AUTH-03      S   Refresh count [row]'
  old lint
  assert_rc 1
  assert_contains "$OUT$ERR" 'depends on AUTH-03, which is not a card'
  new lint
  assert_rc 1
  assert_contains "$OUT$ERR" 'depends on AUTH-03, which is not a card'
}

test_planned_deck_passes_card_plan() {
  planned_deck
  new plan
  assert_rc 0
  # The line for a deck with no outline would also exit 0.
  assert_empty "$OUT" stdout
  assert_empty "$ERR" stderr
  new lint
  assert_rc 0
}
