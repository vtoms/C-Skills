---
name: tdd
description: Test-first (TDD) loop in vertical slices - agree seams, list behaviours, then one failing test and the minimum code to pass it, repeated per behaviour. Use when the user asks for TDD, test-first, red-green-refactor, or tests that drive new code, or when writing new self-contained logic with a precise spec (parser, calculation, state machine). Not for adding tests to existing code, debugging failing tests, refactors, UI/glue/config changes, or prototypes.
---

# TDD

## Phase 1: plan (no test code yet)

- **Runner** - find the command that runs one test and the one that runs the suite. If there is no test setup, propose one and confirm before installing anything.
- **Seams** - the public boundaries to test at (function signature, endpoint, CLI output), each with one line on what it catches and misses. Confirm with the user if present; otherwise pick the narrowest set covering the risky logic and state it.
- **Legacy code with no seam** - first pin current behaviour with a characterization test; once it is green, extracting the seam is allowed.
- **Behaviour list** - a short ordered list of test *names*, simplest first. A to-do list, not a commitment; revise it as slices teach me things.

## Phase 2: the loop, one behaviour at a time

1. **Red** - write one test and run it. It must fail **on an assertion**, not on an import or syntax error. If the unit doesn't exist yet, add a stub with the final signature that returns a wrong value. If the test passes immediately, check it can fail at all; keep it only if it pins real behaviour.
2. **Green** - the least code that passes. No speculative parameters.
3. Tick it off; next behaviour.

Refactor only on green, then re-run everything.

## Done

When the list is empty: run the full suite, verify the feature through its real entry point (`prove-it`), and report what is covered and what was deferred.

## Tests worth keeping

- Behaviour through the public interface; survives an internal rewrite.
- Expected values from an independent source - a worked example, the spec, a known-good literal. Never recompute them the way the code does (`expect(add(a,b)).toBe(a+b)` cannot fail).
- Mocks only at system boundaries (network, clock, filesystem, randomness).
- Named as a specification: "rejects checkout when cart is empty".

## Anti-patterns

Writing all test code before any implementation · testing private methods or reading the DB instead of the interface · unread snapshots · weakening an assertion to get green.
