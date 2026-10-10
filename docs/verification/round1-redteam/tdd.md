# Red-team: .claude/skills/tdd/SKILL.md

File reviewed: /home/user/C-Skills/.claude/skills/tdd/SKILL.md (33 lines). No other files read.

## A. IDENTIFICATION

The description (L3) has two triggers:
- (T1) explicit: "user asks for TDD, red-green-refactor, or test-first". This is precise.
- (T2) implicit: "or when building logic with clear, specifiable behaviour such as parsers, calculations, or state machines". This is broad. Nearly every feature has behaviour you can specify, and the three examples act as keyword magnets ("parser", "calculation", "state").

The description has no exclusions. The body's exclusions (L8: glue code, UI wiring, exploratory work, "mandatory TDD everywhere is ceremony") only become visible after the skill has loaded. That means they cannot stop a bad load. They can only turn it into a wasted load, or into "load and ignore".

### A1. 10 prompts that SHOULD trigger (wording differs from the description)

| # | Prompt | Triggers? | Why |
|---|---|---|---|
| 1 | "Let's do this test-driven: Roman numeral -> int converter." | Yes | "test-driven" is close enough to TDD/test-first. |
| 2 | "Write the failing spec first, then implement the cron-expression parser." | Yes | Matches both T1 and T2 ("parser"). |
| 3 | "Implement 2026 UK income-tax bands; I want the tests to drive the design." | Yes | T2 (calculation) plus the intent of T1. |
| 4 | "Build the order lifecycle: pending -> paid -> shipped -> refunded, with illegal transitions rejected. Tests leading." | Yes | State machine. |
| 5 | "Add a semver range matcher to utils, red/green please." | Probably | "red/green" is not literally "red-green-refactor", but the model should map it. |
| 6 | "Bowling-score kata." | Weak | "kata" implies TDD, but nothing in the description says so. Likely miss. |
| 7 | "Implement Luhn checksum validation for card numbers (spec attached)." | Yes, via T2 | Correct: pure, well specified, high-risk logic. |
| 8 | "Write a tokenizer for our query mini-language; here are 12 input/output examples." | Probably | "tokenizer" is near "parser". The examples make the behaviour specifiable. |
| 9 | "Implement a token-bucket rate limiter with an injectable clock." | Maybe | Has state and calculation, but uses none of the description's words. Coin flip. |
| 10 | "Spec below for discount stacking: exclusive coupons block others, cap at 50%. Build it so each rule is pinned by a test." | Yes | Clear spec plus a request for tests. |

Net: T1 and T2 together catch the real cases well. The misses (6, 9) are low-cost.

### A2. 10 near-misses that should NOT trigger

| # | Prompt | Triggers? | Correct? | Why |
|---|---|---|---|---|
| 1 | "Make the submit button blue and right-align it." | No | Yes | No test or logic keywords. |
| 2 | "Add unit tests for the existing invoice module." | Likely | No | Tests plus "calculations" (invoices). The body breaks here: Red (L17) cannot fail, because the code already exists. Nothing in the description excludes it. |
| 3 | "test_parse_date is failing in CI, figure out why." | Likely | No | "parse" plus "test". This belongs to a debugging flow. The description does not exclude it. |
| 4 | "Bump eslint and set tsconfig target to ES2022." | No | Yes | Config only. |
| 5 | "Add a /health endpoint that returns 200 and the git SHA." | Possible | No | Its behaviour is trivially "clear and specifiable", so T2 matches. The body (L8) calls this glue. |
| 6 | "Add a CSV export button to the reports page." | Possible | No | A CSV writer looks like parser/serializer logic, but the task is UI plus glue. |
| 7 | "Refactor the date parser into smaller functions, no behaviour change." | Likely | No | "parser" matches. The Red step makes no sense for a pure refactor. |
| 8 | "Quick throwaway script to sum these numbers from the logs." | Possible | No | "calculations" matches. The body says exploratory work is out. |
| 9 | "Wire the Stripe webhook to update order status." | Possible | No | "status" sounds like a state machine, but this is boundary glue. |
| 10 | "What's the difference between TDD and BDD?" | Likely | No | "user asks for TDD" fires on a conceptual question. It loads a workflow when the user wanted an answer. |

