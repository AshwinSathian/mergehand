#!/usr/bin/env bash
# PostToolUse hook: one warning per session when the session's context has
# grown past the budget of the card being worked on. Never blocks.
#
# This runs after every tool call in every project where the plugin is
# enabled, so the common exits start no process at all: the project check and
# the branch check read files directly. Any failure ends in exit 0.

# 1. Not a Mergehand project: leave. The repository root is the nearest
#    directory with a .git entry; mergehand.conf must sit beside it.
d=$PWD
while [ ! -e "$d/.git" ]; do
  d=${d%/*}
  [ -n "$d" ] || exit 0
done
[ -f "$d/mergehand.conf" ] || exit 0

# 2. Not on a card branch: leave. In a linked worktree .git is a file that
#    names the real git directory.
gitdir=$d/.git
if [ -f "$gitdir" ]; then
  IFS= read -r line < "$gitdir" || exit 0
  gitdir=${line#gitdir: }
  case $gitdir in /*) ;; *) gitdir=$d/$gitdir ;; esac
fi
[ -r "$gitdir/HEAD" ] || exit 0
IFS= read -r head < "$gitdir/HEAD" || exit 0
# A reftable repository keeps a placeholder in HEAD; ask git there.
[ "$head" != 'ref: refs/heads/.invalid' ] || head="ref: $(git -C "$d" symbolic-ref -q HEAD 2>/dev/null)"
case $head in 'ref: refs/heads/card/'*) ;; *) exit 0 ;; esac

# 3. The fields we need from the hook input: the first of each. A tool call
#    made by a subagent carries agent_id and is ignored, so the reviewer
#    cannot use up the one warning.
session="" transcript="" agent=""
while IFS= read -r kv; do
  v=${kv#*\":\"}
  v=${v%\"}
  case $kv in
    '"session_id":'*) [ -n "$session" ] || session=$v ;;
    '"transcript_path":'*) [ -n "$transcript" ] || transcript=$v ;;
    '"agent_id":'*) agent=$v ;;
  esac
done <<FIELDS
$(grep -o -E '"(session_id|transcript_path|agent_id)":"[^"]*"' 2>/dev/null)
FIELDS
[ -z "$agent" ] || exit 0
case $session in '' | *[!A-Za-z0-9_-]*) exit 0 ;; esac
marker=$gitdir/mergehand/$session.warned
[ ! -e "$marker" ] || exit 0

# 4. Measure growth against the card's budget.
growth="" budget="" size=""
while read -r k v w; do
  case $k in
    growth) growth=$v ;;
    budget) budget=$v size=$w ;;
  esac
done <<TOKENS
$("${BASH:-bash}" "${0%/*}/../bin/card" tokens "$transcript" 2>/dev/null)
TOKENS
case $growth in '' | *[!0-9]*) exit 0 ;; esac
case $budget in '' | *[!0-9]*) exit 0 ;; esac
[ "$growth" -gt "$budget" ] || exit 0

# The marker goes down before the warning is printed: a failure here can lose
# the warning, but can never repeat it on every tool call.
mkdir -p "$gitdir/mergehand" 2>/dev/null && : 2>/dev/null > "$marker" || exit 0
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"Mergehand: this session has grown by %s tokens, past the %s-token budget of a size %s card. Finish the current step, then stop and ask the user to run /mergehand:handoff split."}}\n' \
  "$growth" "$budget" "$size"
exit 0
