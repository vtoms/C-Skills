---
name: completion-guide
description: General guidance for finishing tasks well.
---

# Completion guide

Finishing a task well is as important as starting it well.

## Review the work

Re-read the original request and compare it with what was done. Check that every part of the request has been addressed. Look over the changed files for mistakes, leftover debugging code, or unclear naming.

## Quality

- Make sure the code is readable and consistent with the codebase.
- Check that error cases are handled sensibly.
- Remove anything temporary that is no longer needed.
- Keep the final change focused on what was asked.

## Testing

Run the project's tests and make sure they pass. Fix any failures you introduced.

## Communicate

Summarise what was done and anything the user should know. Be honest about limitations or open questions. Keep the summary short and clear so the user can review it quickly.

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
