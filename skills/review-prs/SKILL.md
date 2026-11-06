---
name: review-prs
description: Light, unblocking review of one or more GitHub PRs, stacked ones included, or of a local branch with "quick [head] [base]". Gives a merge verdict, an approval trade-off and short, emoji-led, paste-ready comments, applying the repo's own CLAUDE.md, AGENTS.md and review conventions. Can add an adversarial-review pass. Never posts anything. Use when the user pastes PR URLs (or a local head ref and base) and says "review these PRs", "review PR [url]", or runs /review-prs.
argument-hint: "[PR URLs | quick <head> <base>]"
---

# Review PRs

Review the PRs the user pastes so they can move forward. The user posts everything themselves. Never comment, review, approve, or push.

## 1. Get the code

If the user gives a local head ref and base instead of PR URLs (`/review-prs quick <head> <base>`), skip the rest of this section. Review it as one PR with that head and base, named by the head ref. This mode needs git alone.

Find the default branch with `git symbolic-ref --short refs/remotes/origin/HEAD` (`<default>` below).

`gh` gives each PR's base, title, body, comments and CI status, never its code. Try `gh pr view <n> --json number,title,body,baseRefName,isDraft` once. If `gh auth status` fails, or a call returns 404 for a repo you know exists, treat `gh` as unavailable. The code always comes from a fetch, whether `gh` worked or not. Run it once yourself; if it fails, ask the user to run it in their own terminal (fill in the default branch and PR numbers) and wait:

```
git fetch origin <default> pull/<n>/head:refs/review/<n> [pull/<m>/head:refs/review/<m> ...]
```

`gh` and authenticated git often fail inside a sandbox, so don't spend more than one attempt on either.

Skip draft PRs unless the user asks for them.

## 2. Map the stack

For each PR, find its base: `origin/<default>`, or the PR below it for stacked PRs. Confirm with `git merge-base --is-ancestor <base> <head>`, then list `git log --oneline <base>..<head>` and `git diff --stat <base>...<head>`. Write refs out explicitly and don't rely on word-splitting a variable (zsh doesn't split).

Review each PR only against its own base so a change is never flagged twice.

## 3. Adversarial pass (ask first)

Ask once, now, before reviewing, whether to add an adversarial pass. Use the question tool if there is one, otherwise ask one plain question and wait. In the question, list which PRs it would run on and which it would skip for being under ~50 changed lines, and say it costs 5 subagents per PR. Don't ask if the request already answers it: "with adversarial review", "adversarial" or "go deeper" mean yes, and "quick" or "just a light review" mean no.

If the answer is yes, run it after your own review in section 4, so your reading isn't shaped by its findings.

- Skip PRs under ~50 changed lines and say so in one line.
- For each remaining PR, invoke the `adversarial-review` skill with the PR's head ref from section 2 (`refs/review/<n>` when it was fetched) as the target and that PR's own base from section 2 (the PR below it for stacked PRs), so nothing is flagged twice across the stack. Pass the PR title and body as the stated intent when you have them.
- Treat the judge's verdicts as candidates for section 4, not as comments:
  - valid blocker: 🔴 if it meets the blocking list in section 4. Re-read the cited line first.
  - valid should fix: 🔴 only if it meets that list, otherwise a 💡 that counts towards the 2 suggestions per PR.
  - nit: drop.
  - unverifiable: ❓ only if the answer would change the verdict, otherwise drop.
  - invalid: drop.
- Merge with your own findings. When both found the same issue, keep one comment and say in its `Why:` note that the judge confirmed it, with its evidence.
- Write every comment yourself under "Writing comments". Don't paste adversarial-review wording through.

## 4. Review

- **Repo standards.** Before reading the diff, find the files that set this repo's rules:
  - `CLAUDE.md` and `AGENTS.md` at the root and in any changed file's directory or its parents. Read them at the PR head, not the working tree: list with `git ls-tree -r --name-only <head>` and read with `git show <head>:<path>`.
  - the review conventions doc at `docs/plans/review-conventions.md`, if it exists. It's usually git-ignored, so read it from disk.

  Pair each file with the changed files it governs. A nested file covers its own subtree. A root file and the conventions doc cover the whole repo, unless a rule names paths. Judge each changed file only against its paired rules. Never apply a rule from another repo, an earlier review or memory, even when it looks like it should hold here.
