# Regression check: diagnose, prove-it (OLD d228028 vs NEW working tree)

Size: diagnose 549 -> 774 words (+41%, body +172); prove-it 463 -> 651 words (+40%, body +185). Both grew about 40%, and bloat is the top user complaint.

## diagnose: VERDICT REGRESSION (1 real, 2 minor)

### YAML
Parsed with Python yaml 6.0.3: the keys are name, description and when_to_use. The `''` escape decodes to `don't` correctly, and the `"..."` examples inside the single quotes survive. Lengths: description 495, when_to_use 292, combined 787 (limits 1024 / 1536). The prove-it edit log's "diagnose description 531 chars" validator failure is stale, because the file now measures 495.

### Regressions
R1 (real): **the tier section bypasses the red-command gate.** The tier-1 condition is "Can't reach the system from here (no code, no environment, read-only, **or the user only asked why**)". The new when_to_use deliberately pulls in bug reports phrased as questions, such as "how come the export drops rows only on Mondays?". Every one of those is a case where "the user only asked why". So when the code IS in the repo and runnable, the skill now tells the model to answer with hypotheses and "stop there". That contradicts the gate ("Editing code or naming a cause before the red command exists is not [fine]"). OLD built a repro in this case, so this behaviour is lost for exactly the prompts the edit was meant to capture.
Edit: `- **Can't reach the system from here** (its code or environment isn't available, or tools are read-only): answer in one message - ...`. In other words, drop "or the user only asked why". To keep a light path for question-only users, add: "If it is reachable but the user only asked why, give the ranked hypotheses first, then build the red command unless they say stop."

R2 (minor): "missing" was dropped from the description. OLD said "wrong or missing/duplicated data" and NEW says "wrong or duplicated data". The when_to_use "drops rows" example only partly covers it. Edit: "wrong, missing or duplicated data" (+9 chars, 504 total).

R3 (minor): "or the user only asked why" also overlaps the gate's own last paragraph ("If no loop is possible, say what was tried, list the unverified hypotheses..."). Two fallback paths now say nearly the same thing. After R1, consider dropping that gate sentence's hypothesis clause, or pointing it at the tier.

Checked, no conflict:
- Step 4 (revert refuted edits, 2/3 failed-fix budget) is consistent with step 5/6 order and "Don't guess-fix".
- The differential run and the alone-vs-suite bisect fit the cheapest-first list.
- The production guard, worktree bisect and step 5/6 order (round-2 R2) are all kept verbatim.

### Intended edits landed (6/6)
1. The description has question forms, "two numbers", "before naming likely causes" and the exclusions: **landed**.
2. when_to_use has fresh examples and the not-in-repo clause: **landed**.
3. The tier section: **landed** (but see R1).
4. The differential run and test-order pollution check: **landed**.
5. The step-4 revert and the 2/3 failed-fix rule: **landed**.
6. The one-sentence mechanism in Done means: **landed**.

### Routing prompts against NEW description + when_to_use

Should trigger:
| # | Prompt | Prediction |
|---|---|---|
| 1 | Why does checkout freeze only on Samsung phones? | fires on wording (device-only, question form); still the known live gap |
| 2 | CI fails on test_sync ~1 in 10, passes locally | fires |
| 3 | Nightly job loads 9,812 rows but the source has 10,004 - should match | fires (two numbers) |
| 4 | After upgrading to v3 the API returns duplicate events | fires |
| 5 | Bumped the pool size and we still get timeouts under load - why? | fires (a fix that did not work) |
| 6 | Save button hangs every time, no console error | fires (hangs) |
| 7 | Memory grows until the pod is OOMKilled | fires (leaks) |
| 8 | Export works in staging but returns an empty CSV in prod - why? | fires |
| 9 | Users randomly get logged out, can't reproduce | fires |
| 10 | Segfault in the parser, trace ends inside libc | likely; slight pull from the "obvious stack traces" exclusion |

Must not trigger:
| # | Prompt | Prediction |
|---|---|---|
| 1 | What is the GIL and why does it slow threads? | correct (conceptual) |
| 2 | What does ECONNRESET mean? | correct (explaining an error) |
| 3 | Why is revenue down 12% this month? | correct (business metric) |
| 4 | TypeError at app.js:42, fix it | correct (obvious stack trace) |
| 5 | ESLint no-unused-vars failures | correct |
| 6 | Review this PR for bugs | **MIS-ROUTE plausible, new**: "reports or asks about a bug" is broader than OLD |
| 7 | Why does 0.1+0.2 != 0.3 in Python? | **MIS-ROUTE plausible, new**: "why does X" plus "two numbers that should match but don't" can outweigh "conceptual" |
| 8 | How can I make this query faster? | MIS-ROUTE plausible (slowdowns; pre-existing) |
| 9 | Prod is down, roll back to v2.3 now | MIS-ROUTE plausible (prod-only; pre-existing) |
| 10 | Write a bug-report issue template for our repo | correct (low risk) |

