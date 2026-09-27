# Step 3. Implementation

## Before the first edit

`../rules/main.md` and every file in `../rules/project/` must be in front of you.
In a Claude Code session the startup hook has already put them there; as a
subagent, or under another agent, read them now. Code written without them gets
rewritten – that is the expensive way to learn the constitution.

## The loop

One checklist item at a time:

1. Read the files you are about to change **in full**. Not the snippet a search
   returned.
2. Make the change.
3. Run the tests that cover it.
4. Tick the item, and add a note if there was a deviation.

Do not batch five items and run once. A mistake caught at an item boundary costs
a minute; the same mistake four hundred lines later costs an hour.

## Branch and commits

Work happens on a branch named after the tracker issue: `AF-xxxxx`, exactly as
the operator supplied it. Commit messages are `AF-xxxxx: short description of
commit`.

Commit when the step finishes and the tests are green – that is authorised
standing, because the operator reviews the diff in an IDE. Stage explicit paths,
never everything. Pushing is not authorised and stays with the operator. Full
rules in `../rules/project/git.md`.

## Tests

For bug fixes – **always start with a failing test** that reproduces the bug,
with the failure output attached. Otherwise there is no proof the right thing
was fixed.

For new code – test at a stable boundary (a public entry point, an observable
effect). Internal classes whose shape may still change are not pinned by tests.

Tests are never bent to fit the code. If a test is in the way, that is the
operator's call, not a fix made in passing.

## Boundaries

- Do not touch what the task does not cover. Found a problem nearby – file it as
  a separate task and move on.
- Do not add functionality "for later" that is not in the acceptance criteria.
- Do not refactor in passing. Refactoring is its own checklist item or its own
  task.

## When to stop and ask

- a test fails twice in a row and you do not understand why;
- the acceptance criteria turn out to be unachievable as agreed;
- the database schema needs changes beyond what was agreed;
- the task turns out to be substantially larger than it looked at step 1.

Stopping to ask is cheaper than guessing. Carrying on "roughly in that
direction" is not allowed.

## Running as an implementation subagent

Normal mode for this step: the conductor session creates the worktree and hands
the task to a subagent. If you are that subagent:

- **Work only inside the worktree you were given.** Its path is in your brief.
  Do not edit files in the main checkout.
- **Run tests in your slot**, never bare `rspec`:
  `AGENT_SLOT=<slot> <main>/bin/agent-test <spec paths>`. Another agent may be
  running the suite at the same time, and a slotless run destroys its data.
- **You cannot talk to the operator.** Every "stop and ask" case above becomes
  "stop and report": write what you found into the card, finish the report with
  the question, and end. The conductor will relay it and send you the answer.
  Never guess in order to keep going.
- **Commit when you finish, do not push.** The operator reviews in an IDE, and
  uncommitted work is not reviewable. Stage the explicit paths from the agent
  spec – never `git add -A`, the working directory holds symlinked personal
  tooling. Message format `AF-xxxxx: short description of commit`; see
  `../rules/project/git.md`. Pushing stays with the operator.
- Keep the card updated as you go – it is the only channel that survives you.
