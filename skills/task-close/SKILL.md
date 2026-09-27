---
name: task-close
description: Close a task after the operator confirms it is done – write the final summary, unblock dependent tasks, and produce an output spec if one was asked for. Use once the operator has confirmed completion.
---

Step 6 of the process. Read `.agentic-coding/workflow/60-completion.md`.

Task: `$ARGUMENTS` – a Backlog.md id. If the argument is empty or substitution
did not happen, take the top task in a suitable status, name it to the operator
and continue.

Precondition: the operator has confirmed completion. Do not set the «Готовые»
status yourself unless the operator explicitly tells you to.

1. Write a short **Final Summary** into the card: what changed, why, how it was
   verified. In the operator's language. This is always required.
2. Write a full **output spec** only if the operator asked for one, or the task
   was a design task. Template:
   `.agentic-coding/workflow/templates/output-spec.md`. For an ordinary bug fix
   or feature it is not written – do not produce one unasked.
3. Walk the tasks this one was blocking: lift the block, check their plans are
   still valid, and flag stale ones without rewriting them.
4. Tear down the working directory: `bin/agent-worktree --remove AF-xxxxx`. It
   drops the slot database and frees the slot. The branch itself is kept – only
   the working copy goes. Do this only after the operator confirms the work is
   merged; there are just 12 slots.
