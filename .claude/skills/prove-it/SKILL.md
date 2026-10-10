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
- **Check directly.** Read the actual value, query the real process, open the real file - not mtimes, cached output, or a subagent's self-report (check its diff).
- **Read the whole result.** Check the exit code and the summary pass/fail/skip counts - don't infer success from a `tail` or `grep` of the log. A filtered run proves only its subset.
- **Re-run the original failure.** For a fix, run the exact repro that failed before and show it passing now.
- **Use the user's path.** Drive the real entry point, not internal setters or test-only endpoints, and check side effects. Don't trust a dry-run flag's name - observe what it skips.
- **UI changes:** if a browser tool is available (the `run` skill, or Playwright if installed - ask before installing it), drive the page, look at the screenshot, and check the console for errors. Otherwise list the UI check under "Not verified".
- **Use the repo's own checks first** - its verify script or skill, the built-in `run` skill, smoke test, lint, typecheck, and the tests for the touched package. If I've done the same manual check twice, propose scripting it, but don't create a new verification skill when one of these fits.
- **No repro and no tests?** Write a throwaway script in a scratch directory that calls the real code and would fail on the old behaviour. Run it, keep its output, delete it afterwards.
- **Suspect the check before the system** - when it fails, confirm I'm observing the right thing; when it passes or finds nothing, confirm it could have failed (red on the old code or a known-bad input, and any edit or probe I made actually landed). But never make a red check green by weakening, skipping, or deleting it. If the failure is real and its cause isn't obvious, hand off to `diagnose`.
- **Stay safe.** Read-only checks (GET requests, status, logs) may hit any environment. Run anything that writes locally or on staging; ask before writing to production or shared data, or anything that sends, charges, migrates, deploys, or pushes.

## Measured numbers

Only for speed, memory, or capacity claims: at least 5 alternating runs per side on the same machine; report median and range, count errors, and confirm the work actually ran in the timed region. A gap outside the run-to-run range is a measured difference; a gap inside it is "no measurable difference". If these conditions can't be met, report the number as inconclusive under "Not verified".

## Report

One line per thing the user asked for (re-read the request), then the overall level (the lowest of them):

```
Verified: <claim> — <command or method> — <result> — level <n>
Failed: <claim> — <command> — <actual output, secrets redacted>
Overall: level <n>
Not verified: <what I could not check> — <verbatim blocker>
```

Below level 4, don't write "done", "fixed", or "works", or hedges like "should work now" - write what was checked and what remains unproven.
