---
name: interrogate
description: Adversarial review of a diff or design by several independent reviewer subagents, each attacking from a different angle, followed by a lead verdict that sorts findings into act-on / consider / noted / dismissed. Use for "interrogate", "tear this apart", "adversarial review", "find blind spots", or before merging a risky change. Does not apply fixes.
disable-model-invocation: true
---

# Interrogate

The deliverable is a verdict, not edits. Do not change code during this skill.

## 1. Scope

Use what the user points at - a file pair (`diff -u old new`), a patch, a PR, or paths. Otherwise review the branch: `git diff $(git merge-base HEAD origin/HEAD 2>/dev/null || echo main)...HEAD`. Fail early on an empty diff or a bad ref.

## 2. State the intent

Write one paragraph on what the change is meant to do, from the user's words, commit messages, and the code. If I can't tell, ask before spawning reviewers - a reviewer without intent reviews the wrong thing.

## 3. Spawn reviewers in parallel

In one message, launch 3 `Agent` calls (`subagent_type: general-purpose`). Each gets the intent, the diff, the paths of relevant context files, and **one** lens:

- **Correctness** - wrong outputs, edge cases, error paths, concurrency, off-by-one, broken invariants.
- **Blast radius** - what breaks outside the diff: serialized formats, callers, config, public APIs, migrations (follow the `blast-radius` skill).
- **Simplicity & fit** - does it match the surrounding code's idiom, is anything speculative or duplicated, is there a smaller change that does the same job.

Add a **Security** lens when the change touches auth, input parsing, secrets, shell/SQL construction, or file paths.

Tell every reviewer: don't edit project files (scratch scripts outside the project that run the real code are encouraged); cite `file:line`; for each finding give a concrete failure scenario (input → wrong result); say "no findings" rather than inventing nits.

**No subagent tool?** Run the lenses myself one after another, finishing each before starting the next, and say so in the verdict. Agreement between lenses run by one reviewer is weaker evidence; don't present it as independent confirmation.

## 4. Lead judgment

I am the lead reviewer: a pragmatic senior engineer, not an aggregator. Merge duplicates (note which lenses raised them; agreement across lenses is strong signal). Verify any finding I plan to put in **Act on** by reading the cited code myself. Then sort:

- **Act on** - real correctness, security, or maintainability problems that would block a PR.
- **Consider** - legitimate, but the cost/benefit is the user's call.
- **Noted** - valid but not worth action now.
- **Dismissed** - wrong or missing context; one-line reason.

## Output

```
### Intent
### Act on      (finding — lenses — failure scenario — file:line)
### Consider
### Noted
### Dismissed
### Where reviewers agreed / disagreed
```
