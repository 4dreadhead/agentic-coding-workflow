---
name: setup-constitution
description: Record the project constitution – the principles all code obeys. The operator states the rules, the agent writes them into rules/project/CONSTITUTION.md. Use when deploying the system on a new project, or when the operator wants to pin down principles.
---

Goal: collect the project's principles from the operator and write them into
`.agentic-coding/rules/project/CONSTITUTION.md`.

The constitution is not a list of stylistic details. It is a handful of
principles the whole codebase obeys: what is tested and how, what may be mocked,
how responsibilities are split, where "enough" ends and "too much" begins.

## Sequence

1. If the file already exists, read it and work in append mode – never rewrite
   it silently.

2. Survey the code: languages, frameworks, test stack, patterns already in use.
   The questions must be about this project, not abstractions.

3. Ask the operator in a single batch, with options. Minimum topics:

   - **Testing.** What is the unit under test? Do we assert behaviour or
     structure? Tests before or after the code?
   - **Mocks.** What may be substituted, and what must run for real (database,
     queues, outbound calls)?
   - **Decomposition.** When does logic move into its own object, and when does
     it stay put?
   - **Excess.** What counts as over-engineering in this project?
   - **Backward compatibility.** How are changes that break data or schema
     rolled out?
   - **Non-negotiable.** What must never be broken?

4. For each principle record: the statement, a bad/good example taken from this
   project's code, and a **rationale** – the cost of breaking it. A principle
   without a rationale is a slogan and will not be applied.

5. Mark which principles are NON-NEGOTIABLE.

6. Show the result to the operator in full before writing the file.

Ask the questions in the operator's language – they read them; see
`.agentic-coding/rules/project/communication.md`. Write the file in
English.

## What does not belong in the constitution

Stylistic details (naming, indentation, line length) – those are
`rules/project/*.md`. The constitution answers "why"; individual rules answer
"exactly how".
