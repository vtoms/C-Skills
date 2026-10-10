# Red-team review: blast-radius/SKILL.md (32 lines)

## A. IDENTIFICATION

Description (L3): "Works out what a change could break outside its own diff, names the single fact that makes it safe, and proves that fact by running real code. Use for "what could this break", "is this safe to merge", "blast radius of X", or before shipping a change to shared, public, or persisted interfaces."

### A1. Should trigger (paraphrased, no reused wording)
| # | Prompt | Correct decision from description? |
|---|---|---|
| 1 | "I renamed `user_id` to `account_id` in the API response model. Who downstream gets hurt?" | Yes - "shared/public interfaces" + "what could break" semantics. Strong. |
| 2 | "Changing the default timeout in our HTTP client from 30s to 5s - any fallout?" | Likely yes; "fallout" ~ "could break". But "defaults" is only in body (L12), not description. Medium. |
| 3 | "Before I bump protobuf from 3.x to 4.x, what depends on the old behaviour?" | Weak. Dependency upgrades aren't named in description; model may just do the upgrade. Miss risk. |
| 4 | "We're dropping the `legacy_flags` column in this migration. Can anything still read it?" | Yes - "persisted interfaces". Good. |
| 5 | "Is it OK to change the cache key format for sessions?" | Probably yes (persisted). "Is it OK" ~ "is it safe". Medium-good. |
| 6 | "Review the impact of making `parse()` raise ValueError instead of returning None." | Ambiguous - "review" pulls toward code-review. Error-type change is in body L12 only. Medium. |
| 7 | "I'm about to publish 2.0 of our npm package with these exports removed - what will consumers hit?" | Yes - "public interfaces", "could break". Good. |
| 8 | "Can I reorder these enum values without breaking anything?" | Yes ("without breaking"). But only if model recognises enums as serialized. Good. |
| 9 | "Does removing this env var from the Helm chart affect other services?" | Medium - config/env vars are body-only (L16). |
| 10 | "Assess the risk of this PR before I hit merge." | Yes, but collides with built-in code-review. Medium. |

### A2. Near-misses (should NOT trigger)
| # | Prompt | Correct decision? |
|---|---|---|
| 1 | "Review my diff for bugs." | Mostly correct (no "break"/"safe" wording) - but if the diff touches a public API, the proactive clause "before shipping a change to shared... interfaces" can fire. Risk. |
| 2 | "Why is this test failing?" | Correct - no match. |
| 3 | "Refactor this module to use dataclasses." | Risky: the proactive clause may fire mid-refactor if the dataclass is serialized. Arguably acceptable, but it'd hijack a simple refactor. |
| 4 | "What does `resolve_tenant()` do?" | Correct. |
| 5 | "Find all callers of `send_email`." | WRONG risk: this is literally the "blast radius" intuition; description doesn't exclude it, and body L8 says listing callers "is not the job" - the skill would overdeliver a full risk report. |
| 6 | "Is this regex safe against ReDoS?" | Risk of misfire on "is this safe". Description's "safe to merge" phrase helps a bit. |
| 7 | "Did my fix actually work?" | Should go to prove-it; description's "proves... by running real code" overlaps. Some misfire risk. |
| 8 | "Clean up unused imports." | Correct. |
| 9 | "Is it safe to run `rm -rf build/`?" | Misfire risk on "is it safe" (operational safety, not change impact). |
| 10 | "Write a migration that adds a nullable column." | Probably correct (no question about risk), but "persisted interfaces" + "before shipping" could fire proactively. Low-medium. |

### A3. Summary
Triggers well on explicit "break/safe/blast radius" wording. Misses dependency upgrades and behavioural changes (defaults, error types) unless phrased as risk. Over-fires on generic "is it safe" questions and on "find callers" (which L8 explicitly disdains). Collides with built-in `code-review` ("safe to merge") and sibling `prove-it` ("proves by running real code"). Half the description ("names the single fact that makes it safe, and proves that fact by running real code") is method, not trigger signal.

