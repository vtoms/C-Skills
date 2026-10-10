# v0.6.2 regression check (HEAD 2fbf26f vs HEAD~1)

Validator: `python tests/validate_skills.py` -> 13 skills checked, 0 problems.

## Verdict: CLEAN on logic; one housekeeping ISSUE, one caveat

### 1. diagnose - consistent
- Tier 2 now says "One exception: if the user only asked why, share ranked hypotheses first, marked unverified".
- Gate forbids "naming a cause" before the red command; unverified hypotheses are not a named cause, and the exception is explicitly labelled, so no contradiction. Gate line 26 ("list the unverified hypotheses") uses the same wording.
- Done means requires a *confirmed* mechanism; unverified hypotheses never satisfy it. Consistent.

### 2. grill - consistent
- Asking: blanket "ok" doesn't cover a warning-marked question; never record one as `default`.
- Stop: warning-marked questions still need an explicit answer even after "you decide".
- Record: `default` = via recommendation/"ok"/"you decide", so warning-marked items can only be `chosen`. All three agree.

### 3. activation.py - traces
| Case | invoked | failed | correct | verdict |
|---|---|---|---|---|
| normal "none", rc 0, no Skill | [] | False | True | OK |
| "none", timeout | ["<timeout>"] | True | None | FAILED-RUN |
| crash (e.g. FileNotFoundError) | ["<error: ...>"] | True | None | FAILED-RUN |
| rc!=0, no Skill | RuntimeError -> ["<error: RuntimeError>"] | True | None | FAILED-RUN |
| rc!=0 with Skill call | [skill,...] | False | scored | OK/MISS |

- Failed runs are never scored (correct=None); summary sums only `scored`, denominator len(scored); 0/0 prints harmlessly. The `isinstance` guard handles a None skill entry. No other place in main() treats `correct` as a bool; JSON writes null.

### Issue (exact edit)
- The commit added `tests/live/__pycache__/activation.cpython-313.pyc` (not gitignored). Fix:
  `git rm --cached -r tests/live/__pycache__`, and add `__pycache__/` and `*.pyc` to `.gitignore`.
  (`tools/reddit/__pycache__/reddit_research.cpython-313.pyc` from an earlier commit is tracked too.)

### Caveat (not a defect in the diff, unverified)
- With `--max-turns 3`, a "none" session that uses up its turns on Read/Grep may exit non-zero. It is now FAILED-RUN instead of OK. That is correct under the "never score" rule, but it can shrink the scored denominator for "none" cases, so watch the failed-run count.
