# agentic-coding

Infrastructure for working with coding agents: rules, a process and entry
points, the same ones for any agent and any project.

It is markdown and two shell scripts. Nothing is compiled, nothing runs in the
background.

**This file is for a human.** Agents enter through `quickstart.md` and never
read this one.

---

## Why

Three problems it solves:

1. **Instructions are tied to one agent.** A project description in `CLAUDE.md`
   is invisible to Codex, Cursor or Gemini. Here the description lives on its
   own, and `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` and the rest are only pointers
   to it.
2. **The same remarks repeat.** Rules are written down once, in `rules/`, and
   the agent reads them before every edit – enforced by a session hook, not by
   hope.
3. **The process lives in someone's head.** Steps, approval gates and spec
   formats are fixed in `workflow/` instead of being re-explained every session.

---

## Dependencies

| What | For | Required |
|---|---|---|
| bash, awk, diff | `install.sh` | yes |
| git | cloning, updating, finding the project root | yes |
| jq | the hook that puts the rules into the session context | no, but without it the rules are not injected |
| [Backlog.md](https://github.com/MrLesk/Backlog.md) | the task store | no, but without it there is no queue and no board |
| Node.js ≥ 20 | needed only by Backlog.md | no |

---

## Install on a new project

**1. Clone into the repository root.**

```sh
cd /path/to/your/project
git clone git@github.com:4dreadhead/agentic-coding-workflow.git .agentic-coding
```

The folder is a git clone of its own, nested inside your project. That is what
makes updates a `git pull` instead of a copy, and it is why nothing local ever
travels between projects: `context/` and `rules/project/` are ignored inside the
clone, so a fresh one starts empty in exactly the places that must be filled per
project.

**2. Deploy the pointers.**

```sh
./.agentic-coding/install.sh
```

Creates or extends `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`,
`.github/copilot-instructions.md`, `.cursor/rules/agentic-coding.mdc`; links the
skills into `.claude/skills/` and generates `.gemini/commands/ac/*.toml`; and
registers the rules hook in `.claude/settings.local.json`.

Existing content is left alone – only the block between
`<!-- BEGIN agentic-coding -->` and `<!-- END agentic-coding -->` is rewritten.

**3. Let the agent set the project up.**

```sh
./.agentic-coding/install.sh --bootstrap
```

It prints three steps, each one a skill the agent runs:

| Step | Skill | Result |
|---|---|---|
| Language | `/setup-language` | which language the agent speaks to you in, and the fixed wording that goes with it, recorded in `rules/project/communication.md` |
| Principles | `/setup-constitution` | you state the principles, the agent writes `rules/project/CONSTITUTION.md` with examples and rationale |
| Description | `/setup-context` | you say in two sentences what the project is, the agent explores the code and fills `context/` |

Language goes first: everything you will read afterwards depends on the answer.

Project rules (`rules/project/*.md`) are not written up front. They accumulate
as you correct the agent – the method is in `rules/project/README.md`.

**4. Install the task store.**

```sh
npm i -g backlog.md
backlog init "Project name" \
  --agent-instructions none \
  --install-claude-agent false \
  --integration-mode cli
```

**The flags are mandatory.** Without them `backlog init` appends its own
`<!-- BACKLOG.MD GUIDELINES -->` block – marked CRITICAL – to `CLAUDE.md`,
`AGENTS.md` and the rest, and installs a `project-manager-backlog` subagent. Its
built-in process conflicts with this one: `backlog instructions task-execution`
step 3 tells the agent to move the task to an active status and assign itself
immediately, which jumps the approval gate, and step 7 permits not blocking on
plan review.

Nothing of Backlog.md's documentation is lost by this: `workflow/05-task-store.md`
lists the entry points, which guide to read at which step, and what to ignore in
each.

If the block appears anyway – after `backlog agents --update-instructions`, or a
Backlog.md upgrade – cut it out:

```sh
./.agentic-coding/install.sh --strip-foreign
```

A normal `install.sh` run cuts it out by itself and says so, and
`install.sh --check` returns 1 while a conflicting block is present. The list of
tracked foreign blocks is the `FOREIGN_BLOCKS` variable at the top of
`install.sh`.

Then set the statuses in `.backlog/config.yml` and turn auto-commit off:

```yaml
default_status: "Открытые"
statuses: ["Открытые", "Заблокированы", "К реализации", "В реализации", "В ревью", "Готовые"]
auto_commit: false
```

Those six labels are the example this repository ships with – they are
configuration values quoted verbatim by `workflow/`, so if you rename them,
rename them in both places. `definition_of_done` is yours to fill: its items end
up in every card. How card sections map to the three spec levels is in
`workflow/05-task-store.md`.

---

## Migrating a copied install

If you already have a copy of this folder that was never a clone:

```sh
cd /path/to/your/project
mv .agentic-coding .agentic-coding.old
git clone git@github.com:4dreadhead/agentic-coding-workflow.git .agentic-coding
cp -r .agentic-coding.old/context/. .agentic-coding/context/
cp -r .agentic-coding.old/rules/project/. .agentic-coding/rules/project/
./.agentic-coding/install.sh
```

Copy only those two paths. Everything else is upstream and comes from the clone;
carrying an old copy of it over is how you lose a fix without noticing.

---

## Language

The system itself is English: instructions, rules, process documents, `context/`,
commit messages, the structural headings of a task card. That is what agents
read, and it is not configurable.

Everything **you** read is in your language: chat replies, clarifying questions,
review comments, handoff reports, the output spec.

Which language that is lives in exactly one file – `rules/project/communication.md`,
written by `/setup-language`. No upstream file names a human language; they all
defer to that one. Along with the language it pins the wording that has to be
stable: the line that closes the intake message and asks for your approval, the
handoff report labels, the card heading an output spec goes under. A project in
another language changes that file and nothing else.

Two exceptions inside the English files, both deliberate: your own words quoted
back at you stay verbatim, and Backlog.md status labels stay verbatim because
they are the strings `backlog task edit -s` expects.

---

## The rules are always in context

The agent reads `workflow/` when it picks up a task. When you just say "fix this
line" there is no task – and the constitution used to never reach it. The rules
apply either way: a microfix outside the process is still code in this project.

`hooks/inject-rules.sh` closes that. At session start it lays the whole rule set
into the context: `rules/main.md`, `CONSTITUTION.md` and every file in
`rules/project/`. The agent has them before your first message, rather than when
it remembers to look.

```sh
./.agentic-coding/hooks/inject-rules.sh --print   # see exactly what gets injected
```

| | |
|---|---|
| Where | `.claude/settings.local.json`, event `SessionStart` |
| Installed by | `install.sh`, together with the pointers and skills |
| Fires on | startup, `/clear`, context compaction. Not on `resume` – the injection is already in the transcript |
| State | `./install.sh --list`, the "хук правил" row |
| Remove | `./install.sh --remove` – other hooks in the file are left alone |

Three things worth knowing.

**A new session is needed.** Claude Code reads hooks at startup, so a
just-installed hook does not fire in the session that installed it.

**The cost.** A rule set of about 35 KB is roughly 9k tokens per session start.
That is the price of the rules not being forgotten. Past 140 KB the hook sends
the file list with an instruction to read them instead, so it cannot eat the
whole context (`AGENTIC_RULES_MAX_BYTES` moves the threshold).

**Claude Code only.** Hooks are its mechanism. For every other agent the text
layer does the work: the requirement to read the rules before the first edit is
in the pointer block (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, Cursor) and in
`quickstart.md`. An implementation subagent does not get the hook either, which
is why `/task-implement` passes the requirement in its brief.

---

## Keeping it out of your project's git

The system is personal tooling, so exclude it locally – through
`.git/info/exclude`, not `.gitignore`. `.gitignore` is itself in git, and your
personal paths in it are everyone's problem.

```sh
cat >> .git/info/exclude <<'EOF'
/.agentic-coding/
/.backlog/
/.claude/
/.gemini/
/.cursor/
/CLAUDE.md
/AGENTS.md
/GEMINI.md
/.agent-slot
EOF
```

**About worktrees.** `git worktree add` does not lay out excluded files: a new
directory gets no `.agentic-coding` and no `CLAUDE.md`, and the agent there is
left with no instructions. Create worktrees through a script that symlinks them
back to the main checkout – `bin/agent-worktree` in this project does that.
Symlinks mean rules and tasks are shared: an edit made from any worktree is
visible everywhere.

`.git/info/exclude` lives in the shared `.git` directory, so it applies to every
worktree at once.

---

## Daily work

| Action | How |
|---|---|
| File a task | the board, `backlog browser` (`localhost:6420` by default), or `backlog task create` |
| Work it through | `/task-intake <id>` – the agent asks questions, writes acceptance criteria, looks for blockers |
| Approve the statement | you, in chat (gate 1). The agent goes on to plan by itself |
| Plan | no separate command – it continues; `/task-plan <id>` if the session was interrupted. The plan goes into the card and the task moves to «К реализации» |
| Implement | `/task-implement <id>` |
| Review | `/task-review <id>` – a separate reviewer agent, then the task moves to «В ревью» |
| Accept | you: read the diff, send it back for rework or let it through (gate 2) |
| Close | `/task-close <id>` – final summary, dependents unblocked |

The two gates are the only places the process waits for a human. «Готовые» is
never set by an agent: that status is yours.

---

## Updating

```sh
./.agentic-coding/install.sh --update   # git pull, then redeploy
./.agentic-coding/install.sh --check    # what is stale; exit code 1 on any drift
./.agentic-coding/install.sh --list     # state of every target
```

`--update` pulls with `--ff-only`, so it refuses rather than merging when you
have local commits on top. Your project's own content is untouched by an update:
`context/` and `rules/project/` are ignored inside the clone, which is the whole
reason the split below matters.

---

## What lives where

```
.agentic-coding/
├── README.md          this file, for humans
├── quickstart.md      the agent's entry point
├── VERSION
├── install.sh
├── hooks/             UPSTREAM: inject-rules.sh – rules into the session at startup
├── workflow/          UPSTREAM: process steps and spec templates
├── skills/            UPSTREAM: entry points
├── adapters/          UPSTREAM: the pointer block template
├── rules/
│   ├── main.md        UPSTREAM: universal rules
│   └── project/       LOCAL: constitution, project rules, your language
└── context/           LOCAL: what this project is
```

UPSTREAM comes from the clone and is replaced by `--update`. LOCAL is ignored by
the clone's `.gitignore`: it never reaches this repository, it is never
overwritten by an update, and it is also not backed up by anything – if you want
history for it, commit it somewhere of your own.

Task state is not stored here. It is in Backlog.md.

---

## Maintenance

**Rules accumulate.** Every time you correct the agent by hand, that is a line
in `rules/project/`. The method for mining them in bulk out of session history
is in `rules/project/README.md`; worth repeating every couple of months, which
also surfaces the rules that have gone stale.

**Keep files short.** Long ones get skimmed. One screen per file, a page at the
outside.

---

## Removal

```sh
./.agentic-coding/install.sh --remove
```

Removes the blocks from the instruction files, deletes the files that are left
empty, unlinks the skills and generated commands, and takes the rules hook out
of `.claude/settings.local.json` – leaving the rest of that file, and anyone
else's hooks, in place. The `.agentic-coding/` folder itself is left alone:
delete it by hand.