- **Previous comments and CI.** If `gh` worked in section 1, read the comments already on each PR (`gh pr view <n> --comments` and `gh api repos/{owner}/{repo}/pulls/<n>/comments`) and its checks (`gh pr checks <n>`). Don't raise a point someone already made. If an open thread still applies to the head, it still counts towards the verdict, but mention it in a `Why:` note or the checked bullets, not as a new comment. A failing check counts towards the verdict like a blocker: name it in the final comment's `Why:` note.
- If the diffs total under ~1000 lines, read them yourself. For bigger ones, use one subagent per PR, on the session's model or lower, and follow any model policy in the user's `CLAUDE.md`. Subagents return findings with `file:line` and evidence, not comment text. You write every comment and note yourself, following "Writing comments".
- Blocking issues: bugs, crashes, data loss, security, broken build or tests, callers broken by removed or renamed symbols, or a clear break of a rule in a paired `CLAUDE.md` or `AGENTS.md`. A conventions doc rule is blocking only when the break also fits this list, otherwise it's a suggestion.
- Non-blocking suggestions: at most 2 per PR, only where a user or the next developer would notice the difference (clearer code, a missing test for a case that matters, a simpler way to do the same thing). Skip pure style and naming preferences.
- Verify every candidate issue before reporting it: grep for callers of removed symbols, read the implementation behind any new wrapper, and compare behaviour with the existing implementation when a PR claims parity with it (another platform, module or service). Turn anything uncertain into a short question, not a blocker.
- Check across the stack: a later PR relying on something missing earlier, or an earlier PR that stays broken until a later one lands.

## 5. Report (in chat)

1. **Verdict.** One line per PR: `#<n> <title>: ✅ OK to merge | ⚠️ Merge after fix | ❌ Not yet`, in a small table if there are several.
2. **Comments.** Under it, paste-ready comments if there's anything to say, written as in "Writing comments" below. List 🔴 first, then ❓, then 💡. Each comment uses this shape:

   ```
   `file:line`
   > 🔴 <paste-ready comment>

   Why: <for the user, never pasted>
   ```

3. **`Why:` notes.** For the user only. Every comment gets one, the final comment included. In one to three plain sentences, say what you found, how you checked it (callers grepped, implementation read, compared with the other platform) and what happens if it's ignored. When the comment rests on a repo rule, name the file it came from. This is where the technical detail and evidence go, so the comment itself can stay short. Write it so the user could defend the comment if the author pushes back.
4. Suggestions alone never move a PR off ✅.
5. **Checked.** A few short bullets on what was checked, the limits (no CI status or existing comments without `gh`, nothing built locally), and which standards files were read, or that there were none.
6. **Adversarial pass.** If section 3 ran, one bullet per PR: the pass ran or was skipped (and why), how many findings were kept and dropped, and which checks ran.
7. **Cleanup.** Mention that `refs/review/*` can be removed with `git for-each-ref --format="%(refname)" refs/review | xargs -n1 git update-ref -d`.
8. **Final comment.** Close the report with the final comment for each PR (section 7). It's always included, not only when asked.

### Writing comments

Applies to every comment, the final one included.

- Start with one emoji, then the text:
  - 🔴 must fix before merge (a real bug, crash, data loss, broken build)
  - ❓ question, when something couldn't be verified
  - 💡 suggestion, non-blocking, fine to skip or do later
- Say why, not what. The author can see the code, so don't describe what it does or restate the diff. Say what happens to a user or the next developer if it stays as it is, then the fix in a few words.
- Don't explain how it goes wrong inside the code (call chains, render cycles, internals). That goes in the `Why:` note.
- Two short sentences at most, roughly 30 words. If it needs more, the rest belongs in the note.
- Talk about the code, not the author or the team. The subject is the code or what it does ("This", "the spinner", a backticked name), never "we", "you" or "let's". Give the fix as what the code needs ("hiding it on error too would fix it") or as a question about the code ("Should this also hide on error?").
- Exception: when the point is product behaviour the code can't settle (who should see something, what should happen in a flow), make it a ❓ that asks for the intended behaviour to be confirmed. Addressing people is fine there.
- Friendly, as to a colleague. The phrasing carries the tone, not pronouns.
- Everyday words, no technical or AI jargon: "the list shows twice on a fast double tap", not "race condition on re-render". Use code names in backticks only when needed to point at the thing.

Examples:

