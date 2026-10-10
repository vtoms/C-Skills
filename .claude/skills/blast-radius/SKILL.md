---
name: blast-radius
description: Work out what a change could break outside its own diff, find the single fact that makes it safe, and prove that fact by running real code. Use for "what could this break", "is this safe to merge", "blast radius of X", or before shipping a small diff to shared, public, or persisted interfaces.
---

# Blast radius

Listing callers is not the job - grep does that in a second. The job is the breakage grep won't show.

## Steps

1. **Read the change completely.** What it adds, changes, and deletes, plus behaviour it changes implicitly (defaults, ordering, timing, error types).
2. **Find the one load-bearing fact.** Most risky-looking changes are safe because of one fact, e.g. "this field is never read after serialization" or "this function is only called from the CLI". Name it. If it holds, most risks are cleared at once.
3. **Look where grep stops:**
   - Serialized forms: JSON responses, DB columns, files on disk, cache keys, wire protocols, other languages reading the same bytes.
   - Dynamic access: reflection, string-built names, config, feature flags, env vars.
   - Timing: async ordering, teardown, retries, concurrency.
   - Dependencies: read the library's actual source at the pinned version.
   - Consumers outside this repo: public APIs, published packages, scripts, docs.
4. **Rate each risk honestly** - realistic likelihood and real cost. Never invent a caller or an API; a search that finds nothing is a valid answer.
5. **Prove the load-bearing fact.** Write a small script or test that exercises the real code, run it, and paste the result. Use the `prove-it` evidence ladder and state the level reached.

## Report

- **What it does** (including the non-obvious part).
- **Safe because:** the fact, its evidence level, and the proof output - or "UNPROVEN".
- **Risks:** how it breaks, `file:line`, likelihood × cost, how to check.
- **Cleared:** what I checked and why it's fine.
- **Before merge:** the cheapest test that would catch the real failure.

Scale effort to the change: a private helper rename needs a paragraph; a changed public schema needs the full pass.
