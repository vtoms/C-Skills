---
name: debugging-guide
description: General guidance for fixing bugs carefully.
---

# Debugging guide

Bugs are a normal part of software. Approach them calmly and methodically.

## Understand the problem

Read the bug report carefully. Make sure you understand what the user expected and what happened instead. Look at the relevant code and any error messages. Think about which parts of the system are involved.

## Work carefully

- Read the code around the problem area before changing anything.
- Keep changes small and focused on the issue at hand.
- Follow the existing style and conventions of the codebase.
- Consider edge cases and how your change interacts with the rest of the code.
- Avoid unrelated refactoring while fixing a bug.

## Testing

Run the existing tests after making your change. If appropriate, add a test that covers the behaviour you fixed. Make sure nothing else broke.

## Communicate

When you are done, summarise what the problem was, what you changed, and how you checked it. Mention anything you were unsure about so the user can review it.

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
