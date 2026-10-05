---
id: TOK-01
title: card tokens with fixture transcripts
size: S
depends:
done: true
---

## Read
- docs/specs/2026-10-05-workdeck-0.1-design.md (section 14)
- docs/plans/2026-10-05-workdeck-0.1-plan.md (section B, transcript shape; step 5.1)
- bin/card (cmd_log_new, conf_get)

## Touch
- bin/card
- test/cases/40-tokens.sh (new)
- test/fixtures/transcripts/* (new)

## Tests
- tokens prints baseline peak and growth
- tokens keeps the peak after compaction
- tokens ignores sidechain and zero usage lines
- tokens ignores the nested iterations copy
- tokens prints unknown for unrecognized shapes
- tokens prints the budget on a card branch

## Acceptance
- The fixture transcripts and the test file are committed before the parser.
- card tokens on normal.jsonl prints exactly baseline 57000, peak 141300, growth 84300.
- Every unrecognized input (no usage, garbage, empty, missing file, unset variable) prints unknown and exits 0.
- A token key that appears only inside usage.iterations is not counted.

## Out of scope
- Subagent transcripts, cost and output tokens.
- Writing figures into the log (TOK-02).

## Notes
- The three keys repeat inside usage.iterations; take the first occurrence after "usage":{ on each line.
- One API message is written as several lines with the same usage. Harmless for baseline and peak.
