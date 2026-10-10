---
name: blast-radius
description: Impact analysis for a code change - finds what could break beyond the diff (APIs, schemas, serialized formats, DB columns, cache keys, config and env, defaults, error types, dependency upgrades, external consumers), rates each risk, and proves the key safety assumption by running code. Use when asked what a change could break, whether it is safe to merge or ship, or its blast radius, and before changing public, shared, or persisted interfaces. Not for bug-hunting reviews or debugging.
argument-hint: "[diff, branch, PR, or described change]"
---

# Blast radius

## Size it first

- **Private, local change** (a rename inside one module, an internal helper): grep the direct callers and string or dynamic references to the name, write one paragraph, stop.
- **Anything crossing a boundary** (public API, serialized data, persisted state, config, dependencies): do the full pass below.

## Steps

1. **Read the change completely** - what it adds, changes, and deletes, plus behaviour it changes implicitly (defaults, ordering, timing, error types).
2. **Grep the direct callers first**, then spend the effort on what grep won't show.
3. **Find the load-bearing fact(s).** Most risky-looking changes are safe because of one fact, e.g. "this field is never read after serialization". Name it. **If no such fact holds, the change is breaking - say so plainly.** Don't hunt for reasons to call it safe.
4. **Look where grep stops:**
   - Serialized forms: JSON responses, DB columns, files on disk, cache keys, wire protocols, other languages reading the same bytes.
   - Dynamic access: reflection, string-built names, config, feature flags, env vars.
   - Timing: async ordering, teardown, retries, concurrency.
   - Dependencies: the library's actual source at the pinned version.
   - Consumers outside this repo: public APIs, published packages, scripts, docs.
5. **Rate each risk honestly** - realistic likelihood and real cost. Never invent a caller or an API. A search that finds nothing is valid evidence **for this repo only**; anything outside it stays UNVERIFIED.
6. **Prove the load-bearing fact.** Write a small script or test that exercises the real code in a scratch directory - only for trusted code (not an external fork), never against production data, networks, or publish steps - run it, and paste the output. State the proof's level: 1 asserted, 2 cited `file:line`, 3 reasoned step by step, 4 executed, 5 observed live (the same ladder as `prove-it`).

## Report

- **Verdict:** SAFE / SAFE IF <condition> / BREAKING.
- **What it does** (including the non-obvious part).
- **Safe because:** the fact, how it was proven, and the output - or "UNPROVEN".
- **Risks:** how it breaks, `file:line`, likelihood × cost, how to check.
- **Cleared:** what I checked and why it's fine.
- **Unverified:** consumers or facts outside what I could inspect.
- **Before merge:** the cheapest test that would catch the real failure.