Net: about 6 of 10 near-misses risk a false trigger, mostly through T2's keyword examples and the absence of any "Not for" clause. That confirms the concern: T2 over-triggers on ordinary feature work, which is anything with a computation or a parse step.

### A3. Auto-invocation

Auto-invocation is right. Users who want TDD often don't say "TDD", and T2 has real value for pure logic. But T2 should be narrowed to *new*, *self-contained* logic with a *precise spec*, and the description needs explicit exclusions. Tests for existing code, debugging failing tests, refactors, UI/glue/config, and prototypes should be named, mirroring L8.

### A4. Proposed frontmatter (description is about 450 chars)

```yaml
---
name: tdd
description: Test-first (TDD) loop in vertical slices - agree seams, list behaviours, then one failing test and the minimum code to pass it, repeated per behaviour. Use when the user asks for TDD, test-first, red-green-refactor or tests that drive new code, or when writing new self-contained logic with a precise spec (parser, calculation, state machine). Not for adding tests to existing code, debugging failing tests, refactors, UI/glue/config changes, or prototypes.
---
```

## B. FUNCTIONING (cited lines)

1. **Impossible Red step on new code (L17).** "see it fail for the right reason (an assertion, not an import or syntax error)". On the first test for a new unit, the symbol does not exist. In Python/JS that is an import error; in TS/Go/Rust/Java it is a compile error. Read literally, the skill forbids the only failure you can get. The fix is a stub with the final signature that returns a wrong value or throws "not implemented", but the skill never says so. Adding that stub also conflicts with the spirit of L18 ("least code").
2. **No handling for a test that passes immediately (L17).** By slice 3 or 4, earlier code often already satisfies the next behaviour. The skill gives no instruction: keep it, verify it can fail, or delete it. A literal reader may "fix" this by writing the test wrong so it fails, which is the opposite of the point.
3. **No stop condition (L19).** "Tick it off; next behaviour." has no "done when". Nothing says to finish when the list is empty, run the full suite, hand off to prove-it, or report what was covered and deferred. L13 makes the list revisable ("revise it as slices teach me things"), so the loop can grow without bound.
4. **Refactor placement is ambiguous (L21).** It sits outside the numbered loop, so it is unclear whether it happens per slice or once at the end. "re-run everything" with a slow suite is unscoped. The loop also never says to run the whole suite after Green, only the one test.
5. **"Refactor only on green" blocks creating seams in legacy code (L21 vs L12).** When no seam exists, you must refactor (extract a pure function, inject a dependency) before any test can exist. With no tests there is no green, so a literal reading forbids the move that creates the seam. Nothing covers characterization tests.
6. **No test-runner discovery or setup.** Phase 1 never establishes how to run one test or whether a framework exists. If none exists, should the agent install one (a new dependency, which needs consent) or stop? Nothing says.
7. **The seam-confirmation gate is vague (L12).** "Confirm with the user if present". In Claude Code the user is nominally always present, so read literally this is a mandatory round-trip even for a 20-line parser. That is the ceremony L8 warns against. "If present" should mean "if the seams aren't obvious or the user asked to be consulted".
8. **"reading the DB instead of the interface" vs "Mocks only at system boundaries" (L32, L27).** For a repository or persistence function, the DB write is the observable behaviour, and an integration test against a real or test DB is legitimate. The anti-pattern as written could push the agent to mock the DB (allowed at a boundary) when a real-DB test would be better. A minor ambiguity.
9. **Green has no triangulation guidance (L18).** "least code that passes" plus "No speculative parameters", read literally, produces `return 5400` for the first duration test. That is fine as fake-it, but nothing says the next test must force generalisation. The agent may either over-build or stay fake. One line ("let the next test force the generalisation") fixes it.
10. **Description/body conflict.** The description (T2) says to use it for "logic with clear, specifiable behaviour" without qualification. The body (L8) immediately narrows it and points to prove-it. The model therefore loads the skill and then the body tells it to leave. The exclusions belong in the description.
11. **Dangling dependency (L8).** `prove-it` is referenced by name. The skill is not self-contained if that skill is absent, though acceptable within this repo.
12. Nothing on bug-fix TDD (write a reproducing test first). That is plausibly intentional (another skill owns it), but the description doesn't hand off, so "fix this bug with TDD" lands here with no guidance.

