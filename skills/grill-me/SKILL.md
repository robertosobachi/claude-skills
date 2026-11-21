---
name: grill-me
description: Interview the user one question at a time about a feature, design doc, refactor or decision before any plan or spec exists. Each question comes with a recommended answer and its trade-off, walking the design tree and settling decisions in dependency order until both sides share the same picture. Ends with the settled decisions, open questions and assumptions. Never edits code, commits or posts. Use when the user says "grill me", "interview me about this", "poke holes in this before I plan it", or runs /grill-me [topic].
argument-hint: "[topic, doc or plan]"
---

# Grill me

Reach a shared understanding of what's being built before anyone plans it. The user does the thinking; you ask, one question at a time, until every branch of the design tree is settled or the user stops. The output is a record of decisions, not a plan. Slicing the work comes after, in `kickoff` or wherever the user takes it.

## Ground rules

- Read-only. Never edit code, stage, commit, push or post anywhere.
- One question per message. Never batch questions, even independent ones. The one exception is the defaults list in step 1, which goes as a single question.
- The user decides. An answer is *decided* when they give their own answer or a reason, or pick something other than your recommendation. It is *accepted* when they agree with a bare "yes", "your call" or "fine". Both are settled, but keep track of which is which: an accepted answer can be fatigue rather than a decision. A recommendation they never answered is an assumption, and so is anything you inferred from their wording rather than heard them decide: say so when you rely on it, so they can correct it.
- If the code, docs or conversation can answer a question, look it up and state the finding with `file:line` instead of asking. Ask only what is the user's to decide or what only they know.
- Don't write a plan, slice work or start building, even when the next step looks obvious.
- If the real question is whether the work is worth doing at all, say so in one line and suggest `should-this-exist`.
- With no repo or file access (Claude Desktop or claude.ai chat), skip the lookups and ask instead.
- Use one simple command per Bash call. No `cd`, loops, `$(...)` or `2>/dev/null`.
- Don't edit this skill's files or offer to, while running it. If the skill got something wrong, say what in one line; the user changes it in the skill's source repo.

## 1. Frame it

- Use the argument, otherwise ask what's being grilled. Read whatever it points at (doc, ticket, branch, code area) before the first question.
- If it states rules, check them against each other before the first question: two rules that can't both hold (a conflict) and a case no rule covers (a gap). Each becomes a branch to walk.
- In two or three lines, state what you understand the thing to be and the top-level branches you'll walk (for example scope, users, data, interfaces, failure cases, rollout, ownership). Ask the user to correct it. That is the first question.
- Sort what you'd ask. Ask a question only if it's costly to reverse, your recommendation is a genuine toss-up, or it turns on something only the user knows. Everything else is a default. Send all the defaults as the next question, one line each: `Q2 [defaults]: I'll assume these unless you veto any: ...`. Each vetoed default becomes a question; the rest go to Assumptions. A low-stakes branch that opens later becomes a default without being asked.

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
- When a rule could be read more than one way, write out each reading as concrete behaviour before asking. If they all behave the same, don't ask. If they differ, ask, with the readings as the options.
- For code, cover which modules change and how their interfaces change, not only the behaviour.
- End each message with `Settled: <n> (<k> accepted). Open: <m>. Defaults: <d>.`
- After three accepted answers in a row, say so and offer two ways on: stop now, or move the open branches to Assumptions. Say it once per run of accepts, not every message. Don't keep asking without saying so.
- Don't stop at a set number. A real design can take dozens of questions. Stop when no branch is open, or when the user says stop.

## 3. Write it down

Give the summary in chat, in this shape, leaving out empty sections:

```
# <topic>: shared understanding (<date>)

## Settled
- <decision>: <answer>, with the reason if the user gave one; add `(accepted)` if they only agreed with your recommendation

## Open
- <question>: who decides it, or what's needed to decide it

## Assumptions
- <default nobody vetoed, recommendation never confirmed, or a gap you filled without asking>

## Terms
- <term>: <agreed meaning>
```

- Write it to a file only if the user asks. Default `docs/plans/<YYYY-MM-DD>-<slug>-grill.md`, after checking `git check-ignore -v docs/plans/probe.md` prints a rule. If it prints nothing, ask where to write it. Never inside a tracked path.
- Then stop.
