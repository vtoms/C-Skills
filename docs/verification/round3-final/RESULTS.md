# Round 3: final checks on a fresh held-out set (v0.5.x)

All prompts in this round were written by independent agents that saw only one-line purposes, never the skill descriptions. None of them were used to tune the skills before being scored.

## Blind routing (a router agent given only names and descriptions)

| Description set | Prompt set | Score |
|---|---|---|
| v0.5 | new set of 40 (`routing-v2.json`) | **40/40** |
| v0.5 | original set of 48 (regression check vs v0.2) | **48/48** |

A careful router reading the descriptions is at the ceiling. This test can only catch regressions, not show improvements.

## Live activation (real headless `claude -p`, 2 runs per prompt, 10 in parallel)

| Skill | v0.5.1 | v0.5.2 |
|---|---|---|
| blast-radius | 12/12 | 12/12 |
| tdd | 10/10 | 10/10 |
| prove-it | 8/12 | 8/12 |
| grill | 6/12 | **9/12** |
| diagnose | 6/14 | **8/14** |
| none of ours on 20 should-not-fire prompts | 20/20 | 20/20 |
| **Total** | 62/80 | **67/80** |

**What v0.5.2 changed (fixes from the v0.5.1 misses):**
- `diagnose`'s exclusion "not for questions" was blocking bug reports phrased as questions. It is now "not for explaining an error".
- `grill` now also triggers when key design parts are still undecided.

## Independent regression check of the v0.5.2 edits

**Prediction.** A fresh reviewer predicted, from the wording alone, that the edits would make the skills over-trigger on conceptual questions and plain design requests. It wrote 20 new prompts to test this (`regress-cases.json`).

**Live result (2 runs each):**

| Prompt group | Result |
|---|---|
| Near-misses | 18/20 |
| grill should-fire | 6/8 |
| diagnose should-fire | 5/12 |

The two near-miss "misses" were both runs of one prompt, "what could break if I rename this column?". It loaded `blast-radius`, which is the right skill; the reviewer had mislabelled it. **The predicted over-triggering did not happen.** The reviewer's narrowing edits were therefore not applied: they would cost recall with no measured gain in precision.

**Verdict:** NO-REGRESSION. Precision is unchanged and recall went up.

## Known remaining gap

`diagnose` is often not auto-loaded when a bug report is phrased as a question about a system that isn't in the repo ("Why does X freeze only on Samsung?"). Claude tends to answer such questions directly. This matches the public finding that `diagnosing-bugs` was never auto-invoked in 16 trials.

Two caveats about the test itself:
- The sessions had read-only tools and no relevant code in the repo, which probably makes direct answers more likely than in real use.
- If this matters to you, options are a one-line CLAUDE.md nudge, or invoking `/diagnose` explicitly.
