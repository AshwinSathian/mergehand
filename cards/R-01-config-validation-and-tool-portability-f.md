---
id: R-01
title: Config validation and tool portability from the review
size: S
depends:
done: true
---

## Read
- docs/development/findings.md (finding 11)
- bin/card (load_conf, g)

## Touch
- bin/card
- test/cases/01-portability.sh
- test/cases/11-conf.sh
- test/cases/20-base.sh
- .github/workflows/ci.yml

## Tests
- conf keys pattern has no backslash
- conf rejects directory forms that break the gates
- conf rejects equal cards and log directories
- conf caps status max chars
- base done ignores user grep config

## Acceptance
- No value passed to awk -v contains a backslash, so gawk prints no escape warning.
- cards_dir and log_dir reject a trailing slash, a double slash and a dot segment, and must differ.
- status_max_chars above 10000 is a configuration error.
- git grep settings in the user's configuration cannot change card state.
- CI runs the suite on Ubuntu with awk as mawk and as gawk.

## Notes
- From the independent review of 2026-10-06, defects 1, 5 and 10.
