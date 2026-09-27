# Task store

Tasks are tracked in [Backlog.md](https://github.com/MrLesk/Backlog.md), under
`.backlog/`. A card is a markdown file living in the repository.

**CLI mechanics are not documented here.** Backlog.md documents itself:

```sh
backlog instructions overview          # read once at the start of a session
backlog instructions task-creation     # before creating a task
backlog instructions task-execution    # before planning or changing status
backlog instructions task-finalization # before finishing
```

Never edit task files by hand – always go through `backlog`, or metadata and
relationships drift out of sync.

What follows is only what Backlog.md cannot know: our statuses, our gates and
our mapping of card sections to spec levels.

Backlog.md's own instruction block is deliberately kept out of the agent
instruction files – `install.sh` strips it – because its lifecycle contradicts
the gates below. The entry points above are the replacement: read them from
here.

## Where Backlog.md's built-in workflow does not apply

Backlog.md ships its own task lifecycle and marks it CRITICAL in the generated
instruction block. **Our process wins on every point below.** Read the built-in
guides for CLI mechanics, not for when to change status.

| The built-in guide says | In this project |
|---|---|
| `task-execution` step 3: "mark it in progress and assign yourself", before research | Never at intake. Status changes only as the table below allows. |
| `task-execution` step 7: "routine plans need not block when no review was requested" | Gate 1 is mandatory, always. No plan proceeds without the operator's approval. |
| statuses `In Progress` / `Done` | our statuses, verbatim – see the table below |
| create a task whenever work needs planning | the operator creates tasks; the agent creates one only when asked |

Which guide to read at which step:

| Step | Guide |
|---|---|
| 1. Intake | `task-creation` only – do **not** read `task-execution` yet |
| 2. Planning | `task-execution`, ignoring its steps 3 and 7 |
| 3–5. Implementation, review, handoff | `task-execution` |
| 6. Completion | `task-finalization` |

Reading `task-execution` during intake is what makes an agent jump the gate: its
step 3 instructs an immediate move to the active status.

## Separation of concerns

`.agentic-coding/` holds instructions: rules and process. `.backlog/` holds
state: cards, decisions, notes. Never mix the two.

## Where things go

| Card section | Spec level | Written by | When |
|---|---|---|---|
| `Description` | input spec | operator | on creation |
| `Acceptance Criteria` | acceptance | agent, approved by operator | step 1, gate 1 |
| `Implementation Plan` | agent spec | agent | step 2 |
| `Implementation Notes` | decisions, deviations, rework, reviewer report | agent | steps 3–5 |
| `Final Summary` | completion summary, always; output spec appended under the heading pinned in `../rules/project/communication.md`, only when asked for | agent | step 6 |

None of this stays in the chat. Chat is transport, the card is memory.

**Trap:** `--notes`, `--plan` and `--final-summary` **replace** the whole
section. Accumulated decisions are added only with `--append-notes`,
`--append-plan`, `--append-final-summary`. Never use `--notes` during steps 3–5
– it wipes everything recorded earlier.

## Statuses and who moves them

| Status | Moved by | Condition |
|---|---|---|
| Открытые | operator | task created |
| Заблокированы | agent | an unresolved blocker was found (step 1) |
| К реализации | agent | the operator approved the criteria (gate 1) **and** the agent spec is written – the task is ready to code |
| В реализации | agent | work on the plan has started |
| В ревью | agent | tests green, self-review done |
| Готовые | **operator only** | deployed to production |

«К реализации» means *ready to code*, not *approved to plan*. The agent makes
that move itself, but only after both conditions hold: the operator approved the
acceptance criteria, and the plan is in the card. A task sitting there with no
`Implementation Plan` is a defect.

«Готовые» stays with the operator alone.

### Allowed and forbidden transitions

| From | To | By |
|---|---|---|
| Открытые | Заблокированы | agent – the only status change allowed during intake |
| Открытые | К реализации | agent, at the end of step 2: criteria approved **and** plan written |
| Заблокированы | Открытые | agent, once the blockers are closed |
| К реализации | В реализации | agent, when it starts writing code |
| В реализации | В ревью | agent, after a green run and self-review |
| В ревью | К реализации | operator, sending it back for rework |
| В ревью | Готовые | operator only |

**Forbidden, no exceptions:**

- Открытые -> В реализации. Intake does not start implementation. This is the
  single most likely mistake, because Backlog.md's built-in guide asks for it.
- Открытые -> К реализации before the operator approved the criteria, or with no
  plan in the card. Both conditions are required.
- anything -> Готовые without the operator.
- assigning yourself to a task during intake.

## Blockers

Dependencies are set with `--dep`. If any blocker is still open, the status is
«Заблокированы» and the card carries one line per blocker explaining exactly
what the dependency is.

Reverse links – which tasks depend on this one – are used in step 6: after
finishing, the agent walks the dependents, lifts the block and checks whether
their plans are still valid.

## Definition of Done

A shared checklist is configured in `.backlog/config.yml` and applies to every
task. It is verified in step 5, before handoff – not after.

## Task IDs

Cards carry a Backlog.md id (`TASK-0001`). Where the operator also supplies a
tracker number in the `AF-xxxxx` form, record it in the card – branches and
commits are named after it. See `../rules/project/git.md`.

## Archive

Archiving is done by the operator. Archived tasks are not searched, planned
against, or scanned for blockers. If the operator references an archived task by
id, read it.

## What must never be in a card

- coding rules – they live in `.agentic-coding/rules/`;
- process descriptions – they live in `.agentic-coding/workflow/`;
- a retelling of how the work went – only decisions and their reasons.
