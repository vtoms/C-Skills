# Debugging and verification feedback checked against diagnose and prove-it

Sources: GitHub issues and discussions from obra/superpowers, mattpocock/skills, garrytan/gstack, EveryInc/compound-engineering-plugin, addyosmani/agent-skills, anthropics/skills, anthropics/claude-code and cursor/plugins, plus hn.json. Filtering ran with `python -I` from scripts in `analysis/` (`dv2.py`, `dv_dump.py`, `dv_hn.py`). About 170 issue titles matched. About 45 of them were read in full, along with 60 HN comments.

How reports were counted: the data has no issue authors, so I used the writing template to spot one author behind several issues. obra#2232, #2231, #2373 and #2485 share a template ("captured in a skill-observation log ... filed upstream because the plugin is version-pinned"), so they count as **one** source.

How maintainers decide: superpowers maintainers (arittr, obra) close standalone new gates as "not planned" and want transcripts plus eval evidence (obra#1502, #2145). mattpocock accepts small, one-sentence additions (#955) and agreed with the "start light" request (#578).

## 1. Clusters

| # | Cluster | Independent reports | Evidence |
|---|---|---|---|
| A | **A check that could not fail gets counted as evidence.** Examples: a green test, an empty log, or "0 matches" from a probe or edit that never took effect, or that could not detect anything | 6+ | obra/superpowers#2186 (V2 "positive control"); #2286 plus an independent second hit in its thread (shreyasramoji); mattpocock/skills#955 (BSD `sed` made no change, but the red was trusted; **maintainer accepted** a one-sentence fix); obra#2092 (the arrange step silently failed, so the test passed even with the implementation deleted); obra#2452 (the "broken stub fails" test was green before the script existed); obra#2008 and #2460 (find-polluter returned a false "clean"; **obra fixed** it) |
| B | **The repro used inputs the agent built, not the user's real failing data**, so a different bug got fixed | 3 | obra#2449 (an all-day-event fix; the user's database showed a different cause); obra#1955 item 2 (the trigger was guessed and the retry fix's tests passed, but the real cause was SSE keepalive lines); mattpocock#1149 (a local workaround passed and the remote target was never verified) |
| C | **Skill too heavy for quick questions**, or too much ceremony | 4 | mattpocock#578 (plus Super-YYQ, Ak-Surya and pongo in the thread; **maintainer agreed** it should start light); HN 48772878 (superpowers greps after every edit) |
| D | **Agent weakens or edits tests to get green** | 3 | HN 47814514, 46586118, 48000357 |
| E | **Proxy success taken as the outcome** (HTTP 200 or "launched" instead of the effect) | 3 | obra#1754; gstack#1038 (maintainer merged #2983 so it "checks final durable side effects"); EveryInc#1828 |
| F | **Subagent says "done" and is trusted** | 4 | obra#994 (merged); obra#633; mattpocock#582; HN 48000357 |
| G | **UI work marked complete without looking at it** | 3 | EveryInc#109; obra#1027; gstack#3058 |
| H | **Secrets leak in debug or verification output** | 2 (#2375 and #2460 report the same example) | obra#2375 and #2460; mattpocock#674 |
| I | **Users want verification to run without being invoked** | 1 issue with 18 reactions and 4 commenters | anthropics/claude-code#79282 |
| J | **Flaky bugs: a negative probe needs enough runs for the failure rate** | 1 source | obra#2232 and #2485 (same author) |

## 2. Status of each cluster with 2 or more reports

- **A: GAP (prove-it).** Today we only cover a check that fails: "When a check fails, suspect the check before the system" (prove-it). The nearest guard, "Re-run the original failure", applies only to fixes. It does not cover checks on new features, greps or empty logs. diagnose already covers its own case: "Run it on the unfixed code and see it fail".
- **B: GAP (diagnose).** The gate asks for a repro of "the user's exact symptom", and "replayed captured payload" is only one option on the list. Nothing makes the agent check the cause against the user's real records once they are readable.
- **C: Handled.** diagnose: "if the user only asked why, share the ranked hypotheses first, marked unverified". Its description says "Not for conceptual questions, explaining an error...". prove-it: "Text-only edits ... Skip the rest of this skill."
- **D: Handled.** prove-it: "never make a red check green by weakening, skipping, or deleting it". diagnose step 5 also requires the test to fail on the old code.
- **E: Handled.** prove-it: "Check the real thing, not a proxy" and "Use the user's path ... and check side effects."
- **F: Handled.** prove-it: "not mtimes, cached output, or a subagent's self-report (check its diff)."
- **G: Handled.** prove-it: "UI changes: if a browser tool is available ... drive the page, look at the screenshot, and check the console".
- **H: Mostly handled.** diagnose already says "show the (redacted) output". prove-it's report template asks for "<actual output>" with no redaction.

## 3. Proposed edits (the minimum)

**Edit 1: prove-it, Rules (cluster A)**

Old:
```
- **When a check fails, suspect the check before the system** - confirm I'm observing the right thing. But never make
```
New:
```
- **Suspect the check before the system** - when it fails, confirm I'm observing the right thing; when it passes or finds nothing, confirm it could have failed (it goes red on the old code or a known-bad input, and any edit or probe I made actually landed). But never make
```
Evidence: obra/superpowers#2186, #2286, #2092, #2452, #2008; mattpocock/skills#955.

**Edit 2: diagnose, "Done means" (cluster B)**

Old:
```
why the code produced the symptom and why the change stops it. If you can't, the cause isn't confirmed.
```
New:
```
why the code produced the symptom and why the change stops it. If you can't, the cause isn't confirmed. If the user's own failing records, logs, or payload are readable, check the mechanism explains them - a repro on inputs you built proves the path exists, not that it is the one the user hit.
```
Evidence: obra/superpowers#2449, #1955 (item 2), mattpocock/skills#1149.

**Edit 3 (optional, very small): prove-it, Report (cluster H)**

Old: `Failed: <claim> — <command> — <actual output>`

New: `Failed: <claim> — <command> — <actual output, secrets redacted>`

Evidence: obra/superpowers#2375 and #2460; mattpocock/skills#674.

## 4. Not worth acting on

- **I (auto-invocation):** we already meet it. prove-it has no `disable-model-invocation`. This is a point in our favour, not a gap.
- **J (sizing negative probes for flaky bugs):** only one source. diagnose already requires a "measured repro rate" and a 3× inverse repro rate for the regression check.
- **Splitting the skill so phases are revealed in order** (mattpocock#1205): one report, and it would restructure the whole skill. Our gate already forbids "naming a cause before the red command exists".
- **`git checkout` in a verification loop wipes uncommitted work** (obra#2231): one source. diagnose already sends bisect to a separate worktree.
- **Commit message taken as proof of the diff** (obra#2495), **chains of identifications carried across sessions** (obra#1502, closed as not planned) and **"grep the error string first"** (obra#1955 item 1): one report each, and "Check directly" mostly covers them.
- **Misleading error caused by a gap in a test double** (obra#2145): one report. The maintainer wants transcripts first.
- **Mobile, touch or backend-only QA** (gstack#3058, #1038, #608): tooling requests for gstack's browser stack. prove-it is already surface-neutral ("a request against the running or deployed system").
- **Bugs in another tool's bundled scripts or examples** (find-polluter, IDENTITY echo, the "ultrathink" keyword in obra#1283, pressure-test fixtures in obra#2277): we ship no scripts. The lesson about checks that cannot fail is taken into Edit 1.
