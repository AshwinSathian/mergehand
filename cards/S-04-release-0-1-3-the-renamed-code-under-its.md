---
id: S-04
title: Release 0.1.3: the renamed code under its own tag
size: XS
depends:
done: true
---

## Read
- CHANGELOG.md
- README.md#install
- docs/development/findings.md (the note of 2026-10-09 on the project's name)
- docs/development/review-0.2.md (fourth pass, "Found by the handoff reviewer")
- bin/card (the header comment and VERSION)

## Touch
- bin/card (the version, in the header comment and in VERSION)
- .claude-plugin/plugin.json
- CHANGELOG.md
- README.md (the download line)
- test/cases/02-plugin.sh

## Tests
- test_changelog_says_what_0_1_3_renames

## Acceptance
- `card version` prints `card 0.1.3`, and `.claude-plugin/plugin.json` has `"version": "0.1.3"`.
- CHANGELOG.md has an entry for 0.1.3 with its date. It says the code is that of 0.1.2 under the name WorkDeck: the configuration file is `workdeck.conf` and the skills are `/workdeck:*`.
- The entry says that the tag `v0.1.2` holds the former name, that its `card` exits 2 in a repository with `workdeck.conf`, and that a CI workflow naming that tag has to name `v0.1.3`.
- The README's download line names `v0.1.3`.
- The diff of bin/card is the two lines that hold the version.
- The main branch holds no 0.2 product code when this card merges: nothing under bin/, hooks/, skills/, agents/, templates/ or reference/ differs from commit 51bdc0c except by this card.
- test_repository_has_the_files_a_stranger_looks_for and test_readme_install_line_matches_the_manifests pass.

## Out of scope
- The tag. The maintainer makes `v0.1.3` on the merge commit of this card. P-08, P-18 and P-22 need it.
- Anything of 0.2.
- Reading `mergehand.conf` as a fallback. The changelog tells such a user to rename the file.

## Notes
- This card is outside the 0.2 deck and goes first. P-02, P-11 and P-12 depend on it, so no 0.2 product code can merge before it; the spike (P-01) writes none and may run beside it.
- Why it exists: the project was renamed after `v0.1.2` was tagged and the version was not changed. Today the README's download line and every workflow that init writes fetch a `card` that reads another configuration file (checked: `git show v0.1.2:bin/card`, line 91).
- Changing the version is what delivers the plugin to users who installed it (docs/design-0.2.md, section 19, row 18). Here that is the purpose.
- Between the merge and the tag the download line names a tag that does not exist. Make the tag right after the merge.
