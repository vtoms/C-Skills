# Red-team review: prove-it (/home/user/C-Skills/.claude/skills/prove-it/SKILL.md)

Only SKILL.md was read. File is 43 lines; frontmatter has only `name` and `description` (line 3, ~300 chars).

## A. IDENTIFICATION

### Core problem
The description says "Use at the end of any code change, bug fix, or config change". Skill selection happens mostly when the model reads a user turn and plans. "The end of work" is a self-generated moment with no user cue. The model sees no new prompt that matches, so it has to remember to load the skill in the middle of its own turn. That works sometimes, but not reliably. The phrases that do give the description a cue are "before claiming something works" and "done, fixed, or working". Those match prompts like "does it work now?" or "make sure it's fixed", which is good. "Any code change" is too broad in the other direction: in principle it covers a variable rename or a comment fix. Line 30 tries to scale the effort down, but the body only loads after invocation, so it cannot stop the trigger. A Stop hook or a CLAUDE.md line ("before saying done, run /prove-it") would make the end-of-work trigger reliable. The description alone will not.

### (1) Should trigger
| # | Prompt / situation | Plausible correct decision? | Why |
|---|---|---|---|
| 1 | "The CSV export was dropping the last row. Fix it." (model finishes the patch) | Partial | "bug fix" matches, but the trigger is at the end. The model may load it at the start, or not at all. |
| 2 | "Can you double-check that the retry logic actually works before I merge?" | Yes | Matches "before claiming something works". |
| 3 | "I bumped the Redis timeout in config.yaml. Is it actually picked up?" | Yes | "config change" plus a request to verify. |
| 4 | "You said the migration was fine last time and it wasn't. Show me this time." | Likely | Distrust of earlier claims matches the spirit, but no keyword like "evidence" or "proof" appears in the description. |
| 5 | "Add rate limiting to /login; ping me when it's done." | Weak | It is an implementation request. "done" appears only in the description's body clause. Whether it fires depends on end-of-work recall. |
| 6 | Autonomous agent finishes a refactor and is about to write "All tests pass, done." | Weak | No user prompt to match. This is the main use case and the weakest trigger. |
| 7 | "Confirm the Dockerfile change still builds and the healthcheck goes green." | Yes | "config change" plus "confirm". |
| 8 | "Did your fix for the flaky login test hold? Run it a few times." | Yes | "fixed" and "working". |
| 9 | "Sanity-check the feature flag rollout: is it really off for EU users?" | Likely | "Verifies ... reads the actual value" fits. "Sanity-check" is not in the description. |
| 10 | "Ship the hotfix for the null pointer in OrderService." | Partial | "bug fix" matches, but "ship" pulls toward a deploy or blast-radius skill. |

### (2) Should NOT trigger
| # | Prompt | Plausible correct decision? | Why |
|---|---|---|---|
| 1 | "What does `useMemo` do?" | Yes | No change and no claim of working. |
| 2 | "Fix the typo 'recieve' in README." | Risky | This is a code/docs change, and "end of any ... change" could fire it. The body (line 30) scales it down, but only after it has loaded. |
| 3 | "Let's plan the auth rewrite. Don't write code yet." | Yes | No change. |
| 4 | "Rename `tmp` to `buffer` in utils.py." | Risky | Literally "any code change", so it over-triggers. |
| 5 | "Explain why this test is failing." | Risky | Diagnosis, not a claim. A sibling `diagnose` skill exists. "fixed/working" may still pull it in. |
| 6 | "Does this function handle empty input?" (a question about existing code) | Ambiguous | "before claiming something works" matches. It is arguably useful, but the user asked a question, not for a verification report block. |
| 7 | "Write a design doc for caching." | Yes | Not a code change. |
| 8 | "Review this PR for bugs." | Mostly | It is a review, not the model's own work. "claiming something works" could still fire it. |
| 9 | "Add a TODO comment here." | Risky | Any code change. |
| 10 | "Grill me on this plan." | Yes | No overlap. |

### (4) Auto-invocation
Keep auto-invocation (do not set `disable-model-invocation: true`). Hiding the description would remove the only passive cue. But auto-invocation alone will not make it fire at the end. Pair it with a hook or a CLAUDE.md rule. Narrow the description so trivial edits do not trigger it.

### (5) Proposed frontmatter
```yaml
---
name: prove-it
description: Verifies a finished change against the real artifact - runs the repro, test, or app and reads the actual output - then reports an evidence level. Use before saying a bug is fixed, a feature works, or a config change took effect, or when the user asks to verify, confirm, double-check, or prove it. Not for questions, planning, or trivial text-only edits.
---
```
(about 370 chars)

## B. FUNCTIONING

