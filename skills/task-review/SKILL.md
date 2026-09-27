---
name: task-review
description: Self-review by a separate reviewer agent, then hand the work to the operator. Use after a green test run, before moving the task into review.
---

Steps 4 and 5 of the process. Read `.agentic-coding/workflow/40-self-review.md`,
then `50-handoff.md`.

Task: `$ARGUMENTS` – a Backlog.md id. If the argument is empty or substitution
did not happen, take the top task in a suitable status, name it to the operator
and continue.

Precondition: tests are green. Never run this on red tests.

The code lives in the task's worktree, not in the main checkout. Take the diff
from there, and run anything that needs the suite as
`AGENT_SLOT=<slot> <main>/bin/agent-test …`.

1. Pick the review depth from the table in `40-self-review.md`.
2. Run the review with a **separate agent** that did not write this code: give
   it the diff, the acceptance criteria and the rules, but not the
   implementation history.
3. Fix blocking findings by returning to the step 3 loop.
4. Record discretionary findings in the card; do not fix them.
5. Present the work per `50-handoff.md`, in the operator's language, and move
   the task to «В ревью».
