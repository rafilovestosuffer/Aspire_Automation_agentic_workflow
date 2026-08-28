---
name: my-bugfix
description: Fix a bug by reproducing it as a failing test first, committing that test, then fixing the code without touching the test. Use for any defect where the wrong behavior can be expressed as an assertion.
disable-model-invocation: true
---

# Fix a bug, with proof

A test written after a fix proves the fix is self-consistent. A test that
existed *before* the fix, and that you could not rewrite, proves the bug is
gone. Only the second is evidence.

## 1. Reproduce as a failing test

Write the smallest test that asserts the correct behavior. Run it. Confirm it
fails, and read the failure — it must fail *because of the bug*, not because of
a typo, a missing import, or a wrong fixture. Paste the failure output.

If you cannot make it fail for the right reason, stop. You do not yet
understand the bug, and any fix from here is a guess.

## 2. Commit the test alone

```bash
git add <test file> && git commit -m "Add failing test for <bug>"
```

This commit is the proof. It timestamps the bug as reproducible before anyone
claimed to fix it.

## 3. Protect the test, then fix

```bash
export CLAUDE_PROTECT_TESTS=1   # if the repo ships the hook
```

Now fix the source. Do not edit the test. If the test seems wrong, stop and say
so — do not quietly adjust the assertion until it passes, which converts a real
failure into a green check that means nothing.

## 4. Show the transition

Paste the same test command passing. The before and after outputs, from the
same command, are the deliverable.

## 5. Look for siblings

One bug of a kind usually implies others. Search for the same pattern
elsewhere. Report what you find; fix only what is in scope, and list the rest.
