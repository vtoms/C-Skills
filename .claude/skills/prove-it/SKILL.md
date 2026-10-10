---
name: prove-it
description: Verifies work against the real artifact (runs it, reads the actual value, inspects the real output) and reports an evidence level before anything is called done, fixed, or working. Use at the end of any code change, bug fix, or config change, and before claiming something works.
---

# Prove it

A summary that sounds right is not evidence. Check the real thing, not a proxy.

## Evidence ladder

Push each claim as far down this list as is cheap, and say where it stopped:

1. **Asserted** — I said so. Worth nothing alone.
2. **Cited** — a real `file:line` or the library's own source.
3. **Reasoned** — I walked the failure case step by step and it cannot happen.
4. **Executed** — a test or script that calls the real code and fails loudly if I'm wrong.
5. **Observed live** — reproduced in the running app, CLI, or service.

Most changes should reach 4. "It compiles" and "the types check" are level 2 at best.

## Rules

- **Check directly.** Read the actual value, query the real process, open the real file. Not mtimes, cached output, or a subagent's self-report.
- **Re-run the original failure.** For a fix, run the exact repro that failed before and show it passing now.
- **Run the repo's own checks.** Lint, typecheck, and the tests for the touched package, the way a contributor would.
- **Script the check when I can.** A deterministic script someone can re-run beats a one-time look. Keep it out of the commit unless the work needs an audit trail.
- **When verification fails, suspect the check first.** Make sure I'm observing the right thing before concluding the system is broken.
- **Size it to the task.** A one-line docs fix needs a glance at the rendered result, not a test harness.

## Report

End with one short block:

```
Verified: <what I checked> — <command or method> — <result>
Evidence level: <1-5>
Not verified: <anything I could not check, and why>
```

Never write "done" or "fixed" for something only at level 1–2 without saying so.
