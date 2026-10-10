# Regression check: grill, spec (OLD 31d6e7e vs NEW working tree)

## grill

### Frontmatter
- YAML valid (name, description, argument-hint). Auto mode kept (correct). Description 484 chars. That is long but the front-loaded clause carries the meaning, so truncation is tolerable.
- Triggers: "grill me" is kept. The code-ambiguous quotes "stress-test this plan" and "poke holes in this" are gone, replaced by "pushed back on or challenged", "gaps or risks in a plan found" and "what they are missing". The over-broad "align before building something non-trivial" is narrowed to "wants to settle decisions before building". Exclusions now include code/PR review and debugging. "Testing" was not added; this is minor.
- "asks what they are missing" is slightly broad (for example, "what am I missing in this stack trace"), but the debugging exclusion covers most cases. Acceptable.

### Regressions / new problems
1. **R1, holes-first can be skipped on the ≤2 path (new internal conflict).** "Holes first" runs "before the first round", but the ≤2-auto branch has no rounds. "Poke holes in my plan" or "what am I missing" is auto-triggered, and it is not an explicit "grill me". A plan with few open *decisions* (the Postgres-upgrade case) therefore takes the ≤2 branch: ask one question or state assumptions. The risk list the user asked for is never produced. This is exactly C2 from round 1, now failing in a new way.
   Edit: change `**If the user explicitly asked to be grilled, grill anyway.**` to `**If the user explicitly asked to be grilled, challenged, or for gaps/risks, grill anyway (and do Holes first).**`
2. **R2, the trigger condition for holes-first is narrower than the description.** The heading says "(when asked to stress-test or find gaps)", but the description now advertises "pushed back on or challenged" and "what they are missing", and has dropped "stress-test".
   Edit: `## Holes first (when asked to challenge the plan, find gaps or risks, or say what is missing)`.
3. **R3, "Never overwrite an existing file" is a dead end.** Re-grilling the same topic, or a single-file ADR log, gives the agent no allowed action. Round-1 proposed "append instead", but NEW kept only the prohibition.
   Edit: `Never overwrite an existing file; append a dated section to it instead.`
4. **R4, valuable lines dropped without a reason.** OLD said "Later work cites this file instead of re-asking." It also had "(or where the user prefers)". NEW lost both. The first is what makes the record useful to spec and later sessions.
   Edit: append `Later work cites this file instead of re-asking.` and change `else docs/decisions/<topic>.md` to `else docs/decisions/<topic>.md (or where the user prefers)`.
5. Minor, not a regression: the "Reply 'ok'..." line is attached to the markdown fallback, and it is unclear whether it applies with AskUserQuestion. Sizing lost "Before asking anything" but did not gain the "after a quick read" step, so the order is now merely unspecified, which is harmless. B13 ("materially") and B14 (reading the argument) were not addressed, and were not in the top 3.

### Fix verification
- Top-1 (≤2 shortcut and code-only framing): **fixed**. "Wait for a go-ahead" and explicit-grill override are in place, and the wording is now outcome-based. The "quick read before sizing" step is only partial.
- Top-2 (holes step): **partially**. The step exists, but see R1/R2.
- Top-3 (batch-ok, "you decide"/"enough", record after confirm, existing ADR location, no handoff): **fixed**, except that the "append instead" half was lost (R3).

### Simulations
- Normal: "/grill per-tenant rate limiting for our Express API". Explicit request; ~5 decisions; rounds of ≤4 with recommendations, ending in "Reply 'ok'". The user says "ok". The agent then summarises, the user confirms, and the agent finds the existing docs/adr/ and writes there. PASS.
- Edge: "Poke holes in my plan to pg_upgrade --link prod PG12 to 16 on Saturday" (auto). Size: perhaps 2 outcome decisions (window, rollback strategy), so the ≤2-auto branch applies. The agent asks one question and does not list --link rollback, extensions, replicas or ANALYZE. FAIL (R1). With R1's edit it would list the holes first, then grill. PASS.

Verdict: **REGRESSION (minor)**: R1, R2, R3, R4.

## spec

### Frontmatter
- YAML valid. Manual mode kept. The description is rewritten as menu text (293 chars) and states the output and the no-side-effects guarantee. Good. The "independently shippable" vs `Blocked by:` tension (B4) remains and is minor.

### Regressions / new problems
1. **S1, "never overwrite an existing file" blocks the common update case.** Re-running /spec on a topic to revise its spec has no allowed path. Round-1 said "update in place, or ask first".
   Edit: `never overwrite an existing file without asking; offer to update it in place or write to a new name.`
2. **S2, the "ask what to spec" prompt misfires.** With `/spec add dark mode` in a fresh session, the argument names the topic but contains no decisions, so "ask what to spec" asks something the user already answered.
   Edit: `If neither contains decisions, say so and ask for them (or suggest running /grill first); don't invent requirements.`
3. **S3, minor contradiction.** "Write the full spec anyway" for one-PR work conflicts with "2–6 slices" in the description and body.
   Edit: append to the Fits-one-PR bullet `(a single slice is fine then)`.
- Nothing valuable from OLD was lost. The removed text was only the auto-trigger phrasing, which was dead in manual mode.

### Fix verification
- Top-1 (one-PR refusal): **fixed**.
- Top-2 (commit offer, pushed-path links): **fixed**.
- Top-3 (source fallback, block-every-slice question, >6 stop): **fixed**. The wording of the ask misfires (S2).

### Simulations
- Normal: "/spec docs/decisions/auth.md". The agent reads it, writes docs/specs/auth.md with 4 slices, shows the list, offers to commit, and creates no issues. PASS.
- Edge: "/spec add dark mode", fresh session. There are no decisions, so the agent asks "what should I spec?", which is redundant (S2). If the user then gives decisions and it fits one PR, the agent offers a plan. If the user still wants the spec, it must contradict "2–6" (S3). If docs/specs/dark-mode.md exists, the agent is stuck (S1). PARTIAL.

Verdict: **REGRESSION (minor)**: S1. S2 and S3 are small rule misfires introduced by the new text.
