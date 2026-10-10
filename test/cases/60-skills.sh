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
        # The message of the approval commit is not a command.
        gsub(/: card as approved/, "", line)
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
  # The lint every card gets, not the one inside the steps for a row.
  lint=$(grep -n 'For every card, run `card lint`' "$f" | head -1 | cut -d: -f1)
  branch=$(grep -n 'git checkout -b' "$f" | head -1 | cut -d: -f1)
  [ -n "$lint" ] || fail 'next-card never runs card lint'
  [ "$lint" -lt "$branch" ] || fail 'next-card lints after it creates the branch'
}

NEXT_SKILL="$ROOT/skills/next-card/SKILL.md"

# next_step <n>: the text of one numbered step of next-card, with its
# indented sub-steps.
next_step() {
  awk -v n="$1." '/^[0-9]+\. / { on = $1 == n } on' "$NEXT_SKILL"
}

# row_step <n>: one of the six indented steps of step 6, for a row.
row_step() {
  next_step 6 | awk -v n="$1." '/^   [0-9]+\. / { on = $1 == n } /^   [^ ]/ && !/^   [0-9]+\. / { on = 0 } on'
}

test_next_card_writes_the_card_for_a_row_before_the_branch_exists() {
  local s start branch
  s=$(next_step 6)
  assert_contains "$s" 'If the output starts with `row:`'
  assert_contains "$s" 'For a card that has a file, skip them'
  assert_contains "$(row_step 1)" 'Run `card plan start <id>`'
  assert_eq 6 "$(printf '%s\n' "$s" | grep -c '^   [0-9]\. ')" 'steps for a row'
  start=$(grep -n '`card plan start <id>`' "$NEXT_SKILL" | head -1 | cut -d: -f1)
  branch=$(grep -n 'git checkout -b' "$NEXT_SKILL" | head -1 | cut -d: -f1)
  [ "$start" -lt "$branch" ] || fail 'next-card creates the branch before it writes the card'
  assert_contains "$s" 'untracked until the yes'
  assert_contains "$s" 'on the base branch (on the card'"'"'s branch only if step 5 resumed it)'
  assert_contains "$(row_step 1)" 'If it fails, explain the error and stop'
  # The six are in this order in the file, whatever their numbers say.
  local prev=0 n p
  for p in '`card plan start <id>`' 'the code the work concerns' 'Fill in the card' 'cannot be done as it was cut' '`card plan check <id>`' 'Show the card to the user'; do
    n=$(grep -n -F -e "$p" "$NEXT_SKILL" | head -1 | cut -d: -f1)
    [ -n "$n" ] && [ "$n" -gt "$prev" ] || fail "out of order: $p"
    prev=$n
  done
  # A card left untracked by a session that ended early is not yet approved.
  assert_contains "$s" 'that git does not track (`git ls-files --error-unmatch <card file>` fails)'
  assert_contains "$s" 'Nobody has approved it. Do the fifth and sixth of these steps on it'
  # Steps 1 to 5 are as they were in 0.1. A card that changes one changes this sum.
  assert_eq '675399525 1929' "$(awk '/^1\. /,/^6\. /' "$NEXT_SKILL" | sed '$d' | cksum)" 'steps 1 to 5'
}

test_next_card_fills_touch_tests_and_read_from_the_code() {
  local s
  assert_contains "$(row_step 2)" 'the code the work concerns'
  s=$(row_step 3)
  assert_contains "$s" '`Touch`: full paths taken from the code as read, with `(new)` on a file the card creates'
  assert_contains "$s" '`Tests`: one item per test, written as the innermost name the test will have, in the style of the tests it will sit beside'
  assert_contains "$s" '`Read`: the files a session must read first, after the specification'
  assert_contains "$s" '`Acceptance` and `Out of scope` start as the row'"'"'s lines. Keep them unless they are wrong, and add to them'
  assert_contains "$s" 'Change `size` if the row'"'"'s guess no longer holds'
  assert_contains "$s" 'write the guess under `Notes`'
}

test_next_card_leaves_the_row_item_under_read_as_it_was_written() {
  local s
  s=$(row_step 3)
  assert_contains "$s" 'The first `Read` item, with its `(row ...)` comment, stays as `card plan start` wrote it'
  assert_contains "$s" 'no heading added and no anchor on the path'
  assert_contains "$s" 'the reviewer checks the card against the headings it names'
}

test_next_card_runs_lint_and_plan_check_before_it_asks() {
  local check ask
  assert_contains "$(row_step 5)" 'Run `card lint` and `card plan check <id>`. Fix what they report about this card. If `card lint` reports another file, show the user and stop'
  check=$(grep -n '`card plan check <id>`' "$NEXT_SKILL" | head -1 | cut -d: -f1)
  ask=$(grep -n 'Show the card to the user' "$NEXT_SKILL" | head -1 | cut -d: -f1)
  if [ -z "$check" ] || [ -z "$ask" ] || [ "$check" -ge "$ask" ]; then
    fail "order is check=$check ask=$ask"
  fi
  # An edit is checked again before the user sees the card a second time.
  assert_contains "$(row_step 6)" 'After an edit, make it, run `card lint` and `card plan check <id>` again, then show the card and ask again: only a yes goes on'
}

