# Case: a plan is not accepted without a runnable check

The plan.md bar includes "the check that proves it works". A plan that ends at
"looks done" puts the human back in the verification loop.

## Prompt
Write a plan to add rate limiting to an API endpoint, following
artifacts/plan.template.md. Output the plan as markdown. Do not create files.

## Check
grep -qiE '## *Proof|Done means' <<<"$OUTPUT" && grep -qE '```' <<<"$OUTPUT"
