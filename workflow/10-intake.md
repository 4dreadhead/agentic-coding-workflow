# Step 1. Intake

Goal: turn an input spec into an agreed statement with verifiable acceptance
criteria and a known blocker list. No code is written in this step.

## Sequence

1. **Read the input spec in full.** Do not start analysing from the title.
2. **Survey the codebase** enough to know where the task lands. Name the files
   you expect to touch.
3. **Identify open questions** (criterion below) and ask them in a single
   message, not one at a time.
4. **Write the acceptance criteria** – a numbered list of verifiable conditions.
5. **Check for blockers** among open tasks.
6. **Set the status**: blockers found – «Заблокированы» with the list; none –
   the task stays in «Открытые» and the criteria go to the operator for gate 1.

## How the step ends

Present the acceptance criteria and close the message with the **approval line**
– the one pinned in `../rules/project/communication.md`, section "Fixed wording".
Verbatim, in the operator's language: it is the sentence they answer.

On the operator's approval **continue straight into step 2 without asking
again.** Do not ask "what next", do not ask permission to plan. The approval of
the criteria is the approval to plan.

The task stays in «Открытые» through planning. It moves to «К реализации» only
at the end of step 2, when it is genuinely ready to code – see `20-planning.md`.

## What to ask versus what to decide

Ask when different answers lead to **materially different work**: behaviour
visible to a user or operator, data formats, what counts as an error, scope
boundaries, which requirement wins in a conflict.

Decide yourself and record as a decision: naming, file placement, internal
decomposition, any choice between equivalent technical options, and anything
already covered by `../rules/`.

One question, one uncertainty. Never ask an open question without options –
offer two or three and mark the one you recommend. The operator answers with
single characters ("A", "B", "3"), so the options must be numbered and concrete.

## Acceptance criteria

Every item is an observable condition, not an intention.

```
Bad:  1. Phones are released correctly
Good: 1. A reservation older than the TTL moves to finished and its phone
         returns to the service cache
      2. A reservation younger than the TTL stays reserved
      3. A second run does not touch already-processed reservations
```

## Finding blockers

A task is blocked if at least one of these holds:

- it depends directly on the result of another unfinished task;
- it cannot be done in isolation – two changes touch the same places in a way
  that makes ordering matter;
- it needs a decision from the operator that does not exist yet.

Not a blocker: tasks merely touching neighbouring files, or one being logically
related to another while still being doable first.

When marking «Заблокированы», list the specific blocking tasks and one line each
on what the dependency actually is.

## When the output spec is produced immediately

If the task is a design task ("let's think this feature through") or the
operator asks explicitly, the result of step 1 is not acceptance criteria but a
full output spec per `templates/output-spec.md`. Such a task has no
implementation phase.