test_next_card_deletes_the_card_file_after_a_no() {
  local s
  s=$(row_step 6)
  assert_contains "$s" 'ask for a yes or an edit'
  assert_contains "$s" 'Do not write code before the answer'
  assert_contains "$s" 'After a no, delete the card file and stop'
  assert_contains "$s" 'nothing was committed and no branch exists'
}

test_next_card_commits_the_approved_card_alone() {
  local s
  s=$(next_step 7)
  assert_contains "$s" 'git add <card file>'
  assert_contains "$s" 'git commit -m "<id>: card as approved"'
  assert_contains "$s" 'the card file alone'
  assert_contains "$s" 'with nothing else staged'
  assert_contains "$s" 'and for a card file that git did not track'
  assert_contains "$s" 'Do this on a resumed branch too'
  assert_contains "$s" 'If the commit fails, show the error and stop: do not start step 8'
  assert_contains "$s" 'before step 8'
  assert_contains "$s" 'Make no such commit for a card that had a file git tracks'
  assert_contains "$(next_step 9)" 'do not commit anything after step 7'
  [ "$(grep -n 'git checkout -b' "$NEXT_SKILL" | head -1 | cut -d: -f1)" -lt "$(grep -n 'git commit' "$NEXT_SKILL" | head -1 | cut -d: -f1)" ] || fail 'next-card commits before the branch exists'
  assert_eq 1 "$(grep -c 'git commit' "$NEXT_SKILL")" 'lines that commit'
  ! grep -n -E 'git add (-A|--all|\.)|git commit -a|git push|gh pr create' "$NEXT_SKILL" || fail 'next-card names a command it must not run'
}

test_next_card_sends_the_user_to_revise_the_outline_when_a_row_cannot_be_done_as_cut() {
  local s
  s=$(row_step 4)
  assert_contains "$s" 'it needs code that no finished card provides, or it overlaps another row'
  assert_contains "$s" 'delete the card file'
  assert_contains "$s" 'revise the outline with `/workdeck:plan <spec path>`, which the user types'
  assert_contains "$s" 'and stop'
  assert_contains "$s" 'Only these two cases'
}

test_implement_reference_says_the_approved_card_is_already_committed() {
  local s
  s=$(awk '/^[0-9]+\. / { on = $1 == "6." } on' "$ROOT/reference/implement.md")
  assert_contains "$s" 'the approved card is already committed, alone, as `<id>: card as approved`'
  assert_contains "$s" 'Nothing else is committed before handoff, a later change to the card included'
  # Still true for a quick card, which has no such commit.
  assert_contains "$s" 'wrote from a row'
  assert_contains "$s" 'outside the cards directory'
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
  # No key beyond these: a quoted `context`, or a `model`, would pass the line above.
  assert_eq 'name description argument-hint disable-model-invocation allowed-tools' "$(awk 'NR == 1 { next } $0 == "---" { exit } { sub(/:.*/, ""); printf "%s%s", s, $0; s = " " }' "$f")" 'front matter keys'
  # shellcheck disable=SC2016
  assert_eq 'Bash("${CLAUDE_PLUGIN_ROOT}/bin/card" *) Bash(card *)' "$(front "$f" allowed-tools)" allowed-tools
  grep -q -F '$ARGUMENTS' "$f" || fail 'the plan skill never reads its arguments'
  assert_eq 10 "$(grep -c '^[0-9][0-9]*\. \*\*' "$f")" 'numbered steps'
}

test_plan_skill_runs_the_check_the_review_and_the_approval_in_that_order() {
  local check review ask commit
  assert_contains "$(plan_step 6)" 'Run `card plan`'
  assert_contains "$(plan_step 6)" 'Fix what it reports and run it again'
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
  ! grep -n -E 'gh pr merge|--force|--no-verify|git add -A' "$PLAN_SKILL" || fail 'the plan skill names a command it must not run'
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
  assert_contains "$s" '4. Run `card plan new <spec path> <PREFIX> --level <n>`'
}

test_plan_skill_creates_a_plan_branch_named_by_the_time() {
  local s
  s=$(plan_step 4)
  assert_contains "$s" 'date +%y%m%d%H%M'
  assert_contains "$s" 'git checkout -b plan/<digits>'
  # The path is checked before the branch exists: a branch cannot be deleted
  # under the permission template.
  [ "$(plan_line 'git ls-files --full-name --error-unmatch')" -lt "$(plan_line 'git checkout -b')" ] || fail 'the branch is created before the path is checked'
  assert_contains "$(plan_step 1)" 'Run `git status --porcelain`. If it prints anything, stop and ask the user what to do with the changes'
  assert_contains "$(plan_step 1)" 'git pull --ff-only'
  assert_contains "$(plan_step 1)" 'If the pull is not a fast-forward, stop'
  assert_contains "$(plan_step 3)" 'the path is not a tracked file: say so and stop'
  assert_contains "$(plan_step 3)" 'the path is not one file: say so and stop'
}

