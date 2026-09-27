# Template: output spec

**When this is written.** Not for every task. Only when the operator explicitly
asks for an output spec, or when the task is a design task – then it is produced
in step 1 and is the whole deliverable. An ordinary bug fix or feature ends with
a short Final Summary instead; see `../60-completion.md`.

The audience is human: an engineer, a manager, an analyst – so it is written in
**the operator's language**, declared in `../../rules/project/communication.md`.

**Localised version wins.** If `../../rules/project/templates/output-spec.md`
exists, use it: the skeleton below is the language-neutral default, the project
file is the one your operator reads.

**Requirements.** Short and clear, no filler, no long paragraphs. No technical
detail, no jargon. Table, field and entity names stay exactly as they are in the
database and the code – never translated or renamed. Exhaustive for an engineer,
readable for a manager.

```markdown
# <ID> <title>

## User story / Bug report
As <role>, I want <what>, so that <why>.

For a bug: what happens now, what is expected, how to reproduce, since when it
has been observed.

## UI
<what it looks like and where. No interface – drop the section>

## Logic
<briefly, step by step: what happens and under which conditions>

## Schema changes
| Table | Field | Type | Change |
|---|---|---|---|
| <table> | <field> | <type, null?> | new / changed / dropped |

<no schema change – say so in one word>

## Acceptance
1. <verifiable condition>
2. <verifiable condition>

## Scope
- <what is included>

## Out of scope
- <what is deliberately left out, and why>
```

## Common mistakes

- **Describing the implementation instead of the behaviour.** "Added a worker
  that reads Redis" is not an output spec. "Stale reservations are released
  within a minute" is.
- **Acceptance stated as intent.** "Works correctly" is not verifiable.
- **Lost out-of-scope.** Anything deliberately cut in step 1 must appear in that
  section, or the question comes back.
