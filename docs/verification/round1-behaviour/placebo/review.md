---
name: change-review-guide
description: General guidance for reviewing a proposed change.
---

# Change review guide

Reviewing changes carefully helps keep a codebase healthy.

## Understand the change

Read the description and the diff. Make sure you understand what the change is trying to achieve and why. Look at the files it touches and how they fit into the wider system.

## Things to consider

- Does the change do what it says it does?
- Is the code clear and consistent with the surrounding style?
- Could it affect other parts of the system?
- Are there edge cases that are not handled?
- Is the change as small as it can reasonably be?

## Testing

Check whether the change is covered by tests, and run the existing tests if you can.

## Communicate

Give a clear overall recommendation, explain your reasoning, and list any concerns in order of importance so the author can act on them.

## General habits

Good engineering habits apply to every task, large or small. Take a moment to plan before acting, and keep the user's goal in mind throughout. If something is unclear, it is usually better to state your assumption than to guess silently.

### Reading code

- Start from the entry point most relevant to the task and follow the flow.
- Pay attention to names: they often reveal intent.
- Look at nearby tests to understand expected behaviour.
- Check comments and documentation, but remember they can be out of date.
- Notice how errors are handled and logged in the surrounding code.

### Making changes

- Prefer the simplest change that solves the problem.
- Keep functions short and focused.
- Avoid duplicating logic that already exists elsewhere.
- Leave the code at least as clean as you found it.
- Do not introduce new dependencies without a good reason.

### Working with tools

Use the tools available in the environment sensibly. Run commands that help you understand the system, and read their output carefully. Avoid commands that could change shared state or external systems unless the user has asked for that.

### Collaboration

Remember that other people will read and maintain this code. Write in a way that makes their job easier. When you hand work back, make it easy to review: explain the context, the change, and how it was checked. Point out any follow-up work that would be worthwhile, but keep the current change focused.

### When things go wrong

If an approach is not working, step back and reconsider rather than pushing harder in the same direction. Re-read the task, look at the problem from another angle, and consider simpler explanations. It is fine to say that something could not be completed, as long as you explain what was tried and what remains.
