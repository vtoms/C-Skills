# Regression check: tdd, handoff, reflect (OLD d228028 vs NEW working tree)

Frontmatter for all three is valid. tdd has name+description (449 chars). handoff and reflect have name, description, argument-hint (double-quoted) and disable-model-invocation: true. No plain scalar contains ": ". Body word counts: tdd 503, handoff 398, reflect 472.

## tdd: REGRESSION (minor, one misfiring rule)

### Lost OLD behaviour
None. Stub rule, assertion-failure rule, passes-immediately rule, "least code" and "no speculative parameters", legacy seam, Done -> prove-it and the anti-patterns are all kept. "Refactor only on green, re-run everything" became numbered step 3 with the same meaning. It is now scoped to "code and test just touched", which is a slight narrowing but acceptable.

### Misfires and contradictions
1. MISFIRE: "Reject a test that would still pass if the code returned `undefined`/`None`". Read literally, this rejects legitimate tests whose specified result is None/undefined, e.g. `assert find([], 1) is None` or "returns undefined for a missing key". Those tests would pass with a None-returning stub, so the rule forbids them.
   Suggested edit: "Reject an assertion that would pass for any return value (only `toBeDefined`, `toBeTruthy`, `not.toThrow`, `is not None`), unless `undefined`/`None` is the specified result."
2. Minor tension: Red says "Write it from the spec, not from code I've already written" and "name the bug it catches". Phase 1's characterization tests are written from existing code and pin behaviour, not a bug. They sit in Phase 1, outside the loop, so this is not a hard conflict.
   Optional: append "(characterization tests in Phase 1 are the exception)".
3. "(only toBeDefined, toBeTruthy, not.toThrow)" reads as an exhaustive list but is meant as examples. Cosmetic.

### Intended edits landed
All 6 landed: name-the-bug/spec-not-code; never edit/skip/delete a test; Refactor step plus "behaviour change = new test"; Done re-read plus naming failing tests; None check, mock-args and clock/wait; anti-pattern wording.

### Hands-on (pytest 9.1.1, venv, scratch dir tdd/): clamp(value, lo, hi)
- Red1: stub `return None` -> `assert None == 5`, an assertion failure. Green1: `return value`, the least code (no bounds yet). Passes.
- Red2 -> `assert -3 == 0`. Green2: add `if value < lo`. Red3 -> `assert 42 == 10`. Green3: add `if value > hi`.
- Refactor on green: `max(lo, min(value, hi))`, 3 passed. The refactor did not change behaviour, so no new test was needed. This fits.
- None check vs "least code": no conflict. The rule judges assertion strength, not implementation size. Hard-coding `return 5` would still be "least code" for test 1 and would still fail a None stub. The rules complement each other: a vacuous `is not None` test fails on Red against a None stub (so the passes-immediately check misses it), then passes against a wrong impl returning 0 (verified: 1 passed). Only the new None rule catches it.
- Red4 (rejects lo>hi) against a real impl -> `DID NOT RAISE ValueError`, a test-level failure.

## handoff: REGRESSION (minor)

### Lost OLD behaviour
None. The path-limited commit, default-branch ask, ask-before-push, decline fallback, "under a page" and redaction are all intact.

### Contradictions
1. The resume prompt now tells the fresh session to "check the State against git log/git status ... report any mismatch". The decline/failed-push fallback (Saving) inlines only the next steps, because the file may be lost. In that case the fresh session has no State to check against.
   Suggested Saving edit: "...inline the next steps and the key State facts (branch, SHAs, status command and its last result) in the resume prompt instead of relying on the file path."
2. State says "quote its output or errors verbatim". This conflicts with "Redact secrets" (status output can contain tokens or env values) and with "Keep it under a page" (long test output).
   Suggested edit: "quote the relevant lines of its output or errors verbatim (secrets redacted)".
3. Resume prompt length: repo, branch, path, first step and the check instruction fit in 3 lines (done in the hands-on run). The rule is OK when pushed. When unpushed, the "longer if the file isn't pushed" clause already permits growth. No new contradiction beyond item 1.

### Intended edits landed
All 3 landed: verified/unverified tags plus the status command; whose call plus don't-do list; resume-prompt State check.

### Hands-on (scratch repo handoff/work, bare origin.git, branch feat/parse with 1 unpushed commit, notes.txt pre-staged, app.py modified, .env untracked with SECRET=abc123)
- Ran the status command `python -c "import app; print(app.g())"` -> `2`, tagged verified. h() was tagged unverified.
- `git add docs/handoffs/2026-10-11-parse.md && git commit -m ... -- <file>`. HEAD 215dfcb contains exactly 1 file (the handoff).
- After the commit: notes.txt is still staged (A), app.py still modified, .env still untracked. `git log --all -- .env notes.txt` is empty.
- Push treated as declined. origin has only main@b06182b. Nothing pushed.
- The doc mentions .env without its value.
- Side note: running the status command created an untracked `__pycache__/`. This is not a skill issue.
- The resume prompt came out at 3 lines including the State-check instruction.

## reflect: REGRESSION (minor)

### Path-scoped rules: real feature
Verified at https://code.claude.com/docs/en/memory: "Organize rules with `.claude/rules/`", "Path-specific rules ... YAML frontmatter with the `paths` field", and "target under 200 lines per CLAUDE.md file". This is not a regression. One gap: the docs say "Rules without a `paths` field are loaded unconditionally". The skill's "path-scoped rule file (e.g. `.claude/rules/<topic>.md`)" does not mention `paths:`, so an agent may write an always-loaded file.
Suggested edit: "a path-scoped rule file (`.claude/rules/<topic>.md` with `paths:` frontmatter)".

### Contradictions and misfires
1. The intro says "After a smooth one, say there's nothing durable to learn and stop." `/reflect repo` is likely run from a fresh or smooth session, so a literal reading stops before repo mode runs.
   Suggested edit to the intro: "After a smooth one (and not in repo mode), say ...". Alternatively, add to the Repo mode line: "the smooth-session stop does not apply."
2. Step 2's process bullet ("otherwise a CLAUDE.md line first") does not apply the new repo-wide-vs-narrow test that the conventions bullet does.
   Suggested edit: "otherwise a CLAUDE.md or rule-file line first".
3. Step 3.4 says to "fail only on new occurrences" (ratchet) and also to "show it catching the original mistake". If the original mistake is still in the code, the ratchet exempts it. Suggested edit: "show it catching a reintroduction of the original mistake".
4. Repo mode does not say where review comments come from (e.g. `gh`). This is minor.
Repo mode is otherwise coherent with the description ("or, on request, recent commits and reverts") and with argument-hint 'repo'.

### Intended edits landed
All 5 landed. The step 3.3 project-scope fix and the step 2 hook-bullet fix from round 2 are preserved.
