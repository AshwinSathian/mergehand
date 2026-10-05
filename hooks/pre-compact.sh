#!/usr/bin/env bash
# PreCompact hook: leaves a marker so the session log can record
# "compacted: true". It never blocks: stopping compaction on a full context
# window would leave the session unable to continue. Always exit 0.

root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -f "$root/workdeck.conf" ] || exit 0

session=$(grep -o '"session_id":"[^"]*"' 2>/dev/null | head -1 | sed 's/^"session_id":"//; s/"$//')
# The id becomes a file name.
case $session in '' | *[!A-Za-z0-9_-]*) exit 0 ;; esac

dir=$(git rev-parse --absolute-git-dir 2>/dev/null) || exit 0
mkdir -p "$dir/workdeck" 2>/dev/null && : 2>/dev/null > "$dir/workdeck/$session.compacted"
exit 0
