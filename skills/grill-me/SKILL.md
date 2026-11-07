---
name: grill-me
description: Interview the user one question at a time about a feature, design doc, refactor or decision before any plan or spec exists. Each question comes with a recommended answer and its trade-off, walking the design tree and settling decisions in dependency order until both sides share the same picture. Ends with the settled decisions, open questions and assumptions. Never edits code, commits or posts. Use when the user says "grill me", "interview me about this", "poke holes in this before I plan it", or runs /grill-me [topic].
argument-hint: "[topic, doc or plan]"
---

# Grill me

Reach a shared understanding of what's being built before anyone plans it. The user does the thinking; you ask, one question at a time, until every branch of the design tree is settled or the user stops. The output is a record of decisions, not a plan. Slicing the work comes after, in `kickoff` or wherever the user takes it.

## Ground rules

- Read-only. Never edit code, stage, commit, push or post anywhere.
- One question per message. Never batch questions, even independent ones.
- The user decides. A recommendation they accept ("yes", "your call") is settled. One they never answered is an assumption.
- If the code, docs or conversation can answer a question, look it up and state the finding with `file:line` instead of asking. Ask only what is the user's to decide or what only they know.
- Don't write a plan, slice work or start building, even when the next step looks obvious.
- If the real question is whether the work is worth doing at all, say so in one line and suggest `should-this-exist`.
- With no repo or file access (Claude Desktop or claude.ai chat), skip the lookups and ask instead.
- Use one simple command per Bash call. No `cd`, loops, `$(...)` or `2>/dev/null`.
- Don't edit this skill's files or offer to, while running it. If the skill got something wrong, say what in one line; the user changes it in the skill's source repo.

## 1. Frame it

- Use the argument, otherwise ask what's being grilled. Read whatever it points at (doc, ticket, branch, code area) before the first question.
- In two or three lines, state what you understand the thing to be and the top-level branches you'll walk (for example scope, users, data, interfaces, failure cases, rollout, ownership). Ask the user to correct it. That is the first question.

## 2. Walk the tree

- Ask first about the decision the most others depend on. Settle it before the ones below it.
- When an answer opens new branches, add them. When it makes a branch moot, say so and drop it.
- Ask each question in this shape:
  ```
  Q<n> [branch]: <question>
  Recommend: <answer>. Trade-off: <what it costs or rules out, one line>.
  ```
- When an answer contradicts an earlier one or doesn't match the code, name the conflict and ask which wins. Don't let it slide.
- When a word could mean two things, or two words name one thing, settle the term as a decision and use only that term from then on.
- For code, cover which modules change and how their interfaces change, not only the behaviour.
- End each message with `Settled: <n>. Open: <m>.`
- Don't stop at a set number. A real design can take dozens of questions. Stop when no branch is open, or when the user says stop.

## 3. Write it down

Give the summary in chat, in this shape, leaving out empty sections:

```
# <topic>: shared understanding (<date>)

## Settled
- <decision>: <answer>, with the reason if the user gave one

## Open
- <question>: who decides it, or what's needed to decide it

## Assumptions
- <recommendation never confirmed, or a gap you filled without asking>

## Terms
- <term>: <agreed meaning>
```

- Write it to a file only if the user asks. Default `docs/plans/<YYYY-MM-DD>-<slug>-grill.md`, after checking `git check-ignore -v docs/plans/probe.md` prints a rule. If it prints nothing, ask where to write it. Never inside a tracked path.
- Then stop.
