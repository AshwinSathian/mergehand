---
id: P-22
title: Trial setup: the two specifications and what is measured
size: S
depends: P-20, P-21, T-01
done: false
---

## Read
- docs/design-0.3.md (must be on the base branch; T-01 writes it, and this card cannot start without it)
- docs/design-0.2.md#14-trial-and-release
- docs/design-0.2.md#22-decisions-locked-and-what-is-deferred (decisions 1 and 2, and what is deferred)
- docs/design-0.2.md#2-goals-and-non-goals (goal 6)
- docs/development/scope-0.2.md (the sections "How we will know it works" and "Deferred")
- docs/development/review-0.2.md (question 4, finding 27, and the third pass)
- docs/development/findings.md (finding 1: the tests gate and nested test names)
- docs/evidence.md

## Touch
- docs/evidence.md
- test/cases/02-plugin.sh

## Tests
- test_evidence_names_the_trial_repositories_and_the_baseline

## Acceptance
- docs/design-0.3.md exists on the base branch when this card starts.
- The question under `Blocked` is answered, and the answer is in docs/evidence.md: the second repository, its language, whether its tests nest, and the specification the planner is run on there.
- docs/evidence.md has a section for the trial that names both specifications and says the two repositories' figures are kept apart, with the reason design section 14 gives.
- The section says how the trial is run: the plugin from a checkout of the main branch with `--plugin-dir`, and each trial repository's CI on `card lint` 0.1.2.
- The section has the table of measures of design section 14, with where each is read from, and no figures yet.
- The section records the baseline: 9 of the 24 hand-written cards of 0.1 had a `Touch` entry at the end that was not there when the card was first committed.
- The section states the one result that stops the release, and the rule of section 22, decision 1, for a trial card that adds a reachable command or skill of 0.3.
- The section says the trial ends at ten implemented planned cards, with at least two S and two M, and that goal 6 is recorded as not met if ten cards do not include them.

## Out of scope
- Writing or changing docs/design-0.3.md. T-01 owns it. No card of this deck writes the 0.3 design.
- The plan runs and the ten card sessions. The maintainer types `/workdeck:plan` and `/workdeck:next-card` in sessions of their own; no card of this deck is one of the ten.
- The figures and the reading of them. P-23 owns the record.
- The version and the tag. P-24 carries the decision.

## Blocked
Which other repository does the second trial run in? Name the repository, its language, whether its tests nest (a `describe` block, a class or a module around the test name: finding 1), and the one markdown specification in it that the planner is run on. Design section 22 defers this to after the build.

## Notes
- This card depends on T-01 so that `card next` does not offer it before the 0.3 design is on the base branch. T-01 depends on no card of this deck.
- The 0.3 design is planned with a prefix of its own. `card plan new` refuses a prefix that a card already uses, so it cannot be `P`, `PLAN` or `T`.
- If the second repository's tests nest, say so beside the measure "`Tests` lines reworded": the tests gate does not join an outer name to an inner one, and rewording there is the gate's known weakness, not only the planner's.
