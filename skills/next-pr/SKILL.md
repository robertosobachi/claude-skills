---
name: next-pr
description: Build the next PR from an approved plan. Re-checks the plan against the code and stops for approval, then builds, tests, mutation-tests new assertions, reviews the diff and hands over the unstaged diff with a commit title, PR title and description. Never stages, commits or pushes. Use when a plan file with a PR list exists and the user says "next PR", "build PR [n] from the plan", or runs /next-pr.
argument-hint: "[PR number or name from the plan]"
---

# Next PR

Build one PR from a plan written by `kickoff`, or any plan with a PR list. If the plan has no current-state section (section 0 in a `kickoff` plan) or no session log, work out the state from the branches and `git log`, confirm it with the user, and offer to add them. Two stops: after the implementation plan, and at the user's piece if the PR has one.

## Ground rules

- Never stage, commit, push, rebase, cherry-pick or post anywhere. Never run `gh pr edit`, `gh pr create` or stacking tools. Give the user the exact commands; they run them.
- The repo's `CLAUDE.md` overrides this skill: test commands and prefixes, house test style, comment rules, migration rules.
- Settled decisions in the plan are settled. Don't reopen them. If the code contradicts one, stop and say so.
- If the sandbox blocks a command (a local service, the database, `gh`), say so and give the exact command for the user to run and paste back.
- No AI attribution. Never hard-wrap prose.
- Use one simple command per Bash call. No `cd`, loops, `$(...)` or `2>/dev/null`.
- Don't edit this skill's files or offer to, while running it. If the skill got something wrong, say what in one line; the user changes it in the skill's source repo.

## Read first, in this order

1. The plan's current state (section 0) and the newest session-log entries, if they exist.
2. The plan's section for this PR, plus any open questions it depends on.
3. The repo's review conventions (default `docs/plans/review-conventions.md`), if there is one.
4. The repo's `CLAUDE.md`.

If the user didn't say which PR, take the next one in the current state whose prerequisites are met, and confirm.

## Step 0: the branch

Check where you are with `git branch --show-current` and `git log --oneline -3`. If the branch for this PR doesn't exist, or its parent isn't what the plan says, give the user the command (e.g. `git switch -c <branch> <base>`) and wait. For a stacked PR, confirm the parent PR's head commit is the parent.

If section 0 shows another PR from this plan in progress, build this one in its own worktree: give the user `git worktree add <dir> -b <branch> <base>` and wait. Only start a PR the plan lists as parallel with every PR in progress. If it isn't, stop and say which PR it's waiting on.

## Step 1: check the plan against the code

- Re-check every claim and `file:line` citation in this PR's section. The code moves between sessions, and earlier PRs may have changed what this one needs.
- Correct the plan text where it's wrong, and add a dated session-log entry listing each correction. Say "every citation holds" when they do. In plan mode, list the corrections in the implementation plan and write them after approval.
- If a correction changes the slicing (a piece moves to another PR, a PR splits), propose it and wait. Don't re-slice on your own.

## Step 2: implementation plan, then stop

Files, tests, and the order you'd build them, plus anything that touches shared code and how existing tests prove the rest is unchanged. If the PR has a **user's piece**, lay out its options with what each changes, and mark where you'll stop. Then stop for approval.

## After approval

Before touching code, run the relevant tests once with the commands from `CLAUDE.md` and keep the result as the baseline. A test that already fails there is failing for a reason outside this PR. Mark this PR in progress in section 0, with its worktree if it has one, so a parallel session can see it.

1. **Build** up to the user's piece, if any, and stop there for their choice. Then finish.
2. **Run** the relevant tests and the linter on changed files, using the commands from `CLAUDE.md`. Report what ran and what couldn't. If the repo has no tests or linter, say so.
3. **Mutation-test every new assertion:** break the code it guards, confirm the test goes red, revert. A green run only counts if it could have gone red. If tests can't run here, give the user the list of mutations to try.
4. **Check the UI**, if the diff changes what a user sees. With a browser tool (Playwright, or a browser or Chrome DevTools MCP), drive the changed flow in the running app, compare it with what the plan says it should do, and record it: a video or trace file (Playwright `video` or `trace`) where the tool can, a screenshot otherwise. Put the path in the handover and tell the user to watch it before staging. If the app can't run here or there's no browser tool, say so and give the user the steps to check by hand.
5. **Run the review conventions checklist**, if the repo has one, on this PR's diff (against its parent for a stacked PR), item by item. Fix what fails.
6. **Review it in a fresh context.** Spawn one subagent. Use the session's model or lower, and follow any model policy in the user's `CLAUDE.md`. Give it only the diff (against the parent for a stacked PR), this PR's section of the plan and the review conventions, if any. It hunts for gaps between pieces that each look right alone (ordering, which source wins, unhandled nil, a caller outside the diff) and anything a reviewer would ask to cut, and returns findings with `file:line`. Check each finding against the code, fix the valid ones and drop the rest. If subagents aren't available, re-read the diff yourself for the same gaps and say so in the handover.
7. **Hand over**, in this order:
   - The files to stage, by name, and any unrelated drift to `git restore`.
   - One commit title in the format the user's instructions or the repo set. One commit per PR unless the user or repo says otherwise.
   - The PR title and description, written to the `pr-description` skill's Write it and Rules sections if it's installed, otherwise as a plain summary, the changes as bullets and the blast radius as bullets. Add a bullet for each departure from the nearest precedent, only where a reviewer would otherwise ask.
   - For a stacked PR whose parent moved: the restack commands (`git rebase --onto <new parent> <old parent head> <branch>`, then `git push --force-with-lease`).
8. **Record:** update the plan's section 0 and add a dated session-log entry with what was built, deviations from the approved plan and why, what ran, and what is pending. If another session will pick up the next PR, offer to write its prompt with the `handover-prompt` skill if it's installed.

## Stop conditions

Stop and ask when: the plan and the code disagree on something settled, a requirement looks ambiguous, the user's piece is reached, a test fails for a reason outside this PR (it already failed in the baseline), or the diff grows past what the plan said this PR is.
