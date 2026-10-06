# Development records

How Mergehand 0.1 was built. None of this is needed to use it; the design is in [`../design.md`](../design.md).

| File | What it is |
|---|---|
| [`plan-0.1.md`](plan-0.1.md) | The build plan, written by the coding agent for the maintainer before any code, and kept as written. "I" in it is the agent and "you" is the maintainer. Its section G was added after an adversarial review of the plan. |
| [`findings.md`](findings.md) | What turned out wrong or awkward while building, with the evidence and what was decided. Twelve findings, three of them independent reviews. |
| [`later.md`](later.md) | Ideas that were left out of 0.1 on purpose. |

The repository's own cards are in [`../../cards/`](../../cards/) and its session logs in [`../../log/`](../../log/). Mergehand 0.1 was built card by card with its own card files, gates and logs, driven by hand in one long agent session, so those logs record `unknown` for the measured token fields: one session's growth does not describe any single card. The exception is DOC-02, which the maintainer ran through the plugin and merged as pull request 1. See [`../evidence.md`](../evidence.md) for the measurements.
