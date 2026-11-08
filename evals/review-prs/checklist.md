# review-prs checklist

Yes/no checks for one saved review-prs report. Each is taken from a rule in `skills/review-prs/SKILL.md`. When a rule there changes, change its check here.

## Script checks (`check.py`)

A comment is a quoted block (`> ...`) in the report. Its text is everything before its `Why:` line.

- **S1 verdict:** at least one verdict line: `✅ OK to merge`, `⚠️ Merge after fix` or `❌ Not yet`.
- **S2 emoji:** every comment starts with 🔴, ❓, 💡, ✅, ⚠️ or ❌.
- **S3 why:** every comment has a `Why:` note, inside the quote or within the next few lines.
- **S4 length:** every comment's text is 35 words or fewer (the skill says roughly 30).
- **S5 final comment:** at least one final comment (✅, ⚠️ or ❌) per verdict line.
- **S6 LGTM:** LGTM only appears in comments that start with ✅.
- **S7 em dash:** no em dash in comment text outside backticks.
- **S8 words:** none of the style pass's banned words in comment text outside backticks.
- **S9 suggestions:** no more than 2 💡 per verdict line.
- **S10 pronouns:** no "we", "you" or "let's" outside ❓ comments.

## Judge checks (`run.sh`, two judge runs each)

Each is answered on its own, against the case's `expected.md` and the diff.

- **J1 found:** every item under "Must fix" is raised, as 🔴 or as ❓ when it couldn't be verified.
- **J2 no invented blockers:** every 🔴 is a real blocker in the diff, and nothing under "Must not flag" is raised.
- **J3 says why:** no comment only describes what the code does.
- **J4 final comment:** each final comment describes the change as the diff shows it.
- **J5 repo rules:** every item under "Repo rules" is raised, and no comment rests on a rule that isn't listed there or in "Must fix".
- **J6 verdict:** the verdict line matches "Verdict".
- **J7 test findings:** every comment on a test file cites a test rule number in its `Why:` note, and none is 🔴 unless it's a real blocker. PASS if there are no comments on test files.

Two judge runs that disagree count as UNSURE, not PASS or FAIL.
