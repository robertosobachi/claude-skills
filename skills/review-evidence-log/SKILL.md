---
name: review-evidence-log
description: Set up or run a weekly, unattended performance-review evidence log (brag doc). Collects evidence of your own work, plus facts about teammates' work you saw, from Slack, GitHub, Confluence and Zoom stand-up summaries into one local markdown file, every item with a link. Read only on every source. Use when the user says "set up my review log", "run / update my review log", "performance review evidence", "brag doc", "evidence for my review", "remember that I ...", "add to my review log", or pastes a "## GitHub evidence" block.
---

# Review evidence log

The routine lives in [references/routine-template.md](references/routine-template.md). Four modes:

- **Setup**: first use, or "set up my review log". Follow section 1.
- **Run**: "update my review log", or the scheduled task firing. Follow the filled routine.
- **Merge**: the user pastes a "## GitHub evidence" block. Follow PASTE-BACK MERGE in the routine.
- **Add item**: "remember that I ...", "add to my review log: ...". Follow section 3.

For Run, Merge and Add item outside the scheduled task, get the config from the existing scheduled task's prompt, else from the conversation, and ask only for what's missing.

## 1. Setup

Ask for the config in one round of questions, with the defaults shown:

- MY_NAME, ROLE, COMPANY, TIMEZONE (IANA), REVIEW_DATE
- LOG_PATH (default `~/Documents/review-log.md`)
- GITHUB_LOGIN, GITHUB_ORG, TOKEN_PATH (default `~/.config/review-evidence-log/gh-token`, or none). Recommend a read-only fine-grained token: chosen repos only, Pull requests and Issues read-only, nothing else, file mode 600. Check TOKEN_PATH isn't in a cloud-synced folder (iCloud Desktop & Documents, Dropbox, OneDrive, Google Drive); if it is, say so and suggest the default.
- SLACK_USER_ID, SLACK_DISPLAY
- DELETES_OWN_SLACK (yes/no, and when): if yes, the scheduled run must happen before the deletion.
- ZOOM_DISPLAY_NAME, STANDUP_MEETING_TOPIC (default "Daily Standup"), STANDUP_FREQUENCY (default daily)
- ATLASSIAN_ACCOUNT_ID, CONFLUENCE_SITE, CONFLUENCE_CLOUD_ID, CONFLUENCE_SPACE_KEYS (including the user's personal space)
- TEAM (full names; Slack and GitHub handles are resolved automatically)
- SCHEDULE (default weekly Monday 08:15 local; if DELETES_OWN_SLACK, before the deletion time)

Then:

1. Check which sources are available: Slack, Atlassian/Confluence and Zoom connectors, and a GitHub token or none. Missing sources become source notes in the log, not failures. Tell the user which ones are missing in one line.
2. Check for a scheduled-task tool that starts a fresh session on this machine (Cowork scheduled tasks). The run writes LOG_PATH and reads TOKEN_PATH on local disk, so a cloud scheduler (e.g. Claude Code `/schedule` routines) can't do it: don't offer one. If there's no local scheduler, say the skill works in manual mode only. Never use an in-session cron or loop.
3. List existing scheduled tasks. If a review log task exists, offer to update it: replace its whole prompt with a freshly filled routine, reuse the old answers and ask only for fields the old prompt lacks. Never create a duplicate.
4. Fill the routine: replace every `{PLACEHOLDER}`; keep each `[If DELETES_OWN_SLACK: ...]` part, without the brackets and condition, only when that setting is yes. The scheduled run starts a fresh session, so the filled prompt must stand alone with no reference to this skill. Show it to the user and wait for their OK.
5. On OK, create the weekly task with the filled prompt, on SCHEDULE in TIMEZONE, push notifications on.
6. Create LOG_PATH with the LOG STRUCTURE if it doesn't exist, then do a first run covering the last 14 days, or from a backfill date if the user gives one. For a long backfill, older weeks go straight into monthly summaries.
7. Ask the user to trigger the task once from the scheduler now, so connector, python, curl and folder-access problems show up before the first unattended run. Matters most with DELETES_OWN_SLACK, where a failed run loses evidence for good.
8. Tell the user in one line that local scheduled tasks only run while the computer is awake and the app is open; a missed run fires on wake.

## 2. Run and Merge

Follow the filled routine. For Merge, apply PASTE-BACK MERGE, using ENTRY FORMAT, LINKS, LOG STRUCTURE and COMPACTION from the same routine.

## 3. Add item

The user describes something they did that the sources may miss (a pairing session, coaching, a 1:1 outcome).

1. Search for a link to back it: their Slack messages that day (DMs allowed for this one lookup only), Zoom meetings that day, PRs, Confluence.
2. Write one line in the right week, following ENTRY FORMAT and LINKS, with the same read-modify-write as the routine.
3. If no link exists, show the line and ask before adding it with "(no link, reported by me)". This is the only exception to the no-link rule.

## Rules

- Never write anything except LOG_PATH. Never send anything to Slack, GitHub, Confluence or Zoom.
- Don't edit this skill's files or offer to, while running it. If the skill got something wrong, say what in one line; the user changes it in the skill's source repo.
