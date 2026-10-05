---
id: DOC-02
title: LICENSE
size: XS
depends: PLUG-01
done: false
---

## Read

## Touch
- LICENSE (new)
- .claude-plugin/plugin.json
- test/cases/02-plugin.sh

## Tests
- plugin manifest names the license

## Acceptance
- The license is the one the owner chose; plugin.json carries its SPDX identifier.

## Out of scope
- Choosing the license: the owner does that.

## Notes
- Ask the owner which license before writing anything.
- The license is MIT, copyright Ashwin Sathian (decided 2026-10-06). `README.md` already says MIT in its last section; link that line to `LICENSE` and add a license badge beside the CI badge. Add `README.md` to Touch with that reason, or leave the README alone.
- `bin/card` has a header line with the version and URL; add `# SPDX-License-Identifier: MIT` under it (then `bin/card` joins Touch).