### A4. Auto-invocation?
Yes, keep model-invocable - the user rarely says "blast radius". But the proactive clause "before shipping a change to shared, public, or persisted interfaces" is the over-fire source; tighten it to "when a change alters..." and add an exclusion.

### A5. Proposed frontmatter
```yaml
---
name: blast-radius
description: Impact analysis for a code change - finds what could break beyond the diff (API/schema/serialized formats, DB columns, cache keys, config/env, defaults, error types, dependency upgrades, external consumers), rates each risk, and verifies the key safety assumption by running code. Use when asked what a change could break, whether it is safe to merge or ship, or its blast radius, and before changing public, shared, or persisted interfaces. Not for bug-hunting reviews, debugging, or simply listing callers.
argument-hint: "[diff, branch, PR, or described change]"
---
```

## B. FUNCTIONING

1. **"The change" is never located (L12).** No instruction for how to get it: working tree, `git diff <base>...HEAD`, a PR number, or a *proposed* change not yet written. Hypothetical changes ("what if I rename X?") make step 5 impossible because there is no code to run. Add: "If the change is not written yet, say what you assume it will be and prove the fact against current code."

2. **Assumes the change is safe (L13, L26).** "Find the one load-bearing fact... safe because of one fact" primes confirmation bias. There is no branch for "no such fact exists - this change IS breaking". The Report has "Safe because: ... or UNPROVEN" but no "Unsafe / breaking: yes" verdict, and no overall go/no-go line, even though the description promises an answer to "is this safe to merge". Literal reading: the model hunts for a reassuring fact and reports it.

