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

## Frontmatter (YAML) optimisation: identification and functioning

The frontmatter decides whether a skill is **found** (the right skill fires for the right prompt, and only then) and whether it **works** as configured (the harness parses it and applies its settings). Every skill passes both layers below before its behaviour checks count. Facts come from https://code.claude.com/docs/en/skills.md and the Agent Skills best-practices page (checked 2026-10-10).

### Layer 1: static checks (automated, `tests/validate_skills.py`, run on every change)

| Check | Why it matters |
|---|---|
| Parses as real YAML (PyYAML `safe_load`) | An unquoted `: ` inside a value is invalid YAML and can make the harness drop the skill. **This already caught two v0.1 regressions** (`plain`, `reflect`) that the earlier line-based parser missed |
| Only known fields (`name`, `description`, `when_to_use`, `argument-hint`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `effort`, `context`, `agent`, `hooks`, `paths`, `shell`) | Claude Code silently ignores unknown keys, so `disable_model_invocation` (underscores) would quietly make a manual skill auto-invocable |
| Booleans are `true`/`false` | Avoids ambiguous values |
| `name` is kebab-case, ≤64 chars, matches its folder, contains no `claude` or `anthropic`, doesn't clash with a built-in (`code-review`, `simplify`, `prototype`, …) | Invocation outside Cursor broke on names with spaces (pstack#4); name clashes hid skills (mattpocock#483, #1019) |
| Description is 40–500 chars (hard cap 1024; description + `when_to_use` ≤1536) | Claude Code truncates at 1,536 characters and drops descriptions when the listing budget (about 1% of context) runs out; short descriptions survive |
| Description is in the third person, with no I/me/my/you/your outside quoted trigger phrases and no imperative first word | The description is injected into the system prompt; best practice is third person |
| Contains a "Use when / for / at / before / after" clause | Gives the model explicit trigger conditions |
| No unsafe command patterns in the body | Security findings from the pstack audit |

### Layer 2: adversarial checks (run by independent agents)

1. **Description red-team (one agent per skill, reading only that skill's frontmatter).** It writes 10 prompts that *should* trigger the skill but avoid its listed trigger phrases, and 10 near-miss prompts that *shouldn't* trigger it. Then it rewrites the description to fix any ambiguity it found. I accept a rewrite only if it improves the routing scores in steps 2 and 3.
2. **Blind routing eval.** A separate agent writes 40 held-out prompts. A router agent sees only the 10 names and descriptions plus the built-ins (`code-review`, `simplify`, …) and picks one skill or none for each prompt. Targets: precision ≥0.9 and recall ≥0.9 per skill, with zero confusions between `interrogate`/`code-review` and `grill`/`spec`.
3. **Live activation.** At least 8 headless `claude -p` sessions per auto skill, using realistic prompts that don't name the skill. Record whether the harness actually loaded it, not whether a router *would* pick it. The r/ClaudeAI test found `diagnosing-bugs` was never auto-loaded in 16 trials. An auto skill that fires in under 50% of should-fire runs either gets a sharper description or becomes manual.
4. **Mode audit.** For each skill, an agent argues for the opposite mode: auto vs. manual (`disable-model-invocation`), and whether `user-invocable: false` or `context: fork` would fit better. Current rule: skills with side effects or high cost (`interrogate`, `handoff`, `spec`, `reflect`) stay manual; skills that should improve default behaviour (`prove-it`, `diagnose`, `blast-radius`, `tdd`, `grill`) are auto.
5. **Config functioning.** Each manual skill is invoked as `/name <args>` and the agent checks that the `argument-hint` makes sense. A test confirms a manual skill is *not* auto-loaded on a prompt that matches its description. If a skill gains `allowed-tools`, the check confirms it doesn't grant more than the skill needs; currently no skill uses it, deliberately.
6. **Listing-budget stress.** Install all 10 skills alongside a large third-party pack (e.g. mattpocock/skills) and confirm our descriptions still show in the listing and still route correctly.
7. **Cross-harness smoke test** (optional, if available). Load the skills via `npx skills add` into Codex or Pi to confirm the frontmatter is portable. Claude Code-only fields would be flagged there.

### Decisions recorded

- **`when_to_use` is not used.** Trigger phrases stay in `description` so the skills still route in harnesses that ignore Claude Code-only fields; Claude Code appends the two fields anyway.
- **No `allowed-tools`**, so skills don't widen permissions.
- **No `model` or `effort` overrides**, in response to the cost complaints about pstack's model routing.

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
| spec | Decisions with 2 open questions; a task that fits in one PR; scope that would need 10 slices | Open questions listed, not grilled; one-PR task gets a 3-line plan with no spec file; oversized scope gets a proposed split rather than 10 slices; every slice is vertical with a runnable "Done when"; nothing created externally unasked |
| reflect | A session with one real repeated mistake and two one-offs | Routes the repeated mistake to the strongest home (a test, lint rule or type over prose); ignores the one-offs |

## Cross-cutting checks

- **Placebo arm** (adopted from the r/ClaudeAI `diagnosing-bugs` test). Every behavioural comparison has three arms: no skill, a placebo skill of the same length and shape with generic advice, and the real skill. The real skill must beat the placebo, not just the no-skill run, on hidden-test scores or blind-judge ratings. Use at least 5 runs per arm.
- **Autonomous activation.** For each auto-invoked skill, run 8+ headless sessions on prompts where it should fire, without naming the skill, and record whether Claude loads it. A skill that never auto-fires either gets a better description or becomes manual-only.

- **Trigger precision and recall.** Hold out 40 prompts (written by a separate agent), including near-misses, and check that each one routes to the right skill or to none.
- **Overhead.** Compare tokens and wall-clock time against the baseline. Flag a skill if it costs more than 1.5× the baseline without a better result (this was pstack's main criticism).
- **Safety.** No skill may push, force-push, merge, run `sudo`, or install unpinned dependencies. Enforce this with `grep` in `tests/validate_skills.py`.
- **Static validity.** See the frontmatter section above.

## v0 smoke results (already run)

- **Routing:** 20 of 20 correct on the first prompt set.
- **grill:** sized the task, asked 4 questions with a recommendation each, and looked up facts itself. The baseline asked 1 question. Both noticed the cart bug.
- **interrogate:** found both breakages in the rename fixture and proved them by running code. The gaps it exposed (no fallback without a subagent tool, no non-git diffs, a "read-only" conflict) are now fixed.
- **blast-radius:** with the skill, it named the load-bearing fact, proved it false with a script ("Evidence level: 4"), and listed unverified items. The baseline also found both breakages but gave no evidence grading. The fixture is too easy to separate outcomes. One overreach: the with-skill run searched outside its assigned folder.
- **diagnose:** with the skill, it ranked 4 falsifiable hypotheses, probed `__defaults__` with a tagged log, wrote the regression test before the fix, and found an extra fact (state leaking between test functions). It took about 47 seconds against 30 seconds for the baseline. The baseline also fixed the bug and checked its tests against the old code, so the fixture is too easy. One violation: the with-skill run added a 2-line justification comment, close to what `diagnose` warns against.
