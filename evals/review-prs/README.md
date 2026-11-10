# review-prs evals

A regression check for `skills/review-prs`. After each edit to SKILL.md, run the skill a few times on fixed cases and compare pass counts with the previous version. One run can't show whether an edit helped, because the output changes between runs.

This folder sits outside `skills/` so `install.sh` and `package.sh` don't ship it.

## What's public and what's private

- **Here (public):** the method. [checklist.md](checklist.md), `check.py`, `tooltrace.py`, `summary.py`, `new-case.sh`, `run.sh`.
- **Your private evals repo:** the cases, because they describe private PRs. Clone it on each machine and point `SKILL_EVALS_DIR` at it. Nothing here names it.

```
$SKILL_EVALS_DIR/
  repos.local                  # git-ignored: <remote URL><TAB><local clone path>, per machine
  review-prs/<case>/
    case.md                    # remote, PR, base SHA, head SHA, title, body
    expected.md                # what a good review of this case does
    guidelines/                # git-ignored standards files, at their repo paths
    case.patch                 # optional: synthetic change applied on top of head
    runs/<batch>-<skill>-<n>.md          # saved report, with a header
    runs/<batch>-<skill>-<n>.trace.jsonl # stream-json trace: every tool call and result
    runs/<batch>-<skill>-<n>.judge1.md   # judge verdicts, two passes
    runs/<batch>-<skill>-<n>.me.md       # optional: your own J1-J6 verdicts
```

Before you sync cases to a personal repo, check your employer's policy on keeping notes about their code there. If it isn't allowed, keep `SKILL_EVALS_DIR` on each machine and don't push it.

## First: smoke test

Before building any cases, check that a skill runs non-interactively in a local repo:

```
cd <some repo>
claude -p "/review-prs quick <head sha> <base sha>" --allowedTools "Bash(git:*),Read,Grep,Glob"
```

If it doesn't produce a report, the runner won't work. Adjust the flags and set them in `CLAUDE_EVAL_FLAGS`.

## Building cases

Run `new-case.sh <PR URL>` inside a clone of the PR's repo. It needs `gh`. It picks the commit the first reviewer commented on as the head and the parent of the PR's first commit as the base. It pins both under `refs/eval/<case>/`, copies `docs/plans/review-conventions.md` if present, adds the clone to `repos.local` and drafts `expected.md` from the reviewers' comments. Pass `--head <sha>` to review a different commit.

Then edit `expected.md` yourself and delete the DRAFT line. Runs skip DRAFT cases. If Claude writes the expected answers, the judge ends up grading Claude against Claude.

Sources, best first:

1. **A human comment that led to a fix.** The default head is what the reviewer saw. Keep their real blockers under "Must fix".
2. **A clean PR**, merged with no changes requested. Verdict ✅, "Must fix" empty.
3. **A repo-rule PR**: one that broke a rule in that repo's `CLAUDE.md`, `AGENTS.md` or conventions doc. Fill "Repo rules".
4. **A corrected real run.** After a real review-prs run, note what you dropped or rewrote before posting (goes under "Must not flag") and what you added that it missed (goes under "Must fix"). Make the case straight away with `--head` set to the commit you reviewed.
5. **Cross-repo.** Copy a case from repo B, write a small change that breaks a repo A rule into `case.patch`, and list that rule under "Must not flag".

Cover the skill's branches: one diff under ~50 lines, one over ~1000 lines, one stacked pair. Start with 3-5 cases. Once every skill version passes a case 3/3, retire it and replace it with a source-4 case.

## Running

```
evals/review-prs/run.sh                  # every case, 3 runs each, judged
evals/review-prs/run.sh --runs 1 app-12  # one case, one run
evals/review-prs/run.sh --no-judge       # script checks only
```

For each case it makes a detached worktree at the head, restores `guidelines/`, applies `case.patch`, runs the skill, scores it with `check.py`, runs the judge twice and removes the worktree. It ends with `summary.py`.

Each run also saves its stream-json trace. `tooltrace.py <run>.trace.jsonl` prints the tool calls, the failed ones and the retries (a failed call followed by another call to the same tool), and `summary.py` prints their medians per group. The report only shows what the skill concluded. The trace shows what it tripped over on the way: a blocked `gh`, a wrong path, an instruction that no longer matches the repo. Errors going up between two skill versions with the same pass count means the skill now works around something, so read the failed calls.

Each run's header records the machine, skill commit (`-dirty` for uncommitted SKILL.md edits), Claude Code version, model, effort and a hash of `~/.claude/CLAUDE.md`. `summary.py` only groups runs that share skill, Claude Code version, model and effort. If the CLAUDE.md hash changed between two groups, check that before blaming the skill.

Env: `CLAUDE_EVAL_MODEL`, `CLAUDE_EVAL_EFFORT`, `CLAUDE_JUDGE_MODEL`, `CLAUDE_EVAL_FLAGS`.

To compare models, run the same cases once per setting and leave the judge on its default model, so only the reviewer changes:

```
evals/review-prs/run.sh                                                   # your default
CLAUDE_EVAL_MODEL=sonnet CLAUDE_EVAL_EFFORT=medium evals/review-prs/run.sh
CLAUDE_EVAL_MODEL=sonnet CLAUDE_EVAL_EFFORT=high evals/review-prs/run.sh
```

The cheaper setting wins only if it matches the default on the judge checks.

## Checking the judge

Before trusting the judge, score the first 9 runs yourself. Write `J1: PASS` or `J1: FAIL` lines into `<run>.me.md` next to each run. `summary.py` then prints the judge's agreement with you per item. An item that disagrees with you more than once becomes a check you do by hand.

## Sanity check

Make a deliberate bad edit, such as removing the emoji rule from SKILL.md, and run once. The script pass count should drop. If it doesn't, the checks are broken.
