---
name: spike
description: Answers one design question with time-boxed throwaway code in a scratch location, then reports the answer, the evidence, and a delete-or-keep decision. Never changes or commits the project's main code.
argument-hint: "[the one question to answer]"
disable-model-invocation: true
---

# Spike

Throwaway code that answers one question. The answer is the deliverable; the code is not.

## Frame it

Before writing code, state in one line each:
- **Question** - one, answerable yes/no or by a measurement. If the argument holds several, ask which comes first.
- **Signal** - what result means yes and what means no.
- **Time box** - default ~30 minutes or three attempts.

If reading code or docs can answer it, do that and stop.

## Build

- Work in a scratch location: the session scratchpad, a temp dir, or a separate git worktree on a throwaway branch. Never edit the project's source files, never overwrite existing files, and never commit spike code to the main branch.
- Build the smallest thing that answers the question: hardcode, stub, skip tests and polish. Use the real library, API (sandbox, not production) or data wherever the question is about them.
- At the time box, stop. "Inconclusive, because…" is a valid answer.

## Report

```
Question: <the question>
Answer: yes | no | inconclusive - <one line>
Evidence: <command run and its actual output, or screenshot path>
Doesn't prove: <what was stubbed or hardcoded>
Unblocks: <the decision this settles>
Code: delete (default) | keep at <path> - <why>
```

Keeping spike code is a new request: rebuild it properly rather than promoting it. If a grill or decisions file is waiting on this, offer to append the answer there. Delete the scratch files once the user agrees.
