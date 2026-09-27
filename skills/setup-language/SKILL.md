---
name: setup-language
description: Ask the operator which language they want to be spoken to in, and record it – together with the fixed wording that depends on it – in rules/project/communication.md. Use when deploying the system on a new project, before anything else, or when the operator wants to switch language.
---

First step of setting up a new project. Everything the operator will read
depends on its answer, so it runs before `/setup-constitution` and
`/setup-context`.

Nothing upstream names a human language. `rules/project/communication.md` is the
one file that does, and this skill writes it.

## What to ask

Ask in English if you have nothing better to go on – the operator's own message
is usually enough of a hint, and you may open in the language they wrote to you
in. Three questions, with options, in one message:

1. **Which language do I speak to you in?** Chat replies, questions, review
   comments, handoff reports, the output spec. Offer the language they have been
   writing to you in as the default.
2. **The same for the output spec?** It goes to engineers, managers, analysts –
   sometimes a different audience from the operator. Default: the same language.
3. **Task status labels.** Read the current ones out of `.backlog/config.yml` if
   it exists and ask whether to keep them. They are configuration values, not
   prose: whatever they are, they get quoted verbatim in `backlog` commands.

Do not ask about instructions, rules, context or commit messages. Those are
English, always, and that is not the operator's choice to make – see
`rules/main.md`.

## What to write

Into `rules/project/communication.md`, a section that declares the language and
pins every fixed string that goes with it:

- the declaration itself: which language, and for what;
- the **approval line** that closes the intake message (step 1) – translate
  "Если всё утверждаете – начинаю планирование задачи." into their language, then
  read it back to them for approval, because they answer this sentence dozens of
  times;
- the **output-spec heading** the card section uses;
- the **handoff report** labels – the block in `workflow/50-handoff.md`,
  translated;
- the **rework line** added after a rework round;
- the **status labels** as configured.

If the file already exists, edit that section and leave the rest of it alone:
the brevity rules, the "analyse means do not write code" rule and the rest are
independent of language.

If the operator asked for a language other than the one in
`workflow/templates/output-spec.md`, also write
`rules/project/templates/output-spec.md` – a translated copy of that skeleton.
It overrides the upstream one.

## What not to do

Do not translate the rest of the system. `workflow/`, `rules/main.md`, the
skills and `context/` stay in English however the answer comes out: they are
read by agents, and an upstream update would overwrite a translation anyway.