3. **"Single" fact is false for many changes (L3, L13).** Multi-surface changes (API field rename that's also persisted and also in a cache key) have several independent conditions. "One" forces the model to collapse them or to pick the easiest one to prove.

4. **Step 5 is often impossible or misleading (L21).** Typical load-bearing facts are *negatives about the world*: "no external consumer reads this field", "nothing in prod has this cache key format". A script against local code cannot prove them; running code proves only what the local code does. The skill gives no guidance on what to do when the fact is unprovable by execution (except the "UNPROVEN" escape on L26), and doesn't say a search with documented scope is the right evidence for negatives. Risk: a toy script that "passes" gets reported as proof.

5. **Dangling reference (L21).** "Use the `prove-it` evidence ladder and state the level reached" - the levels are not defined here. If prove-it isn't installed or loaded, "state the level" is meaningless or the model invents a ladder. The Report (L26) requires "its evidence level". Not self-sufficient. Inline a 3-4 level ladder (e.g. "ran real code and read the output > ran a test > read the code > reasoned").

6. **Contradiction: mandatory proof vs. scaling (L21 vs L31).** Step 5 says write and run a script; L31 says a private helper rename "needs a paragraph". Which wins? L31 is placed after the Report so it's read last, after the model may already be writing scripts. Move it to the top and say explicitly which steps are skippable for small changes.

7. **L8 can be read as "don't check direct callers".** "Listing callers is not the job - grep does that in a second." A literal reader may skip the grep entirely, missing the most common breakage (a direct in-repo caller with a changed signature). Say "Grep callers first (it's cheap), then look where grep stops."

8. **Unsafe actions, no guardrail (L18, L21).** "Write a small script or test that exercises the real code, run it" - no restriction on where it runs: could hit a real DB, prod config, network, run migrations, publish. No instruction on where to put the script (scratch vs repo) or to clean up. "Read the library's actual source at the pinned version" (L18) may require fetching/installing packages - no "prefer the vendored/installed copy" guidance.

9. **Unbounded search, no stop condition (L19).** "Consumers outside this repo: public APIs, published packages, scripts, docs" - the model can't see other repos; nothing says "list them as unverifiable and ask the user" or stop after a bounded search. Combined with "Never invent a caller" (L20) it's OK in spirit, but "a search that finds nothing is a valid answer" is wrong for out-of-repo consumers: finding nothing locally is NOT evidence of no external consumer. The two lines interact badly.

10. **"likelihood × cost" (L27) has no scale.** No low/med/high vocabulary, so ratings are freeform and incomparable. Minor.

11. **Report section "Before merge" (L29) assumes a merge context**; for an already-merged change or a hypothetical change it's off. Minor.

12. **Description/body mismatch.** Description promises "proves that fact by running real code" unconditionally; body L26 permits "UNPROVEN" and L31 permits a paragraph. Description omits body triggers (defaults, error types, timing, deps).

Ceremony: overall the skill is lean; ceremony risk is mainly step 5 forced on trivial changes (see 6).

## C. SIMULATIONS

### C1. Ideal: rename JSON field `user_id` -> `account_id` in a FastAPI response model; mobile app in another repo consumes it.
- Step 1: model reads diff, notes the Pydantic alias change. Fine.
- Step 2: "find the one fact that makes it safe" - there is none; this is breaking for the mobile client. Model either (a) invents a reassuring fact ("no in-repo test reads `user_id`") and proves it with a script, or (b) has nowhere to put "this breaks". BREAK: no unsafe verdict path (B2).
- Step 3: serialized form + external consumer flagged. Good - this is the skill's strength.
- Step 5: script calls the endpoint with TestClient and shows `account_id` in output - proves what the change does, not that it's safe. Evidence level: undefined (B5).
- Report: "Safe because: UNPROVEN" plus a risk row. Usable, but the headline answer "No, not safe to merge without versioning/alias" is not a required field. Partial success.

### C2. Edge: genuinely safe change - rename private helper `_fmt_ts` to `_format_timestamp` in one module, all 3 callers updated, no `getattr`/string refs.
- L31 says a paragraph. Step 5 says write and run a script and state evidence level. Model likely writes a throwaway script importing the module or runs the test suite - ceremony for a trivial change. If it follows L31, it skips step 5 and Report's "Safe because" requires an evidence level it didn't produce. BREAK: contradiction (B6).
- L8 literal reading could skip the grep that is actually the whole proof here (B7).
- Variant: the helper is pickled by name in a cache (dynamic access, L16) - skill does mention it, good; step 5 would need to unpickle an old cached object - only possible if a real cached artifact exists; no guidance to fabricate one safely.

### C3. Edge (bonus): consumer in another repo, user asks "is it safe to remove `/v1/export`?"
- L20 "a search that finds nothing is a valid answer" -> model greps this repo, finds nothing, reports "Cleared". Wrong: external callers are invisible. Needs: "Out-of-repo consumers are UNVERIFIED unless you checked access logs / dependent repos; say so and ask."

## D. VERDICT: PASS-WITH-FIXES

Strong core idea (look where grep stops, serialized/dynamic/timing/external lists), lean. But it is biased toward declaring safety, its proof step is impossible for the negatives it most needs to prove, and its evidence ladder is undefined.

### Top 3 fixes (ranked)
1. **Add an unsafe verdict and kill the safety bias.** Replace L13 with: "2. **Find the load-bearing fact(s).** Name the fact(s) that would make this safe, e.g. ... If none holds - the change is breaking - say so plainly; that is a valid outcome." Add as first Report bullet: "- **Verdict:** SAFE / SAFE IF <condition> / BREAKING - one line."
2. **Make step 5 honest and self-contained.** Replace L21 with: "5. **Prove the load-bearing fact.** If it's about code behaviour, run a small script or test against the real code (in a scratch dir, never against prod data, networks, or publish steps) and paste the output. If it's a negative ('nothing reads X'), the evidence is the search itself - state exactly what was searched; anything outside this repo stays UNVERIFIED. State the level: ran-and-observed > test passed > read the code > inferred." And change L20 to: "...a search that finds nothing is a valid answer for this repo only."
3. **Resolve scaling vs. mandatory proof, and fix L8.** Move L31 to directly under the heading and expand: "Scale effort: a private rename needs a grep and one paragraph (skip step 5; evidence = the grep); a changed public/persisted interface needs the full pass." Change L8 to: "Grep the direct callers first - it takes a second - then spend the real effort on the breakage grep won't show."
