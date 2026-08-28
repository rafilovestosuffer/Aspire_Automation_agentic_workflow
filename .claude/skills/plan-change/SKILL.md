---
name: plan-change
description: Turn an intent or ticket into a committed spec.md and plan.md before any code is written. Use when starting a change that touches more than one file, or when the approach is not obvious.
disable-model-invocation: true
---

# Plan a change

Produce the two artifacts that make the work reviewable before it is expensive
to change. Do not edit source files during this skill.

## 1. Read the intent

Read `artifacts/intent.md` if it exists. If it does not, and the user gave you a
ticket or a paragraph, write it first from `artifacts/intent.template.md`. Ask
the user to confirm it captures what they meant before going further.

## 2. Explore in isolation

Delegate codebase investigation to subagents so the file contents land in their
context rather than yours:

> Use subagents to find every call site of X, and report which ones would need
> to change. Return paths and line numbers, not file contents.

## 3. Write spec.md

Requirements and design, written against the intent. State what is out of
scope. Flag concerns explicitly. Prefer rich references over prose: a failing
test, an existing function to follow, an HTML mockup for UI. If a reference
exists in the codebase, name it instead of describing it.

## 4. Write plan.md

Iterate until an engineer who never saw this conversation could implement the
change from the plan alone. It must name:

- every file that changes, and in what order
- the risks, and what makes each one visible if it happens
- the check that proves the work is done, as a command that returns pass or fail

If you cannot name the check, the plan is not finished.

## 5. Commit before implementing

Commit `spec.md` and `plan.md` on their own. That commit is what review will
check the diff against. Then start a fresh session to implement, so the
implementation context is clean.
