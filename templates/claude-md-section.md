## WorkDeck session protocol

This project runs as cards in `cards/`, one card per session. The `card` command and the `/workdeck:*` skills come from the WorkDeck plugin.

- Work starts with `/workdeck:next-card [id]`, or `/workdeck:quick "<description>"` for a small change that needs no plan. The user types these.
- Work on the card's branch, `card/<id>-<slug>`. One card, one branch, one pull request.
- A `plan/*` branch changes only outlines, the files in `cards/plan/`. `/workdeck:plan` commits, pushes and opens its pull request itself.
- For a row of an outline, `/workdeck:next-card` writes the card and waits for a yes before any code, then commits that card alone as `<id>: card as approved`: the one commit on a card's branch before handoff.
- Read what the card lists under `Read` and the code under `Touch`. Say why before reading further.
- Change only the files listed under `Touch`. If another file must change, add it to `Touch` with a reason, or revert it.
- Write the tests named under `Tests` first, with those names, and see them fail for the expected reason.
- Do not commit, push or open a pull request. When the card's tests pass, say the card is ready and that `/workdeck:handoff` is next. Handoff runs the check, the gates and the review, and then commits.
- If you are waiting on a person, add a `## Blocked` section with the question to the card.
- If a budget warning appears, finish the current step and ask the user to run `/workdeck:handoff split`.
- A session does not start a second card.
- Never merge a pull request, force-push, delete a branch or run `git reset --hard`.

`card status` shows where things stand, `card list` shows every card, and session logs are in `log/`.
