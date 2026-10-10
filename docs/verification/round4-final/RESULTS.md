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
