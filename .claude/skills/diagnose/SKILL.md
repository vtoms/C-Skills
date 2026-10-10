---
name: diagnose
description: 'Finds why a specific system misbehaves when the cause is unknown. Use when the user reports or asks about a bug, including "why does X only happen on Y?" or two numbers that should match but don''t, before naming likely causes - flaky, CI-, prod- or device-only failures, regressions, crashes, hangs, wrong, missing or duplicated data, slowdowns, leaks, or a fix that failed. Not for conceptual questions, explaining an error, business-metric moves, obvious stack traces, or lint/build errors.'
when_to_use: 'Bug reports phrased as questions count, e.g. "how come the export drops rows only on Mondays?" or "the worker still gets OOM-killed after the patch - why?". Also when the system is not in this repo or cannot be run here; the skill then gives ranked hypotheses and the check that settles each.'
---

# Diagnose

## First: which tier

- **Can't reach the system from here** (no code, no environment, read-only): answer in one message - 3-5 ranked hypotheses, each with the one observation or command that would confirm or kill it. Mark them unverified, offer to build the red command given access, a log, or a capture, and stop there.
- **Can reach it:** the gate below applies. If the user only asked why, share the ranked hypotheses first, then build the red command unless told to stop.

## Gate: a red command before any theory

Produce **one command** that reproduces the user's exact symptom, run it, and show the (redacted) output. It must be:

- **red on this bug** - asserts the reported symptom, not "doesn't crash";
- **deterministic** - or, for flaky bugs, a measured repro rate raised (loop it, add stress) until it is debuggable;
- **fast and unattended.**

Cheapest first: failing test at the seam → script against a running server → CLI + fixture diff → differential run (same input through the working and failing version, config, device, or environment; diff the outputs and list every difference between the setups) → headless browser, if one is installed → replayed captured payload → `git bisect run` between known-good and known-bad states. Flaky test: also run it alone vs in the full suite; if only the suite fails, bisect the tests that run before it.

Reproduce and instrument locally or on staging; ask before touching production, shared data, or anything that sends, charges, migrates, or deploys. Run `git bisect` in a separate `git worktree`.

Reading code to find where to reproduce is fine. Editing code or naming a cause before the red command exists is not. If no loop is possible, say what was tried, list the unverified hypotheses, and ask for an environment, a captured artifact, or permission to instrument.

## Then

1. **Minimise** - cut inputs and steps one at a time until every remaining piece is needed to stay red.
2. **Hypothesise** - 3–5 ranked, each with a prediction ("if X, then changing Y turns it green"). Share them if the user is around; don't wait.
3. **Instrument** - one probe per prediction; tag temporary logs `[DBG-<4 hex>]`. Perf: record a baseline measurement (timer, profiler, query plan) first, then bisect or test one hypothesis at a time against it.
4. **All hypotheses wrong, or a fix didn't hold?** Revert any edit a refuted hypothesis motivated. After two failed fixes, write down the premise they shared and test it before writing another; after three, stop and report to the user. Otherwise shrink further (step 1) or widen the search (recent commits, dependency versions, environment differences). Don't guess-fix.
5. **Regression test before the fix**, at a seam that exercises the real failure. Run it on the unfixed code and see it fail, apply the fix (step 6), see it pass. For flaky bugs, run old and new code enough times that the old code would almost surely fail (e.g. 3× the inverse repro rate) and report both counts. No honest seam → report that as a finding.
6. **Fix the root cause** - a guard that silences the symptom is not a fix. "Fails after restart" → suspect stale state first. Grep for the same pattern; fix other instances only if they cause the same bug, and list the rest for the user.

## Done means

- The original red command is now green (report the evidence level, as in `prove-it`); the regression test fails on old code and passes on new.
- `git grep -nE --untracked "\[DBG-[0-9a-fA-F]{4}\]" -- ':(top)' ':(top,exclude).claude'` returns nothing; throwaway harnesses removed.
- The summary (and the commit message, if committing was asked for) states the confirmed mechanism in one sentence - why the code produced the symptom and why the change stops it. If you can't, the cause isn't confirmed.