Net: none of the three round-3 precision prompts (GIL, ECONNRESET, revenue) should mis-route, because each is now explicitly excluded. There are two new plausible leaks (6, 7), both caused by the broadened "asks about a bug" and "two numbers" wording. These need a live run.
Optional tightening: "Use when the user reports or asks about a bug **in a system they run**" and "Not for conceptual or language-semantics questions, code review, ...". Only apply it if the live run shows leaks, because it costs characters and possibly recall.

### Cleanup command test (Windows, git 2.53.0.windows.3)
I made a scratch repo at C:\Users\visha\AppData\Local\Temp\cskills-run\regression\scratch, with a .claude/skills/diagnose/SKILL.md containing the tag text.

| Case | Result |
|---|---|
| Clean tree | no output, rc=1; the `.claude` exclude works |
| Tracked modified file | caught |
| Untracked new file (upper-case hex) | caught |
| Run from a subdirectory | caught (path shown relative to cwd) |
| Staged file | caught |
| `[DBG-12]` (not 4 hex) | not matched (correct) |
| Same command from PowerShell 7 | identical results |
| Gitignored file (node_modules/x.js) | NOT caught (limitation of --untracked, unchanged from OLD; acceptable) |
| cmd.exe | fails with `fatal: ':(top)' ... outside repository`, because single quotes are literal there (not a regression; the agent's shells are Bash/PowerShell) |

Verdict: the command works.

## prove-it: VERDICT REGRESSION (1 real, 2 minor)

YAML parses (name, description). The description is unchanged from OLD and is 466 chars. The edit log says 437, which is stale and cosmetic.

### Regressions
R1 (real): **the Measured numbers logic is inverted.** "A gap inside the run-to-run range is 'no measurable difference'. Otherwise the verdict is INCONCLUSIVE." The natural reading is that a gap outside the range gives INCONCLUSIVE, which is backwards: that is the case with a real, measured difference. The intended meaning is "if the protocol can't be met, then INCONCLUSIVE". "INCONCLUSIVE" also appears nowhere in the ladder or the report format.
Edit: `Only for speed, memory, or capacity claims: at least 5 alternating runs per side on the same machine; report median and range, count errors, and confirm the work actually ran in the timed region. A gap outside the run-to-run range is a measured difference; inside it, "no measurable difference". If you can't meet this, report the claim under Not verified as inconclusive.`

R2 (minor): **the UI rule has no fallback and conflicts with "as high as is cheap".** "UI changes: drive the page (the run skill or Playwright)" is mandatory even for a one-line CSS tweak, or when no browser tool exists. diagnose says "if one is installed".
Edit: `- **UI changes:** if a browser tool is available, drive the page (the \`run\` skill or Playwright), look at the screenshot, and check the console for errors; otherwise list it under Not verified.`

R3 (minor): **"Read all of it ... not a `tail` or `grep`"** can be read as "dump the whole log into context", which works against the bloat complaint. The intent is that the conclusion comes from the exit code and the summary counts.
Edit: `- **Read the verdict, not a slice.** Check the exit code and the pass/fail/skip summary; a \`tail\` or \`grep\` can hide failures, and a filtered run proves only its subset.`

Checked, no conflict:
- "Size it first" still gates everything. Text-only edits skip all of the new rules, and "UI changes" applies to code or style, not copy.
- "Fresh evidence only" and "Use the user's path" are compatible with "Stay safe", which still governs side effects.
- Round-2 R1 (read-only anywhere) and R2 (push as high as is cheap) are kept.
- The report change from "one line per claim" to "one line per thing the user asked for" keeps the lowest-level rule.
- "Failed:" lines carry no level, so it is undefined how they affect Overall. Suggest adding: "any Failed line means the claim is not done, whatever the Overall level".

### Intended edits landed (8/8)
All eight landed: fresh evidence, subagent diff check, read all, user's path, UI changes, repo checks plus the run skill, measured numbers (with the logic bug in R1), and the report format (one line per request, Failed, verbatim blocker, no hedges). The description was intentionally unchanged.