1. **Ladder ordering and direction (lines 12-20).** "Push each claim as far down this list" depends on the reader taking "down" to mean a higher number. Level 3 "Reasoned" ranks above level 2 "Cited", and its wording "it cannot happen" (line 16) invites overconfidence: an LLM can claim it has walked through every case and call that level 3 without running anything. Line 20 says "'It compiles' and 'the types check' are level 2 at best". Compiling is a real execution of a tool, so that does not fit level 2's definition ("a real file:line"). The ladder mixes two axes: the kind of evidence and how strong it is.
2. **Per-claim vs single level (line 12 vs line 38).** Line 12 says to give each claim a level ("say where it stopped"). The report template has one `Evidence level: <1-5>`. A change with 3 claims at levels 4, 4 and 2 has no defined output. The model will either report the max, which overstates, or improvise.
3. **Mandatory ceremony vs sizing (line 30 vs lines 26, 34, 42).** Line 26 says to run lint, typecheck and tests with no condition. Line 34 says "End with one short block" with no condition. Line 30 says a docs fix needs only a glance. Read literally, a typo fix still gets lint, tests and a report block. Neither rule says which one wins.
4. **No path when level 4 is unreachable.** There is no test suite, no runnable app, no credentials, or the platform is missing (iOS, Windows, CI-only). The only outlet is "Not verified:" (line 39). The skill never says to write a throwaway script or test that calls the real code. That is the cheapest way to reach level 4 and the most common case. Line 28 implies it ("Script the check") but frames it as optional.
5. **"Re-run the original failure" assumes a repro exists (line 25).** For bugs reported only in prose, there is no instruction to build the repro first and confirm it fails on the old code. Without that step, "passing now" proves nothing.
6. **"Suspect the check first" has no stop condition (line 29).** Nothing says when to accept that the system is broken. A literal reader can rationalize red results away by rewriting the check until it is green. This is the opposite of what the skill is for. It needs a rule like: "fix the check only if you can show it was observing the wrong thing; never weaken an assertion to make it pass."
7. **Unsafe "observe live" (lines 18, 24).** "Query the real process" and "reproduced in the running app ... or service" have no guardrail against side effects. Examples: hitting production, sending real emails or payments, running migrations against a shared DB, restarting services, pushing to trigger CI. There is no "local/staging only; ask before touching shared or prod systems."
8. **Stray files (line 28).** "Keep it out of the commit" gives no location for the script, such as a scratchpad or temp directory, and no cleanup step. Scripts end up as untracked files in the repo, and `git add -A` picks them up.
9. **Unclear threshold for claims (line 42).** It forbids "done/fixed" only at levels 1-2, so level 3 ("Reasoned") is allowed to say "fixed". That conflicts with line 20, "Most changes should reach 4". Is 3 acceptable or not?
10. **"Use the repo's own verifier first" vs "Run the repo's own checks" (lines 26-27).** These overlap, and neither sets an order or a budget. In a large monorepo, "the tests for the touched package" can take 30+ minutes. There is no guidance to run a targeted subset first.
11. **"a subagent's self-report" (line 24).** Good. But it does not say the model's own earlier claims in the session are also level 1. That is the more common failure.
12. **Body vs description.** The description says "reports an evidence level", which matches. It says "any code change", but the body says "size it to the task", a conflict covered under A. The description never mentions the report block format, which is fine.

## C. SCENARIOS

### Ideal: Python service, pytest present
The user says pagination skips item 21. The model reproduces it with `pytest -k test_page_boundary` (red), fixes the off-by-one, and reruns (green). It then runs the package tests and ruff and mypy, and reports `Evidence level: 4`. This works well. Weak spots:
- If no boundary test existed, step 5 above applies: nothing tells the model to write the failing test first.
- The model may skip level 5 (running the server and curling page 2). That is acceptable because "as cheap" is in line 12.
- "Run the repo's own checks" pulls in the whole suite even when a focused run would do.

### Edge: GitHub Actions workflow change, no local runner, plus a prod-only env var
The user asks to make CI cache pip. There are no tests for YAML, and `act` is not installed.
- Line 26: lint? Maybe actionlint, which is not mentioned and may not be installed.
- Line 25: there is no "original failure".
- Line 18: "Observed live" means pushing a branch to trigger CI, which is a side effect needing permission. The skill does not say to ask first. A literal agent might push.
- Line 29: if CI goes red for an unrelated reason, "suspect the check first" may lead the model to edit the workflow's test step.
- Report: the model can honestly give level 2 or 3 with "Not verified: workflow not run". But line 42 does not stop it from writing "fixed" at level 3.

The skill breaks on the missing side-effect guard and on the missing "build a throwaway harness or validator" fallback.

### Edge 2: one-word README typo
With auto-trigger, the skill loads. Lines 26 and 34 versus line 30: the model either runs lint and the test suite for a typo, or prints the 3-line report block. Either way it is noise. The over-trigger comes from "any code change" in the description.

## D. VERDICT: PASS-WITH-FIXES

The core idea and the ladder are sound and short. The triggering and the safety and failure-mode gaps are real but fixable.

Top 3 fixes, ranked:
1. **Description (line 3).** Replace it with the proposed frontmatter above. It drops "any code change", adds the cues verify/confirm/double-check and "fixed/works/took effect", and excludes trivial edits. Also recommend a Stop hook or CLAUDE.md line for the end-of-work trigger, since the description alone cannot provide it.
2. **Add rules after line 29:**
   "- **No repro or no tests? Build one.** Write a throwaway script or test in a scratch dir that calls the real code and fails on the old behaviour; delete it after unless asked to keep it.
   - **Never make a red check green by weakening it.** Change the check only when you can show it observed the wrong thing.
   - **Observe safely.** Live checks run locally or on staging. Ask before touching prod, shared data, or anything that sends, charges, migrates, deploys, or pushes."
3. **Report and sizing (lines 30-42).** Change it to: "Report one line per claim with its level; the overall level is the lowest. Below 4, do not say done/fixed/works. For text-only edits, skip lint/tests and the block; one line suffices." This also makes line 26 conditional: "for code changes, run ...".
