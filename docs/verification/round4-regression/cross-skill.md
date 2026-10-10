# Cross-skill check (13 skills)

Validator: `13 skills checked, 0 problems`.
Auto skills (6): blast-radius, diagnose, grill, prove-it, review-feedback, tdd. Manual (7): handoff, interrogate, plain, reflect, spec, spike, unslop.

## 1. Cross-references

| Ref | Status |
|---|---|
| grill -> `/spike` | OK. spike exists and is manual. spike says "offer to append the answer" to a waiting grill/decisions file, which matches grill's "append a dated section" rule. |
| grill -> `/spec <path>`; spec -> `/grill`, `/blast-radius` | OK. |
| **spec Source -> "newest file in `docs/decisions/`"** | **INCONSISTENT.** grill writes to "the repo's existing ADR/decisions location if there is one, else docs/decisions/". In a repo that uses docs/adr, spec won't find grill's output. |
| prove-it -> "`run` skill" / "built-in `run` skill" | OK. `/run` is a built-in. Naming is a little uneven ("the `run` skill" vs "/run"). |
| blast-radius ladder 1-5 "same ladder as prove-it" | OK. The levels match exactly. |
| diagnose "report the evidence level, as in prove-it" | OK. Diagnose's tiers (can reach / can't reach) are about access, not evidence, so they don't clash. But the tier-1 output says "unverified" and gives no level (it would be level 1-3). |
| tdd Done -> `prove-it` | OK. |
| **review-feedback <-> interrogate** | **GAP.** review-feedback takes "findings from /code-review or interrogate". interrogate is manual, so it should be written `/interrogate`. interrogate's buckets (Act on / Consider / Noted / Unverified / Dismissed) are not mapped: should Consider/Noted items be fixed by default ("Default to fixing")? Unverified ones? |
| review-feedback <-> /code-review --fix | Overlap. /code-review --fix already applies findings without the per-item judging step. Fine, but neither skill points to the other. |
| spec builder check | OK. It has its own fallback ("or, without one, yourself"). |
| handoff Suggested skills | OK. Limited to .claude/skills + built-ins. |

## 2. Conflicting rules

- **Commit/push/post.** handoff commits without asking (only its own file, and it asks first on the default branch), and asks before pushing. grill and spec offer to commit and ask before pushing. diagnose commits only if asked. spike never commits to the main branch. review-feedback says "Never push, resolve threads, or post replies" but **says nothing about committing**. The other skills say this explicitly, so the silence is inconsistent. interrogate never edits. Overall no direct conflict, but review-feedback should say "Don't commit unless asked."
- **Where files go.** docs/decisions (grill), docs/specs (spec), docs/handoffs (handoff), scratch (spike, prove-it, blast-radius), .claude/rules or CLAUDE.md (reflect). Consistent apart from the spec/grill path mismatch above.
- **Evidence vocabulary.** prove-it uses "Not verified" and levels. blast-radius uses "UNVERIFIED" / "UNPROVEN". interrogate uses "Unverified". handoff uses "verified/unverified". diagnose uses "unverified". This is mostly consistent; the only outlier is blast-radius's uppercase UNPROVEN, which could read as "level <=3".
- **Test rules.** tdd: never edit/skip/delete a test to get green; the test must fail on an assertion. diagnose: run the regression test on the unfixed code and see it fail. prove-it: never weaken a check. **review-feedback: "add or adjust a test that fails without the fix"**. It never requires *seeing* the test fail, and "adjust" invites editing an existing test, possibly loosening it. This is the weakest of the four and conflicts with tdd and prove-it.

## 3. Routing (6 auto skills)

| # | Prompt | Route | Flag |
|---|---|---|---|
| 1 | "Is it safe to merge this PR?" | blast-radius | OK (manual /interrogate and /code-review are the alternatives, but neither is auto) |
| 2 | "I patched the OOM but it still dies - check it works now" | diagnose ("a fix that did not work") vs prove-it ("verify ... works") | **DOUBLE** |
| 3 | "Address the comments on PR #42" | review-feedback | OK |
| 4 | "Reviewer says this breaks the mobile client's JSON parsing - true?" | review-feedback ("checking each item") vs blast-radius ("what a change could break") | **DOUBLE** |
| 5 | "Plan: migrate users.id to UUID. What am I missing?" | grill (gaps in a plan) vs blast-radius ("before changing ... persisted interfaces") | **DOUBLE** (grill excludes only *concrete* changes) |
| 6 | "Write an ISO-week parser, test-first" | tdd | OK |
| 7 | "Fix issue #12: totals are doubled" | diagnose (tdd excludes reported bugs) | OK |
| 8 | "Write tests for the existing billing module" | none (tdd excludes it) | NONE - intended, but worth noting |
| 9 | "Confirm the deploy didn't break API consumers" | prove-it (deploy took effect) vs blast-radius (consumers) | **DOUBLE** |
| 10 | "/code-review found 5 issues - are they real?" | review-feedback | Fires, but its default is to *fix*; the user only asked for a judgement. **Scope risk** |

## 4. Safety

- review-feedback: "Default to fixing" edits code, which is fine since the user asked. It is silent on committing and on `gh pr checkout`. With a PR # argument it may switch branches over uncommitted work.
- prove-it: "the `run` skill or Playwright" could lead to installing Playwright without asking. tdd and diagnose both guard installs ("confirm before installing", "if one is installed").
- prove-it: "Read-only checks (GET...) may hit any environment", including production. Acceptable, but GETs with side effects exist.
- handoff: commits without asking (the user invoked it manually, and the description states it). OK.
- reflect: adds hooks only after approval. OK.
- No skill merges, deploys, or posts comments without asking.

## 5. Size (body words)

blast-radius 484, diagnose 633, grill 650, handoff 398, interrogate 827, plain 191, prove-it 566, reflect 472, review-feedback 351, spec 535, spike 250, tdd 503, unslop 494. **Total 6354.**
Risk: interrogate (827) is long, but it is a manual, run-once procedure. **grill (650) and diagnose (633)** are auto skills with many bolded rules, so rules placed late (grill's Record/commit; diagnose's DBG cleanup) are the most likely to be skipped.
