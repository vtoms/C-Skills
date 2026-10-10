# Regression check: tdd, handoff (OLD = 31d6e7e, NEW = working tree)

## tdd — NO-REGRESSION

Frontmatter: name and description only (valid). Auto-invoked. The description now carries the exclusions, so it no longer conflicts with the body.

Fix verification (round-1 top 3):
1. Description replaced with the A4 text: FIXED (verbatim).
2. Red step: FIXED. Stub "with the final signature that returns a wrong value" is there, and so is the passes-immediately rule.
3. Runner, legacy and Done lines: FIXED. Runner setup asks before installing. The characterization-test path is there. Done runs the full suite, then prove-it, then a report.
Secondary fixes not applied (none of these is a regression): the "Confirm with the user if present" gate, Refactor sitting outside the numbered loop, and triangulation guidance.

Lost from OLD: the body's opening line ("glue/UI/exploratory -> build it and verify with prove-it instead"). The description's "Not for" clause replaces it, so nothing is lost before load. The only loss is the explicit pointer to prove-it for excluded work. Acceptable.

Minor tension (not a misfire): the body's "Legacy code with no seam -> characterization test" vs the description's "Not for adding tests to existing code". Read in context, the body line is a step before adding new logic. Optional wording: "Legacy code with no seam (when adding new logic to it)".

Hands-on (python3, pytest 9.1.1, scratch dir):
- Stub `def parse_minutes(s: str) -> int: return -1`.
- test_parses_hours_and_minutes -> `AssertionError: assert -1 == 90`. This is an assertion failure, so the rule works.
- test_rejects_empty (pytest.raises) -> `Failed: DID NOT RAISE ValueError`. Also a test-level failure, not import or syntax.
- If a later test expects the value the stub already returns (for example "0m" -> 0 vs a stub returning 0), it passes at once. The passes-immediately rule covers that case.
- Done references `prove-it`, which exists in this environment. For a pure function, the "real entry point" is the function itself, which is slightly vague but not broken.

## handoff — REGRESSION (minor, one internal contradiction); safety fix verified

Frontmatter: name, description, argument-hint "[focus for the next session]", disable-model-invocation: true. All valid. The description is good menu text.

Fix verification:
1. Commit only the handoff file, ask on the default branch, ask before pushing, fallback if declined: FIXED.
   The "before context runs low" sentence was removed: FIXED.
2. Print the resume prompt in chat and inline next steps if unpushed: FIXED.
3. State lists pushed yes/no and uncommitted changes; Suggested skills restricted to ones that exist: FIXED.

Regressions / contradictions:
- R1 (contradiction): Resume prompt is "3–5 lines" (Contents #8). Saving says that on decline you "inline the next steps in the resume prompt". Ordered next steps plus repo, branch and path will often exceed 5 lines.
  Edit #8 to: "**Resume prompt** - 3–5 lines (longer if the file is not pushed, see Saving) to paste into a new session: ..."
- R2 (gap the fix exposed, not present in OLD in this form): "Commit only the handoff file" doesn't say how. Hands-on showed that `git add <file> && git commit` also commits anything already staged.
  Edit the bullet to: "Commit **only the handoff file** (`git add <file> && git commit -m "..." -- <file>`, so already-staged changes stay out) on the current branch."
- Lost from OLD: the scratchpad alternative ("If the user doesn't want it in the repo, put it in the scratchpad"). Now a declined commit leaves an untracked docs/handoffs/ file in the user's tree. This is cosmetic, and the temporary-file warning is kept.

Hands-on (scratch repo, bare local origin, branch feat/x, modified app.py, untracked .env containing SECRET=abc):
- Followed NEW literally. Wrote docs/handoffs/2026-10-10-x.md. `git add <file>; git commit`. HEAD contains only that file (1 file changed). app.py stays modified, .env stays untracked.
- Push treated as declined. origin still has only main@init, so nothing was pushed.
- .env: no leak through git. The doc lists ".env (untracked)" per the State rule, without its value, because the redaction rule applies.
- Variant with app.py pre-staged: a plain `git add <file> && git commit` committed app.py too, which leaks the unrelated change. `git commit -- <file>` committed only the handoff and left app.py staged. That is why R2's edit is needed.
- On a default branch the skill asks first. If the user declines, the fallback (temporary file, inline steps) applies correctly.
