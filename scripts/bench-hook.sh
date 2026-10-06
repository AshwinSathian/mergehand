#!/usr/bin/env bash
# Measures the wall time the PostToolUse hook adds to a tool call.
# Usage: scripts/bench-hook.sh [runs]     (default 50 runs per path)
# Prints median and 95th percentile in milliseconds for each path the hook
# can take. Not part of the test suite: timings are not pass/fail.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd -P)
RUNS=${1:-50}
HOOK="$ROOT/hooks/post-tool-use.sh"
T=$(mktemp -d) && T=$(cd "$T" && pwd -P) || exit 1
trap 'cd /; rm -rf "$T"' EXIT
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.invalid GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.invalid

# transcript <file> <megabytes>: assistant lines whose context size climbs
# from 50,000 to about 120,000 tokens, between user lines of 4 kB.
transcript() {
  awk -v mb="$2" 'BEGIN {
    pad = sprintf("%4000s", ""); gsub(/ /, "x", pad)
    lines = int(mb * 1024 * 1024 / 4700)
    for (i = 0; i < lines; i++) {
      printf "{\"isSidechain\":false,\"type\":\"user\",\"message\":{\"role\":\"user\",\"content\":\"%s\"}}\n", pad
      printf "{\"isSidechain\":false,\"message\":{\"role\":\"assistant\",\"content\":[],\"usage\":{\"input_tokens\":10,\"cache_creation_input_tokens\":990,\"cache_read_input_tokens\":%d,\"output_tokens\":5,\"iterations\":[{\"input_tokens\":10}]}},\"type\":\"assistant\"}\n", 49000 + int(70000 * i / lines)
    }
  }' > "$1"
}

input() { # <transcript> [payload bytes]
  printf '{"session_id":"bench","transcript_path":"%s","cwd":"%s","hook_event_name":"PostToolUse","tool_name":"Bash","tool_result":{"type":"text","text":"' "$1" "$PWD"
  [ -z "${2-}" ] || awk -v n="$2" 'BEGIN { for (i = 0; i < n / 10; i++) printf "0123456789" }'
  printf '"}}'
}

# bench <label>: runs the hook $RUNS times in the current directory on $T/in.
bench() {
  local i=0 TIMEFORMAT=%R
  while [ "$i" -lt "$RUNS" ]; do
    { time "$BASH" "$HOOK" < "$T/in" > /dev/null 2>&1; } 2>&1
    i=$((i + 1))
  done | sort -n | awk -v label="$1" -v n="$RUNS" '
    { v[NR] = $1 * 1000 }
    END { printf "%-44s %6.0f ms %6.0f ms\n", label, v[int((n + 1) / 2)], v[int(n * 0.95 + 0.5)] }'
}

transcript "$T/2mb.jsonl" 2
transcript "$T/20mb.jsonl" 20

mkdir "$T/plain" "$T/repo" && cd "$T/repo" || exit 1
git init -q . && git symbolic-ref HEAD refs/heads/main
printf 'check = true\n' > mergehand.conf
mkdir cards
i=1
while [ "$i" -le 30 ]; do
  printf -- '---\nid: A-%s\ntitle: Card %s\nsize: M\ndepends:\ndone: false\n---\n' "$i" "$i" > "cards/A-$i-thing.md"
  i=$((i + 1))
done
git add -A && git commit -q -m deck

printf '%-44s %9s %9s\n' "path ($RUNS runs each, $(uname -s), bash ${BASH_VERSION%%(*})" median p95
cd "$T/plain" && input "$T/2mb.jsonl" > "$T/in" && bench 'not a Mergehand project'
cd "$T/repo" && bench 'Mergehand project, not on a card branch'
git checkout -q -b card/A-1-thing
bench 'card branch, under budget, 2 MB transcript'
input "$T/2mb.jsonl" 1000000 > "$T/in" && bench 'same, with a 1 MB tool result on stdin'
input "$T/20mb.jsonl" > "$T/in" && bench 'card branch, under budget, 20 MB transcript'
mkdir -p .git/mergehand && : > .git/mergehand/bench.warned
bench 'card branch, already warned'
