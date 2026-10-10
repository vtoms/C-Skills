---
name: tdd
description: Test-first development in vertical slices - agree the seams, list the behaviours, then one failing test and the minimum code to pass, one behaviour at a time. Use when the user asks for TDD, red-green-refactor, or test-first, or when building logic with clear, specifiable behaviour such as parsers, calculations, or state machines.
---

# TDD

Use it where behaviour can be specified up front. For glue code, UI wiring, or exploratory work, build it and verify with `prove-it` instead - mandatory TDD everywhere is ceremony.

## Phase 1: plan (no test code yet)

- **Seams** - the public boundaries I'll test at (function signature, endpoint, CLI output), each with one line on what it catches and misses. Confirm with the user if present; otherwise pick the narrowest set covering the risky logic and state it.
- **Behaviour list** - a short ordered list of test *names* only, simplest first. It is a to-do list, not a commitment; revise it as slices teach me things.

## Phase 2: the loop, one behaviour at a time

1. **Red** - write one test. Run it and see it fail **for the right reason** (an assertion, not an import or syntax error).
2. **Green** - the least code that passes. No speculative parameters.
3. Tick it off; next behaviour.

Refactor only on green, then re-run everything.

## Tests worth keeping

- Behaviour through the public interface; survives an internal rewrite.
- Expected values from an independent source - a worked example, the spec, a known-good literal. Never recompute them the way the code does (`expect(add(a,b)).toBe(a+b)` cannot fail).
- Mocks only at system boundaries (network, clock, filesystem, randomness).
- Named as a specification: "rejects checkout when cart is empty".

## Anti-patterns

Writing all test code before any implementation · testing private methods or reading the DB instead of the interface · unread snapshots · weakening an assertion to get green.