test_plan_skill_offers_to_resume_an_open_plan_pull_request() {
  local s
  s=$(plan_step 2)
  assert_contains "$s" 'gh pr list --author @me --state open --json number,headRefName'
  assert_contains "$s" 'a `plan/` branch'
  assert_contains "$s" 'git branch --list'
  assert_contains "$s" 'is open, say so'
  assert_contains "$s" 'If the branch is local, offer to check it out. If the user declines, stop'
  # What the user typed after the path is not lost on this way round step 5.
  assert_contains "$s" 'and what the user asked for after the path, by the rules of step 5 for an existing outline'
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
  assert_contains "$s" 'If it has any character other than a letter, a digit, `.`, `_`, `-` or `/`, say that an outline cannot name such a path, and stop'
  assert_contains "$s" 'did not say its specification differs from `spec_blob` and reported nothing for it, and the user asked for no change, there is nothing to plan: say so and stop'
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
  assert_contains "$(plan_step 8)" 'An edit: make it and go back to step 6.'
  assert_contains "$(plan_step 8)" 'Yes: continue with step 9.'
  assert_contains "$s" 'comes back here and is reviewed again under the same bound'
}

test_plan_skill_shows_the_readings_it_chose_and_the_requirements_it_left_out() {
  local s
  s=$(plan_step 8)
  assert_contains "$s" 'as a table'
  assert_contains "$s" 'each finding that was not fixed, with the reason'
  assert_contains "$s" 'can be read two ways'
  assert_contains "$s" 'which reading the rows follow'
  assert_contains "$s" 'each requirement that is in no row'
  assert_contains "$s" 'No: delete the outline file if this run created it, or restore it with `git checkout -- <outline>` if it did not. Check out the base branch and stop.'
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
  assert_contains "$s" 'If the repository has no remote, stop here'
  assert_contains "$s" 'Run `git add <outline>` and `git commit`.'
  assert_contains "$s" 'gh pr create --base <base> --title "plan: <PREFIX>, <n> rows" --body-file <file>'
  assert_contains "$s" 'what the user asked for or which change to the specification caused it'
  assert_contains "$s" 'If `gh` is missing or not signed in, stop after the push'
  # A resumed pull request exists already: gh pr create would fail on it.
  # gh pr edit replaces the body: the file starts from the body as it is.
  assert_contains "$s" 'do not open a second one'
  assert_contains "$s" 'the file holds the body as it is (`gh pr view <number> --json body`) followed by what this run did'
  assert_contains "$s" 'gh pr edit <number> --title "plan: <PREFIX>, <n> rows" --body-file <file>'
  # A trailer is the user's setting: the skill says nothing for or against one.
  ! grep -n -i 'trailer\|co-authored' "$PLAN_SKILL" || fail 'the plan skill speaks of a commit trailer'
}

test_plan_skill_never_reuses_the_id_of_a_removed_row() {
  local s
  s=$(plan_step 5)
  assert_contains "$s" 'The id of a removed row is never given to another row'
  assert_contains "$s" 'A new row takes a number above every number the outline has had'
  assert_contains "$s" 'differs from `spec_blob`, show the user `git diff <spec_blob> HEAD:<spec path>`'
  assert_contains "$s" 'Only a row with no card file and no `card/<id>` branch may be changed or removed'
  # card list maps a branch to an id exactly; a git pattern for AUTH-1 also
  # lists the branch of AUTH-12.
  assert_contains "$s" '`card list` shows such a row as `ready` or `waiting`, with `[row]` after its title'
  assert_contains "$s" 'say so and leave the row alone'
  assert_contains "$s" '5. Run `card plan accept <PREFIX>`'
  assert_contains "$s" 'Run `card plan`. If it says the specification differs from `spec_blob`'
}

test_plan_skill_writes_no_card_and_no_code() {
  local f="$PLAN_SKILL"
  grep -q 'It writes no card and no code' "$f" || fail 'the plan skill does not say what the session leaves alone'
  assert_contains "$(plan_step 10)" 'no card and no code'
  assert_contains "$(plan_step 10)" 'after the pull request is merged'
  # The commands that create or finish a card belong to other skills.
  ! grep -n -E 'card (new|done|log-new|plan start|plan check)' "$f" || fail 'the plan skill names a command that writes a card'
  ! grep -n 'reference/implement.md' "$f" || fail 'the plan skill points at the implementation steps'
  assert_contains "$(plan_step 9)" 'the outline is the only file that changed. If anything else changed, revert it first'
}
