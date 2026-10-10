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
  grep -q "date +%y%m%d%H%M" "$f" || fail "quick does not build the id from the time"
  grep -q -- '--size XS' "$f" || fail 'quick does not create an XS card'
  grep -q 'reference/implement.md' "$f" || fail 'quick does not follow the shared implementation steps'
  # A counter would give two people the same id on separate branches.
  ! grep -n -i -E 'next (free )?number|increment' "$f" || fail 'quick uses a counter for the id'
}

# Found in the first run from the marketplace (finding 16): quick wrote bare
# lines under Touch, which are not items, and nothing said so until handoff.
test_quick_writes_list_items_and_lints_the_card_before_showing_it() {
  local f="$ROOT/skills/quick/SKILL.md" a b
  grep -q 'starts with `- `' "$f" || fail 'quick does not say that an item starts with "- "'
  a=$(grep -n '`card lint`' "$f" | head -1 | cut -d: -f1)
  b=$(grep -n 'Show the card to the user' "$f" | head -1 | cut -d: -f1)
  if [ -z "$a" ] || [ -z "$b" ] || [ "$a" -ge "$b" ]; then
    fail 'quick does not lint the card before showing it'
  fi
}

test_handoff_runs_the_gates_in_order() {
  local f="$ROOT/skills/handoff/SKILL.md" a b c d e
  a=$(grep -n 'card conf check' "$f" | head -1 | cut -d: -f1)
  b=$(grep -n '`card lint`' "$f" | head -1 | cut -d: -f1)
  c=$(grep -n '`card touched <id>`' "$f" | head -1 | cut -d: -f1)
  d=$(grep -n '`card tests <id>`' "$f" | head -1 | cut -d: -f1)
  e=$(grep -n 'workdeck:reviewer' "$f" | head -1 | cut -d: -f1)
  if [ -z "$a" ] || [ -z "$b" ] || [ -z "$c" ] || [ -z "$d" ] || [ -z "$e" ]; then
    fail "a step is missing: check=$a lint=$b touched=$c tests=$d reviewer=$e"
  fi
  if [ "$a" -ge "$b" ] || [ "$b" -ge "$c" ] || [ "$c" -ge "$d" ] || [ "$d" -ge "$e" ]; then
    fail "order is check=$a lint=$b touched=$c tests=$d reviewer=$e"
  fi
  # done and the log come after the review, and the commit after both.
  local done_line log_line commit_line
  done_line=$(grep -n '`card done <id>`' "$f" | head -1 | cut -d: -f1)
  log_line=$(grep -n 'card log-new <id>' "$f" | head -1 | cut -d: -f1)
  commit_line=$(grep -n 'git commit' "$f" | head -1 | cut -d: -f1)
  if [ "$e" -ge "$done_line" ] || [ "$done_line" -ge "$log_line" ] || [ "$log_line" -ge "$commit_line" ]; then
    fail "order is reviewer=$e done=$done_line log=$log_line commit=$commit_line"
  fi
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

# A command substitution is denied by prefix permission rules in a session
# that cannot prompt (finding 10), so skills give each command on its own.
test_skills_do_not_use_command_substitution() {
  local f
  for f in $(skill_files) "$ROOT"/reference/*.md "$ROOT"/agents/*.md; do
    ! grep -n -F '$(' "$f" || fail "$f uses a command substitution"
  done
}

test_next_card_can_resume_a_card_in_progress() {
  local f="$ROOT/skills/next-card/SKILL.md"
  grep -q -i 'resume' "$f" || fail 'next-card has no way to resume an active or blocked card'
  grep -q -i 'remove the `## Blocked` section' "$f" || fail 'next-card never removes the Blocked section'
  grep -q -i 'remove the `## Blocked` section\|delete the `## Blocked` section' "$ROOT/reference/implement.md" || fail 'implement.md never removes the Blocked section'
}

test_init_tells_the_user_to_commit_before_the_next_command() {
  local f="$ROOT/skills/init/SKILL.md"
  grep -q -i 'commit .* before' "$f" || fail 'init does not say to commit what it wrote before the next command'
  grep -q 'git check-ignore' "$f" || fail 'init does not check whether the project ignores the log directory'
}

test_next_card_lints_the_card_before_it_starts() {
  local f="$ROOT/skills/next-card/SKILL.md" lint branch
  lint=$(grep -n '`card lint`' "$f" | head -1 | cut -d: -f1)
  branch=$(grep -n 'git checkout -b' "$f" | head -1 | cut -d: -f1)
  [ -n "$lint" ] || fail 'next-card never runs card lint'
  [ "$lint" -lt "$branch" ] || fail 'next-card lints after it creates the branch'
}

PLAN_SKILL="$ROOT/skills/plan/SKILL.md"

# plan_step <n>: the text of one numbered step of the plan skill, with its
# indented sub-steps.
plan_step() {
  awk -v n="$1." '/^[0-9]+\. / { on = $1 == n } /^## / { on = 0 } on' "$PLAN_SKILL"
}

# plan_line <pattern>: the line number of the first match in the plan skill.
plan_line() { grep -n -e "$1" "$PLAN_SKILL" | head -1 | cut -d: -f1; }

test_plan_skill_is_typed_by_the_user_and_does_not_fork() {
  local f="$PLAN_SKILL"
  assert_eq plan "$(front "$f" name)" name
  assert_eq true "$(front "$f" disable-model-invocation)" disable-model-invocation
  assert_eq '"<spec path> [what to change]"' "$(front "$f" argument-hint)" argument-hint
  # A forked skill runs in a subagent, which cannot ask the user (design 0.2,
  # section 19, rows 1, 2 and 6).
  ! grep -n -E '^(context|agent|background):' "$f" || fail 'the plan skill forks'
  grep -q -F '$ARGUMENTS' "$f" || fail 'the plan skill never reads its arguments'
  assert_eq 10 "$(grep -c '^[0-9][0-9]*\. \*\*' "$f")" 'numbered steps'
}

test_plan_skill_runs_the_check_the_review_and_the_approval_in_that_order() {
  local check review ask commit
  assert_contains "$(plan_step 6)" 'Run `card plan`'
  assert_contains "$(plan_step 7)" 'wait for it'
  assert_contains "$(plan_step 8)" 'Ask for a yes, an edit or a no'
  assert_contains "$(plan_step 9)" 'git commit'
  check=$(plan_line '^6\. ')
  review=$(plan_line 'Launch the `workdeck:plan-reviewer`')
  ask=$(plan_line 'Ask for a yes, an edit or a no')
  commit=$(plan_line 'git commit')
  if [ -z "$check" ] || [ -z "$review" ] || [ -z "$ask" ] || [ -z "$commit" ]; then
    fail "a step is missing: check=$check review=$review ask=$ask commit=$commit"
  fi
  if [ "$check" -ge "$review" ] || [ "$review" -ge "$ask" ] || [ "$ask" -ge "$commit" ]; then
    fail "order is check=$check review=$review ask=$ask commit=$commit"
  fi
  # Nothing before step 9 commits or pushes.
  assert_eq "$(plan_line '^9\. ')" "$(plan_line 'git commit\|git push\|gh pr create')" 'first line that commits, pushes or opens a pull request'
}

test_plan_skill_names_the_plan_reviewer_by_its_scoped_name() {
  local s
  s=$(plan_step 7)
  assert_contains "$s" '`workdeck:plan-reviewer` subagent'
  assert_contains "$s" "the outline's path and the base branch"
  [ -f "$ROOT/agents/plan-reviewer.md" ] || fail 'the agent the plan skill names does not exist'
  # The bare name could be another plugin's agent.
  ! grep -n 'plan-reviewer' "$PLAN_SKILL" | grep -v 'workdeck:plan-reviewer' || fail 'the plan reviewer is named without its plugin'
}

test_plan_skill_delegates_the_search_to_explore() {
  local s
  s=$(plan_step 5)
  # The wording both runs of the spike followed (design 0.2, section 19, row 15).
  assert_contains "$s" 'Do not read the code yourself: launch the built-in Explore subagent'
  assert_contains "$s" 'wait for its answer'
  assert_contains "$s" 'ask the user to confirm both'
  assert_contains "$s" 'found none of the code'
  assert_contains "$s" 'say so in the same question'
  assert_contains "$s" 'do not stop a second time'
  assert_contains "$s" 'card plan new <spec path> <PREFIX> --level <n>'
}

test_plan_skill_creates_a_plan_branch_named_by_the_time() {
  local s
  s=$(plan_step 4)
  assert_contains "$s" 'date +%y%m%d%H%M'
  assert_contains "$s" 'git checkout -b plan/<digits>'
  # The path is checked before the branch exists: a branch cannot be deleted
  # under the permission template.
  [ "$(plan_line 'git ls-files --error-unmatch')" -lt "$(plan_line 'git checkout -b')" ] || fail 'the branch is created before the path is checked'
  assert_contains "$(plan_step 1)" 'git status --porcelain'
  assert_contains "$(plan_step 1)" 'git pull --ff-only'
  assert_contains "$(plan_step 3)" 'not a tracked file'
}

test_plan_skill_offers_to_resume_an_open_plan_pull_request() {
  local s
  s=$(plan_step 2)
  assert_contains "$s" 'gh pr list --author @me --state open --json number,headRefName'
  assert_contains "$s" 'a `plan/` branch'
  assert_contains "$s" 'git branch --list'
  assert_contains "$s" 'offer to check it out'
  assert_contains "$s" 'gh pr view <number> --comments'
  assert_contains "$s" 'continue with step 6'
  assert_contains "$s" 'Otherwise stop'
  assert_contains "$s" 'If `gh` is missing or not signed in, say so and continue with step 3'
}

test_plan_skill_stops_when_card_has_no_plan_command() {
  local s
  s=$(plan_step 3)
  assert_contains "$s" "unknown command 'plan'"
  assert_contains "$s" 'must be updated, and stop'
  # A path card plan new would refuse is refused here too, and a run with
  # nothing to revise ends here: both before the branch.
  assert_contains "$s" 'If it has a space in it'
  assert_contains "$s" 'there is nothing to plan: say so and stop'
  # Before the branch, so that an old card leaves no plan branch behind.
  [ "$(plan_line "unknown command 'plan'")" -lt "$(plan_line 'git checkout -b')" ] || fail 'the plan command is first run after the branch is created'
}

test_plan_skill_runs_the_reviewer_again_after_a_must_fix_and_at_most_twice() {
  local s
  s=$(plan_step 7)
  assert_contains "$s" 'Fix every `must-fix` finding and run step 6 again'
  assert_contains "$s" 'If a fix changed the outline, launch the reviewer once more'
  assert_contains "$s" 'at most twice'
  assert_contains "$s" 'What the second run finds and you do not fix goes to the user in step 8'
  assert_contains "$s" 'Keep every finding of both runs'
  # An edit by the user is checked and reviewed again, under the same bound.
  assert_contains "$(plan_step 8)" 'go back to step 6'
  assert_contains "$s" 'under the same bound'
}

test_plan_skill_shows_the_readings_it_chose_and_the_requirements_it_left_out() {
  local s
  s=$(plan_step 8)
  assert_contains "$s" 'as a table'
  assert_contains "$s" 'each finding that was not fixed, with the reason'
  assert_contains "$s" 'can be read two ways'
  assert_contains "$s" 'which reading the rows follow'
  assert_contains "$s" 'each requirement that is in no row'
  assert_contains "$s" 'restore'
  assert_contains "$s" 'Check out the base branch and stop'
}

test_plan_skill_puts_every_finding_in_the_pull_request_body() {
  local s
  s=$(plan_step 9)
  assert_contains "$s" 'plan: <PREFIX>, <n> rows'
  assert_contains "$s" 'id, size, dependencies and title'
  assert_contains "$s" 'the `Not planned` list'
  assert_contains "$s" 'every reviewer finding of both runs, with what was done about it'
  assert_contains "$s" 'the readings chosen and the requirements left out'
  assert_contains "$s" '`card tokens`'
  assert_contains "$s" 'for a run that revised an outline'
  assert_contains "$s" 'Do not copy the `does` and `not` lines'
  assert_contains "$s" 'no remote'
  assert_contains "$s" 'If `gh` is missing or not signed in, stop after the push'
  # A resumed pull request exists already: gh pr create would fail on it.
  assert_contains "$s" 'gh pr edit <number> --body-file <file>'
  # A trailer is the user's setting: the skill says nothing for or against one.
  ! grep -n -i 'trailer\|co-authored' "$PLAN_SKILL" || fail 'the plan skill speaks of a commit trailer'
}

test_plan_skill_never_reuses_the_id_of_a_removed_row() {
  local s
  s=$(plan_step 5)
  assert_contains "$s" 'The id of a removed row is never given to another row'
  assert_contains "$s" 'git diff <spec_blob> HEAD:<spec path>'
  assert_contains "$s" 'no card file and no `card/<id>` branch'
  assert_contains "$s" 'card plan accept <PREFIX>'
  assert_contains "$s" 'Run `card plan`. If it says the specification differs from `spec_blob`'
}

test_plan_skill_writes_no_card_and_no_code() {
  local f="$PLAN_SKILL"
  grep -q 'It writes no card and no code' "$f" || fail 'the plan skill does not say what the session leaves alone'
  assert_contains "$(plan_step 10)" 'no card and no code'
  # The commands that create or finish a card belong to other skills.
  ! grep -n -E 'card (new|done|log-new|plan start|plan check)' "$f" || fail 'the plan skill names a command that writes a card'
  ! grep -n 'reference/implement.md' "$f" || fail 'the plan skill points at the implementation steps'
  assert_contains "$(plan_step 9)" 'the outline is the only file that changed'
}
