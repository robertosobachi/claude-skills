---
name: accessibility
description: Set up, audit or check a web repo's accessibility so coding agents build it in from the start instead of patching it at the end. Setup agrees the target standard and writes a standing accessibility directive into the repo's AGENTS.md or CLAUDE.md. Audit finds existing flaws, grouped by the shared component whose fix lands everywhere, and fixes them after approval. Check reviews the current diff against the directive. Rules are semantic HTML first, ARIA only as a last resort, every interactive element keyboard-operable, and native platform features over custom JavaScript. Use when starting UI work in a repo with no accessibility rules, when the user says "audit accessibility", "a11y check", "is this accessible", or runs /accessibility [setup|audit|check].
argument-hint: "[setup | audit | check]"
---

# Accessibility

Agents copy the standard the code already shows, and pick the popular approach over the native one. So accessibility has to be set before they work, not added at the end. This skill sets the rule once, cleans up what agents would otherwise copy and checks each change against it. It's web-oriented. For native mobile, agree the platform's own guidelines in Setup and follow the same steps.

## Ground rules

- Read only until the user approves. After that, edit only what was approved.
- Never stage, commit, push or post. Give the user the commands.
- The repo's CLAUDE.md, AGENTS.md and review conventions override this skill where they already cover accessibility.
- Passing this skill doesn't make a product accessible. Say so in every report, and say what still needs a person: keyboard and screen reader runs through the real flows.
- Use one simple command per Bash call. No `cd`, loops, `$(...)` or `2>/dev/null`.
- Never hard-wrap prose.
- Don't edit this skill's files or offer to, while running it. If the skill got something wrong, say what in one line; the user changes it in the skill's source repo.

## The rules

The directive Setup writes. Audit and Check apply these rules.

1. **Semantic HTML first.** Use the native element for the job: `button` for actions, `a` for navigation, a `label` for every input, headings in order, landmarks such as `main` and `nav`. A `div` or `span` with a click handler is a finding.
2. **ARIA only as a last resort.** Add a `role` or `aria-*` attribute only when no native element or attribute does the job. Wrong ARIA is worse than none: a role promises keyboard behaviour and states, so check they exist.
3. **Every interactive element is keyboard-operable.** It's reachable with Tab in a logical order, it works with the keys its native counterpart uses and its focus is visible. No `tabindex` above 0. A dialog moves focus in when it opens and returns it when it closes.
4. **Native platform features over custom JavaScript.** Use `details` and `summary` for disclosure and accordions, `dialog` with `showModal()` for modals, and the `popover` attribute for non-modal overlays such as menus and toggletips. A popover is non-modal, so don't use one where the rest of the page must be blocked. For newer features and their browser support, use Chrome's Modern Web Guidance skill if it's installed (https://developer.chrome.com/docs/modern-web-guidance/get-started). If it isn't, say in one line that it would help, and carry on.
5. **Fix it in the shared component.** Where a design system or component library exists, fix the component, not each call site.

## Mode

`setup`, `audit` or `check`. With no argument: `setup` if neither AGENTS.md nor CLAUDE.md has an accessibility section, `check` if there's an uncommitted diff, otherwise `audit`.

## Setup

1. **Requirements.** In one message, ask what the product must meet: the standard and level (WCAG 2.2 AA is a common target), the platforms (web, native mobile or both), and any rule the team or a client has already set. Don't decide which law applies; that's the team's call.
2. **Read what exists:** CLAUDE.md, AGENTS.md, the review conventions doc if there is one, the lint config (accessibility plugins such as `eslint-plugin-jsx-a11y`), the test setup (axe or similar) and the component library folder. Note which rules a tool already enforces.
3. **Draft the directive:** a short "Accessibility" section for the file the repo's agents read: AGENTS.md if it exists, CLAUDE.md otherwise. It holds the target from step 1 and the rules above, cut to what the repo needs. Where a component or check already covers a rule, add an "In <repo>:" note naming the file. Word it as mandatory ("every UI change"), not as advice ("consider").
4. **Propose enforcement** for each rule a machine can check, using tools the repo already has: a lint rule, or an axe check in the existing component or end-to-end tests. Don't install or write it; the user decides.
5. Show the directive and the file it goes in, then stop. After approval, write only that section.

## Audit

1. **Scope:** the UI source the user names, or the whole app. List the folders covered.
2. **Run the checks the repo already has** (lint with accessibility rules, axe in tests) and report the raw output. If there are none, say so.
3. **Read the code for the rules.** Search for click handlers on non-interactive elements, positive `tabindex`, `outline: none` with no replacement focus style, images without `alt`, inputs without a label, every `role=` and `aria-` use, and modals, accordions, menus and tooltips built in JavaScript. Confirm each finding against the code and cite `file:line`.
4. **Group by where the fix lands:** shared components first, each with the number of call sites its fix reaches, then one-off pages. With no design system, name the repeated pattern that should become one component. Don't build the library.
5. **Report, then stop.** One table per group: Rule | `file:line` | Problem | Fix, ordered by how many call sites each fix reaches. End with what still needs a person to test.
6. **After approval,** fix only what was approved. Run lint and the tests that cover the changed files, then hand over `git diff --stat`. Then stop.

## Check

1. Read the repo's accessibility directive. If there isn't one, say so, offer Setup and use the rules above for now.
2. Read the diff: run `git merge-base <base> HEAD`, then `git diff <merge-base>`. That covers the branch's commits and uncommitted changes to tracked files. Add untracked files from `git status --short`. The base is the parent branch for a stacked PR, otherwise the default branch from `git symbolic-ref --short refs/remotes/origin/HEAD`. If there's nothing, say there's nothing to check and stop.
3. Check each changed UI element against each rule: pass, fail (with `file:line` and the fix) or not applicable. Before suggesting new markup, look for an existing component that already does it.
4. Fix nothing yourself unless the user asks. End with the failures, most severe first.
