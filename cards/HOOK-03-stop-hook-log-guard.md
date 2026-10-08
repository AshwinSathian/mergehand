---
id: HOOK-03
title: Stop hook log guard
size: S
depends:
done: true
---

## Read
- docs/design.md (section 13, log guard)
- docs/development/plan-0.1.md (step 6.3)
- bin/card (fork_point, id_of_branch)

## Touch
- hooks/stop.sh (new)
- test/cases/52-hook-stop.sh (new)
- test/fixtures/hooks/*
- test/lib.sh

## Tests
- stop is silent without config
- stop passes when stop hook active
- stop passes off a card branch
- stop blocks when commits have no log
- stop passes once a log for the card exists
- stop passes with a dirty tree

## Acceptance
- Exit 2 with a message naming /workdeck:handoff only when the branch has commits, the tree is clean and no log for this card was added on the branch.
- A log for a different card does not satisfy the guard.
- Every other path, including malformed input, exits 0.

## Out of scope
- Forcing a log on review-fixes sessions (known limit in the spec).

## Notes
- This is the only deliberate exit 2 in the plugin.
