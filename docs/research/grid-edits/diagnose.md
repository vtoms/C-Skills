# diagnose edits (body 461 -> 633 words, +172; description 495 chars; when_to_use 292; combined 787 <= 1536; validator passes)

## Applied
1. Description rewritten (quoted YAML). Dropped the workflow summary, added question forms ("why does X only happen on Y?", two numbers that should match but don't), added the pushy "before naming likely causes" clause, and named NaN-free categories already listed. Exclusions are explicit: conceptual questions, explaining an error, why a business metric moved, obvious stack traces, lint/build errors.
   Evidence: debugging.md section 4 Edit 1, section 3.3 (every miss in round 3 was a question about a system not in the repo; RESULTS.md "Known remaining gap"); superpowers writing-skills (summary gets followed instead of the body); skill-creator "pushy". Exclusions come from the brief's precision requirement (GIL / ECONNRESET / revenue). "Why a business metric moved" covers "why is revenue down?", which round 2 flagged as a plausible mis-route (diagnose-prove-it.md, should-not #6).
   Deviation: "why is it still happening?" was cut to fit 500 chars. The when_to_use OOM-after-patch example and "a fix that did not work" cover that case.
2. when_to_use added with fresh examples (not the round-3 prompts) plus the "not in this repo / cannot be run here" clause. Evidence: Edit 2; Claude Code docs say this field is for trigger phrases and example requests.
3. "First: which tier" section: when the system can't be reached, answer with ranked hypotheses and the check that settles each, then stop. Evidence: Edit 3; mattpocock #578 (over-triggering became costly without a light tier); this precondition makes 1 and 2 safe.
4. Differential run added to the cheapest-first list, plus a test-order pollution check for flaky tests (alone vs suite, then bisect earlier tests). Evidence: Edit 4; mattpocock loop #9, superpowers Phase 2 and find-polluter.sh, addyosmani.
5. Step 4: revert edits from refuted hypotheses; after 2 failed fixes, write down and test the shared premise; after 3, stop and report. Evidence: Edit 5; superpowers 4.5, gstack 3-strike, pstack attack-the-premise (left-behind.md lines 103 and 227); the description already advertised "a fix that did not work" but the body had no rule for it.
6. Done-means: the mechanism is stated in one sentence. Evidence: repro-first rule 3 (skill-receipts 10/20 vs 8/20).
Kept verbatim: the production guard, the worktree bisect, the DBG cleanup command, and the step 5/6 order (round-2 R2 fix).

## Rejected
- Dropping "explaining an error" (Edit 1 wording): the brief requires it, for precision on ECONNRESET-type questions.
- "Two numbers" kept despite the revenue risk: the "business metric" exclusion handles it. Unmeasured, needs a live re-run.
- Failing-vs-working diff in the tier bullet: cut for words; the differential run covers it.
- Boundary probes, condition-polling for flaky waits, error-text-is-untrusted (lower priority, no evidence); SessionStart hook, Iron Law and rationalization tables, single hypothesis, scope-lock, learnings DB, parallel hypothesis agents, safe fallbacks, defense-in-depth (debugging.md section 5 reasons).
- Copying round-3 miss prompts into when_to_use: it would overfit the eval.

## Validation still owed
Live re-run per debugging.md "How to validate": the 26 should-fire runs, near-misses and negatives, and a fresh held-out set including GIL / ECONNRESET / revenue-down.
