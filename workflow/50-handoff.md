# Step 5. Handoff

Moving to «В ревью» means presenting the work, not announcing that it is over.

## What you present

A short message in the operator's language, with no retelling of the process.
**The exact labels are pinned in `../rules/project/communication.md`, section
"Fixed wording" – copy them from there.** One line each:

```
<id> <title>

Done:        2–4 lines, what changed in substance.
Acceptance:  N/N closed (or: K of N closed, and why the rest are not).
Tests:       <command>, <result>.
Self-review: depth, no blocking findings / K found and fixed.
Discretionary: findings left unfixed, one line each.
Deviations:  from the plan, if any.
Commits:     <branch>, <hashes and subjects>.
Files:       list.
```

Name the branch and the commits: that is what the operator opens in the IDE. If
the round produced two commits – implementation and review fixes – list both, in
order.

What must not be in it: a retelling of how the work went, apologies, assessments
of your own work, offers to "also do X".

## Honesty

Anything not done is stated plainly and first, not buried at the end. A failing
test is named, with the reason. A partially met criterion says which part.

A report claiming "all done" when it is not costs more than a failed task: it
poisons trust in every later report.

## Rework

The operator's remarks are copied into the card verbatim, into a `### Rework`
section, with the date and round number. Do not paraphrase – the operator's
wording is the source, and it stays in their language.

The task then returns to step 3. After rework, present it again in the same
format plus the rework line from `../rules/project/communication.md`.
