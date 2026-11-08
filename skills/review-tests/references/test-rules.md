# Test rules

These are the default rules. The repo's own conventions override them, and the skill says so when they disagree.

1. Readability
   1.1 Names in plain words, one shared pattern across sibling examples, and they say exactly what's asserted, nothing more and nothing less. No enum values (`push only`, not `push_only`), no code terms, no parentheticals like "(visible or silent)", no "since ..." reasons. Good example: "creates the notification, sends a visible push and no email for a push-only campaign when the user enabled promotional notifications".
   1.2 The body follows the name's order: setup in story order (the user and their settings, then the thing under test, then the action), then one assertion per claim, in the name's order.
   1.3 If the behaviour has a hidden variant (a silent or visible push, which of two messages went out, which job was enqueued), the assertions settle it, not just the name. A bare count doesn't.
   1.4 One scenario per example. Two actions guarded by two different reasons get split; two actions behind one reason can stay together.
   1.5 Comments only when the user asks: one line, simple words, on the assertion they explain, never above the example title.
   1.6 Match house patterns before inventing: check how sibling specs do it and count usages. The nearest sibling's habit wins.
2. Keeping and trimming
   2.1 Never trim the test that answers "why does this code exist". The regression it guarded lands green, or the first review comment is exactly the question it answered.
   2.2 Invert a test instead of deleting it when a defence is removed: assert the absence of the old behaviour, so reintroducing it fails loudly.
   2.3 Fix a badly named test instead of deleting it. An overclaiming name is a naming bug, not a reason to lose coverage.
   2.4 Every assertion answers "what is this protecting against".
   2.5 Trim tests that restate a guarantee you already have (the framework, the standard library, another test on the same path).
   2.6 A green run only counts if it could have gone red. Mutation-test every new assertion: break the code, see red, revert. Use inputs that reach the changed branch.
   2.7 Follow the house test style in the repo's CLAUDE.md or AGENTS.md.
