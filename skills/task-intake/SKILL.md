---
name: task-intake
description: Take a task from the queue – read the input spec, ask clarifying questions, write acceptance criteria, find blockers. Use when the operator hands over a new task or asks to work through the queue.
---

Step 1 of the process. Read `.agentic-coding/workflow/10-intake.md` and follow it.

Task: `$ARGUMENTS` – a Backlog.md id, optionally with the tracker number in the
`AF-xxxxx` form. If the argument is empty or substitution did not happen, take
the top task in «Открытые», name it to the operator and continue.

## Hard constraints for this step

- **Write no code.** Reading the codebase is expected; changing it is not.
- **The only status change allowed is «Открытые» -> «Заблокированы».** Moving
  the task to «В реализации» or «К реализации» here is a process violation.
- **Do not assign yourself to the task.**
- Read `backlog instructions task-creation` if you need CLI mechanics. Do
  **not** read `task-execution` at this step: its step 3 tells you to mark the
  task in progress, which does not apply here. See
  `.agentic-coding/workflow/05-task-store.md`.

## How the step ends

One of two ways:

- blockers found -> status «Заблокированы», one line per blocker in the card,
  then report to the operator;
- no blockers -> the task **stays in «Открытые»**, the acceptance criteria are
  written into the card and presented to the operator, and the message closes
  with the approval line from `.agentic-coding/rules/project/communication.md`,
  section "Fixed wording" – verbatim.

Once the operator approves, **continue straight into step 2 yourself** – run the
`task-plan` step without asking anything further. Asking "what next" after
approval is a defect. The task moves to «К реализации» at the end of planning,
not here.

Reply to the operator in their language – see
`.agentic-coding/rules/project/communication.md`.
