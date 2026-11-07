---
name: explain-the-diff
description: Make sure the author of a mostly agent-written change understands it before sending it for review. Explains the diff concept first (the background, the core idea in plain words, then a walk through the changes in reading order with file:line anchors), quizzes the author one question at a time and gives a verdict, ready to send or what to re-read. Defaults to the current branch, uncommitted work included. Read-only, never edits, commits, posts or comments. Use when the user says "explain the diff", "explain my changes to me", "do I understand this change", "quiz me on this PR", or runs /explain-the-diff [PR, branch or base].
argument-hint: "[PR number | branch] [base branch]"
---

# Explain the diff

Teach the author their own change, then check they got it. Don't send it for review until you can pass a short quiz on it. The explainer and the quiz are for the author only: nothing here is written for reviewers.

## Ground rules

- Read-only. Never edit files, stage, commit, push, post or comment. Everything stays in chat.
- Teach, don't review. Reviewer-facing text belongs to `annotate-pr` and `pr-description`, bug hunting to `adversarial-review`. If you trip over a likely bug, say so in one line with `file:line` and carry on.
- Every claim about behaviour comes from the code you read, with a `file:line` worked out from the `@@` hunk headers or the file itself. Never estimate a line number.
- Never hard-wrap prose.
- Don't edit this skill's files or offer to, while running it. If the skill got something wrong, say what in one line; the user changes it in the skill's source repo.

## 1. Resolve the diff

Use one simple command per Bash call. No `cd`, loops, `$(...)` or `2>/dev/null`.

- **Base:** the base argument if given, else the PR's base, else the default branch from `git symbolic-ref --short refs/remotes/origin/HEAD`. Don't assume `main`. If `git log --oneline <base>..HEAD` holds commits that aren't this branch's work, the branch is stacked: ask which branch it stacks on.
- **No target (default):** the current branch, uncommitted work included. Run `git merge-base <base> HEAD`, then read `git diff <merge-base>`, which covers the branch's commits and uncommitted changes to tracked files. Add untracked files from `git status --short`.
- **One branch argument:** if `git merge-base --is-ancestor <branch> HEAD` succeeds, it's the base; otherwise it's the branch to explain, as `<base>...<branch>`.
- **PR number:** try `gh pr view <n> --json baseRefName,headRefName,title,body` once for the base and the intent. If `gh auth status` fails, or a call returns 404 for a repo you know exists, treat `gh` as unavailable. Get the code with `git fetch origin <base> pull/<n>/head:refs/review/<n>`; if that fails in the sandbox, ask the user to run it in their own terminal and wait.
- When the head isn't checked out, read files with `git show <head>:<path>`, not from the working tree.

If the diff is empty, say so and ask what to explain. If it's purely mechanical (renames, formatting, generated files, a lockfile), say so in one line and stop.

## 2. Understand it first

- `git log <base>..<head>` with full bodies, the diff from step 1 with `--stat`, then in full.
- Each touched file in full, and the callers of anything whose behaviour changed. The explainer needs the code around the hunks, not just the hunks.
- The intent: the conversation, the commit bodies, the PR body, the repo's plan docs (e.g. `docs/plans/`). If the intent isn't anywhere, say so instead of inventing one.

## 3. Explain

Scale to the diff. A few-line change gets a few lines in total. Sections, in this order:

1. **Background:** how the part of the system this touches works today, only as much as the change depends on. Leave out what the conversation shows the user already knows.
2. **The idea:** what the change does and why, in two or three plain sentences, with one concrete example (an input and what now happens to it). No identifiers unless the idea needs one.
3. **The walk:** the changes in the order that makes them make sense (data shape before the code that uses it, the core change before its follow-ons), never file order. Each step opens with a sentence on what's happening and why, then `file:line` and the few lines that matter. Group mechanical follow-ons into one line.

End with "Say when you're ready for the quiz." Don't show any question yet.

## 4. Quiz

- About five questions, fewer for a small diff. Medium difficulty.
- Test behaviour, not recall: what happens on an edge case, why an order matters, what breaks if a line is reverted, which callers see a difference, what the change deliberately doesn't handle. Never ask for a name, a file or a line number.
- Work out each answer from the code, with `file:line`, before asking. Don't show the answers.
- Ask one question at a time and wait. Give no hints before the answer.
- After each answer, mark it right, partly right or wrong. Say plainly where the user's model differs from the code and point to the `file:line` that shows it. "I don't know" counts as wrong.
- If the user's answer describes what the change should do and the code does something else, that's a likely bug, not a misunderstanding: say so in one line.

## 5. Verdict

- **Ready to send:** every answer right, or one partly right.
- **Not yet:** list each missed point with the walk step and `file:line` to re-read, one line each. Offer a fresh question on each missed point, never the same one again.
- If `refs/review/*` refs were fetched, mention they can be removed with `git for-each-ref --format="%(refname)" refs/review | xargs -n1 git update-ref -d`.
