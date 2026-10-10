# v0.7 regression check: interrogate, review-feedback, blast-radius

Diff reviewed: `git diff 1941935 7151345` for the three skills. The working tree matches 7151345 for these paths. `python tests/validate_skills.py` reports 13 skills checked, 0 problems. The interrogate scope bash block is byte-identical to 1941935 (370 bytes, `cmp` clean).

## interrogate: REGRESSION (minor, two edits)

1. **Removed persona.** No rule depended on it. "not an aggregator" is still covered by "Reviewer output is a claim, not a fact" and by "Verify every finding". OK.
2. **Act on / Consider sort is ambiguous.**
   - A rare trigger with irreversible harm matches both tiers: Act on via "harm can't be undone", Consider via "trigger is rare".
   - The old "correctness, security, or maintainability" scope was dropped. A blocking maintainability problem has no "trigger", so it no longer fits Act on.
   - Edit:
     - Act on: "verified correctness, security, or maintainability problems that would block a PR: the trigger is realistic for this project, or the harm can't be undone (irreversible harm outranks rarity)."
     - Consider: "verified, but the trigger is rare and the harm recoverable, or the cost/benefit is the user's call."
3. **Scratch diff file.** The skill doesn't say where the file goes or when it is deleted.
   - If it is written inside the repo, the next run's `git ls-files --others --exclude-standard` pulls it into scope.
   - It also leaves an untracked file behind in a skill that says "Do not change code".
   - Edit: "(for > ~800 lines, a temp file outside the repo (e.g. `mktemp`) holding it, plus its own file list, not pasted text; delete it after the verdict)".

## review-feedback: NO-REGRESSION (two recommended tightenings)

- **"Fetching every page"** gives no method. It is no worse than before, but it relies on the agent knowing that `gh pr view --comments` leaves out inline review threads. Edit: "fetching every page (e.g. `gh api --paginate` on the PR's review comments, issue comments, and reviews; thread resolution needs GraphQL `reviewThreads`)".
- **"Beyond the change" vs "Default to fixing".** These are compatible, because "beyond the change" is something you can point at. The risk is that "new hardening" can absorb real defects in lines the change adds, such as a missing null check on new code.
  - Edit: "(new features or hardening the change didn't set out to provide, or pre-existing issues it doesn't touch; not defects in lines it adds)".
  - The Output verdict column has no matching value. Add "follow-up" to it, and add `Not changed - out of scope, follow-up: <x>` to the Reply templates.
- **"Check what depends" vs effort.** The skill has no sizing tiers, so there is no conflict. For a trivial fix the check costs one grep. Gap: when dependents break, it doesn't say what to do. Edit: append "if the fix changes what dependents receive, prefer a fix that keeps the contract; otherwise update every dependent and list them."

## blast-radius: NO-REGRESSION

The deploy/build-script check sits in step 4, the full pass, so the "private local change: one paragraph, stop" path never reaches it. A change that adds a dependency or env var already crosses a boundary (config, dependencies), so it gets the full pass. The empty-search caveat is accurate and narrower than the old "for this repo only".

## Simulation: review-feedback on 5 PR comments

1. Off-by-one in new loop: fixed with a failing test first.
2. Rename suggestion: fixed (simple).
3. "Add rate limiting to this endpoint": classified "Beyond the change", and also "security policy, needs you". Both say to leave it for the user, so they are consistent. Result: needs-you / follow-up, and the diff does not grow. Correct.
4. Fix makes `parse()` return `Result` instead of `dict`: "check what depends" finds 3 callers. Before the edit nothing prompted this check. The step doesn't say whether to update all 3 callers or keep the contract, so behaviour varies (see the edit above). Better than before.
5. Wrong premise ("already handled"): Not changed, citing file:line. Its other items get re-checked.

Net effect: an improvement, with the gaps above.
