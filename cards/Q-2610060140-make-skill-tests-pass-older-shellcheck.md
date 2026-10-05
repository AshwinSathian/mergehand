---
id: Q-2610060140
title: Make skill tests pass older shellcheck
size: XS
depends:
done: true
---

## Read

## Touch
- test/cases/60-skills.sh

## Tests
- handoff runs the gates in order

## Acceptance
- make lint passes on Ubuntu 24.04, whose shellcheck reports SC2015 where 0.11 does not.

## Notes
- From the first CI run: macOS passed, Ubuntu failed at the shellcheck step on three lines of one test.
