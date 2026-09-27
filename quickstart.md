# Quickstart

Entry point of the `.agentic-coding` system. Read it in full before starting
work – it is short.

## What to read, and when

| When | What |
|---|---|
| Before you change one line of code – no exceptions | `rules/main.md`, then every file in `rules/project/` |
| Now, once per session | this file |
| You don't know what this project is | `context/overview.md`, then the rest of `context/` as needed |
| When you pick up a task | `workflow/00-overview.md`, then `workflow/05-task-store.md` |
| When unsure about a process step | the matching `workflow/NN-*.md` |

Do not read the whole folder up front. Read the step you are on – the rules are
the one thing that is not conditional.

In Claude Code the rule set is injected into the session by
`hooks/inject-rules.sh` at startup, so it is already in front of you. If it is
not there – another agent, a subagent, a resumed session – read the files
yourself before the first edit.

## Layout

```
.agentic-coding/
├── README.md              operator handbook, for humans – agents need not read it
├── quickstart.md          this file
├── context/               what this project is: domain, architecture, layout, commands
├── workflow/              process steps: what to do, in which order
│   ├── 05-task-store.md   where tasks live and how they are structured
│   └── templates/         templates for the three spec levels
├── rules/
│   ├── main.md            universal rules (shared across projects)
│   └── project/           rules for this project
├── hooks/                 inject-rules.sh – puts the rules into the session at startup
├── skills/                entry points: /task-intake, /task-plan, /task-implement, …
│                          plus /setup-language, /setup-constitution, /setup-context
│                          for a new project
├── adapters/              template of the pointer block install.sh injects into CLAUDE.md et al.
└── install.sh             deploys pointers, skills and the rules hook
```

Instruction files at the repository root (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`
and the rest) contain only a pointer here. Never write content into them – it
would be lost to every agent but one.

## Language

All instructions, context and rules are written in **English**. Anything a human
reads – replies to the operator, clarifying questions, review comments, the
output spec – is written in **the operator's language**.

Which language that is, and every piece of fixed wording that goes with it, is
declared in `rules/project/communication.md`. No upstream file names a human
language; they all defer to that one. If it is not there, ask, and record the
answer with `/setup-language`.

## Work with a task card, and without one

Two modes, and only one of them is optional.

**With a card** – anything worth tracking. The full process applies:
`workflow/`, both operator gates, the card as the only memory. Entry points are
the skills: `/task-intake`, `/task-plan`, `/task-implement`, `/task-review`,
`/task-close`.

**Without a card** – the operator asks for a microfix straight in chat: a typo, a
one-line condition, a rename. No card, no statuses, no gates. What still holds
in full:

- every rule in `rules/main.md` and `rules/project/`, the constitution included;
- nothing irreversible without asking – see `rules/main.md`;
- the scope you were given, and not a line more.

If the "microfix" turns out to need a migration, touch several layers, or change
behaviour the operator has not described – stop and say it belongs in a task.
That judgement is the whole reason this mode is narrow.

## The three spec levels

Core vocabulary of the system. Do not conflate them.

| Level | Written by | For | Contents |
|---|---|---|---|
| **Input spec** | operator | agent | the task as it arrived: anything from "let's think this feature through" to a finished statement |
| **Agent spec** | agent | agent | decomposition, checklist, how to verify, decisions taken, deviations from plan |
| **Output spec** | agent | humans | the settled statement with no technical detail: story/bug, interface, logic, schema, acceptance, scope |

The input spec and the agent spec exist for every task. **The output spec does
not** – it is written only when the operator asks for one, or when the task is a
design task with no implementation phase. An ordinary task ends with a short
Final Summary instead.

Detailed formats live in `workflow/templates/`.

## Task states

```
Открытые → Заблокированы → К реализации → В реализации → В ревью → Готовые → archive
              ↑                  ↑                           │
              └──────────────────┴───────────────────────────┘  rework
```

The status names below are this project's labels as configured in Backlog.md –
they are configuration values, not prose, so they are quoted verbatim and never
translated. They are also listed in `rules/project/communication.md`.

| State | Meaning | Moved by |
|---|---|---|
| Открытые | submitted, or under intake and planning – not yet ready to code | operator |
| Заблокированы | has unresolved blocking tasks | agent |
| К реализации | criteria approved, plan written, no blockers – ready to code | agent, at the end of step 2 |
| В реализации | agent is writing code | agent |
| В ревью | code and self-review done, waiting for the operator | agent |
| Готовые | deployed to production | **operator only** |
| archive | long closed, outside the agent's index | operator |

## Non-negotiable rules

Breaking any of these stops the work – they are not minor slips.

1. **Only the operator moves a task to «Готовые».** The furthest an agent goes is «В ревью».
2. **Scope never changes silently.** Found an adjacent problem – file it as a separate task, do not fix it in passing.
3. **Never claim what you have not verified.** "Tests pass" is written only after a run, with the output attached.
4. **Every decision goes into the task card, not the chat.** The next session starts from zero.
5. **Two mandatory operator gates:** spec approval (before code) and code review (before GitLab). Neither may be skipped.
6. **The rules hold for every change, card or no card.** A fix small enough to skip the process is never small enough to skip `rules/`.
