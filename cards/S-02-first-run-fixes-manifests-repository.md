---
id: S-02
title: First-run fixes, manifests, repository hygiene and CI
size: M
depends:
done: true
---

## Read
- docs/findings.md (finding 12)
- skills/init/SKILL.md
- skills/next-card/SKILL.md
- skills/handoff/SKILL.md
- templates/settings-permissions.json
- .github/workflows/ci.yml

## Touch
- skills/*
- templates/settings-permissions.json
- .claude-plugin/*
- .github/*
- .gitattributes (new)
- .gitignore (new)
- .editorconfig (new)
- SECURITY.md (new)
- CHANGELOG.md (new)
- CONTRIBUTING.md (new)
- Makefile (new)
- scripts/bench-hook.sh (moved from test/)
- test/bench-hook.sh (moved to scripts/)
- test/run.sh
- test/cases/01-portability.sh
- test/cases/02-plugin.sh
- test/cases/60-skills.sh
- log/.gitkeep (removed)

## Tests
- init tells the user to commit before the next command
- next card lints the card before it starts
- permission template allows what next card runs
- repository has the files a stranger looks for
- plugin manifest names its repository

## Acceptance
- A stranger who runs init and then next-card is told to commit first, and is never handed an empty card.
- The permission template allows gh pr list, gh pr view and git branch --list.
- The repository has .gitattributes with eol=lf, .gitignore, .editorconfig, SECURITY.md, CHANGELOG.md, CONTRIBUTING.md and a Makefile with test and lint targets.
- plugin.json carries displayName, homepage and repository; the author is a name, not a handle.
- CI runs on pushes to main and on pull requests, with read-only permissions and a visible shellcheck step.

## Notes
- The license field and LICENSE file are DOC-02, which the maintainer runs through the plugin.
