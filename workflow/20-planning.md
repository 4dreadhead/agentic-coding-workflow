# Step 2. Agent spec

Goal: a plan you can write code against without going back to think. It is
written into the task card, not the chat.

## Structure

```markdown
## Agent spec

### Affected places
- path:line – what changes and why

### Decomposition
- [ ] 1. <vertical slice with an observable effect>
- [ ] 2. ...

### How to verify
- the test command for this task
- what to check manually where automation is impossible

### Decisions taken
- <decision> – because <reason>; <X> rejected because <Y>

### Deviations from plan
(filled in during implementation)
```

## How the step ends

When the agent spec is written into the card and the task is genuinely ready to
be coded – decomposition done, verification command known, decisions recorded –
move it to «К реализации» and tell the operator in one line that the plan is in
the card.

«К реализации» means *ready to code*, not *approved to plan*. A task with no
plan in its card never belongs in that column.

Do not start writing code. Implementation begins when the operator runs
`task-implement`.

## Decomposition rules

**Slice vertically.** A slice is a thin end-to-end piece of behaviour with an
observable effect, not a layer ("all models first"). Each slice must be
verifiable on its own.

**Slice size: half an hour to half a day.** Larger is hard to control, smaller
is bookkeeping overhead.

**Order from risky to routine.** The slice that could invalidate the plan goes
first, while reworking it is still cheap.

**Phrase a checklist item as a result, not an action.** Not "add a method", but
"a reservation older than the TTL is closed".

## When the plan changes

That is normal and expected. What is not normal is changing it silently. Every
deviation gets one line under "Deviations from plan": what was assumed, what
turned out to be true, what was done instead.

If a deviation changes the acceptance criteria, stop and go back to the
operator. The criteria were approved at gate 1 and the agent does not rewrite
them.
