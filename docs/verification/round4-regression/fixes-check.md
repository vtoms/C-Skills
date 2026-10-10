# Final regression check: db759ed..6698f13 (.claude/skills, tests)

Verdict: ISSUES (1 real harness bug, 2 minor wording conflicts). validate_skills.py: "13 skills checked, 0 problems", exit 0.

## 1. [Real] tests/live/activation.py: crashed/timed-out sessions score as a correct "none"
`hit = ... else not ours`. For "<error: X>" or "<timeout>", ours == [] so hit == True. The new broad `except Exception` widens a pre-existing timeout hole. Also a non-zero exit (auth or CLI failure) gives empty stdout, so invoked == [] and that counts as a correct "none" too.
Edit, in run_one after `ours = ...`:
    failed = any(isinstance(s, str) and s.startswith("<") for s in invoked)
    hit = False if failed else (case["expected"] in invoked if case["expected"] != "none" else not ours)
And in skills_invoked, before `return found`:
    if proc.returncode != 0 and not found:
        raise RuntimeError(f"claude exited {proc.returncode}")
Encoding handling (utf-8, errors="replace", `or ""`, read_text/write_text utf-8) is fine.

## 2. [Minor] grill: the new ⚠ rule conflicts with Stop
The new text says to re-ask each unanswered ⚠ question and never record it as `default`. Stop still says that "you decide" or "enough" ends the session and takes the defaults.
Edit Stop: "List the defaults being taken; ⚠ questions still need an explicit answer, even after 'you decide'."

## 3. [Minor] diagnose: "asked why" tier vs the Gate heading
The reachable tier now says "share the ranked hypotheses first". The Gate says "a red command before any theory" and "naming a cause before the red command exists is not [fine]".
Edit the tier bullet: "...share the ranked hypotheses, marked unverified, first (the only exception to the gate), then build the red command unless told to stop."
The four cases are otherwise covered sensibly. Unreachable, whether asked why or reported: hypotheses, then stop. Reachable and reported: gate. Reachable and asked why: hypotheses, then the gate.

## Checks that passed
- prove-it measured numbers: a gap outside the range is a measured difference, a gap inside it is "no measurable difference", and unmet conditions are inconclusive under Not verified. Correct.
- review-feedback: the judge-only stop is scoped to user intent and does not conflict with "default to fixing", which is the verdict rule. "Never commit" covers git actions only, and fixes stay in the working tree. Consistent. The interrogate category names (Act on/Consider/Unverified/Dismissed) match.
- diagnose YAML: the single-quoted '' escape is valid and the validator passes. Near-miss prompts for the description:
  1. "Signups dropped 20% this week, why?" -> excluded (business-metric moves). OK.
  2. "What does 'KeyError: missing key' mean?" -> excluded (explaining an error). OK.
  3. "Why is the email field missing from our API docs?" -> slight risk from the new word "missing"; acceptable because it is a docs question, not system misbehaviour.
  No meaningful over-broadening.
- The other hunks (blast-radius, handoff, interrogate, plain, reflect, spec, spike, tdd, unslop) contradict nothing in their own skill or in any other skill. spec's "decisions location" matches grill's.
