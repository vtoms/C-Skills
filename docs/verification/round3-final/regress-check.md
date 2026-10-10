# Regression check: diagnose + grill description edits

Validator: 11 skills checked, 0 problems (frontmatter OK).

## diagnose  ("or questions" -> "or explaining an error"; "environment"->"env"; "wrong output"->"wrong")
- REGRESSION RISK: the old blanket "questions" exclusion also blocked conceptual/general questions
  (GIL, linked-list vs array speed, "usual causes of CrashLoopBackOff", "why is revenue down").
  The new exclusion only covers explaining an error, so "why is X slow / what's causing Y" without
  any failing system of the user's now matches "slowdowns" / "wrong or missing data" unopposed.
- Minor narrowing: "wrong output" -> "wrong" reads as "wrong data" only; wrong computed results
  (e.g. off-by-a-cent totals) lose a direct cue.
- Suggested edit: "... wrong output or missing/duplicated data, ... Not for obvious stack traces,
  lint/build errors, explaining an error, or general/conceptual questions not about a failure in the user's system."

## grill  ("wants to settle decisions before building" -> "hasn't yet decided key parts of a design before building")
- REGRESSION RISK: trigger changed from user intent to a state the model infers. Nearly every
  "design me X" / "sketch a schema" / "Redis or Memcached?" request has undecided parts, so grill can
  fire when the user just wants an answer. Neighbour overlap (tdd/blast-radius/prove-it): none new.
- Suggested edit: "... or wants to work through undecided parts of a design before building.
  Not for ..., requests that just want a design or answer, ..."

Live cases: regress-cases.json (20: 6 diagnose, 4 grill, 10 none). rg-12/17/20 and rg-14/15/19 target the risks above.
