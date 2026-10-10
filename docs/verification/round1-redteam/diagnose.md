# Red-team review: `.claude/skills/diagnose/SKILL.md`

Only this file was read. Line numbers refer to it.

## A. Identification (frontmatter)

Current description (line 3, about 330 chars) starts with jargon ("Repro-first loop") and a method summary. The trigger clause comes last: "Use when something is broken, throwing, failing, flaky, or slow and the cause is not already obvious."

Main problem: whether "the cause is not already obvious" can only be known after investigating, and the model is confident by default. At the moment it decides whether to load the skill, it almost always believes it can see the cause, so it skips the skill. That fits the external result (never auto-loaded in 16 headless trials). The trigger words ("broken, throwing, failing, slow") are also so generic that they match every near-miss below, so the description is both too broad on keywords and too narrow on the escape hatch.

### (1) Prompts that SHOULD trigger (none reuse the description's wording)

| # | Prompt | Would the current description trigger correctly? |
|---|---|---|
| 1 | "Checkout totals are off by a cent on some orders, can't figure out which" | Unlikely. No keyword matches ("off by a cent"), and the model will assume a float rounding fix is obvious. |
| 2 | "CI is red about 1 run in 8 on `test_sync_queue`, passes locally" | Plausible, since "flaky" is semantically close. The model may still just add a retry or sleep. |
| 3 | "The dashboard went from 300ms to 4s after last week's deploy" | Plausible ("slow"), but the model may jump straight to profiling and theory. |
| 4 | "I already tried bumping the timeout, uploads still die around 2GB" | Unlikely. A failed prior fix is the strongest signal that the cause is not obvious, and the description never mentions it. |
| 5 | "Users say they get logged out randomly, can't reproduce it myself" | Unlikely. Nothing about "random" or "can't reproduce". |
| 6 | "After restarting the worker, jobs get processed twice" | Weak. "broken" is implied but not stated. |
| 7 | "The export is missing the last record for some customers" | Unlikely. It reads as a data question, not a bug. |
| 8 | "Memory keeps creeping up until the pod gets OOMKilled overnight" | Weak. Neither "slow" nor "throwing". |
| 9 | "This worked on v2.3 and doesn't on v2.4, no idea which commit" | Unlikely. "Regression" is listed only as "performance regressions", and the bisect-shaped case isn't named. |
| 10 | "Tests pass individually but fail when run as a whole suite" | Plausible ("failing"), but the model is likely to just read the code. |

### (2) Near-misses that should NOT trigger

| # | Prompt | Would the current description decide correctly? |
|---|---|---|
| 1 | "`TypeError: cannot read 'map' of undefined` at line 42, fix it" | Risky. "throwing" matches, and only the "not obvious" clause, applied by the model, saves it. Probably OK. |
| 2 | "Why does Python raise KeyError here?" (conceptual question) | Risk of false positive on "throwing". |
| 3 | "Review this PR for bugs" | Probably correct (no symptom). |
| 4 | "How can I make this query faster?" (no regression) | False positive likely on "slow". The body's perf path assumes a regression baseline. |
| 5 | "`npm install` fails with ERESOLVE" | False positive on "failing". This is a one-line dependency fix. |
| 6 | "Fix the typo causing the build to fail" | Probably correct, because the cause is stated. |
| 7 | "Add a test for the date parser" | Correct. |
| 8 | "What does this stack trace mean?" | False positive possible ("throwing"). The user wants an explanation, not a fix loop. |
| 9 | "Lint is failing on unused imports" | False positive possible on "failing". |
| 10 | "Is O(n^2) going to be slow for 10k items?" | False positive possible on "slow". |

### (3) Summary

- **Recall:** poor. The model's own judgement ("obvious") gates the skill, and the high-signal cues are missing: a prior fix failed, can't reproduce, intermittent, "worked before", only in CI or prod, wrong output rather than a crash.
- **Precision:** mediocre. Single generic verbs match ordinary errors, questions and lint.

### (4) Is auto-invocation right?

Yes, keep it model-invocable. The skill matters most when the user doesn't know to ask for it. The trigger should be observable facts, not a judgement call. Add a self-trigger the model can notice mid-task: "or after a first fix attempt did not resolve it".

### (5) Proposed frontmatter

```yaml
---
name: diagnose
description: Debugs bugs whose cause is unknown by first building a command that reproduces the exact symptom, then fixing the root cause with a regression test that fails on the old code. Use for intermittent or flaky failures, regressions ("worked before", only in CI/prod), wrong output with no clear error, slowdowns or leaks after a change, or when a first fix attempt did not work. Not for a stack trace that points to the fix, lint/build/install errors, or questions about an error.
---
```

That is about 480 characters. Why this version:
- It is in the third person and front-loads "Debugs bugs".
- The triggers are concrete situations a model can observe.
- It includes "first fix attempt did not work", a cue the model can recognise mid-task.
- An explicit "Not for" list cuts the false positives.

## B. Functioning (body)

