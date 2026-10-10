---
name: diagnose
description: Debugs bugs whose cause is unknown by first building a command that reproduces the exact symptom, then fixing the root cause with a regression test that fails on the old code. Use for intermittent or flaky failures, regressions ("worked before", only in CI or prod), wrong output with no clear error, slowdowns or leaks after a change, or when a first fix attempt did not work. Not for a stack trace that points to the fix, lint/build/install errors, or questions about an error.
---

# Diagnose

## Gate: a red command before any theory

Produce **one command** that reproduces the user's exact symptom, run it, and show the (redacted) output. It must be:

- **red on this bug** - asserts the reported symptom, not "doesn't crash";
- **deterministic** - or, for flaky bugs, a measured repro rate raised (loop it, add stress) until it is debuggable;
- **fast and unattended.**

Cheapest first: failing test at the seam → script against a running server → CLI + fixture diff → headless browser, if one is installed → replayed captured payload → `git bisect run` between known-good and known-bad states.

Reading code to find where to reproduce is fine. Editing code or naming a cause before the red command exists is not. If no loop is possible, say what was tried, list the unverified hypotheses, and ask for an environment, a captured artifact, or permission to instrument.

## Then

1. **Minimise** - cut inputs and steps one at a time until every remaining piece is needed to stay red.
2. **Hypothesise** - 3–5 ranked, each with a prediction ("if X, then changing Y turns it green"). Share them if the user is around; don't wait.
3. **Instrument** - one probe per prediction; tag temporary logs `[DBG-<4 hex>]`. Perf: record a baseline measurement (timer, profiler, query plan) first, then bisect or test one hypothesis at a time against it.
4. **All hypotheses wrong?** Go back to step 1 and shrink further, or widen the search (recent commits, dependency versions, environment differences). Don't guess-fix.
5. **Fix the root cause** - a guard that silences the symptom is not a fix. "Fails after restart" → suspect stale state first. Grep for the same pattern; fix other instances only if they cause the same bug, and list the rest for the user.
6. **Regression test before the fix**, at a seam that exercises the real failure. Run it on the unfixed code and see it fail, apply the fix, see it pass. For flaky bugs, run old and new code enough times that the old code would almost surely fail (e.g. 3× the inverse repro rate) and report both counts. No honest seam → report that as a finding.

## Done means

- The original red command is now green; the regression test fails on old code and passes on new.
- `git grep -n "\[DBG-" -- ':!.claude'` returns nothing; throwaway harnesses removed.
- The summary (and the commit message, if committing was asked for) names the cause that was confirmed.
