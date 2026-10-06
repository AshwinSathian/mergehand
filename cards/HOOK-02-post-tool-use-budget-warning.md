---
id: HOOK-02
title: Post-tool-use budget warning and timing
size: M
depends: TOK-01
done: true
---

## Read
- docs/design.md (section 13, budget warning)
- docs/development/plan-0.1.md (step 6.2, section G items 2 and 16)
- bin/card (cmd_tokens)

## Touch
- hooks/post-tool-use.sh (new)
- test/cases/51-hook-post-tool-use.sh (new)
- test/bench-hook.sh (new)
- test/fixtures/hooks/*
- bin/card
- docs/development/findings.md

## Tests
- post tool use is silent without config
- post tool use is silent off a card branch
- post tool use is silent under budget
- post tool use warns once over budget
- post tool use ignores subagent calls
- post tool use is silent when tokens are unknown

## Acceptance
- Over budget, stdout is the documented hookSpecificOutput JSON with the growth, the budget and /mergehand:handoff split.
- The warning appears once per session; the marker is written before the warning is printed.
- Tool calls that carry agent_id are ignored.
- test/bench-hook.sh reports median and 95th percentile for the no-config, under-budget and already-warned paths, with 2 MB and 20 MB transcripts, and the numbers are in docs/development/findings.md.

## Out of scope
- Blocking, a narrower matcher, caching an offset into the transcript.

## Notes
- If the under-budget median is above 50 ms, stop and report options. Do not optimize silently.
