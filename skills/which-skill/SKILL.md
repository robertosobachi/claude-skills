---
name: which-skill
description: Suggest the skill to start the current work with, chosen from every skill available in the session.
disable-model-invocation: true
argument-hint: [task]
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/context.sh)
---

## Context

Before anything else, run `bash ${CLAUDE_SKILL_DIR}/context.sh` with Bash. It prints the installed skills and the working state.

If the call is denied or fails, don't retry it or work around it with other tools. Choose from the skills already in your context, and add one line saying user-only skills weren't checked because context.sh didn't run.

## Your task

Suggest the one skill the user should start their work with. Don't run it.

Work out what the user is about to do from the first of these that tells you:

1. `$ARGUMENTS`, if given.
2. The conversation so far.
3. The working state from context.sh, or the git status in your context. For example, uncommitted changes point to committing, open PR links point to reviewing, a clean tree at the start of a session points to new work.

Choose from the installed skills context.sh printed and the skills already listed in your context, such as built-in and plugin skills. Skills marked `disable-model-invocation: true` only run when the user types them, so context.sh is the only place they are visible to you. Ignore `which-skill` itself. Match on what each skill is for, not on shared words.

## Output

- The skill as the user would type it, e.g. `/name`, with an argument if one helps, then one line on why.
- Add the next skill only if the sequence is obvious.
- If the context is too thin to choose, ask one question instead.
- If no skill fits, say so in one line. Don't stretch a match.

Nothing else.
