---
name: task-plan
description: Write the agent spec – decomposition into vertical slices, checklist, how to verify, decisions taken. Use after the acceptance criteria are approved and before any code.
---

Step 2 of the process. Read `.agentic-coding/workflow/20-planning.md` and follow
it. Template: `.agentic-coding/workflow/templates/agent-spec.md`.

Task: `$ARGUMENTS` – a Backlog.md id. If the argument is empty or substitution
did not happen, take the top task in a suitable status, name it to the operator
and continue.

Precondition: the acceptance criteria are approved by the operator. If they are
not, run `task-intake` first. After that approval this step runs on its own –
it is reached without a second question.

Result: the agent spec is written into the task card, and the task is moved to
«К реализации» – meaning ready to code, not approved to plan. Never move it
there without a plan in the card.

Do not rewrite the acceptance criteria – they are agreed and only the operator
changes them. Do not start writing code: implementation begins when the operator
runs `task-implement`.
