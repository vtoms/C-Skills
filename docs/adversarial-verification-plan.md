# Adversarial verification plan

Status: **planned, to run after the Perplexity findings are folded in.** The current skills are drafts (v0).

## Order of work

1. **Perplexity research.** The user runs both prompts in `docs/perplexity-prompts.md` and pastes the results back.
2. **Polish pass.** Turn each confirmed community complaint or praise into a concrete skill edit. Every edit names the finding it answers (`docs/research-findings.md`).
3. **Independent adversarial checks** (below), one per skill.
4. **Fix and re-check** any skill that fails. A skill ships only when it passes its check.

## What "independent" means here

- **One checker per skill.** Each runs as its own subagent with fresh context and no access to this conversation, other skills' results, or my reasoning.
- **Checkers attack the skill, not my description of it.** They get only the `SKILL.md` path and the attack brief.
- **Fixtures the author never saw.** A separate subagent writes each skill's test fixtures from a short spec. I don't see them before the run, so the skills can't be tuned to the tests.
- **Judges are separate from runners.** A blind judge scores with-skill against baseline transcripts in shuffled order, labelled A and B.
- **Fixtures must be hard enough that the baseline can fail.** In the v0 runs the baseline also solved the cart and rename fixtures, so they showed process differences but not outcome differences. The v1 fixtures must include traps where the obvious answer is wrong.

## Per-skill attack briefs

| Skill | What the checker tries to break | Pass criterion |
|---|---|---|
| grill | A trivial task (should not grill), a 15-decision task (round cap), a user who says "one at a time", questions answerable from the code | Never more than 4 questions per round; no factual questions it could have looked up; writes a decision record; skips grilling on trivial tasks |
| diagnose | A bug whose obvious fix (a guard or null check) hides the root cause; a flaky bug with about 10% repro; a perf regression | Has a red-capable command before any hypothesis; fixes the root cause, not a guard; the regression test fails on the old code; no `[DBG-` left behind |
| prove-it | A "fix" that passes typecheck but fails at runtime; a stale build artifact that looks fresh | Catches both; reports the evidence level honestly; never says "done" at level 1–2 |
| blast-radius | A consumer that grep can't find (dynamic key, other language, persisted data); a change that really is safe | Finds the hidden consumer **and** clears the safe change without inventing risks; the load-bearing fact is proven by running code |
| tdd | A spec where it is tempting to write a tautological test; a pull toward mocking internal collaborators | Each test seen red for the right reason; no tautologies; mocks only at boundaries |
| interrogate | A clean diff (should produce no fabricated nits) and a diff with one subtle bug | Clean diff: no invented "Act on" items; buggy diff: the bug is in "Act on" with a failure scenario |
| handoff | A messy session with dead ends and a secret in the transcript | A fresh agent can continue from the document alone; dead ends are listed; the secret is redacted |
| plain | A dense, jargon-heavy previous message | Under 120 words, no undefined jargon, meaning kept (a judge checks it against the original) |
| reflect | A session with one real repeated mistake and two one-offs | Routes the repeated mistake to the strongest home (a test, lint rule or type over prose); ignores the one-offs |

## Cross-cutting checks

- **Trigger precision and recall.** Hold out 40 prompts (written by a separate agent), including near-misses, and check that each one routes to the right skill or to none.
- **Overhead.** Compare tokens and wall-clock time against the baseline. Flag a skill if it costs more than 1.5× the baseline without a better result (this was pstack's main criticism).
- **Safety.** No skill may push, force-push, merge, run `sudo`, or install unpinned dependencies. Enforce this with `grep` in `tests/validate_skills.py`.
- **Static validity.** `python3 tests/validate_skills.py` must pass, and the skills must show up in Claude Code's skill list.

## v0 smoke results (already run)

- **Routing:** 20 of 20 correct on the first prompt set.
- **grill:** sized the task, asked 4 questions with a recommendation each, and looked up facts itself. The baseline asked 1 question. Both noticed the cart bug.
- **interrogate:** found both breakages in the rename fixture and proved them by running code. The gaps it exposed (no fallback without a subagent tool, no non-git diffs, a "read-only" conflict) are now fixed.
- **blast-radius:** with the skill, it named the load-bearing fact, proved it false with a script ("Evidence level: 4"), and listed unverified items. The baseline also found both breakages but gave no evidence grading. The fixture is too easy to separate outcomes. One overreach: the with-skill run searched outside its assigned folder.
- **diagnose:** with the skill, it ranked 4 falsifiable hypotheses, probed `__defaults__` with a tagged log, wrote the regression test before the fix, and found an extra fact (state leaking between test functions). It took about 47 seconds against 30 seconds for the baseline. The baseline also fixed the bug and checked its tests against the old code, so the fixture is too easy. One violation: the with-skill run added a 2-line justification comment, close to what `diagnose` warns against.
