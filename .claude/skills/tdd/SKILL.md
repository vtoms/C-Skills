---
name: tdd
description: Test-first (TDD) loop, one behaviour at a time - agree seams, list behaviours, then one failing test and the minimum code to pass it. Use when the user asks for TDD, test-first, red-green-refactor, or tests that drive new code, or when writing new self-contained logic with a precise spec (parser, calculation, state machine). Not for fixing a reported bug (diagnose), adding tests to existing code, refactors, UI/glue/config changes, or prototypes.
---

# TDD

## Phase 1: plan (no test code yet)

- **Runner** - find the command that runs one test and the one that runs the suite. If there is no test setup, propose one and confirm before installing anything.
- **Seams** - the public boundaries to test at (function signature, endpoint, CLI output), each with one line on what it catches and misses. Confirm with the user if present; otherwise pick the narrowest set covering the risky logic and state it.
- **Legacy code with no seam** (when adding new logic to it) - first pin current behaviour with a characterization test; once it is green, extracting the seam is allowed.
- **Behaviour list** - a short ordered list of test *names*, simplest first, ending with the edges the spec implies (empty, each limit and the values either side, invalid input). A to-do list, not a commitment; revise it as slices teach me things.

## Phase 2: the loop, one behaviour at a time

1. **Red** - first name the bug this test would catch; if I can't, it is not a test. Write it from the spec, not from code I've already written - another correct implementation must pass it too. Run it. It must fail **on an assertion**, not on an import or syntax error. If the unit doesn't exist yet, add a stub with the final signature that returns the wrong result of the bug I named, so red shows the test catches that bug. If the test passes immediately, check it can fail at all; keep it only if it pins real behaviour.
2. **Green** - the least code that passes. No speculative parameters. Never edit, skip or delete a test to get green; if the test itself is wrong, say so and fix it as its own step.
3. **Refactor** - on green, tidy the code and test just touched, then re-run everything. A change in behaviour is a new test, not a refactor.
4. Tick it off; next behaviour.

## Done

When the list is empty: re-read the request and add a behaviour for any requirement no test covers. Then run the full suite, verify the feature through its real entry point (the `prove-it` skill), and report what is covered (quoting the red assertion failure for each behaviour, or how I showed one that passed first time could fail) and what was deferred, naming any failing test even if I didn't cause it.

## Tests worth keeping

- Behaviour through the public interface; survives an internal rewrite.
- Expected values from an independent source - a worked example, the spec, a known-good literal. Never recompute them the way the code does (`expect(add(a,b)).toBe(a+b)` cannot fail). Reject a test that would still pass if the code returned `undefined`/`None`, unless that is the specified result (only `toBeDefined`, `toBeTruthy`, `not.toThrow`).
- Mocks only at system boundaries (network, clock, filesystem, randomness). Assert what the mock received, not just that it was called.
- Time and async - inject the clock; wait for a condition with a timeout, never a fixed sleep.
- Named as a specification: "rejects checkout when cart is empty".

## Anti-patterns

Writing all test code before any implementation · testing private methods or reading the DB instead of the interface · unread snapshots · weakening, skipping or deleting a test to get green.
