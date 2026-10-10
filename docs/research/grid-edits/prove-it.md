# prove-it edit log
Body 460 -> 645 words (+185). Description unchanged (437 chars, already meets constraints).

## Applied
1. Fresh evidence only (new rule) - verification.md E1; superpowers Iron Law; `actually`/claimproof tools catch claims made after a later edit.
2. Check directly: subagent self-report -> "check its diff" - verification.md E1; superpowers "Agent completed requires VCS diff".
3. Read all of it (exit code, pass/fail/skip, filtered run proves only its subset) - E2; superpowers gate step 3; gstack sentinel (exit code always 0).
4. Use the user's path (real entry point, side effects, dry-run flag) - E3; pstack create-verification-skill proof standards.
5. UI changes: drive page via `run` skill or Playwright, look at screenshot, check console - E4; gstack "Read the copied screenshot", CONSOLE_ERRORS; addyosmani "console clean"; Cherny/HN screenshot evidence.
6. Repo's own checks: add verify skill + built-in `run` skill; don't create a new verification skill - verification.md section 6 (built-in /run, /run-skill-generator make a parallel generator redundant); left-behind create-verification-skill row.
7. Measured numbers section (>=5 alternating runs, median+range, errors, work actually ran, else INCONCLUSIVE) - left-behind.md section 5 fold; verification.md E6; pstack benchmark-checklist Q4/Q5/Q7.
8. Report: one line per user request, `Failed:` line, verbatim blocker in Not verified, no hedges - E5; superpowers requirements checklist + red-flag words; verify-this "do not soften"; gstack Claimed Limitations.

## Kept (per round2-regression)
Size it first, ladder "push as high as is cheap" (R2), Stay safe read-only-anywhere wording (R1), never weaken a check.

## Rejected / trimmed
- Measured-numbers bullets "name the limiter", "both sides tuned", "physical-limits sanity check" (left-behind) - word budget; least load-bearing vs Q5/Q7.
- E7 description trigger words (prove/show evidence) - no live miss shown; description already passes; avoids re-testing routing.
- Red-green regression revert step - diagnose covers it (verification.md notes this).
- Iron Law caps, rationalization tables, verdict triad, artifact dirs, gstack QA workflow, Stop hook - see verification.md section 7 (overtriggering, length, overlap with ladder, out of scope).
- "A screenshot I haven't viewed is not evidence" sentence - trimmed for budget; "look at the screenshot" kept.

## Validator
prove-it: no problems. Run currently reports 1 failure in diagnose (description 531 chars) - another agent's file, not touched.
