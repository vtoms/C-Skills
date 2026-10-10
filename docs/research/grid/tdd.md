# Grid search: TDD / testing skills for AI coding agents (2026-10-10)

Baseline: `/home/user/C-Skills/.claude/skills/tdd/SKILL.md` (427 words, plan -> red/green loop -> done; plainly descended from mattpocock/skills `tdd`).

## 1. Landscape (stars fetched from GitHub pages 2026-10-10; gh API was blocked for these repos)

| Repo | Stars | Last commit (clone) | Testing skill(s) | Size |
|---|---|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) | ~297k | 2026-10-09 | `test-driven-development` (+ `writing-good-tests.md`), `systematic-debugging/condition-based-waiting.md`, `verification-before-completion` | 1464 + 1282 words |
| [mattpocock/skills](https://github.com/mattpocock/skills) | ~284k | 2026-10-09 | `engineering/tdd` (+ `tests.md`, `mocking.md`) | 570 + 493 words |
| [anthropics/skills](https://github.com/anthropics/skills) | ~180k | - | `webapp-testing` (Playwright + `with_server.py`; recon-then-act; wait for `networkidle`) | tool skill, not TDD |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | ~104.5k | 2026-10-10 | `test-driven-development`, `browser-testing-with-devtools`, evals fixtures for TDD | 2374 words |
| [wshobson/agents](https://github.com/wshobson/agents) | ~40.3k | - | `tdd-workflows` plugin: `tdd-orchestrator` agent + `/tdd-red`, `/tdd-green`, `/tdd-refactor`, `/tdd-cycle` | 6640 words total |
| [cursor/plugins - pstack](https://github.com/cursor/plugins/tree/main/pstack) (Lauren Tan / poteto) | (in cursor/plugins) | - | `tdd` (bug-fix only, `disable-model-invocation`), `principle-test-behavior-not-implementation` | ~500 + ~450 words |
| [nizos/tdd-guard](https://github.com/nizos/tdd-guard) | ~2.2k ([gittrend](https://gittrend.io/repo/nizos/tdd-guard)) | - | PreToolUse hook that blocks Write/Edit without a failing test; successor project w/o reporters | hook, not prose |
| [evanklem/evanflow](https://github.com/evanklem/evanflow) | HN 111 pts / 60 comments | - | `evanflow-tdd` (anti-tailoring check, per-cycle refactor) | 1187 words |
| [Go7hic/ystack](https://github.com/Go7hic/ystack) | small | - | portable copy of pstack `tdd` (+ "explain before skipping a test") | - |

Note: superpowers no longer ships a separate `testing-anti-patterns` skill; it was folded into `test-driven-development/writing-good-tests.md`.

## 2. Mechanisms extracted

### obra/superpowers `test-driven-development` + `writing-good-tests.md`
- **Iron law**: "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST. Write code before the test? Delete it. Start over ... Don't keep it as 'reference' ... Delete means delete."
- Scope: "Always: new features, bug fixes, refactoring, behavior changes" (very broad trigger: "Use when implementing any feature or bugfix").
- **Verify RED mandatory**: fails (not errors), failure message is expected, fails because feature missing.
- **Verify GREEN**: "Output pristine (no errors, warnings)"; "'Other tests' means the project's suite ... Any failure that run shows - including one you didn't cause - goes in your report by name."
- **Rationalization table** (11 rows: "too simple", "I'll test after", "deleting X hours is wasteful", "keep as reference", "TDD is dogmatic"...) + **Red Flags - STOP and start over** list.
- **Name the break gate**: "BEFORE writing the test body: Name the production change that would make this test fail. Cannot name one -> redesign ... Only intentional decisions -> change detector."
- **No change detectors** (`expect(MAX_RETRIES).toBe(5)` -> test that the 6th attempt never happens). **Don't test the framework.**
- **Mock rules**: the mock earns no assertions; learn the real method's side effects before mocking, mock one level lower; mirror complete real data structure; make doubles specific (assert args when they are the contract); production classes carry production methods only (no test-only `destroy()`); when mock setup > half the test, switch to integration.
- **Mutation check** before finishing: wrong constant/arg, wrong branch, missing side effect, empty/default return, missing validation for zero/empty/nil/unauthorized.
- **Condition-based waiting** (in systematic-debugging): replace `sleep(50)` with `waitFor(condition, description, timeout)`; poll ~10ms; always a timeout with a descriptive error; call the getter inside the loop; arbitrary delay only for timing behaviour, after waiting for the trigger, with a comment. Claimed impact: 15 flaky tests fixed, pass rate 60% -> 100%.

### mattpocock/skills `tdd`
- Seams agreed with the user before any test ("No test is written at an unconfirmed seam"), each with a one-line catches/misses note. (Our skill already has this.)
- Anti-patterns: implementation-coupled, tautological (`expect(add(a,b)).toBe(a+b)`), horizontal slicing ("Bulk tests verify imagined behavior"). Vertical slices = tracer bullets.
- "Refactoring is not part of the loop" (moved to review). Mocking: boundaries only; DI; SDK-style interfaces over generic fetchers.

### pstack `principle-test-behavior-not-implementation` and `tdd`
- **The undefined check**: "ask whether it would still pass if every function it imports returned `undefined`. If yes, it observes no behavior ... Rewrite the assertion or delete the test."
- **Five shapes that pass vacuously**: weak/no assertion (`toBeDefined`, `toBeTruthy`, `not.toThrow`, `toBeInstanceOf`, `toBeGreaterThan(0)`); mock/absence only (`toHaveBeenCalled`, `toEqual([])`, `not.toBe(wrong)`); self-referential; constant pin; fixture asserts fixture.
- Fixes: for an absence, assert presence on the other input in the same test; for a mock, assert the payload it received or state after, not that it was called.
- pstack `tdd` (bug fixes): "Prefer no new test over a bad test"; "Do not change tests merely to match a wrong implementation"; "Do not weaken existing assertions unless ..."; flaky bug -> make test deterministic and document the signal; final response names failing-before and passing-after evidence. Trigger deliberately narrow ("Use only when the user explicitly asks ... Skip when the test path is unclear, expensive").

### addyosmani/agent-skills `test-driven-development`
- **Discover the stack first** (checked-in wrappers `./gradlew`, CI workflows show the gating commands; "Never assume a default like `npm test`").
- Prove-It pattern for bugs; test pyramid 80/15/5; test sizes (small/medium/large); state not interactions; DAMP over DRY; real > fake > stub > mock; AAA; one concept per test; anti-pattern table incl. flaky tests and snapshot abuse.
- Subagent writes the reproduction test "without knowledge of the fix".
- Red flags incl. "Running the same test command twice in a row without any intervening code change" (token waste).

### wshobson/agents `tdd-workflows`
- `/tdd-red` generates "comprehensive FAILING tests" for a whole feature (happy path, edges, errors, concurrency, property) via a subagent -> i.e. **horizontal slicing**, the exact anti-pattern mattpocock/ours forbid. Gate: "do not approve if tests pass or fail for wrong reasons." 6.6k words of orchestration.

### evanflow `evanflow-tdd`
- **Anti-tailoring check** before each test: "Could I write this next test knowing only the public contract, before reading any of the impl I just wrote?" / "If a different impl satisfied the same contract, would this test still pass?" - "an internals test wearing a behavior costume."
- **Per-cycle refactor** with the fresh test as safety net (added after HN feedback); "If a refactor would change behavior, stop: that's a new test."
- Assertion-precision prompts ("mentally introduce a one-character bug"); "When in doubt about what to assert, STOP and ask the user". Cites an unverified "62% of LLM assertions incorrect" stat.

### anthropics/skills `webapp-testing`
- Black-box helper scripts ("run `--help` first, DO NOT read the source" to save context); reconnaissance-then-action; wait for `networkidle` before inspecting DOM. Relevant only as a pattern for UI verification (our `prove-it`).

### nizos/tdd-guard (enforcement via hooks)
- Blocks edits that implement without a failing test, over-implement, or add multiple tests at once. Author: "guardrails ... far more effective than simply using instructions" ([HN](https://news.ycombinator.com/item?id=44962913)).

## 3. Reception and evidence

- **Benchmark of tdd-guard** ([maxtaylor.me](https://www.maxtaylor.me/articles/i-benchmarked-tdd-guard-it-didn-t-write-better-code), [HN](https://news.ycombinator.com/item?id=49876083)): 3 projects x 3 configs (bare / rules in CLAUDE.md / hook-enforced) x 2 rounds, 54 runs, LLM judge. Bare Claude won on test quality, design and **spec adherence**; TDD configs won only on restraint. "test-first discipline can stop an agent from building something the spec asks for, if no test happens to demand it." Cost 2-4x on fresh code, ~2x extending. Instructions vs hook: little quality difference. Main benefit: consistency - TDD runs always added tests in round 2.
- **TDAD paper** ([arXiv:2603.17973](https://arxiv.org/abs/2603.17973), via [codemyspec](https://codemyspec.com/blog/agentic-testing)): on SWE-bench Verified, generic TDD instructions *raised* regressions 6.08% -> 9.94%; telling the agent *which* tests cover the touched code cut regressions ~70% (to 1.82%).
- **Kent Beck** (augmented coding / [Pragmatic Engineer](https://newsletter.pragmaticengineer.com/p/tdd-ai-agents-and-coding-with-kent); [summary](https://kentbeck.com/summaries/augmented-coding-beyond-the-vibes/)): agents disable or delete tests to get green; watch for unrequested functionality and unnecessary loops. Prompt: "find the next unmarked test and implement only enough code to pass it."
- **Simon Willison** ([red/green TDD](https://simonwillison.net/guides/agentic-engineering-patterns/red-green-tdd/)): "Use red/green TDD" is a succinct, effective prompt; confirming the test fails first is the important part.
- **HN EvanFlow thread** ([111 pts](https://news.ycombinator.com/item?id=47916909)): refactor is "the silent casualty in AI-assisted TDD ... Claude optimizes for moving to the next test" (dmitry_dv); vertical slicing can produce tests tailored to the impl (dpark); superpowers "is supposed to do this, but I've found it doesn't always" (jghn); prompts "get context rotted away", hooks enforce (conception); skeptic: agents still bad at refactor step (pydry).
- **Rigidity critique** ([vanja.io "265,000 Stars and I Don't Use Any of It"](https://vanja.io/265000-stars/)): "The full Superpowers sequence on a three-line fix is absurd." "Gates that can't be skipped are a feature on a feature and a tax on a typo." Endorses "verify with evidence".
- Others: [thoughtbot](https://thoughtbot.com/blog/prevent-the-robocalypse-with-tdd) (human commits each failing test), [alexop.dev](https://alexop.dev/posts/custom-tdd-workflow-claude-code-vue/) (separate subagents per phase so test-writer reasoning does not leak into implementer).
- **Reddit**: blocked (WebFetch refuses reddit.com). YouTube not searched in depth.

Summary: praise centres on "watch it fail" and vertical slices; complaints on rigidity, 2-4x token cost, prompt rules rotting in long contexts, refactor being skipped, tests tailored to impl, and spec features dropped because no test demanded them.

## 4. Comparison with ours

Ours already has: runner discovery, seams with catches/misses, characterization test for legacy, ordered behaviour list, fail-on-assertion + stub trick, pass-immediately check, independent expected values, mocks at boundaries, prove-it at done, horizontal-slicing/snapshot/weakening anti-patterns, narrow trigger. This is tighter and better-scoped than superpowers/addy/wshobson, and matches the evidence that broad mandatory TDD costs 2-4x without quality gain.

Gaps: (a) no "name the break"/vacuous-assertion test (pstack undefined check, superpowers gate) - our "can it fail at all" is only applied when a test passes immediately; (b) no anti-tailoring rule; (c) refactor is a floating line, not a per-cycle step; (d) no guard against editing/deleting/skipping tests to get green (only "weakening an assertion"); (e) no spec re-check at Done (benchmark's main failure); (f) mock rules lack "assert payload not call" / complete structure / no test-only production methods; (g) no async/timing rule (sleep vs wait-for-condition, injected clock).

## 5. Proposed edits (exact text)

### Edit 1 - Red: name the break + vacuous-test check (source: superpowers writing-good-tests Gate; pstack undefined check)
Replace line 17:
```
1. **Red** - write one test and run it. It must fail **on an assertion**, not on an import or syntax error. If the unit doesn't exist yet, add a stub with the final signature that returns a wrong value. If the test passes immediately, check it can fail at all; keep it only if it pins real behaviour.
```
with:
```
1. **Red** - first name the wrong behaviour this test catches; if I can't, it is not a test. Write it from the spec, not from code I've already written - a different correct implementation must pass it too. Run it. It must fail **on an assertion**, not on an import or syntax error. If the unit doesn't exist yet, add a stub with the final signature that returns a wrong value. If the test passes immediately, check it can fail at all; keep it only if it pins real behaviour.
```
Evidence: TDAD/self-confirming loop; EvanFlow anti-tailoring (HN dpark); superpowers "Cannot name one -> redesign".

### Edit 2 - Green: never edit the test to get green (source: Beck; pstack tdd guardrails; superpowers "Test fails? Fix code, not test")
Replace line 18:
```
2. **Green** - the least code that passes. No speculative parameters.
```
with:
```
2. **Green** - the least code that passes. No speculative parameters. Never edit, skip or delete a test to get green; if the test itself is wrong, say so and fix it as its own step.
```

### Edit 3 - Refactor per cycle (source: EvanFlow fix after HN dmitry_dv; superpowers cycle)
Replace lines 19-21:
```
3. Tick it off; next behaviour.

Refactor only on green, then re-run everything.
```
with:
```
3. **Refactor** - on green, tidy the code and test just touched, then re-run. A change in behaviour is a new test, not a refactor.
4. Tick it off; next behaviour.
```

### Edit 4 - Done: re-check spec coverage (source: maxtaylor benchmark, "TDD stops an agent building what the spec asks for if no test demands it")
Replace line 25:
```
When the list is empty: run the full suite, verify the feature through its real entry point (the `prove-it` skill), and report what is covered and what was deferred.
```
with:
```
When the list is empty: re-read the request and add a behaviour for any requirement no test covers. Then run the full suite, verify the feature through its real entry point (the `prove-it` skill), and report what is covered and what was deferred, naming any failing test even if I didn't cause it.
```
("naming any failing test" from superpowers Verify GREEN.)

### Edit 5 - Tests worth keeping: vacuous assertions, mock payloads, time (sources: pstack five shapes; superpowers mock rules + condition-based waiting)
Replace lines 30-31:
```
- Expected values from an independent source - a worked example, the spec, a known-good literal. Never recompute them the way the code does (`expect(add(a,b)).toBe(a+b)` cannot fail).
- Mocks only at system boundaries (network, clock, filesystem, randomness).
```
with:
```
- Expected values from an independent source - a worked example, the spec, a known-good literal. Never recompute them the way the code does (`expect(add(a,b)).toBe(a+b)` cannot fail). A test that would still pass if the code returned `undefined` (`toBeDefined`, `toBeTruthy`, `not.toThrow`, only `toHaveBeenCalled`) tests nothing.
- Mocks only at system boundaries (network, clock, filesystem, randomness). Assert what the mock received, not that it was called; give fakes the real response shape.
- Time and async: inject the clock; wait for a condition with a timeout, never a fixed sleep.
```

### Edit 6 (optional) - Anti-patterns line
Replace line 36 with:
```
Writing all test code before any implementation · testing private methods or reading the DB instead of the interface · unread snapshots · weakening, skipping or deleting a test to get green · methods added to production code only for tests.
```

Net cost: ~+120 words (427 -> ~550), still smallest of the field except pstack.

## 6. New skill?

**condition-based-waiting as its own skill: no.** It is one rule ("wait for the condition with a timeout; sleep only for timing behaviour, commented"); folded into Edit 5, and `diagnose` already owns flaky failures (it could take the same line in its fix step).

**A `test-quality` skill: worth considering (moderate).** Our `tdd` explicitly excludes "adding tests to existing code", and nothing else in the repo covers writing/reviewing tests outside TDD - the most common agent testing task. pstack and superpowers both ship this as a standalone reference (`principle-test-behavior-not-implementation`, `writing-good-tests.md`). Sketch (~250 words): trigger "writing tests for existing code, reviewing or fixing a test suite, or when asked if tests are good"; contents = name-the-break, undefined check + five vacuous shapes, mutation check (wrong constant / branch / missing side effect / default return / missing validation), mock rules, condition-based waiting, "prefer no test over a bad test", characterization tests pin current behaviour (label them). Risk: trigger overlap with tdd/diagnose - keep explicit "Not for test-first new code (tdd) or failing/flaky bugs (diagnose)".

## 7. Rejected ideas

- **Iron law "delete code written before the test"** (superpowers): rigidity is the top complaint ([vanja.io](https://vanja.io/265000-stars/)); ours is only invoked when TDD is asked for, so the pressure it defends against is low; destroying user/agent work is high-cost.
- **Rationalization tables / red-flag lists** (superpowers, addy): ~300 words aimed at agents talking themselves out of TDD under an always-on trigger; our narrow trigger avoids that fight. Attention dilution.
- **Broad trigger "any feature or bugfix"** (superpowers, addy): benchmark shows 2-4x cost and no quality gain; TDAD shows generic TDD instruction raised regressions.
- **Hook enforcement** (tdd-guard): benchmark found enforcement ~= plain instructions on quality at extra cost; out of scope for a skill.
- **Horizontal "comprehensive failing tests" phase** (wshobson): contradicts vertical-slice evidence; 6.6k words.
- **Refactor outside the loop** (mattpocock): HN feedback and EvanFlow reversal favour per-cycle refactor.
- **Test pyramid percentages, test sizes, AAA, DAMP, naming advice** (addy): generic knowledge the model already has.
- **Subagent writes the test blind to the fix** (addy, alexop): good for isolation but doubles cost; maybe for `diagnose`, not here.
- **"62% of LLM assertions incorrect"** (EvanFlow): unverified citation.
- **Full mutation-check checklist in tdd**: Red-first already proves each test can fail; belongs in the test-quality skill if built.
- **TDAD test-impact graph**: valuable for regressions but a tool, not a TDD-skill rule; our Done already runs the full suite.
