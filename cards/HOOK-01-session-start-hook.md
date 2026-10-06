---
id: HOOK-01
title: Session-start hook
size: S
depends:
done: true
---

## Read
- docs/design.md (sections 13 and 16)
- docs/development/plan-0.1.md (stage 6 preamble, step 6.1, section G items 16 and 17)
- bin/card (cmd_status)

## Touch
- hooks/session-start.sh (new)
- test/cases/50-hook-session-start.sh (new)
- test/fixtures/hooks/* (new)
- test/lib.sh

## Tests
- session start is silent without config
- session start prints card status
- session start exports transcript and session
- session start writes hostile values literally
- session start survives a broken config

## Acceptance
- With no mergehand.conf the hook prints nothing and exits 0.
- With one, stdout is the output of card status and stays under status_max_chars.
- CLAUDE_ENV_FILE gains MERGEHAND_TRANSCRIPT and MERGEHAND_SESSION, single-quoted.
- The hook never fetches and exits 0 on every error.

## Out of scope
- Registering the hook (PLUG-01).

## Notes
- Re-read code.claude.com/docs/en/hooks before writing: SessionStart input fields and CLAUDE_ENV_FILE.
- A git call costs about 17 ms on macOS; keep them few.
