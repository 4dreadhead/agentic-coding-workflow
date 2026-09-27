# Step 4. Self-review

Runs **always**, after a green test run and before moving to «В ревью». It never
runs on red tests – that wastes effort on the obvious.

The review is performed by a separate reviewer agent that **did not write this
code** and receives the task without the implementation history: only the diff,
the acceptance criteria and the rules.

## Depth

| Level | When |
|---|---|
| Basic | everything else |
| Deep | the diff touches migrations, the database schema, external APIs, authentication, encryption, money; or the diff is larger than ~300 lines; or it touches areas flagged as critical in `../rules/project/` |
| Deep + regressions | the task has gone back for rework more than once |

## What the reviewer checks

1. **Acceptance criteria** – every item closed and verifiable, not "seems to work".
2. **Regressions** – what else calls the changed code, and whether anything broke silently.
3. **Omissions** – edge cases, empty values, repeated runs, concurrent execution.
4. **Scope** – nothing in the diff that is not in the task.
5. **Rules** – `rules/main.md` and `rules/project/` are honoured.
6. **Tests** – they assert behaviour rather than mirror the implementation, and they fail if the code is broken.

## Handling findings

Findings split in two:

- **blocking** – acceptance not met, a regression, a rule broken. Fixed before
  handoff by returning to the step 3 loop.
- **discretionary** – recorded in the card and presented to the operator with
  the diff, never fixed silently.

The reviewer's report stays in the card. The operator needs it to know what has
already been checked and not re-check it by hand.
