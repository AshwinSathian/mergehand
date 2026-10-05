#!/usr/bin/env bash
# shellcheck disable=SC2154
# Skills are prompts and cannot be unit tested. These checks catch the
# mechanical mistakes: a skill the model could invoke on its own, and a skill
# that tells the agent to run a card command that does not exist.

skill_files() { find "$ROOT/skills" -name SKILL.md | sort; }

# front <file> <key>: a frontmatter value.
front() { awk -v k="$2:" 'NR == 1 { next } $0 == "---" { exit } index($0, k) == 1 { sub(/^[^:]*: */, ""); print }' "$1"; }

test_skills_disable_model_invocation() {
  local f n=0
  for f in $(skill_files); do
    assert_eq '---' "$(sed -n 1p "$f")" "first line of $f"
    assert_eq true "$(front "$f" disable-model-invocation)" "disable-model-invocation in $f"
    [ -n "$(front "$f" description)" ] || fail "$f has no description"
    assert_eq "$(basename "$(dirname "$f")")" "$(front "$f" name)" "name in $f"
    n=$((n + 1))
  done
  [ "$n" -gt 0 ] || fail 'no skills found'
}

# Every `card <word>` inside a code span or code block of a skill, the shared
# reference or the reviewer must be a real subcommand.
test_skills_name_only_card_commands_that_exist() {
  local known f bad
  known=$("$BASH" "$CARD" help | awk '/^  [a-z]/ { print $1 }' | tr '\n' ' ')
  for f in $(skill_files) "$ROOT"/reference/*.md "$ROOT"/agents/*.md; do
    bad=$(awk -v known=" $known" '
      /^```/ { fence = !fence; next }
      {
        line = $0
        if (!fence) {
          # keep only the text inside `code spans`
          out = ""
          while ((i = index(line, "`")) > 0) {
            line = substr(line, i + 1); j = index(line, "`")
            if (j == 0) break
            out = out " " substr(line, 1, j - 1) " ;"; line = substr(line, j + 1)
          }
          line = out
        }
        while (match(line, /(^|[ \/"])card [a-z][a-z-]*/)) {
          word = substr(line, RSTART, RLENGTH); sub(/^.*card /, "", word)
          if (index(known, " " word " ") == 0) print FILENAME ":" FNR ": card " word
          line = substr(line, RSTART + RLENGTH)
        }
      }' "$f")
    [ -z "$bad" ] || fail "unknown card command: $bad"
  done
}

test_skills_never_tell_the_model_to_invoke_a_skill() {
  local f
  for f in $(skill_files) "$ROOT"/reference/*.md; do
    ! grep -n -i -E '(use|invoke|call|run) the (skill|Skill tool)|Skill\(' "$f" || fail "$f tells the model to invoke a skill"
  done
}

test_implement_reference_says_not_to_commit() {
  grep -q -i 'do not commit' "$ROOT/reference/implement.md" || fail 'reference/implement.md does not say not to commit'
  grep -q '/workdeck:handoff' "$ROOT/reference/implement.md" || fail 'reference/implement.md does not point at handoff'
}

test_quick_creates_an_xs_card_with_a_time_based_id() {
  local f="$ROOT/skills/quick/SKILL.md"
  grep -q 'Q-$(date +%y%m%d%H%M)' "$f" || fail 'quick does not build the id from the time'
  grep -q -- '--size XS' "$f" || fail 'quick does not create an XS card'
  grep -q 'reference/implement.md' "$f" || fail 'quick does not follow the shared implementation steps'
  # A counter would give two people the same id on separate branches.
  ! grep -n -i -E 'next (free )?number|increment' "$f" || fail 'quick uses a counter for the id'
}
