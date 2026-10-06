#!/usr/bin/env bash
# Stop hook: the log guard. On a card branch that has commits, a clean tree
# and no session log for the card, it blocks the stop once and says what to
# do. This is the only deliberate exit 2 in the plugin; every other path,
# including every failure, is exit 0.

root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -f "$root/mergehand.conf" ] || exit 0

input=$(cat)
# Only act on input we recognize, and never twice in a row: stop_hook_active
# is true when this hook already blocked the turn that is ending now.
case $input in *'"hook_event_name"'*) ;; *) exit 0 ;; esac
printf '%s' "$input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0

branch=$(git symbolic-ref -q --short HEAD 2>/dev/null) || exit 0
[[ $branch =~ ^card/([A-Z][A-Z0-9]*-[0-9]+[a-z]?)(-|$) ]] || exit 0
id=${BASH_REMATCH[1]}

card() { "${BASH:-bash}" "$(dirname "$0")/../bin/card" "$@" 2>/dev/null; }
base=$(card conf base) || exit 0
log_dir=$(card conf log_dir) || exit 0

# Commits that belong to this branch: reachable from HEAD and from neither
# the local nor the remote base branch.
set --
for ref in "refs/heads/$base" "refs/remotes/origin/$base"; do
  git rev-parse -q --verify "$ref" >/dev/null 2>&1 && set -- "$@" "$ref"
done
[ "$#" -gt 0 ] || exit 0
ahead=$(git rev-list --count HEAD --not "$@" 2>/dev/null) || exit 0
[ "$ahead" -gt 0 ] || exit 0
[ -z "$(git status --porcelain --untracked-files=normal 2>/dev/null)" ] || exit 0

# A log for this card that was added on the branch satisfies the guard.
# If git fails here, leave: an internal error must never block a session.
added=$(git -c core.quotepath=off log --no-renames --diff-filter=A --name-only --format= HEAD --not "$@" -- "$log_dir" 2>/dev/null) || exit 0
printf '%s\n' "$added" | grep -Eq "^$log_dir/[0-9]{4}-[0-9]{2}-[0-9]{2}-$id-[0-9]+\.md\$" && exit 0

printf 'Mergehand: card %s has commits on this branch and no session log.\n' "$id" >&2
printf 'Tell the user the work is ready and ask them to run /mergehand:handoff.\n' >&2
printf 'If the session is waiting on a person instead, add a "## Blocked" section with the question to the card, run "card log-new %s blocked", fill it in and commit.\n' "$id" >&2
exit 2
