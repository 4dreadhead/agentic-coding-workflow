# Template: agent spec

Written by the agent in step 2 and maintained until the task is done. Lives in
the task card.

```markdown
## Agent spec

### Affected places
- `path/to/file.rb:120` – what changes and why
- `path/to/other.rb` – new file, purpose

### Decomposition
- [ ] 1. <vertical slice with an observable effect>
- [ ] 2. <next>
- [ ] 3. <...>

### How to verify
- `<test command for this task>`
- <what to check manually where automation is impossible>

### Decisions taken
- <decision> – because <reason>; <X> rejected because <Y>

### Deviations from plan
- <date> assumed <A>, turned out <B>, did <C> instead

### Rework
- Round 1, <date>: «<operator's wording, verbatim, in their language>»

### Self-review report
- depth: basic / deep
- blocking findings: N (fixed)
- discretionary: <list>
```

Headings are structure and stay English – the card is read by agents. What is
quoted from the operator keeps the operator's language, verbatim.
