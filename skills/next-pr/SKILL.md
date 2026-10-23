---
name: next-pr
description: Build the next PR from an approved plan. Re-checks that PR's section of the plan against the code, writes an implementation plan and stops for approval, then builds, tests, mutation-tests every new assertion, runs the repo's review checklist, reviews the diff as a reviewer would and hands over the unstaged diff with a commit title, PR title and description. Updates the plan's current state and the session log. Never stages, commits or pushes. Use when a plan file with a PR list exists and the user says "next PR", "build PR <n> from the plan", or runs /next-pr.
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

## Read first, in this order

1. The plan's current state (section 0) and the newest session-log entries, if they exist.
2. The plan's section for this PR, plus any open questions it depends on.
3. The repo's review conventions (default `docs/plans/review-conventions.md`), if there is one.
4. The repo's `CLAUDE.md`.

If the user didn't say which PR, take the next one in the current state whose prerequisites are met, and confirm.

## Step 0: the branch

Check where you are with `git branch --show-current` and `git log --oneline -3`. If the branch for this PR doesn't exist, or its parent isn't what the plan says, give the user the command (e.g. `git switch -c <branch> <base>`) and wait. For a stacked PR, confirm the parent PR's head commit is the parent.

## Step 1: check the plan against the code

- Re-check every claim and `file:line` citation in this PR's section. The code moves between sessions, and earlier PRs may have changed what this one needs.
- Correct the plan text where it's wrong, and add a dated session-log entry listing each correction. Say "every citation holds" when they do. In plan mode, list the corrections in the implementation plan and write them after approval.
- If a correction changes the slicing (a piece moves to another PR, a PR splits), propose it and wait. Don't re-slice on your own.

## Step 2: implementation plan, then stop

Files, tests, and the order you'd build them, plus anything that touches shared code and how existing tests prove the rest is unchanged. If the PR has a **user's piece**, lay out its options with what each changes, and mark where you'll stop. Then stop for approval.

## After approval

1. **Build** up to the user's piece, if any, and stop there for their choice. Then finish.
2. **Run** the relevant tests and the linter on changed files, using the commands from `CLAUDE.md`. Report what ran and what couldn't. If the repo has no tests or linter, say so.
3. **Mutation-test every new assertion:** break the code it guards, confirm the test goes red, revert. A green run only counts if it could have gone red. If tests can't run here, give the user the list of mutations to try.
4. **Run the review conventions checklist**, if the repo has one, on this PR's diff (against its parent for a stacked PR), item by item. Fix what fails.
5. **Review it as a reviewer would.** Re-read the diff hunting for gaps between pieces that each look right alone (ordering, which source wins, unhandled nil, a caller outside the diff). Trim anything a reviewer would ask to cut.
6. **Hand over**, in this order:
   - The files to stage, by name, and any unrelated drift to `git restore`.
   - One commit title in the format the user's instructions or the repo set. One commit per PR unless the user or repo says otherwise.
   - The PR title in the repo's format.
   - The PR description (below).
   - For a stacked PR whose parent moved: the restack commands (`git rebase --onto <new parent> <old parent head> <branch>`, then `git push --force-with-lease`).
7. **Record:** update the plan's section 0 and add a dated session-log entry with what was built, deviations from the approved plan and why, what ran, and what is pending. If another session will pick up the next PR, offer to write its prompt with the `handover-prompt` skill.

## PR description shape

Use the repo's PR template or the shape in its review conventions if either exists. Otherwise:

```
## Summary

<Context: one or two sentences on the overall goal in plain words, with the design doc linked inline, and the base branch or the PR it stacks on. Never "Part of <ticket>".>

<This PR: what it achieves and how it fits the goal, in a short paragraph. Then each departure from the nearest precedent, one sentence each, only where a reviewer would otherwise ask.>

### Blast radius

<One or two sentences: is it safe, what breaks if it's wrong, side effects, how to roll back.>
```

Add other `###` sections only for operational steps this PR needs (a migration to run, a rollout step). A bug fix goes shorter: cause in one or two sentences, changes as bullets, blast radius. Verify every factual claim in the description against running code, or say it's unverified.

## Stop conditions

Stop and ask when: the plan and the code disagree on something settled, a requirement looks ambiguous, the user's piece is reached, a test fails for a reason outside this PR, or the diff grows past what the plan said this PR is.
