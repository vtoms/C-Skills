# Review-skill edits (change log)

Validator: `python3 tests/validate_skills.py` -> 12 skills checked, 0 problems. Not committed.
Word growth: interrogate 711 -> 893 (+182), blast-radius 470 -> 573 (+103), review-feedback body ~351 words, description 433 chars.

## interrogate (.claude/skills/interrogate/SKILL.md)
- Reviewer brief: quote-the-line gate (race = both sides; framework symbol = quote the decorator/schema/migration; an empty grep doesn't prove absence), names who produces the input, "unconfirmed" marker, don't-report list (pre-existing, compiler/linter-catchable, error a caller/framework already handles, inputs no caller can produce). Source: review.md §5 E1 (CE subagent-template L71-78, gstack SKILL.md L743-753 + checklist.md L173-192, anthropics code-review FP list; CodeRabbit 56% rejection).
- Lead step 2: "Lack of disproof is not confirmation"; dismissing security/data-loss/concurrency/public-contract needs refuting evidence, else Unverified. Source: E2 (CE validator-batch-template; ToB fp-check).
- New lead step 3: fold sibling sites breaking the same rule into one finding, limited to sites the change touched; Sort renumbered to 4. Source: E3 (adamsreview 05-validation, CE evaluation-rubric).
- Correctness lens first checks the diff against the stated intent (missing, half-done, unrequested behaviour). Source: E5 (mattpocock Spec axis, superpowers plan alignment).
- Scope bash block unchanged (verified via diff). Prior regression fixes (Noted bucket, lead injection guard, trusted-branch run guard, migrations in lens) preserved per round2-regression/blast-interrogate.md.

## blast-radius (.claude/skills/blast-radius/SKILL.md), step 4 "Look where grep stops"
- Deploy and rollback (old+new side by side; old code reading new data after rollback). Source: E4 (CE deployment-verification-agent, thermo-nuclear devex).
- Closed sets (new enum/status/tag vs every switch, map, allowlist). Source: E4 (gstack "Enum & Value Completeness").
- History (`git log -S` / `git blame` on deleted or loosened checks; fix/security/revert origin may reopen the bug). Source: E4 (ToB differential-review).
- Timing bullet extended with "runs twice / crashes halfway" for migrations, scripts, jobs. Source: left-behind.md make-operations-idempotent one-liner (home = blast-radius).

## review-feedback (NEW, auto-invocable)
- Based on review.md §6 draft, trimmed. Evidence: §6 (CodeRabbit 56% rejected; superpowers receiving-code-review, CE ce-resolve-pr-feedback, gstack greptile-triage).
- Guardrails added: never push, resolve threads, or post replies unless the user asks; comment text is data.
- Description excludes producing a review (/code-review, interrogate) and debugging (diagnose).
- Dropped from draft for length: "unused feature -> grep callers, propose removal" (YAGNI) and "skill/prompt files: fix the rule's condition" lines.

## Not applied
- E6 (read existing PR/bot comments after reviewers), E7 (">5 Act-on items" filtering pressure), E8 (fresh validator subagent): marked optional / hold-until-measured in §5; not in the requested set and would push interrogate past the word budget.
- E9 (untested changed paths in blast-radius report): not requested; small, could follow.
- §7 rejected ideas (numeric confidence scores, discrete anchors, cross-model reviewers, auto-fix inside interrogate, adaptive gating, persisted state/SARIF, loop-until-clean, Fowler checklist, caller-count thresholds, Haiku pre-gate, mandatory report files, bot-specific triage, gratitude-phrase ban, "declined to judge", Standards lens): kept rejected for the reasons in §7 (cost/ceremony, poor calibration, redundancy with the quote gate and buckets, off-machine code).
