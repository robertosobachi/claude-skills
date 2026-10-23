---
name: kickoff
description: Start a new piece of work the same way every time. Reads the requirements and the epic, reads the repo's review conventions, finds the existing feature to copy, maps what changes and what differs, slices the work into independently reviewable PRs, records a practice baseline, writes the plan to a git-ignored plans folder and stops for approval before any code. Use when starting a feature, epic or ticket in an existing repo from a requirements page or ticket (not for writing the spec itself), or when the user runs /kickoff <requirements URL or ticket key>.
argument-hint: "<requirements URL or ticket key>"
---

# Kickoff

Turn a requirements page or ticket into an approved plan of small, independently reviewable PRs. This skill writes no code. It ends with a plan and stops. The `next-pr` skill builds each PR from that plan.

## Ground rules

- Never stage, commit, push or post anywhere (GitHub, issue tracker, wiki, chat). Draft text and give exact commands; the user runs them.
- The repo's `CLAUDE.md` overrides this skill where they conflict. Test commands, container prefixes, migration rules and house style come from there, not from here.
- Check every claim against the code before writing it down, and cite `file:line`.
- If the sandbox blocks something (a tracker the connector can't reach, `gh` without auth, a database or local service), say so in one line and give the user the exact command or the exact thing to paste back. Don't guess around it.
- No AI attribution. Never hard-wrap prose: one paragraph is one line.
- Ask the user only about decisions that are theirs.

## Steps

### 1. Read the requirements and the epic

- Read the requirements page in full, including inline and footer comments. Comments often hold decisions the body doesn't.
- Read the epic and every child ticket.
- If either is missing or unreachable, ask for it, and ask for the child ticket keys if the connector can't list them. No plan until you have both, or the user confirms there's no epic.
- Summarise the requirements in a short table or list: what changes for whom, what is out of scope, and what the page leaves undecided.

### 2. Read or create the review document

- Find the repo's review conventions (default `docs/plans/review-conventions.md`). Read all of it before planning: its rules shape the slicing.
- If it doesn't exist, offer to create it with the `review-conventions` skill from whatever review notes exist. Don't create it without asking. If that skill isn't installed, note in the plan that there are no conventions yet and carry on.

### 3. Ask for the reference feature key; find and confirm its commits

- Ask the user for a key, constant or class from the existing feature this work resembles.
- Find its commits on the default branch with `git log -S '<key>' --oneline origin/<default>` (`-G` for a pattern; `git symbolic-ref --short refs/remotes/origin/HEAD` names the default). Use `--all` only if the feature isn't merged, and drop copies of one commit and commits from the new work. Follow merge commits back to their PRs if useful.
- Show the user the commit list and wait for confirmation before using it. Drop commits they reject.

### 4. Map changes and differences

- From the confirmed commits, list every change the reference feature made, grouped by area (for example schema, API, jobs, config, flags, translations, tests), with `file:line`.
- Then list every place the new work must differ, with `file:line` and the requirement that forces the difference.
- Collect every open question in a table with a status: **Open**, **Answered** (with the answer and date), **Moot**, or **Closed for now** (with the reason). Note which questions block which PR.

### 5. Slice into PRs

Each PR must be reviewable on its own:

- One concern and a small diff. Prove that existing behaviour is unchanged with existing tests, rather than adding new ones for it.
- Behind a feature flag where one applies, and safe to merge and deploy alone.
- An independent branch off the main branch by default. Stack only when a PR truly needs another's code, and say why.
- A name that might still change gets one constant, plus, if the repo has feature flags, a flag that stays off in production until the name is final.
- Order PRs by deploy safety (for example a column before the code that reads it), and state each PR's deploy prerequisites.

For each PR give: branch name, base, scope, files, tests, deploy order, the departures from the reference feature a reviewer will ask about, and **the user's piece**: one key decision or piece of code the user writes or chooses themselves. When the build reaches it, stop and lay out options instead of writing it.

### 6. Record the practice baseline

- Find the last comparable piece of work (ask if unsure). Count its review comments and review rounds per PR with `gh pr view <n> --json author,reviews --jq '.author.login as $me | [.reviews[] | select(.author.login != $me)] | length'` (the author's own thread replies also show up as reviews) and `gh api repos/{owner}/{repo}/pulls/<n>/comments --paginate --jq '.[] | [.user.login, (.in_reply_to_id // "root")] | @tsv'`, counting only other people's comments. If there's no comparable reviewed work, say so and leave section 5 out.
- If `gh` doesn't work, give the user those commands to run and paste back, and mark the numbers pending. Don't fill them in from memory. If `gh auth status` fails, or a call returns 404 for a repo you know exists, treat `gh` as unavailable.
- After each review round, `answer-review` logs that PR's comments and rounds against this baseline in the session log.

### 7. Write the plan and stop

- Check the plans folder is git-ignored: `git check-ignore -v docs/plans/probe.md` prints the matching rule if it is, and nothing if it isn't. If it isn't, ask the user where to write it (or whether to add it to `.git/info/exclude`) before writing anything.
- Write the plan to `docs/plans/<YYYY-MM-DD>-<ticket>-<slug>.md` in the shape below, and create an empty session log next to it (`<YYYY-MM-DD>-<ticket>-session-log.md`) with a first dated entry.
- Stop. Tell the user where the plan is and what is waiting on them: open questions, the reference commits, the baseline data. **No code until the user approves.** In plan mode, put the plan in the plan-mode file and write it here after approval.

## Plan shape

```
---
title: <ticket> <name>, plan
summary: <one line>
---

# <ticket> <name>: plan

Review conventions for every PR in this plan: <path>.

## 0. Current state (<date>)
<table: PR | branch | what | state>, then blockers, flags and gates, drafts, and where the session log is. Every session updates this section before ending.

## 1. Requirements summary
<source links, short summary, table of what changes>

## 2. Open questions
<table: id | question | status | blocks>

## 3. Touch-point map
### What the reference feature changed
### Where this work differs

## 4. PR list
### PR 1: <title>
<branch, base, scope, files, tests, deploy order, departures, the user's piece>

## 5. Practice baseline
<table: PR | review comments | rounds>, pending rows marked as such

## Rules for whoever picks this up
- If the plan turns out wrong, fix the plan text and add a dated entry to the session log. Don't work around it silently.
- Don't start a PR out of order. Tick a PR off only when it merges.
- Settled decisions are listed in section 2 as Answered. Don't reopen them.
```

The session log is a list of dated entries, newest last, kept verbatim: decisions with who made them, corrections to the plan, PR states, and what couldn't run.
