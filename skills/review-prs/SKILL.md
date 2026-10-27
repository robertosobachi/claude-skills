---
name: review-prs
description: Light, unblocking code review of one or more GitHub PRs (including stacked PRs). Gives a merge verdict per PR, an approval trade-off (cost, what happens if it's wrong, what you get back), paste-ready comments only for blocking issues, a paste-ready final comment per PR that is always included, and a short summary if asked. Never posts anything. Use when the user pastes PR URLs and says "review these PRs", "review PR <url>", or runs /review-prs.
---

# Review PRs

Review the PRs the user pastes so they can move forward. The user posts everything themselves. Never comment, review, approve, or push.

## 1. Get the code

Find the default branch with `git symbolic-ref --short refs/remotes/origin/HEAD` (`<default>` below).

`gh` and authenticated git often fail inside a sandbox, so don't spend attempts on them. Try `gh pr view <n>` once; if it fails, ask the user to run this in their own terminal (fill in the default branch and PR numbers) and wait:

```
git fetch origin <default> pull/<n>/head:refs/review/<n> [pull/<m>/head:refs/review/<m> ...]
```

Skip draft PRs unless the user asks for them.

## 2. Map the stack

For each PR, find its base: `origin/<default>`, or the PR below it for stacked PRs. Confirm with `git merge-base --is-ancestor <base> <head>`, then list `git log --oneline <base>..<head>` and `git diff --stat <base>...<head>`. Write refs out explicitly and don't rely on word-splitting a variable (zsh doesn't split).

Review each PR only against its own base so a change is never flagged twice.

## 3. Review

- If the diffs total under ~1000 lines, read them yourself. For bigger ones, use one subagent per PR (sonnet or lower).
- Report only blocking issues: bugs, crashes, data loss, security, broken build or tests, callers broken by removed or renamed symbols, or a clear break of the repo's CLAUDE.md rules. Leave out style, naming, and nice-to-haves entirely.
- Verify every candidate issue before reporting it: grep for callers of removed symbols, read the implementation behind any new wrapper, and compare behaviour with the existing implementation when a PR claims parity with it (another platform, module or service). Turn anything uncertain into a short question, not a blocker.
- Check across the stack: a later PR relying on something missing earlier, or an earlier PR that stays broken until a later one lands.

## 4. Report (in chat)

One line per PR: `#<n> <title> — ✅ OK to merge | ⚠️ Merge after fix | ❌ Not yet`, in a small table if there are several. Under it, paste-ready comments only if something blocks: `file:line — <1-2 sentences: issue + small reason, or a question>`. Then a few short bullets on what was checked, and the limits (no CI status or existing comments without `gh`, nothing built locally). Mention that `refs/review/*` can be removed with `git for-each-ref --format="%(refname)" refs/review | xargs -n1 git update-ref -d`. Close the report with the final comment for each PR (section 6). It's always included, not only when asked.

## 5. Approval trade-off (per PR, in the report)

For each PR, answer three questions in one short line each, based on the actual diff. Use a table when there are several PRs (columns: PR, Cost, If it's wrong, What I get back).

- **Cost:** what approving takes from the user. How much they had to read or understand, anything they're vouching for without having verified it (CI, a manual test, the matching implementation), and anything they now co-own.
- **If it's wrong:** what breaks and for whom, how visible it is (crash, wrong data, hidden row, test-only), and how easy it is to undo (revert one PR, fix forward, or a stacked PR has to come out with it). Say so plainly when the blast radius is small.
- **What I get back:** the concrete payoff. A bug fix users feel, parity with another implementation, tests that protect later work, unblocking the next PR in the stack, or less code to maintain.

Keep it to three lines per PR, with no hedging. If a PR is refactor-only with tests, say that the risk is low and why.

## 6. Final comment (always)

One paste-ready comment per PR, whatever the verdict, at the end of the section 4 report.

- ✅ OK to merge: open with "LGTM", then add one or both, briefly: the payoff in plain words if users or developers will notice it (for example "so we can get this new behaviour now, nice!"), or a one-line restatement of what the PR does, to show the change was understood.
- ⚠️ Merge after fix or ❌ Not yet: no LGTM. One or two sentences on what has to change before it can merge, pointing to the inline comments. Restate what the PR does if that helps.
- Keep every comment to one or two short sentences. Plain, natural English, no filler, no AI attribution.
- Describe the change exactly as the diff shows it. A new property on an existing event isn't a "new event". When the user's wording and the diff disagree, follow the diff and flag the difference outside the comment.
- LGTM is the expected opening, so vary only what comes after it. Don't reuse the same wording or sentence pattern across PRs.
- Only praise something that matters to a reader. Don't call out things with no visible effect (for example "now read-only") unless you can say why it helps in a few words.

## 7. Summary (when asked)

One line on what the set of PRs does overall, then one bullet per PR: what changed and where (module, platform or service), and whether it's a refactor, a behaviour change, or tests. Short enough to answer "what was in those PRs?" in a meeting.
