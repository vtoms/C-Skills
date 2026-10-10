---
name: tdd
description: Test-first development in vertical slices - agree the seams, then one failing test, the minimum code to pass, repeat. Use when the user asks for TDD, red-green-refactor, test-first, or when building logic with clear, specifiable behaviour.
---

# TDD

## Pick the seams first

A seam is the public boundary where behaviour is observed: a function's signature, an HTTP endpoint, a CLI's stdout. Before the first test, list the seams I intend to test, each with one line on what it catches and what it misses. If the user is present, confirm them; otherwise choose the narrowest set that covers the risky logic and state it.

## The loop

1. **Red.** Write one test for one behaviour. Run it and **see it fail for the right reason** (an assertion, not an import error).
2. **Green.** Write the least code that passes. No speculative parameters or features.
3. **Repeat** with the next behaviour. Each test is a tracer bullet informed by what the last one taught me.

Refactor only once the slice is green, and re-run the full test set afterwards.

## What makes a test worth keeping

- **Tests behaviour through the public interface.** It survives a rewrite of internals.
- **Expected values come from an independent source** - a worked example, the spec, a known-good literal. Never recompute the expected value the way the code does (`expect(add(a,b)).toBe(a+b)` can't fail).
- **Mocks only at system boundaries** (network, clock, filesystem, randomness), never internal collaborators.
- **Named as a specification**: "rejects checkout when cart is empty", not "test2".

## Anti-patterns

- Writing all tests up front, then all code (horizontal slicing). The tests describe imagined behaviour.
- Testing private methods, or verifying by reading the database instead of the interface.
- Snapshot tests nobody reads.
- Weakening an assertion to get green.
