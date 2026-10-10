# Regression check: diagnose, prove-it (OLD 31d6e7e vs NEW working tree)

Both frontmatters parse as valid YAML (keys: name, description). Description lengths: diagnose 488 chars, prove-it 437 chars (were ~330 / ~300).

## diagnose — VERDICT: REGRESSION (3, all small)

### Regressions
R1. Cleanup check misses untracked files (tested). Scratch repo results:
- clean tree: no output, rc=1 (no false hit on .claude/skills/diagnose/SKILL.md) - OK
- `[DBG-a1f3]` added to a tracked file: caught - OK
- `[DBG-beef]` in a NEW untracked file: NOT caught (rc=1). `--untracked` catches it.
- Run from a subdirectory: NOT caught (git grep scopes to cwd). `:(top)` pathspecs fix it.
OLD `grep -r` caught untracked files (but false-hit the skill itself). Debug logs often live in new harness files, so this is a real loss.
Edit: `` `git grep -n --untracked "\[DBG-" -- ':(top)' ':(top,exclude).claude'` returns nothing ``
(Repo-specific note: in C-Skills itself docs/verification/round1-redteam/diagnose.md contains `\[DBG-` text and would still hit; harmless elsewhere.)

R2. Internal ordering contradiction: step 5 "Fix the root cause" comes before step 6 "Regression test before the fix ... apply the fix". A literal reader fixes first, then cannot see the test fail on unfixed code.
Edit: swap steps 5 and 6 (renumber), and start the fix step with "Then fix the root cause".

R3. Trigger lost for deterministic, locally reproducible bugs with unclear cause. OLD: "broken, throwing, failing ... cause not already obvious". NEW only lists flaky / regression / env-specific crashes / wrong data / slow. "App hangs on save every time", "segfault in the parser, the trace is inside libc", or "I bumped the timeout and uploads still die at 2GB" (round-1's recommended "first fix attempt did not work" cue was dropped) no longer match.
Edit (description): replace "crashes only on some devices or environments or not reproducible locally," with "crashes or hangs whose trace doesn't point to the fix (including device- or environment-only ones),", and append before "Not for": "or when a first fix attempt did not work."

Minor (not counted): body dropped "If the cause is obvious ... just fix it and use prove-it" hand-off; "Not for ... build errors" conflicts with "only in CI" when a build fails only in CI with no clear cause.

### Round-1 top fixes
1. Description: PARTIAL (observable cues + Not-for added; "first fix attempt failed" cue omitted).
2. Reading code allowed before red command: FIXED.
3. grep / flaky / test-before-fix: grep PARTIAL (works for tracked files only, cwd-scoped); flaky counts FIXED (3x inverse rate ~95%); test-before-fix PARTIAL (contradicts step order; git stash warning omitted).
Others: commit-only-if-asked FIXED; scope creep FIXED; Chromium FIXED; all-hypotheses-wrong loop ADDED but no budget/ask stop; first-person voice FIXED.

### Should trigger (NEW description)
1. "CI fails ~1 in 8 on test_sync_queue, passes locally" - yes
2. "Dashboard went 300ms -> 4s after last deploy" - yes
3. "App crashes on Pixel 6 only, fine on emulator" - yes
4. "Order export has duplicate rows for some customers" - yes
5. "Worked on v2.3, broken on v2.4" - yes
6. "Memory creeps up until the pod is OOMKilled" - yes (leaks)
7. "Users get logged out randomly, can't reproduce" - yes
8. "Totals in the report are off by one cent on some orders" - yes (wrong output)
9. "Save button hangs forever every time, no error" - MIS-ROUTE likely (no hang/always-reproducible cue)
10. "Bumped the timeout, uploads still fail at 2GB" - MIS-ROUTE plausible (first-fix-failed cue missing)

### Should not trigger
1. "TypeError at line 42, fix it" - correct (excluded)
2. "npm install ERESOLVE" - probably correct (build/install-ish), "install" not named
3. "Lint fails on unused imports" - correct
4. "What does this stack trace mean?" - correct (questions)
5. "How can I make this query faster?" - MIS-ROUTE plausible ("slowdowns")
6. "Why is revenue in the dashboard lower than in Stripe?" (reconciliation/data question) - MIS-ROUTE plausible ("wrong output or missing data"); "questions" exclusion helps only partly
7. "Prod is down, roll back now" (incident ops) - MIS-ROUTE plausible ("only in prod")
8. "Review this PR for bugs" - correct
9. "Add a test for the date parser" - correct
10. "This SQL returns 0 rows, is my WHERE clause wrong?" - borderline; could route to diagnose

## prove-it — VERDICT: REGRESSION (2, small)

### Regressions
R1. Safety rule blocks the newly added trigger. Description now targets "a config or deploy took effect" / "confirm it's serving", but the body says "Ask before touching production". A read-only GET against prod health/version now requires asking, so "confirm the deploy is serving" always stalls on a question.
Edit: "**Stay safe.** Read-only checks (GET, status, logs) may hit any environment. Run anything that writes locally or on staging; ask before writing to production or shared data, or anything that sends, charges, migrates, deploys, or pushes."

R2. Lost the push to climb the ladder. OLD "Push each claim as far down this list as is cheap"; NEW "Rate each claim on this list" only rates. Combined with "Below level 4 don't say done", the model can stop at level 3 and just report "not done" instead of running the cheap check.
Edit: "Push each claim as high on this list as is cheap, and say where it stopped:"

Minor: OLD "Script the check when I can" (re-runnable beats one-time look) now only applies when there's no repro/tests; "double-check"/"prove it" cue words from the round-1 proposal not included.

### Round-1 top fixes
1. Description: FIXED (dropped "any code change", added verify/confirm/staging, Not-for). End-of-work hook recommendation not addressed (outside SKILL.md).
2. Rules (throwaway script, never weaken check, stay safe): FIXED (stay-safe over-broad, see R1).
3. Per-claim report + lowest-overall + below-4 wording + text-only sizing: FIXED.

### Should trigger
1. "Is the new Redis timeout actually picked up?" - yes
2. "Confirm the fix works on staging" - yes
3. "Double-check the retry logic before I merge" - yes ("check that something works")
4. "Confirm it's serving after the deploy" - yes (then stalls per R1)
5. Model about to say "fixed" after a bug fix - yes, if recalled
6. "Did the flaky login fix hold? Run it a few times" - yes
7. "Make sure the feature flag is really off for EU" - yes
8. "Prove the migration works this time" - likely
9. "Check the Dockerfile still builds and healthcheck is green" - yes
10. "Ship the hotfix" - partial (pulls to blast-radius)

### Should not trigger
1. "What does useMemo do?" - correct
2. "Fix typo in README" - correct (text-only)
3. "Plan the auth rewrite" - correct
4. "Rename tmp to buffer" - MIS-ROUTE plausible (code change, model then claims "works")
5. "Change log level to debug in config.yaml" - MIS-ROUTE plausible ("config took effect"); arguably acceptable
6. "Does this function handle empty input?" - borderline (question vs "check that it works")
7. "Review this PR" - mostly correct
8. "Why is this test failing?" - correct-ish (diagnose)
9. "Write a design doc" - correct
10. "Is this deploy safe to ship?" - correct (blast-radius), small overlap on "deploy"
