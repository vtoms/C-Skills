# Round 4: grid-search release (v0.6.x) — final verification

Run on the user's Windows machine (Claude Code 2.1.296) after the session moved off the cloud. The live tests ran from a clean clone, so only the skills under test could load. User-level skills (graphify and others) were present too, which makes this closer to a real setup.

## What changed in v0.6

- Evidence-backed edits to all 11 skills, from a 9-agent grid search of the most-starred and trending skill repos plus community reception (`docs/research/grid/`, edit logs in `docs/research/grid-edits/`).
- New skills: `review-feedback` (auto) and `spike` (manual).
- **Round-4 regression checks** (`docs/verification/round4-regression/`): six independent checkers found real regressions, all fixed in v0.6.1. The most serious:
  - an inverted measured-numbers verdict in `prove-it`;
  - `diagnose` stopping at hypotheses even when it could reproduce the bug;
  - `review-feedback` allowing a test to be weakened.
- **v0.6.2:** a further independent check of those fixes closed three more gaps:
  - live-harness scoring that counted a crashed session as a correct "none";
  - a `grill` stop-rule conflict;
  - wording in `diagnose`'s tiers.

  A last check of v0.6.2 was clean.

## Blind routing (descriptions only)

| Prompt set | Score |
|---|---|
| v2 (40 held-out prompts) | 40/40 |
| v3 (44 new held-out prompts, including `review-feedback`) | 44/44 |

## Live activation (real headless `claude -p`, 2 runs per prompt, 6 in parallel)

Results are scored with the v0.6.2 rule: timed-out, crashed or non-zero-exit sessions are reported separately and never scored. There were none in this run.

| Skill | v2 set: v0.5.2 → v0.6.x | All sets, v0.6.x |
|---|---|---|
| diagnose | 8/14 → **14/14** | **38/38** |
| prove-it | 8/12 → **12/12** | 20/22 |
| grill | 9/12 → 11/12 | 25/30 |
| blast-radius | 12/12 → 12/12 | 24/26 |
| tdd | 10/10 → 10/10 | 20/22 |
| review-feedback (new) | — | 12/14 |
| none of ours on should-not-fire prompts | 20/20 → 20/20 | **56/56** |
| **Total** | 67/80 → **79/80** | **195/208** |

The descriptions are identical in v0.6.1 and v0.6.2; v0.6.2 changed only skill bodies and the harness. Skills load based on their descriptions, so these numbers hold for v0.6.2.

## Remaining misses, and why no further fixes

| Misses | Explanation |
|---|---|
| `prove-it` ×2, `review-feedback` ×2 | These prompts refer to earlier turns ("you told me three messages ago", "the review you ran earlier"). Each test session starts fresh, so those turns don't exist. This is a limit of the test setup. |
| `grill` ×5 | Critique-style prompts ("play devil's advocate", "poke holes", "tear it apart") got a direct critique instead of an interview. That is a reasonable response, and earlier rounds showed adding these exact phrases to the description didn't change it. |
| `tdd` ×2, `blast-radius` ×2 | One prompt each, missed in both runs. The skills were otherwise 10/12 on that set. Left as-is so the descriptions aren't tuned to held-out prompts. |

## Platform notes

The live harness now decodes subprocess output as UTF-8. On Windows the default ANSI code page crashed the first run partway through; its 59-session partial log is kept in `round4-regression/`.

## v0.7: feedback-mining round

**Sources.** 4,142 GitHub issues (about 1,960 with full comment threads), 198 discussions, 235 skill-related Claude Code tracker issues and 973 Hacker News comments. These were collected with `tools/github/collect_feedback.py` through the signed-in GitHub CLI.

**Method.** Six analysts clustered the feedback and checked each cluster against our skills. Most clusters were already handled. Edits were made only for gaps with at least 2 independent reports, for example:
- implementing after a grill without being asked (more than 10 reports across 4 repos);
- a passing or empty check that could never have failed (6 or more);
- fixes that broke the code's dependents (3 or more);
- stale steering text (4 or more).

**Mechanics.** Two descriptions lost `<topic>`, because claude.ai and API uploads reject XML-like tags. The validator now also checks for XML tags, `$N` argument tokens (Claude Code substitutes them), literal booleans, the exact `SKILL.md` filename, an updated built-in name list, and personal-copy shadowing.

**Regression.**
- **First pass:** five independent checkers on v0.7-rc found small regressions. Examples:
  - `handoff` would have committed a transcript path containing the OS username;
  - `plain`'s CLAUDE.md offer could be confused with consent;
  - `tdd`'s stub example could pass;
  - the validator missed `$B$6` and boolean values with comments.

  All are fixed in v0.7.
- **Second pass:** a final check of those fixes came back **CLEAN**. Its one validator edge case (`true#c`) was fixed and tested against how YAML actually reads each value.

**Activation.** No auto skill's description changed in v0.7; only the two manual skills' descriptions did. So the v0.6.x live results above (195/208, 56/56 precision) still apply.
