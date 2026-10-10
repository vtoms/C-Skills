# tdd SKILL.md change log (427 -> 575 words, +148)

## Applied
1. Red: name the bug the test catches; write from spec so another correct impl passes. Source: superpowers writing-good-tests "name the break" gate; EvanFlow anti-tailoring check (HN dpark: tests tailored to impl); TDAD self-confirming loop (grid/tdd.md §2, §5 Edit 1).
2. Green: never edit/skip/delete a test to get green; fix a wrong test as its own step. Source: Kent Beck (agents disable/delete tests); pstack tdd "don't change tests to match wrong impl"; superpowers.
3. Refactor as numbered per-cycle step; behaviour change = new test. Source: HN EvanFlow thread (dmitry_dv "refactor is the silent casualty"), EvanFlow per-cycle refactor reversal; round2-regression noted Refactor sitting outside loop as unapplied secondary fix.
4. Done: re-read request, add behaviours for uncovered requirements; name any failing test even if not mine. Source: maxtaylor tdd-guard benchmark (TDD dropped spec features no test demanded); superpowers Verify GREEN.
5. Tests worth keeping: undefined/None check with vacuous shapes; assert what mock received; inject clock, wait-for-condition not sleep. Source: pstack principle-test-behavior (undefined check, five shapes; also left-behind.md "small principle folds"); superpowers mock rules + condition-based-waiting (flaky 60%->100%).
6. Anti-patterns: "weakening, skipping or deleting a test to get green".

## Kept
Stub rule, legacy-seam rule, description (unchanged; already scoped tight), "Not for" exclusions.

## Rejected
- Widening trigger / iron law / rationalization tables: maxtaylor benchmark 2-4x cost, no quality gain; TDAD generic TDD raised regressions 6.08%->9.94%; vanja.io rigidity critique. Scope left tight.
- "Give fakes the real response shape" and "no test-only production methods": cut to stay within ~150-word budget; lower evidence than the rest.
- Mutation checklist, test pyramid/AAA/DAMP, blind-subagent test writer, hook enforcement, horizontal failing-test phase: generic, costly, or contradicted (grid/tdd.md §7).
- "62% of LLM assertions incorrect": unverified.
