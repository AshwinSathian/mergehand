# Implementing a card

You are on the card's branch. The card is the contract: what to read, which files to touch, which tests must exist, and what must be true at the end. These steps are shared by `/workdeck:next-card` and `/workdeck:quick`.

1. **Read.** Read every item under `Read`, and the existing code for every path under `Touch`. Do not read further without first saying why in one line.

2. **Plan.** State a plan of at most 10 lines. If the card cannot be done as written (a path that does not exist, a dependency that is not there, a question only a person can answer), stop. Add a `## Blocked` section with the question to the card and ask the user. When the question is answered, remove the `## Blocked` section and put the answer under `Notes`.

3. **Tests first.** Write the tests named under `Tests`. Give each test a name in which the card line appears on one line: `refresh rotates the token` is satisfied by `test_refresh_rotates_the_token`, `TestRefreshRotatesTheToken` or `it('refresh rotates the token')`. The gate compares letters and digits only and does not join a `describe` with its `it`, a class with its method, or a module with its function. Use the innermost name, or edit the card line to match the name you chose. Run the tests and confirm each fails for the reason you expect, not from a typo or a missing import.

4. **Implement** until those tests pass. While iterating, run only the touched tests, not the whole check command.

5. **Stay in scope.** Change only files that match the card's `Touch` list. If another file has to change, either revert it or add it to `Touch` with the reason after the path; the addition shows in the pull request. `card touched <id>` prints what the scope gate will say. `Touch` entries are shell patterns matched against the whole path: `src/` or `src/*` covers everything under `src`, `*.ts` matches at any depth, and a bare `a.ts` matches only a file at the repository root.

6. **Do not commit, push or open a pull request.** Handoff does all three after the check, the gates and the review. A commit made now leaves a clean tree with no session log, and the stop hook will block the end of every turn until one exists.

7. **If a Workdeck budget warning appears,** finish the step you are on, stop, and ask the user to run `/workdeck:handoff split`.

8. **When the card's tests pass,** tell the user in a few lines what was done, which tests pass and anything that differs from the card. Then say that `/workdeck:handoff` is the next command, for them to type. Do not start another card in this session.
