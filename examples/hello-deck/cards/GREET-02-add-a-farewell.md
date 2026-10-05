---
id: GREET-02
title: Add a farewell
size: XS
depends: GREET-01
done: false
---

## Read
- src/greet.sh

## Touch
- src/greet.sh
- tests/greet.sh

## Tests
- farewell says goodbye with the name

## Acceptance
- `bye World` prints `goodbye World`.
- `hello` still works: the GREET-01 test passes.

## Out of scope
- Changing how `hello` is called.