1. **Self-defeating done check (line 33).** `grep -r "DBG-"` from the repo root matches this SKILL.md itself (lines 26 and 33). Confirmed by running it in /home/user/C-Skills. In any repo that vendors this skill under `.claude/skills/`, the done check can never pass. Read literally, it causes either an infinite loop or a false "done". It also scans `.git`, `node_modules` and build output. Fix: `git grep -n "\[DBG-"` limited to tracked and changed files, excluding `.claude/`.
2. **Ban on reading code (line 20).** "If I'm reading code to build a theory before this command exists, stop." But writing a "failing test at the seam" (line 18) requires reading code to find the seam. Read literally, the agent stalls or writes blind tests. Fix: allow reading code to build the reproduction; forbid only editing code and stating a cause before the red command exists.
3. **Commit assumed (line 34).** "The commit message names the cause" assumes the agent commits. Claude Code's defaults say to commit only when asked. Fix: "the final report (and commit message, if committing) names the confirmed cause".
4. **Unsafe scope creep (line 27).** "Grep for the same pattern and fix every instance" invites edits across the codebase, outside the reported bug, without asking. Fix: list the other instances, fix the ones that clearly share the cause, and report the rest.
5. **"Run it against the unfixed code" (line 28) has no method.** Agents will use `git stash`, which can lose work or mix in unrelated changes. Fix: say how, e.g. write the test before applying the fix, or temporarily revert only the fix hunk.
6. **Flaky contradictions.**
   - Line 15 allows a "measured repro rate" for flaky bugs, but lines 28 and 32 demand a regression test that "fails on old code". For a race at 10%, a single run proves nothing.
   - No target rate or run count is given, and "until it is debuggable" is undefined.
   - Fix: "for flaky bugs, run N≥ enough times that the old code fails with >95% probability (e.g. 30 runs at 10%), and report the counts".
7. **Perf path is underspecified (line 26).** "Then bisect" doesn't say what (commits? code regions?). Perf belongs in the Gate: the red command should assert a threshold with noise margin over a median of k runs. The perf instruction currently sits in step 3, after the hypotheses, which contradicts the gate.
8. **Environment assumption (line 18).** "Chromium is installed" is false on many machines. Fix: "headless browser (if available)".
9. **No stop conditions.**
   - Nothing says what happens when all 3–5 hypotheses are falsified (loop back? widen? ask?).
   - There is no time or iteration budget, and no limit on how far to minimise (line 24 could minimise forever on a slow repro).
   - Fix: "If every hypothesis is falsified, return to Minimise with the new data; after two full rounds, report findings and ask."
10. **"Share them if the user is around" (line 25).** The agent cannot tell whether the user is around. Fix: "State them in your next message; don't wait for a reply."
11. **Unexplained "(redacted)" (line 12).** It doesn't say what to redact (secrets, PII?). Fix: "redact secrets and personal data".
12. **Voice shifts to first person (lines 15 and 20, "I raise", "If I'm").** This is odd in an instruction file; the agent may read "I" as the user. Use the imperative.
13. **No final report format.** No final report is defined: the repro command, root cause, evidence, test name, and leftovers. Add a 4-line report template.
14. **Body vs description.** The description promises a "regression test that fails on the old code". Line 28's "No honest seam → report that as a finding" is the escape, which is fine but should appear in Done means (line 32 currently makes it mandatory).
15. **Ceremony.** "3–5 ranked" hypotheses is wasteful when minimisation already pins the cause. Allow 1 if the minimised repro makes it evident.

## C. Simulations

### Ideal: export drops the last CSV row

The user says "export is missing the last customer for some accounts".
- **Gate:** the agent reads the exporter (technically forbidden by line 20, but needed). It writes a pytest with a fixture of 3 rows and no trailing newline, asserting 3 rows out. The test goes red.
- **Minimise:** the trailing newline alone toggles it.
- **Hypotheses:** an off-by-one in the chunked reader. Probe, confirm, fix the loop bound.
- **Regression test:** already written, red before the fix and green after.
- **Done check:** `grep -r "DBG-"` matches SKILL.md, so the literal check fails (break #1).
- **Commit:** the agent commits without being asked (break #3).
- **"Fix every instance":** it touches two other readers the user didn't mention (break #4).

Otherwise the loop works well.

### Edge: production-only race, intermittent duplicate charges

There is no prod access, and logs are pasted by the user.
- **Gate:** a loop isn't possible at first. Line 20 sends the agent to ask for an environment or artifact, which is correct.
- **Where it breaks:** it also forbids reading code to form a theory. The most useful thing the agent could offer is a code-based hypothesis (e.g. a non-idempotent retry) to guide what to capture, and that is banned.
- **Stress repro:** the agent then writes a concurrent stress test against the payment handler with a local DB and gets 3/200 duplicates. That is a measured rate, which line 15 allows.
- **After the fix:** 0/200, but nothing defines how many runs count as proof, and line 32 ("fails on old code") is binary (break #6).
- **Root-cause pressure:** line 27 says suspect stale state, which is irrelevant here. The "a guard is not a fix" rule pressures the agent to reject an idempotency key, which actually is the correct root-cause fix for at-least-once delivery. The skill doesn't help tell a guard from a fix.
- **Gaps:** there is no stop condition if the local stress never reproduces, and no instruction to report "unverified in prod".

## D. Verdict: PASS-WITH-FIXES

The core loop is sound and short, but discovery is weak, and the done check is literally unsatisfiable in this repo.

Top 3 fixes:

1. **Description.** Replace line 3 with the proposed frontmatter above, which triggers on observable cues: flaky, regression, CI/prod-only, wrong output, a first fix that failed. It also gets a "Not for" list.
2. **Line 20.** Replace with: "Reading code to find where to reproduce is fine; editing code or naming a cause before the red command exists is not. If no loop is possible, say what you tried, list unverified hypotheses, and ask for an environment, a captured artifact, or permission to instrument."
3. **Line 33 and lines 28/32.** Replace the grep with `` `git grep -n "\[DBG-" -- ':!.claude'` returns nothing ``. Add: "Flaky: run old and new code N times (enough that the old code fails with >95% probability) and report both counts. Write the regression test before applying the fix; don't use git stash."
