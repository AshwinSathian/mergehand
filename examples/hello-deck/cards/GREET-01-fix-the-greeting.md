---
id: GREET-01
title: Fix the greeting
size: XS
depends:
done: true
---

## Read
- src/greet.sh

## Touch
- src/greet.sh
- tests/greet.sh (new)

## Tests
- greet says hello with the name

## Acceptance
- `hello World` prints `hello World`.

## Out of scope
- A farewell. GREET-02 owns it.

## Notes
- The typo is in the string, not in the function name.
