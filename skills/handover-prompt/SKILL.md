---
name: handover-prompt
description: Write a prompt that lets a fresh Claude session with no memory pick up the current work exactly where it stands. Covers the goal, gating, what to read first and in what order, the verified state, decisions not to reopen, what's still open, the task and how to work. References existing docs instead of copying them. Use when the user says "write a prompt for the next session", "hand this over", "I'll continue in a new session", or runs /handover-prompt.
argument-hint: "[what the next session is for]"
---

# Handover prompt

Write the prompt the user pastes into a new session. That session starts with no memory of this one, so the prompt must stand on its own. It should also be short, because it points at the documents that hold the detail.

## Ground rules

- Verify every fact before it goes in: branch names and heads with `git branch` and `git log --oneline -3`, PR numbers, file paths, flag states. Mark anything you couldn't verify as unconfirmed.
- Don't copy what a plan, log, spec, PR description or memory already holds. Point to it by path, section or URL.
- Redact secrets, tokens and personal data.
- Write in the user's voice, addressed to Claude ("Plan and build...", "Ask me..."). No hard-wrapped prose, no AI attribution.
- Never stage, commit, push or post anywhere. This skill writes only the prompt file and, if needed, the plan's notes.

## 1. Find out what the next session is for

Use the argument if given. Otherwise ask: one task (build PR 4, answer review round 3, draft the handover to ops, test on staging), or several in order. One prompt per session's task.

## 2. Gather

- From this conversation: decisions made and by whom, corrections, what's blocked and why, what the user said they'll do themselves.
- From the repo: current branch, stack and heads, uncommitted changes, plan doc section 0 and the latest session-log entries if they exist.
- From memory, if the session uses it: which memory entries the next session should read.
- Before writing the prompt, update the plan's current state and the session log if this session changed them, so the prompt can point to them instead of repeating them.
- Anything the next session will need from the user (a link still to come, whether a local copy of a live page is current): ask now, or list it in the prompt as the first thing to ask.

## 3. Write it in this shape

```
<One or two sentences: the goal, the repo path, and how the session starts, e.g. "Start in plan mode. Development starts only after I approve the plan.">

<Gating, one sentence: what never happens, e.g. "Don't stage, commit or push, and don't post anywhere. Draft it and hand it to me.">

## Read first, in this order
1. <memory entries, if any>
2. <plan doc, section 0, and the newest session-log entries>
3. <review conventions, design doc mirror, other docs, each with why>

## Where things stand (<date>)
<Short: branches and heads, PRs and their state, what's deployed, what's verified vs unconfirmed. Point to section 0 for the rest.>

## Decided (don't reopen)
- <decision, who decided, date if useful>

## Still open (mention if the work touches it)
- <open item and who owns it>

## The task
### Step 1: check <the plan / the design / the state> against the code
<what to verify, with the user's expectations stated so the session can say "correct" or "wrong">
### Step 2: <plan / options>, then stop for my approval
### After I approve
<numbered steps: build, run, verify, hand over, record>

## How we work
- <sandbox limits and what to do about them, e.g. "gh isn't authenticated; ask me to run these and paste the output" with the exact commands>
- <repo style points the session would otherwise get wrong, or "follow CLAUDE.md">
- <files the user's local setup dirties, to keep out of the diff>
- Ask me only about decisions that are mine.
- When code or decisions change, update <plan section 0 / memory entry> in the same pass.
```

Leave out sections that would be empty. If the task has a piece the user wants to decide or write themselves, mark it: "**This is my piece.** Lay out the options, then stop." If an installed skill does the task (for example `next-pr` or `answer-review`), make the task section "Run /<skill> <args>" plus only what that skill can't know.

## 4. Save and hand over

- Save it where the user keeps prompts: `docs/plans/PROMPT-<ticket>-<slug>.md` if `git check-ignore -v docs/plans/probe.md` prints a rule, otherwise ask. Never inside a tracked path. In plan mode, show the prompt and save it after approval.
- Reply with the path and a two-line summary of what the next session will do. Mention any fact you marked unconfirmed.
