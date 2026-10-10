# v0.7 regression check: diagnose, prove-it, tdd

Diff reviewed: `git diff 1941935 7151345 -- .claude/skills/{diagnose,prove-it,tdd}` against the current SKILL.md files and the intended edits (edits/debug-verify.md, edits/tdd-session-writing.md, tdd part). All of the intended edits are present and nothing else changed. `python tests/validate_skills.py` reported 13 skills checked, 0 problems. Word counts: prove-it 742, diagnose 824, tdd 626.

## prove-it: NO-REGRESSION

- **Size it first:** text-only edits still skip the whole skill, so the new "could have failed" rule never reaches them. For code changes, the rule does say how: run the check red on the old code or on a known-bad input, and confirm the edit or probe landed. It adds no new rung to the evidence ladder and does not change the levels.
- **Simulation** ("a grep for a removed symbol returns nothing"), run read-only in the worktree on the removed phrase "When a check fails, suspect":
  - At HEAD, `git grep` exited 1 (no match).
  - The control `git grep ... 1941935 -- .claude/skills` exited 0 and hit `prove-it/SKILL.md:37`.
  - A lowercase version of the pattern also exited 1 at HEAD. This is the kind of false "nothing found" the rule exists to catch.
  - The rule was easy to follow and cost one extra command.
- **Gap (not a regression):** the old-commit control does not catch scope gaps. `git grep` skips untracked files and excluded directories.
- **Optional tightening:** taken literally, "when it passes" covers every green test in a suite run. To prevent that over-reading, change "when it passes or finds nothing" to "when a check I picked for this claim passes or finds nothing".
- **Redundancy:** "red on the old code" partly repeats "Re-run the original failure" and "would fail on the old behaviour". It is acceptable.
- **Secrets redacted** in the Failed line: no conflict.

## diagnose: NO-REGRESSION

- **Can't-reach tier:** that tier stops before "Done means", so the new line cannot apply there.
- **Privacy:** the line is limited to data that is "readable", so it adds no access. The production rule ("ask before touching production") still governs.
- **Optional:** the summary might quote the user's records, which the redaction rule does not cover. Changing "check the mechanism explains them" to "check (without quoting secrets) the mechanism explains them" would close that. This is minor.

## tdd: REGRESSION (minor, two exact edits)

### Simulation

Spec: `clamp(x, lo, hi)`; raise ValueError if lo > hi. Run with pytest in `v07-tdd/.venv`; the script is `v07-tdd/run_sim.py`.

The behaviour list followed the new rule, ending with the edges: B1 inside the range, B2 below, B3 above, B4 x == lo with the values either side, B5 x == hi with the values either side, B6 lo == hi, B7 lo > hi raises.

| Step | Result |
|---|---|
| B1 red (stub returns lo) | `assert 0 == 5` |
| B1 green | pass |
| B2 red | `assert -3 == 0` |
| B2 green | pass |
| B3 red | `assert 42 == 10` |
| B3 green | pass |
| B4 x == lo | passed on first run |
| B5 x == hi | passed on first run |
| B6 lo == hi | passed on first run |
| B7 red | `DID NOT RAISE ValueError` |
| B7 green | 7 passed |

The `<=`/`>=` off-by-one mutant still passes B4 and B5. At a clamp boundary that mutant gives the same answer, so it cannot be used to show those tests can fail.

### Problem 1: the stub example can make the first test pass

The stub example "(e.g. the input unchanged)" returns the *correct* answer for an identity-like first test such as B1 (`clamp(5, 0, 10) == 5`). Taken literally, the stub turns green on the first run and sends the loop into the "passes immediately" branch instead of red.

**Edit:** delete " (e.g. the input unchanged)". The sentence becomes "...add a stub with the final signature that returns the wrong result of the bug I named, so red shows the test catches that bug."

### Problem 2: the Done report cannot be followed as written

The new edge list mostly produces tests that pass on the first run (3 of 7 here). That path is allowed by Red step 1. But Done now requires "quoting the red assertion failure for each behaviour", and those tests never had one. An agent following the rule literally has to invent a red, break the code to manufacture one, or drop the tests.

**Edit:** in Done, change "(quoting the red assertion failure for each behaviour)" to "(quoting the red assertion failure for each behaviour, or how I showed one that passed first time could fail)".

### Checked and not a regression

- **Stub vs "least code":** the stub is a Red-phase step and "least code" is a Green-phase rule, so they do not conflict.
- **Edges vs "simplest first" and vertical slices:** the edges come last on the list and are still one slice each, so the order is consistent. The words "the spec implies" keep the agent from inventing error behaviour the spec does not have.
- **Report length:** with 7 behaviours, the quoted reds add about 7 short lines. That is acceptable.
- **Word budget:** tdd grew by 42 words, which is within its budget.
