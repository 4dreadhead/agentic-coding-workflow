# Skills

Thin wrappers over `../workflow/`. A skill is an entry point: the operator types
`/task-intake AF-22990`, the agent opens the right process file and performs the
step.

Five skills for the task cycle – `task-intake`, `task-plan`, `task-implement`,
`task-review`, `task-close` – and three for setting a project up:
`setup-language`, `setup-constitution`, `setup-context`. The setup ones run once,
in that order; `setup-language` first, because everything the operator reads
after it depends on the answer.

**The logic lives in `workflow/`, not here.** A skill contains only: which file
to read, which task to work on, and how the step ends. Never duplicate process
content into a skill – the two copies will drift.

`install.sh` deploys skills per agent:

| Agent | Where |
|---|---|
| Claude Code | symlinks in `.claude/skills/<name>` |
| Gemini CLI | generated `.gemini/commands/ac/<name>.toml` |
| Everything else | reads this directory directly; the pointer block links to it |

## Format

One folder per skill, containing `SKILL.md` with front matter:

```markdown
---
name: task-intake
description: When the skill applies – the agent decides from this line whether to use it
---

<body: what to do, briefly>
```
