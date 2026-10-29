---
name: adversarial-review
description: Adversarial pre-ship review of a PR, branch or file against its base. Four fresh-context reviewers (correctness, contracts, behaviour, tests) each try to prove the change wrong, then a fresh judge verifies every finding against the code and drops what has no evidence. Reports valid blockers and should-fix items with evidence, up to 5 nits, and unverifiable items. Read-only, never edits, commits, pushes or comments. Use when the user runs /adversarial-review <PR, branch or path> [base].
argument-hint: "<PR number | branch | path> [base branch]"
disable-model-invocation: true
---

# Adversarial review

Find reasons the change is wrong before it ships. No summary, no praise, no fixes. The user picks what to act on.

## Scope

This block applies to you and to every subagent. Paste it into each subagent prompt as written.

```
- Read-only. Don't edit files, commit, push or comment on GitHub.
- Review only the diff and the code it directly touches.
- Allowed commands: read-only git, search, the test suite, the type checker and the linter. Nothing else that changes state.
```

## 1. Resolve the target

Use one simple command per Bash call. No `cd`, loops or `$(...)`.

- **Base:** the argument if given, else the PR's base, else the default branch from `git symbolic-ref --short refs/remotes/origin/HEAD`. Don't assume `main`.
- **PR number:** try `gh pr view <n> --json baseRefName,headRefName,title,body` once. `gh` often fails inside a sandbox, so if it does, ask the user to run this in their own terminal and wait:
  ```
  git fetch origin <base> pull/<n>/head:refs/review/<n>
  ```
- **Branch:** review `<base>...<branch>`.
- **Path:** review `git diff <base> -- <path>`, working tree included.

Collect:

- The diff: `git diff <base>...<head>` (or the path form).
- The touched files: `git diff --name-only <base>...<head>`.
- The stated intent: the PR title and body, or the ticket text if the user gave one. If there's neither, say so to reviewer 3 instead of inventing one.

If the diff is under ~50 lines, say once that a single pass would do and ask whether to run the full panel anyway.

## 2. Run the checks once

Find the repo's test, type check and lint commands in `package.json` scripts, the Makefile, CI config or `CLAUDE.md`. Run each once on the head and keep the raw output. If one can't run, record the command and why.

Run them here, not in the reviewers: four parallel runs collide on build caches, ports and test databases, and cost four times as much.

## 3. Reviewers

Spawn 4 general-purpose subagents in one message, each with fresh context. Use the session's model or lower, and follow any model policy in the user's `CLAUDE.md`.

Give each one only:

- the scope block
- the diff and the list of touched files
- the raw check output from step 2
- the stated intent
- its angle, below

Don't pass on your own reading of the change. No summary, no hints about where you think the problems are.

Angles:

1. **Correctness:** logic, edge cases, async and state bugs, error handling.
2. **Contracts:** types, the shape of APIs between modules, services or client and server, backwards compatibility for existing callers and stored data.
3. **Behaviour:** does it do what the stated intent says, user-visible regressions, and a11y and i18n where the diff touches UI.
4. **Tests:** what the tests don't prove, and the failing case they'd add.

Instruction for each:

```
Your job is to prove this change is wrong from the angle below. Do what a strong engineer would: read the call sites, grep for other usages, check the types, run a single targeted test file if it helps. The full suite has already run; its output is below.

For each finding give:
- claim: one sentence
- evidence: file:line, or the command and its output
- severity: blocker | should fix | nit
- confidence: high | medium | low

No finding without evidence. "No findings" is a valid answer; don't pad.
```

## 4. Judge

Spawn one more general-purpose subagent with fresh context. Give it the scope block, the diff and every finding verbatim, with the reviewer labels removed so the angle doesn't bias the verdict.

Instruction:

```
For each finding, open the cited file:line and rerun any cited command that's cheap to run. Then mark it:
- valid: the evidence shows what the claim says
- invalid: the evidence is missing, wrong, or doesn't support the claim
- unverifiable: the claim may be true but can't be confirmed from the code or a command here

One line why for each. Merge duplicates. Keep the highest severity the evidence justifies, and downgrade with a reason when it's overstated.
```

## 5. Report

In chat, in this order:

1. **Blockers**, then **Should fix**. Each: `file:line`, the claim, the evidence.
2. **Nits:** up to 5, one line each.
3. **Unverifiable:** listed separately, one line each with what would confirm it.
4. One line on which checks ran and which couldn't, with the reason.

If nothing valid survives, say so in one line. Don't fix anything. If `refs/review/*` refs were fetched, mention they can be removed with `git for-each-ref --format="%(refname)" refs/review | xargs -n1 git update-ref -d`.
