---
id: HOOK-04
title: Pre-compact marker
size: XS
depends:
done: true
---

## Read
- docs/specs/2026-10-05-workdeck-0.1-design.md (section 13)

## Touch
- hooks/pre-compact.sh (new)
- test/cases/53-hook-pre-compact.sh (new)
- test/fixtures/hooks/*
- test/lib.sh

## Tests
- pre compact is silent without config
- pre compact writes the marker
- pre compact rejects a hostile session id

## Acceptance
- With a config, <git-dir>/workdeck/<session>.compacted exists after the hook runs; nothing is printed.
- The hook never blocks compaction.

## Out of scope
- Removing old markers.