Ceremony check: Phase 1 is short. The only real ceremony risk is the L12 confirm gate (item 7).

## C. Simulations

### C1. Ideal: Python plus pytest, "TDD a parse_duration('1h30m') -> seconds"
- The skill triggers via T1 and T2. Good.
- Phase 1 seam: `parse_duration(s: str) -> int`, raising ValueError. The L12 confirm gate is a pointless pause here. Behaviour list: parses_seconds, parses_minutes, parses_combined_units, rejects_empty, rejects_unknown_unit.
- Red 1: `from durations import parse_duration` fails with ImportError. L17 says that is the wrong reason, and there is no guidance. A sensible agent writes a stub `raise NotImplementedError`. That still isn't an assertion failure; it needs `return -1` or `pytest.raises` semantics. **Break point 1: the agent improvises.**
- Green 1: `return int(s[:-1])`. Fine.
- Slice 3 (combined): forces a regex. Fine.
- Slice 4 (rejects_empty): `int('')` already raises ValueError, so the test passes immediately. **Break point 2: no instruction (B2).**
- After slice 5: there is no stop rule, so the agent may keep inventing behaviours (L13) or stop silently without a full-suite run or summary. **Break point 3 (B3).**
- Outcome: works, thanks to model common sense. Three gaps get papered over.

### C2. Edge: legacy Node, no test framework, "add exclusive-coupon rule to checkout()"
- `checkout.js` is 600 lines and calls `db.query` and `stripe.charges.create` directly. `package.json` has no test script and no test dependencies.
- Trigger: T2 (calculation) fires. Arguably correct, because the discount logic is pure.
- Phase 1: there is no runner. The skill has no step for this. Installing vitest adds a dependency without consent. **Break 1 (B6).**
- Seam: the natural seam is a new pure `computeDiscount(cart, coupons)`. Extracting it from `checkout()` is a refactor with no green suite, which L21 forbids. The alternative is to test through `checkout()`, mocking `db` and `stripe` (permitted by L27 as boundaries). That means module-mocking a direct import, and the observable outcome is a DB row plus a Stripe call, which L32 discourages asserting on. **Break 2 (B5, B8): the skill pulls both ways and offers no characterization-test path.**
- If the agent extracts the function anyway and TDDs it, the result is good. But there is no test proving `checkout()` actually calls `computeDiscount`, and no stop condition or prove-it handoff ensures the integration is verified. **Break 3.**
- Outcome: the skill gives no usable guidance at the hardest point. The result depends entirely on the model's judgment.

## D. Verdict: PASS-WITH-FIXES

The core loop is sound and concise, and the test-quality rules (L25-28) are excellent. The trigger is too broad, and the loop has an impossible first step and no exit.

Top 3 fixes, ranked:
1. **Replace the description (L3)** with the A4 text. It narrows T2 to "new self-contained logic with a precise spec" and adds "Not for adding tests to existing code, debugging failing tests, refactors, UI/glue/config changes, or prototypes."
2. **Fix Red (L17).** Replace it with: "**Red** - write one test. If the unit doesn't exist yet, add a stub with the final signature that returns a wrong value, so the failure is an assertion, not an import/compile error. If the test passes immediately, confirm it can fail (break the code briefly), then keep it or drop it and move on."
3. **Add a setup line and an exit line.**
   - At the top of Phase 1: "- **Runner** - find the command to run one test and the full suite. If there is none, propose the smallest standard runner and confirm before installing. If the code has no seam, first pin current behaviour with a characterization test at the nearest public boundary; extracting the seam is allowed once that test is green."
   - After L21: "**Done** when the behaviour list is empty: run the full suite, verify with `prove-it`, and report the seams, behaviours covered, and anything deferred."

Secondary: change L12 "Confirm with the user if present" to "Confirm only if the seams are non-obvious or the user asked to review them". Move Refactor into the loop as step 3 ("Refactor on green; re-run the suite"). Add "let the next test force the generalisation" to Green.
