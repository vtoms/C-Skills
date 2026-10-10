---
name: prove-it
description: Verifies a finished change against the real artifact - runs the repro, test, app, or a request against the running or deployed system and reads the actual output - then reports an evidence level. Use before saying a bug is fixed, a feature works, or a config or deploy took effect, and when the user asks to verify, confirm, or check that something actually works (locally or on staging). Not for finding why something fails (diagnose), planning, or text-only edits.
---

# Prove it

A summary that sounds right is not evidence. Check the real thing, not a proxy.

## Size it first

- **Text-only edits** (docs, comments, copy): look at the rendered result. Skip the rest of this skill.
- **Code, config, or behaviour changes:** apply everything below.

## Evidence ladder

Push each claim as high on this list as is cheap, and say where it stopped:

1. **Asserted** - I said so.
2. **Cited** - a real `file:line` or the library's own source.
3. **Reasoned** - I walked the failure case step by step and it cannot happen.
4. **Executed** - a test or script that calls the real code and fails loudly if I'm wrong.
5. **Observed live** - reproduced in the running app, CLI, or service.

"It compiles" and "types check" are level 2 at best.

## Rules

- **Fresh evidence only.** Output from before my last edit doesn't count - re-run after the final change.
- **Check directly.** Read the actual value, query the real process, open the real file - not mtimes, cached output, or a subagent's self-report (check its diff yourself).
- **Read all of it.** Check the exit code and the pass/fail/skip counts, not a `tail` or `grep`. A filtered run (`-k`, one file) proves only that subset; say so.
- **Re-run the original failure.** For a fix, run the exact repro that failed before and show it passing now.
- **Use the user's path.** Drive the real entry point, not internal setters or test-only endpoints, and check side effects (files written, rows, messages sent). Don't trust a dry-run flag's name - observe what it skips.
- **UI changes:** drive the page (the `run` skill, or Playwright), then open the screenshot and look at it, and check the console for errors. A screenshot I haven't viewed is not evidence.
- **Use the repo's own checks first** - its verify script or skill (or the built-in `run` skill), smoke test, lint, typecheck, and the tests for the touched package. If I've done the same manual check twice, propose scripting it - don't write a new verification skill when one of these fits.
- **No repro and no tests?** Write a throwaway script in a scratch directory that calls the real code and would fail on the old behaviour. Run it, keep its output, delete it afterwards.
- **When a check fails, suspect the check before the system** - confirm I'm observing the right thing. But never make a red check green by weakening, skipping, or deleting it.
- **Stay safe.** Read-only checks (GET requests, status, logs) may hit any environment. Run anything that writes locally or on staging; ask before writing to production or shared data, or anything that sends, charges, migrates, deploys, or pushes.

## Measured numbers

Only when claiming a speedup, regression, or capacity: run each side at least 5 times, alternating, same machine and build; report median and range. Count errors and confirm the work actually ran in the timed region (awaited, iterated, written). A gap inside the run-to-run range is "no measurable difference". Missing any of this, the verdict is INCONCLUSIVE - say which check is missing.

## Report

One line per thing the user asked for (re-read the request, not just what the tests cover), then the overall level (the lowest of them):

```
Verified: <claim> — <command or method> — <result> — level <n>
Failed: <claim> — <command> — <actual output>
Overall: level <n>
Not verified: <what I could not check> — <the verbatim error or missing access>
```

Below level 4, don't write "done", "fixed", or "works", and don't hedge into them ("should work now", "probably fixed") - write what was checked and what remains unproven. Report a failure as a failure.
