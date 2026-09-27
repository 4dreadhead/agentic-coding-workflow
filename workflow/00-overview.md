# Process map

Tasks live in Backlog.md – see `05-task-store.md` for where things go. Read it
before step 1.

A task goes through six steps. Each has its own file – open the one you are on,
not all of them.

This file describes the process. It does not describe the rules: `../rules/` is
in force whether or not there is a task, and a change made outside this process
is bound by it exactly as a change made inside. See `../quickstart.md`, "Work
with a task card, and without one".

| Step | File | Input | Output |
|---|---|---|---|
| 1. Intake | `10-intake.md` | input spec | acceptance criteria for gate 1, blocker list |
| 2. Planning | `20-planning.md` | approved criteria | agent spec in the card, task moved to «К реализации» |
| 3. Implementation | `30-implementation.md` | agent spec | code + tests, green run |
| 4. Self-review | `40-self-review.md` | green run | reviewer report, blocking findings fixed |
| 5. Handoff | `50-handoff.md` | all of the above | task waiting for operator review |
| 6. Completion | `60-completion.md` | operator's OK | final summary, dependents unblocked; output spec only if asked for |

## Operator gates

Two places where the agent stops and waits for a human. They are never skipped,
however obvious the task looks.

**Gate 1 – approval of the acceptance criteria (between steps 1 and 2).** The
operator approves the criteria in chat. This is the cheapest place to change
course: you are editing a statement, not code.

The gate is the operator's word, not a card move. Once it is given, steps 1 and
2 run together without further questions: the agent plans, writes the spec into
the card, and moves the task to «К реализации» itself. Asking "what shall I do
next" after approval is a defect.

While waiting at the gate the task stays in «Открытые» (or «Заблокированы»).
Moving it to «В реализации» during intake is a process violation – see the
transition table in `05-task-store.md`. Tool-provided workflows that ask you to
claim a task and mark it active before planning do not apply here.

**Gate 2 – review (between steps 5 and 6).** The operator reads the diff and
either sends the task back for rework or on to GitLab.

## Rework

The task returns to step 3. While doing so:

- copy the operator's remarks into the card verbatim, do not paraphrase;
- if a remark contradicts the agent spec, fix the spec first, then the code;
- if a task goes back for rework twice in a row, that is a signal the statement
  was misunderstood. Return to step 1 and ask, rather than patching the code a
  third time.

## A working directory per task

**Every** task that reaches step 3 gets its own branch, its own git worktree and
its own test slot – an isolated database and Redis db. This is not an
optimisation for when several tasks happen to overlap; it is the normal mode,
because it is what lets the operator's session stay a conductor while the code
is written elsewhere.

Two tasks must never share a working copy, and two agents must never run the
suite against the same database: the suite truncates it on start.

```sh
bin/agent-worktree AF-22990           # branch, worktree, slot and database in one step
bin/agent-worktree --remove AF-22990  # release everything when done
```

The conductor creates it in step 3 and tears it down in step 6. Details in
`../rules/project/parallel-testing.md`; branch and commit naming in
`../rules/project/git.md`.
