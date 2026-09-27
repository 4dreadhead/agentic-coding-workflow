---
name: setup-context
description: Fill the context folder with a description of the project – domain, architecture, layout, commands. The operator gives a short prompt about what the project is, the agent explores the code and writes the files. Use when deploying the system on a new project, or when the description has gone stale.
---

Goal: fill `.agentic-coding/context/` so that any agent reading those files
understands the project without further questions.

## Sequence

1. **Ask the operator, briefly:** what the project is, what problem it solves,
   who uses it, what is unusual or counter-intuitive about it. One or two
   sentences from them is enough – you dig out the rest.

2. **Explore the code.** What to look at: dependency manifests, entry points,
   models and schema, routes, background jobs, configuration, existing
   documentation and README, commit history for direction of travel.

3. **Fill four files:**

   | File | Contents |
   |---|---|
   | `overview.md` | what the system is, the stack, the core domain model as a table, key flags and modes |
   | `architecture.md` | the main path from entry to result, key subsystems, storages, queues, integrations |
   | `structure.md` | a map of directories with the purpose of each, and the code organisation patterns in use |
   | `commands.md` | how to run it, how to run the tests, how to migrate, what to prefix commands with |

4. **Show the operator** and confirm what cannot be derived from the code: why a
   decision was made, what is legacy, what is about to be replaced.

Ask the questions in the operator's language – see
`.agentic-coding/rules/project/communication.md`. Write the files in English.

## Requirements

- Describe what **is**, not what ought to be. This is a reference, not a manifesto.
- Diagrams are ASCII so they render in any tool.
- Use real file paths so they can be opened straight away.
- Do not duplicate `rules/` – context answers "what is here", rules answer "how
  things are done here".
- Do not paraphrase the code line by line. Aim for the level where connections
  are visible.
