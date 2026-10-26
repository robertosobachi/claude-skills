# Seed rules

Generic rules that hold in most codebases. Use them to seed a new review conventions doc, keeping only those that fit the repo.

## Where reasoning lives

- **Put the reason for a departure in the PR description.** When the code departs from what a reader would expect by analogy (an unusual class hierarchy, one thing split in two, a less obvious naming precedent, a duration instead of a timestamp, a hardcoded value), write one sentence of reasoning in the PR description before the PR opens. Reason: the biggest driver of comment volume is a departure whose reason sits where the reviewer can't see it, such as a local plan or the author's head.
- **Keep code comments for facts the code can't show.** A comment earns its place only if not knowing the fact would cause a regression (an ordering that depends on a framework internal, a filter that covers one field name). Everything else goes in the PR description.
- **Expect unusual structure to draw a comment even when it's correct.** Write the reason down before you're asked. Two reviewers landing on the same unexplained lines means that spot needs a recorded reason.
- **Explain side effects that depend on code outside the diff.** If a write relies on a guard elsewhere, say so in the description and cover it with a test.

## Structure and naming

- **Reuse before inventing.** Check for an existing helper, module, library or sibling that already solved the problem. The nearest neighbour's convention beats a locally defensible one.
- **Use the codebase's meaning of a word,** and say so in the name when the code does something narrower.
- **Inline a private method or constant with one caller,** unless its name explains something the code doesn't.
- **Keep code readable in place.** New lines match their siblings' shape. Repos disagree on test literals (name every repeated one, or no constant that exists only for tests), so follow the repo.
- **Put a single method where its behaviour already lives,** not in a new class.
- **Give each hardcoded list one decision.**
- **Return objects, not positional tuples,** from any method whose result callers destructure.
- **Make config fail soft** to a safe default on bad input.
- **Don't add a knob nothing turns.** No env var or tunable unless deployed infrastructure actually sets it.

## Logging and jobs

- **Don't pass or log values the framework already carries** (request IDs, job IDs, the class name).
- **Give a log message something to say,** beyond the class or method name.
- **Do the work, then log it.** The main action runs on its own line, and the log call reads its result.
- **Batch a fan-out** with the job queue's batch API.
- **Say what a dry run is meant to show,** and check that it can show it.
- **Cut observability that drives no decision.**

## Tests

- **Never trim the test that answers "why does this code exist".** It's the most expensive mistake to repeat: the regression it guarded lands green, or the first review comment is exactly the question it answered.
- **Invert a test instead of deleting it** when a reviewer wants a defence removed: assert the absence of the old behaviour, so reintroducing it fails loudly.
- **Fix a badly named test instead of deleting it.** An overclaiming name is a naming bug, not a reason to lose coverage.
- **Make a test's name match exactly what it asserts.**
- **Make every assertion answer "what is this protecting against".**
- **Trim tests that restate a guarantee you already have** (the standard library, another test on the same path).
- **A green run only counts if it could have gone red.** Mutation-test every new assertion: break the code, see red, revert. Use inputs that reach the changed branch, and after a fix a reviewer asked for, break it again to check the new test fails.
- **Expect security-relevant code to draw comments on its tests** more than on its implementation.
- **Follow the house test style** in `CLAUDE.md`.

## Migrations and deploy order

- **Assume deploys aren't atomic.** New code can run before its migration, and running processes may hold an old schema. Guard every read of a new column, or ship the column in an earlier deploy.
- **Stay correct while a new column fills in,** not just alive, when it drives a decision.
- **Remove temporary guards in a follow-up PR** once the migration has run everywhere.
- **Keep unrelated schema drift and regenerated files out of the diff.**

## PR descriptions

- **Context, this PR, blast radius.** One or two sentences on the overall goal with the design doc linked inline and the base or parent PR; what this PR achieves and how it fits, with each departure in one sentence; then whether it's safe, what breaks if it's wrong, and how to roll back. Never "Part of <ticket>" in place of the goal.
- **Verify every factual claim by running it.**
- **No AI attribution and no hard-wrapped prose,** so the text pastes cleanly.

## Working the review

- **Rehearse the review before opening the PR.** Re-read the diff as a reviewer, hunting for gaps between pieces that each look right alone.
- **Comply rather than debate.** One brief counter-argument at most.
- **When complying gives up something real, write down what was lost,** in your own notes rather than the thread.
- **Verify a suggestion before accepting it,** then apply it exactly as written.
- **Check the reviewer's premise too.** They can be right about the smell and wrong about the cause.
- **Agree with the problem even when you decline the fix,** and offer the fix that works.
- **Keep replies to one to three sentences.** A simple accepted nit gets a 👍 and no reply.
- **Change the code or doc first, then point at it.** Correct an earlier wrong answer openly.
- **Track every thread to an end state:** resolved, or open and waiting on whom.
- **Fold reasoned comments into the conventions doc.**

## Pre-PR checklist seed

- [ ] Every departure has one sentence of reasoning in the description.
- [ ] No redundant code comments; existing comments untouched.
- [ ] Searched for an existing helper or sibling before writing new plumbing.
- [ ] Test literals follow the repo's convention.
- [ ] Config fails soft, and every knob is set somewhere real.
- [ ] Every trimmed test or comment was re-checked: does it answer a "why"?
- [ ] Test names match their assertions, and every new assertion was mutation-tested.
- [ ] New columns are guarded or shipped a deploy earlier; no unrelated schema drift.
- [ ] Description has context, this PR and blast radius; every claim checked by running it.
- [ ] Diff re-read as a reviewer would.
