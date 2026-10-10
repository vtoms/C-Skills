---
name: diagnose
description: Repro-first loop for hard bugs, flaky failures, and performance regressions - get one command that goes red on the exact symptom before theorising, then fix the root cause and prove it with a regression test that fails on the old code. Use when something is broken, throwing, failing, flaky, or slow and the cause is not already obvious.
---

# Diagnose

If the cause is obvious from the error, just fix it and use `prove-it`. This skill is for when it isn't.

## Gate: a red command before any theory

Produce **one command** that reproduces the user's exact symptom, run it, and show the (redacted) output. It must be:

- **red on this bug** - asserts the reported symptom, not "doesn't crash";
- **deterministic** - or, for flaky bugs, a measured repro rate I raise (loop it, add stress) until it is debuggable;
- **fast and unattended.**

Cheapest first: failing test at the seam → script against a running server → CLI + fixture diff → headless browser (Chromium is installed) → replayed captured payload → `git bisect run` between known-good and bad states.

If I'm reading code to build a theory before this command exists, stop. If no loop is possible, say what I tried and ask for an environment, a captured artifact, or permission to instrument.

## Then

1. **Minimise** - cut inputs and steps one at a time until every remaining piece is needed to stay red.
2. **Hypothesise** - 3–5 ranked, each with a prediction ("if X, then changing Y turns it green"). Share them if the user is around; don't wait.
3. **Instrument** - one probe per prediction; tag temporary logs `[DBG-<4 hex>]`. Perf: baseline measurement first, then bisect.
4. **Fix the root cause** - a guard that silences the symptom is not a fix. "Fails after restart" → suspect stale state first. Grep for the same pattern and fix every instance.
5. **Regression test** at a seam that exercises the real failure. Prove it bites: run it against the unfixed code and see it fail, then pass after the fix. No honest seam → report that as a finding.

## Done means

- Original red command now green; regression test fails on old code, passes on new.
- `grep -r "DBG-"` returns nothing; throwaway harnesses removed.
- The commit message names the cause that was confirmed.
