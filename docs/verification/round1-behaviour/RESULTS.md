# Round 1: blind three-arm behaviour test (v0.3)

## Setup
- **Fixtures:** 3 hidden fixtures, written by an independent agent that never saw the skills (answers in a separate directory):
  - `debug-guard-trap`: the obvious guard fix hides a stale-cache root cause.
  - `verify-trap`: tests pass, but the real CLI ignores `--format json`.
  - `safe-change`: a rename that looks risky but is safe, with grep decoys.
- **Arms:**
  - **none:** no guidance.
  - **placebo:** a generic "be careful" guide of matched length (462–490 words vs 425–502).
  - **real:** the C-Skills skill (`diagnose`, `prove-it` or `blast-radius`).
- **Runs:** 2 per arm per fixture (18 total), each in an isolated copy.
- **Judge:** a blind agent that never saw the key, the skills or the placebos. It re-ran every fix and repro itself and scored each run 0–10: outcome (5), executed evidence (3), calibration (2).

## Results

| Fixture | none | placebo | real |
|---|---|---|---|
| debug-guard-trap | 9, 10 | 10, 10 | 10, 10 |
| verify-trap | 9, 9 | 10, 10 | 10, 9 |
| safe-change | 7, 8 | 6, 6 | 7, 8 |

- All 18 runs had the correct outcome or found the key fact, proved it by running code, and did not overclaim.

## Conclusion

**No measurable outcome gain from the real skills over no skill or the placebo, on a strong model, on tasks of this size.**

This matches the public r/ClaudeAI placebo test of `diagnosing-bugs` (61.8 / 61.8 / 62.6). Despite being designed as traps, the fixtures did not trip the baseline; the judge flagged both debug fixtures as too easy.

What the skills did change, visible in the reports but not in scores:
- a consistent report shape (verdict line, evidence levels, "unverified" section);
- stricter behaviour around commits, pushes and production;
- explicit sizing to the task.

Their value is therefore consistency, safety rails and fit with the user's workflow, **not** making a strong model smarter. The README states this.

**Not tested:** weaker or faster models, long multi-hour tasks, or context-pressured sessions, where process scaffolding is more likely to matter. These are future work.

The judge's notes on fixture quality are in `judge-notes.md`. The `safe-change` ground truth was ambiguous about the `legacy_csv` decoy, so all arms lost points there equally.
