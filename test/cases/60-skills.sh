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

test_handoff_runs_the_gates_in_order() {
  local f="$ROOT/skills/handoff/SKILL.md" a b c d e
  a=$(grep -n 'card conf check' "$f" | head -1 | cut -d: -f1)
  b=$(grep -n '`card lint`' "$f" | head -1 | cut -d: -f1)
  c=$(grep -n '`card touched <id>`' "$f" | head -1 | cut -d: -f1)
  d=$(grep -n '`card tests <id>`' "$f" | head -1 | cut -d: -f1)
  e=$(grep -n 'workdeck:reviewer' "$f" | head -1 | cut -d: -f1)
  [ -n "$a" ] && [ -n "$b" ] && [ -n "$c" ] && [ -n "$d" ] && [ -n "$e" ] || fail "a step is missing: check=$a lint=$b touched=$c tests=$d reviewer=$e"
  [ "$a" -lt "$b" ] && [ "$b" -lt "$c" ] && [ "$c" -lt "$d" ] && [ "$d" -lt "$e" ] ||
    fail "order is check=$a lint=$b touched=$c tests=$d reviewer=$e"
  # done and the log come after the review, and the commit after both.
  local done_line log_line commit_line
  done_line=$(grep -n '`card done <id>`' "$f" | head -1 | cut -d: -f1)
  log_line=$(grep -n 'card log-new <id>' "$f" | head -1 | cut -d: -f1)
  commit_line=$(grep -n 'git commit' "$f" | head -1 | cut -d: -f1)
  [ "$e" -lt "$done_line" ] && [ "$done_line" -lt "$log_line" ] && [ "$log_line" -lt "$commit_line" ] ||
    fail "order is reviewer=$e done=$done_line log=$log_line commit=$commit_line"
  grep -q 'gh pr merge' "$f" && fail 'handoff mentions merging'
  return 0
}

test_init_names_only_templates_that_exist() {
  local f="$ROOT/skills/init/SKILL.md" t n=0
  for t in $(grep -o 'templates/[A-Za-z0-9_.-][A-Za-z0-9_.-]*' "$f" | sort -u); do
    [ -f "$ROOT/$t" ] || fail "init names $t, which does not exist"
    n=$((n + 1))
  done
  assert_eq 6 "$n" 'templates used by init'
  grep -q -i 'does not commit\|do not commit' "$f" || fail 'init does not say that it leaves committing to the user'
  # Every placeholder in the templates must be filled in by a step of the skill.
  for t in '<check>' '<base>' '<repo>' '<tag>'; do
    grep -q -F "$t" "$f" || fail "init never fills in $t"
  done
}
