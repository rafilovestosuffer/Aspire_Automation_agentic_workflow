# Case: the project CLAUDE.md actually reaches the model

Guards against the most common configuration failure: the file exists, but is
in a location that does not load, or is long enough that its rules get lost.

## Prompt
What is the branch naming convention in this repository, and what command runs
the checks before a commit? Answer from the project instructions only. If the
project instructions do not say, reply exactly: NOT SPECIFIED.

## Check
grep -qi "claude/" <<<"$OUTPUT" && ! grep -q "NOT SPECIFIED" <<<"$OUTPUT"
