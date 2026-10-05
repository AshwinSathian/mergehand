---
id: S-01
title: Polish card as a product: version, help, arguments, messages
size: M
depends:
done: true
---

## Read
- docs/development/findings.md (finding 12)
- bin/card (usage, dispatch, card_path, cmd_new, cmd_stats, cmd_tokens, cmd_next)

## Touch
- bin/card
- test/cases/10-basics.sh
- test/cases/12-show.sh
- test/cases/30-new.sh
- test/cases/40-tokens.sh
- test/cases/41-stats.sh
- test/cases/01-portability.sh
- cards/REVIEW.md (the rule on message format now says where reports go)

## Tests
- basics version matches the plugin manifest
- basics help for one command
- basics surplus arguments are rejected
- show unknown prefix has no dangling colon
- new slug ends at a word
- stats says how many sessions are unmeasured
- tokens says why it is unknown
- card file carries no persona markers

## Acceptance
- card --version, -V and version print card and the version in plugin.json.
- card <command> --help prints that command's synopsis and exits 0; a surplus argument is a usage error, exit 2, printed as usage: with no card: prefix.
- No message ends in a dangling colon, and no comment in bin/card carries another tool's marker or skeleton text.
- card help says that reports go to stdout and errors to stderr.

## Notes
- From the comparison against respected repositories, 2026-10-06. Command renames are left for 0.2.
