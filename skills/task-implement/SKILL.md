---
name: task-implement
description: Start implementing a task – create its worktree and hand the work to an implementation subagent. Use once the plan is approved and it is time to write code.
---

Step 3 of the process. In this skill **you are the conductor, not the
implementer.** The operator stays in this chat and starts other tasks; the code
is written by a subagent in its own working directory.

Task: `$ARGUMENTS` – a Backlog.md id, and the `AF-xxxxx` issue number recorded
in its card. If the argument is empty, take the top task in «К реализации», name
it to the operator and continue.

Precondition: the task is in «К реализации». If it is still in «Открытые», the
operator has not passed gate 1 – stop and say so.

## What you do

1. **Create the working directory.** From the main checkout:

   ```sh
   bin/agent-worktree AF-xxxxx
   ```

   It makes the branch, copies the untracked environment files, symlinks the
   instructions and the task store, claims a test slot and prepares its
   database. Note the printed path and slot number.

   Never use Claude Code's own worktree isolation or plain `git worktree add`
   for this – both skip the slot and the symlinks, and the subagent would end
   up with no instructions and no database. See
   `.agentic-coding/rules/project/parallel-testing.md`.

2. **Move the task to «В реализации».**

3. **Spawn one implementation subagent**, in the background, with:

   - the worktree path, the branch name and the slot number;
   - the task id, and an instruction to read the card itself;
   - an instruction to read `.agentic-coding/rules/main.md` and every file in
     `.agentic-coding/rules/project/` **before its first edit**, and to follow
     `.agentic-coding/workflow/30-implementation.md`. The session hook that
     injects the rules does not fire for a subagent, so this instruction is the
     only thing that gets the rules in front of it;
   - the test command: `AGENT_SLOT=<slot> <main>/bin/agent-test <spec paths>`;
   - the explicit note that it cannot talk to the operator and must stop and
     report instead of guessing;
   - the instruction to **commit on the task branch when it finishes** – staging
     explicit paths, message `AF-xxxxx: …` – and **not** to push.

4. **Report to the operator in one line** what was started, where, and on which
   slot. Then stay available – the operator will start other tasks meanwhile.

5. **When the subagent reports back**, relay the result. If it stopped with a
   question, put the question to the operator, then send the answer back to the
   same subagent rather than starting a new one.

Do not write the code yourself and do not read the whole codebase into this
chat: the point of the split is that this session stays a conductor.

## Inline mode

If the operator says to do it here, in this chat, or the change is a one-line
fix, skip the subagent and follow `30-implementation.md` yourself – still on the
task's branch. State plainly that you are working inline.

## Where it ends

The subagent finishes on a green test run and a commit on the task branch. Pass
its branch and commit hashes on to the operator. Next: `task-review`.
