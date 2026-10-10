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

- **Check directly.** Read the actual value, query the real process, open the real file - not mtimes, cached output, or a subagent's self-report.
- **Re-run the original failure.** For a fix, run the exact repro that failed before and show it passing now.
- **Use the repo's own checks first** - its verify script, smoke test, lint, typecheck, and the tests for the touched package. If I've done the same manual check twice, propose scripting it.
- **No repro and no tests?** Write a throwaway script in a scratch directory that calls the real code and would fail on the old behaviour. Run it, keep its output, delete it afterwards.
- **When a check fails, suspect the check before the system** - confirm I'm observing the right thing. But never make a red check green by weakening, skipping, or deleting it.
- **Stay safe.** Read-only checks (GET requests, status, logs) may hit any environment. Run anything that writes locally or on staging; ask before writing to production or shared data, or anything that sends, charges, migrates, deploys, or pushes.

## Report

One line per claim, then the overall level (the lowest of them):

```
Verified: <claim> — <command or method> — <result> — level <n>
Overall: level <n>
Not verified: <what I could not check, and why>
```

Below level 4, don't write "done", "fixed", or "works" - write what was checked and what remains unproven.
