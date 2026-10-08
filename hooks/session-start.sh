#!/usr/bin/env bash
# SessionStart hook: prints `card status` into the session and hands the
# transcript path to later Bash tool commands through CLAUDE_ENV_FILE.
#
# Plugin hooks run in every project where the plugin is enabled, so the first
# action is to leave silently when this is not a WorkDeck project. Every
# other failure also ends in exit 0: a broken hook must not block a session.

root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -f "$root/workdeck.conf" ] || exit 0

input=$(cat)
card=$(dirname "$0")/../bin/card

# field <key>: the first "key":"value" string in the hook input.
field() {
  printf '%s' "$input" | grep -o "\"$1\":\"[^\"]*\"" | head -1 | sed 's/^"[^"]*":"//; s/"$//; s|\\/|/|g'
}

if [ -n "${CLAUDE_ENV_FILE-}" ]; then
  transcript=$(field transcript_path)
  session=$(field session_id)
  {
    # Single-quoted so the file can be sourced whatever the path contains.
    [ -z "$transcript" ] ||
      printf "export WORKDECK_TRANSCRIPT='%s'\n" "$(printf '%s' "$transcript" | sed "s/'/'\\\\''/g")"
    case $session in
      '' | *[!A-Za-z0-9_-]*) ;;
      *) printf "export WORKDECK_SESSION='%s'\n" "$session" ;;
    esac
  } >> "$CLAUDE_ENV_FILE" 2>/dev/null
fi

# No --fetch: starting a session stays fast and works offline.
status=$("${BASH:-bash}" "$card" status 2>/dev/null) && [ -n "$status" ] && printf '%s\n' "$status"
exit 0
