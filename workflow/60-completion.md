# Step 6. Completion

Runs after the operator has confirmed the task is done. The «Готовые» status is
set by the operator; the agent does not make that transition on its own.

## Final Summary – always

Every finished task gets a short completion summary in `Final Summary`: what
changed, why, and how it was verified. A few lines, in the operator's language.
This is the
default deliverable of step 6.

## Output spec – only on request

A full output spec per `templates/output-spec.md` is written **only** when:

- the operator asks for it explicitly, or
- the task was a design task, in which case the spec was already produced in
  step 1 and this step only brings it up to date (see `10-intake.md`).

Do not write one otherwise. For an ordinary bug fix or feature the Final Summary
is enough, and a full spec is wasted work.

When it is requested, it goes into the card under the output-spec heading
pinned in `../rules/project/communication.md`
appended to `Final Summary`, and it is what goes to people: managers, analysts,
the team tracker.

The key requirement: **exhaustive for an engineer, readable for a manager**.
Technical detail and jargon are removed, but table, field and entity names stay
exactly as they are – they live in the database and in the code and must not be
translated.

Both the summary and the output spec are written in the operator's language –
see `../rules/project/communication.md`: their audience is
human.

## Dependent tasks

Walk the tasks this one was blocking:

1. Lift the block if no other blockers remain.
2. Check whether their agent spec went stale after the merged changes.
3. If it did, add the line "plan needs revisiting after <id>: <what changed>"
   to the card and do **not** rewrite the plan yourself – that is step 2
   with its own gate.

## What stays in the card forever

Decisions taken, deviations from plan, the reviewer report, the operator's
remarks per rework round. This is exactly why archived tasks stay readable: when
the question "why was it done this way" comes up in six months, the answer must
be findable.

## Working directory

Tear down the task's worktree with `bin/agent-worktree --remove AF-xxxxx` once
the operator confirms the work is merged. It frees the test slot and drops its
database; the branch is untouched.

## Archive

Archiving is done by the operator, by hand. Archived tasks are not consulted
during search or planning, but must be read if the operator references one by
id.
