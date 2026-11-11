---
name: ticket
description: Move one ticket to its next stage. Reads the kickoff plan's current state, git and the PR, picks the stage (kickoff, next-pr, test and adversarial review, explain-the-diff, answer-review), runs that skill and stops at its gate. One stage per run, so every human gate stays. Never stages, commits, pushes or posts. Use when the user says "next step on this ticket", "where am I on [ticket]", "carry on with the ticket", or runs /ticket [ticket key or URL].
argument-hint: "[ticket key or URL]"
---

# Ticket

Route one ticket through the existing skills, one stage per run. This skill does no stage's work itself: it works out where the ticket is, invokes the skill for that stage with the Skill tool and stops where that skill stops. One stop per run: the stage's own gate.

## Ground rules

- Never stage, commit, push, rebase or post anywhere. Never run `gh pr create`, `gh pr edit` or `gh pr comment`. Committing and opening the PR are the user's steps; give the commands and stop.
- Don't re-do what a stage skill does. If a skill's steps and this skill disagree, the stage skill wins.
- Write nothing except the `state` cell of the plan's section 0, and only with the words in "States" below. Everything else in the plan belongs to `kickoff` and `next-pr`.
- One stage per run. After the stage's gate, print the next stage as `/ticket <key>` and stop. Don't run on into the next stage, even if the user approved the gate in the same message.
- If a stage's skill isn't installed, say which one and give the user what it would have done in one line. Don't improvise it.
- Use one simple command per Bash call. No `cd`, loops, `$(...)` or `2>/dev/null`.
- Don't edit this skill's files or offer to, while running it. If the skill got something wrong, say what in one line; the user changes it in the skill's source repo.

## States

The `state` column of section 0 in a `kickoff` plan, per PR:

- `planned`: in the plan, not started.
- `in progress`: `next-pr` is building it.
- `handed over`: `next-pr` handed over the unstaged diff.
- `reviewed`: the review stage below finished on that diff.
- `in review`: the PR is open.
- `merged`: done.

## 1. Find the ticket and its state

- **Plan:** the ticket key from `$ARGUMENTS`, else from the branch name, else ask. Find the plan with Glob `docs/plans/*<key>*.md`, skipping the session log. If there are several, take the newest by date prefix and say which.
- **Current PR:** the first PR in section 0 whose state isn't `merged`.
- **Check it against git and `gh`:** `git branch --show-current`, `git status --short`, and for a PR past `reviewed`, `gh pr view <branch> --json state,reviewDecision,url`. If `gh auth status` fails, treat `gh` as unavailable and ask the user for the PR's state.
- If `gh` says the PR is open or merged and section 0 says less, update the state cell to match and say so. If section 0 and git disagree any other way (state `handed over` but a clean tree, the wrong branch checked out), ask one question. Don't guess.

## 2. Run the stage

First match wins:

| Situation | Stage | Gate |
|---|---|---|
| No plan for the ticket | `kickoff <ticket>` | The plan, for the user's approval |
| Plan has an open question marked as blocking the current PR | None. List the questions | The user's answers |
| Current PR is `planned` or `in progress` | `next-pr <PR>` | Its implementation plan, then the user's piece |
| Current PR is `handed over` | Review: see below | Findings to accept |
| Current PR is `reviewed` | `explain-the-diff` | The quiz verdict |
| Current PR is `in review` with unresolved comments or changes requested | `answer-review <PR url>` | Replies and changes, for the user's approval |
| Current PR is `in review` with nothing to answer | None. Say it's waiting on reviewers | |
| Every PR is `merged` | None. Say the ticket is done | |

**Review stage**, on a `handed over` diff, in this order:

1. `review-tests`, if the diff adds or changes test files.
2. `adversarial-review`, only if the diff touches code outside this PR's files in the plan, `next-pr`'s handover left findings open, or the user asks. Otherwise skip it and say why in one line: `next-pr` already ran a fresh-context review.

When both are done and the user has accepted or rejected each finding, set the state to `reviewed`.

**After `explain-the-diff`** says the change is ready, give the user their own steps and stop: `/commit` (or the commit title from the handover), push, open the PR with the title and description from the handover. When `gh` later shows the PR open, the state becomes `in review`.

**After a PR merges**, if this session already built or reviewed a PR, suggest `/handover-prompt` so the next PR starts in a fresh session.

## Output

- One line on where the ticket stands: plan path, current PR and its state.
- Then the stage's own output.
- Last line: the next command, e.g. `Next: /ticket ABC-123`, or what the ticket is waiting on.
