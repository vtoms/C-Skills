---
name: diagnose
description: Disciplined loop for hard bugs, flaky failures, and performance regressions - build a red-capable repro first, then hypothesise, instrument, fix the root cause, and lock it with a regression test. Use when something is broken, throwing, failing, flaky, or slow and the cause is not already obvious.
---

# Diagnose

The repro is the skill. With a fast signal that goes red on *this* bug, the cause is found mechanically. Without one, reading code produces theories, not fixes.

## 1. Build a feedback loop (do not skip)

Get **one command** that reproduces the user's exact symptom. In rough order of preference:

1. A failing test at the seam that reaches the bug.
2. A curl/HTTP script against a running server.
3. A CLI run on a fixture input, diffed against a known-good output.
4. A headless browser script (Playwright/Chromium is installed here).
5. Replay of a captured payload or log through the code path.
6. A throwaway harness that calls the one function with real inputs.
7. A fuzz loop for "sometimes wrong" bugs; `git bisect run` for regressions between known states.

The loop is done when it is **red on this bug**, **deterministic** (or a pinned high repro rate for flaky bugs), **fast**, and runnable without a human. Show the command and its (redacted) output.

If I catch myself building a theory before this command exists, stop and go back. If no loop is possible, say so, list what I tried, and ask for access, a captured artifact, or permission to instrument.

## 2. Minimise

Cut inputs, config, and steps one at a time, re-running after each cut. Keep only what is load-bearing. Confirm the failure matches what the *user* reported, not a nearby bug.

## 3. Hypothesise

Write 3–5 ranked hypotheses, each falsifiable: "If X is the cause, changing Y makes the bug disappear." Show the list to the user if they are present; they often know which to rule out. Don't wait on them if they are away.

## 4. Instrument

One probe per prediction, one variable at a time. Prefer a debugger or REPL; otherwise targeted logs tagged with a unique prefix like `[DBG-7f3a]` so cleanup is one grep. For perf bugs, measure a baseline first and bisect; logs mislead.

## 5. Fix the root cause

- Ask "why" until the answer is a design fact, not a symptom. A null-check that silences a crash is not a fix.
- When something fails "after restart", suspect stale state (cache, lock file, config) before code.
- Grep for the same pattern elsewhere and fix every instance.
- Write the regression test **before** the fix, at a seam that exercises the real failure. Watch it fail, apply the fix, watch it pass, then re-run the original loop. If no honest seam exists, report that as a finding.

## 6. Clean up before claiming done

- Original loop is green; regression test passes.
- `grep` for the debug prefix returns nothing.
- Throwaway harnesses deleted or clearly parked.
- The commit message names the hypothesis that was correct.
