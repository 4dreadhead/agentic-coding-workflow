# Project rules

Rules that apply **to this project only**. One file per topic, the filename is
the topic. All of it is read before writing code, together with `../main.md`.

Written in English, like every other instruction file. See `../main.md`.

## Rule format

An abstract statement does not get applied. It needs contrast:

```markdown
## <Short imperative title>

<The rule, in one or two sentences.>

Bad:
  <minimal example>

Good:
  <minimal example>

Why: <the reason, showing the cost of breaking it>
```

## Where rules come from

Not from general notions of good code – that produces a list of platitudes
nobody reads. There is one source: **the operator's own repeated remarks.**

How to collect them: hand the agent the project's session history
(`~/.claude/projects/<slug>/`) and ask it to find the operator's corrective
messages, group them by kind and sort by frequency. Rules are written from the
top of that list down.

Worth repeating every couple of months – it also surfaces rules that have gone
stale along with the environment.

## Maintenance

Every time you correct the agent by hand, add a line here. Without that the
rule set goes stale within a month.

A rule that has never been broken can be deleted: it occupies context and earns
nothing.
