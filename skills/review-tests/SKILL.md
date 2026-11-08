---
name: review-tests
description: Review the tests the current branch adds or changes the way a reviewer reads them, before the PR opens, and propose fixes. Checks that each example's name is in plain words and says exactly what its assertions check, that the body follows the name, that hidden variants are settled, that each example is one scenario, that every new assertion can go red (with the mutation that proves it), and that the spec follows the repo's house patterns. Reads the repo's CLAUDE.md, AGENTS.md and review conventions at run time, so it works with any test framework. Reports per test file and stops for approval, then edits test files only. Never stages, commits or pushes. Use when the user says "review my tests", "check the specs before I open the PR", "are these tests readable", "spec clarity pass", or runs /review-tests [base branch]. Not for reviewing someone else's PR or for a full pre-PR checklist.
argument-hint: "[base branch]"
---

# Review tests

Read the tests the current branch adds or changes as a reviewer will, before the PR opens. A spec can be correct and still cost a review round: the reviewer reads the names to learn what the code does, then reads the bodies to check them, and asks when the two don't match. One stop: after the report, before any edit.

## Ground rules

- Read only until the user approves. After that, edit test files and test support only, never application code.
- Never stage, commit, push or post anywhere. Give the user the commands; they run them.
- The repo's CLAUDE.md and AGENTS.md override this skill: test commands, house test style, comment rules.
- No code comments unless the user asks. If they do, draft one short line for them to add: the file, the assertion it goes above, the text.
- If a test run is blocked (sandbox, missing service, no network), say so and give the exact command.
- Never hard-wrap prose in the report.

## Read first, in this order

1. [references/test-rules.md](references/test-rules.md). Every check in step 2 comes from it.
2. The repo's CLAUDE.md and AGENTS.md if present: test style, how mocks are asserted and flags toggled, the test and lint commands.
3. The repo's review conventions doc if one exists (look for files like `CONTRIBUTING.md`, `docs/**/review*`, `docs/**/conventions*`, `.github/*.md`): its testing rules and any pre-PR checklist lines about tests. If there's none, say so in one line and use `references/test-rules.md` alone.

Cite rules by number where the doc numbers them, by name otherwise. Where the repo's rules and `test-rules.md` disagree, follow the repo and say so.

## Step 1: find the examples

1. Base: the argument if given; else the open PR's base (`gh pr view --json baseRefName --jq .baseRefName` if `gh` is available); else `git symbolic-ref --short refs/remotes/origin/HEAD`; else ask the user. Don't assume `main`. Prefer `origin/<base>` over a local branch that may be stale. If `gh` fails, say so and use the fallback.
2. Changed test files: `git diff --name-only <base>...HEAD`, `git diff --name-only HEAD` for staged and unstaged changes, and `git status --short` for untracked files. Keep test files only (`spec/`, `test/`, `tests/`, `__tests__/`, `*_spec.*`, `*_test.*`, `test_*.py`, `*.test.*`, `*.spec.*`). If there are none, say so and stop.
3. Read each file in full, not only the hunks. Sibling examples set the naming pattern and the house style.
4. Scope: an example is in scope if its name or body is in the diff, or if setup it depends on changed (`let`, `before`, `beforeEach`, fixtures, a helper in the same file). Mark the setup-only ones, and list deleted examples. With nested `describe`/`context` blocks, the name a reviewer reads is the joined chain, so check that.

## Step 2: check each example

Check each in-scope example against the list below and against the repo's own rules. Confirm every finding against the code before reporting it: a claim about what the code does needs the `file:line` that shows it.

1. Name (rules 1.1, 2.3). An overclaiming name gets reworded or the example split, never deleted.
2. Body (1.2).
3. Hidden variants (1.3). When the test could pass more than one way, the assertions settle which. A bare count such as `.twice`, `toHaveBeenCalledTimes(2)` or a queue length doesn't. Propose one that does, such as matching each message's content in order, or the list of enqueued job classes.
4. One scenario per example (1.4).
5. Can it go red (2.6). Trace the path from setup to the asserted line. A threshold, flag, env value or early return that ends the path first makes the assertion pass for nothing (for example, a test environment that skips the external call unless the environment is faked). For each new or changed assertion, give the mutation that proves it: the application `file:line`, the edit, and the assertion that should go red. If no mutation turns it red, that is a finding.
6. House patterns (1.6). Before suggesting a helper, matcher or style, grep the sibling specs and count each option's usages, and give the counts.
7. Removal (2.1, 2.2, 2.5). Before suggesting an example or assertion go, check: does it answer "why does this code exist", or guard a regression nothing else covers? If so, keep it and fix it. Only something that restates a guarantee the framework or another test already gives can go. Say which case applies.

Examples outside the diff with the same problem go in the questions. Never change them.

## Step 3: report, then stop

One section per test file, headed with its path:

**Names:** a table: Line | Current name | Proposed name | Why. Only the rows that change, then one line naming the in-scope examples that need nothing.

**Body and assertions:** one bullet per example that changes: the line, the change (setup order, an assertion added, replaced or removed, an example split or merged) and why. Show the proposed assertion as code when words alone are ambiguous.

**Mutations:** a table: Assertion | Break | Expect red. Example row: `file_spec.rb:42` | `app/x.rb:17`: return before the send | `have_received(:send_message)`. One row per new or changed assertion, including the ones the proposed fixes add.

**Questions for the user:** numbered. Out-of-diff examples with the same problem, and judgement calls with two reasonable answers. For a judgement call, give both answers and recommend one.

A file with no findings gets one line saying so, plus its mutations. End with what would change if the user approves everything, and that nothing has been changed yet. Then stop.

## After approval

1. Edit only what was approved, in test files and test support.
2. Lint each changed test file with the command from CLAUDE.md or AGENTS.md (or the repo's obvious linter config). Fix what it flags on the lines you changed.
3. Run the changed examples if the environment allows. If not, say why and give the exact command, by file and line.
4. Mutations: give the list from step 3 again, updated for the final code, for the user to run: break, expect red, revert.
5. Hand over `git diff --stat` and one commit title in the format the repo uses (check `git log --oneline -20`). Then stop.

If the review turned up a rule that isn't in `test-rules.md` or the repo's conventions, and the user agreed with it, offer to add it to the repo's conventions doc. Don't add it yourself.

## Stop conditions

Stop and ask when: a fix would need a change to application code, a finding shows the code under test is wrong rather than the test, or a test fails for a reason outside the examples in scope.

## Rules

- Use one simple command per Bash call. No `cd`, loops, `$(...)` or `2>/dev/null`.
- Don't edit this skill's files or offer to, while running it. If the skill got something wrong, say what in one line; the user changes it in the skill's source repo.