- `🔴 If the request fails, the spinner never goes away and the user is stuck. It needs hiding in the error case too.`
- `💡 Keeping the date logic in one helper would mean one place to fix next time. Fine as a follow-up.`
- `❓ Guests no longer see the price on this screen. Is that the intended behaviour?`

Too long, and mostly the what:

> 🔴 `fetchItems` is called inside the effect without a cleanup, so when `filter` changes the previous promise can resolve after the new one and `setItems` overwrites the fresh results with stale data, which is a race condition. You should add an `AbortController` or an ignore flag in the cleanup function.

Better:

> 🔴 If the filter changes quickly, the list can end up showing results for the old filter. Responses that arrive after a filter change need ignoring.
>
> Why: the effect has no cleanup, so an older request can resolve last and overwrite the newer results. An ignore flag or `AbortController` in the cleanup fixes it.

**Style pass.** Check every comment, the final one included, before handing it over and fix failures in place, without mentioning them:

- No em dashes outside code, commands and paths. Use a comma, full stop, colon or brackets.
- No "it's not X, it's Y" or "less X, more Y" contrasts. Say the point directly.
- No opener ("Good catch", "Great question") and no closing recap.
- Plain words over tell-words: delve, robust, seamless, crucial, comprehensive, leverage (say "use"), ensure (say "make sure", or cut it).
- Don't force groups of three. At most one hedge per sentence, and none on a claim you've verified.
- Leave quoted text, code and identifiers as they are.
- The one opener allowed is LGTM, at the start of a ✅ final comment.
- No technical jargon: regression, edge case, race condition, idempotent, side effect, refactor. Say what happens instead.
- No sentence that only describes what the code does.
- No "we", "you", "let's" or "could we", except in a ❓ that confirms product behaviour.
- Every comment starts with its emoji and has a `Why:` note under it.

## 6. Approval trade-off (per PR, in the report)

For each PR, answer three questions in one short line each, based on the actual diff. Use a table when there are several PRs (columns: PR, Cost, If it's wrong, What I get back).

- **Cost:** what approving takes from the user. How much they had to read or understand, anything they're vouching for without having verified it (CI, a manual test, the matching implementation), and anything they now co-own.
- **If it's wrong:** what breaks and for whom, how visible it is (crash, wrong data, hidden row, test-only), and how easy it is to undo (revert one PR, fix forward, or a stacked PR has to come out with it). Say so plainly when the blast radius is small.
- **What I get back:** the concrete payoff. A bug fix users feel, parity with another implementation, tests that protect later work, unblocking the next PR in the stack, or less code to maintain.

Keep it to three lines per PR, with no hedging. If a PR is refactor-only with tests, say that the risk is low and why.

## 7. Final comment (always)

One paste-ready comment per PR, whatever the verdict, at the end of the section 5 report.

- Open with the verdict emoji (✅, ⚠️ or ❌).
- ✅ OK to merge: "✅ LGTM", then add one or both, briefly: the payoff in plain words if users or developers will notice it (for example "users get the new behaviour now, nice!"), or a one-line restatement of what the PR does, to show the change was understood.
- ⚠️ Merge after fix or ❌ Not yet: no LGTM. One or two sentences on what has to change before it can merge, pointing to the inline comments. Restate what the PR does if that helps.
- Keep every comment to one or two short sentences. Plain, natural English, no filler, no AI attribution.
- Describe the change exactly as the diff shows it. A new property on an existing event isn't a "new event". When the user's wording and the diff disagree, follow the diff and flag the difference outside the comment.
- LGTM is the expected opening, so vary only what comes after it. Don't reuse the same wording or sentence pattern across PRs.
- Only praise something that matters to a reader. Don't call out things with no visible effect (for example "now read-only") unless you can say why it helps in a few words.
- Its `Why:` note says in a line why you gave that verdict.
- Run the style pass from "Writing comments" on it.

## 8. Summary (when asked)

One line on what the set of PRs does overall, then one bullet per PR: what changed and where (module, platform or service), and whether it's a refactor, a behaviour change, or tests. Short enough to answer "what was in those PRs?" in a meeting.

## Rules

- Use one simple command per Bash call. No `cd`, loops, `$(...)` or `2>/dev/null`.
- Don't edit this skill's files or offer to, while running it. If the skill got something wrong, say what in one line; the user changes it in the skill's source repo.
