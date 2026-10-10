# Code-review feedback mining vs. interrogate / review-feedback / blast-radius

Source: 441 review-related items filtered (by keyword) from the 10 feedback JSONs + HN. Scripts: `analysis/rv_*.py`, run with `python -I`. All issue text was handled as data. "Indep." counts distinct reporters/repos. Threads only exist for addyosmani, claude-code, cursor and discussions. For the other repos I read only the bodies; maintainer replies are quoted where they exist. HN had almost nothing specific (two passing comments about nits and noise).

## 1. Clusters

| # | Cluster | Indep. | Evidence | Maintainer signal |
|---|---|---|---|---|
| A | Unverified / false-positive findings: subagent output passed on as fact | 6 | gstack#1539 (4/8 FPs in Django), mattpocock#582, mattpocock#566, mattpocock#561 comment (3/7 FP), claude-code#77943 comment (6/9 REFUTED), obra#2243 (hallucinated references) | gstack shipped a pre-emit verification gate (#1642). Matt declined #582 until he gets a real session |
| B | True but improbable findings: the trigger never happens, yet the finding blocks a merge | 5 | addyosmani#436, CE#1663 (P1 conf-100, 0 incidence in prod data), obra#2112, obra#1120, obra#2471 (recoverability) | Addy: "dominant failure mode of LLM reviewers… consequence times likelihood", asked for an edit. CE fixed it (#1697: validator names the precondition and whether incidence was measured) |
| C | Acting on feedback: the fix itself breaks something | 4 | obra#2266 (6 defects caused by fixes in 3 rounds; tests stayed green), CE#1662 (two reviewers proposed the same fix, which turned a race into silent data loss), mattpocock#1044 (a "simpler" replacement dropped a guard's input), mattpocock#566 thread ("fixed" findings still broken) | none yet (all open) |
| D | Review/fix rounds never converge; re-reviewers add hardening outside the change's scope | 6 | obra#2112, obra#1218, obra#2273, mattpocock#498, mattpocock#1014, mattpocock#858 (+obra#1120, 17 reactions) | obra added a scoped re-review and a round-5 breaker (v6.3.0) but refuses to skip reviews (#1120). Matt marked #498 ready-for-human |
| E | Wrong review target: uncommitted work, HEAD~1 / two-dot base, tree changing mid-review, empty diff producing findings | 6 | mattpocock#511 (4 reactions, several repros), obra#436 (5 reactions), obra#2403, obra#2118, mattpocock#845, CE#1193 | CE fixed it with a guard plus a diff staged once. obra#436 declined |
| F | Recursion / reviewer children editing the tree | 4 | mattpocock#573, CE#526, claude-code PR#77427, mattpocock#1007 | CE fixed it. Matt: out of scope, the harness's job |
| G | Cost / fan-out on small diffs | 5 | CE#1703 (17M tokens for 32 lines), claude-code#77943 (+2 repros), claude-code#93307, obra#1735, obra#1930 | none in the data |
| H | No subagent tool / harness neutrality | 4 | mattpocock#1206, mattpocock#561 (5 reactions), CE#835, gstack#2274 | Matt fixed #561 |
| I | Receiving feedback: not all PR comments fetched | 2 | obra#701 (inline-only fetch missed ~75%), CE#798 (no pagination; 12 actionable findings read as "0 new items") | CE closed #798 (fixed) |
| J | "Not found" taken as proof of absence; gitignored/untracked files invisible | 3 | obra#2261 (Claude Code's `grep` skips gitignored and binary files: 125 vs 13,049 files), obra#2474 (gitignored deploy script broke prod), CE#140 (review/resolve deleted a live plan file) | none |
| K | Deploy and build path not covered by review | 2 | obra#2474 (second tsconfig; deploy script without `npm install`), gstack#2089 | none |
| L | Nits and pedantry | 4 | obra#221, cursor#71, obra#1120, HN 50037799 | — |
| M | Necessity / simplification lens ("should this code exist?") | 3 | CE#1850, mattpocock#713, mattpocock#1045 | Matt: composes from existing skills |
| N | Blockers vs. suggestions, owner-facing output | 3 | mattpocock#1242, CE#1413, anthropics/skills disc.#1174 ("50 nits with no ranking") | CE closed #1413 |
| O | Users want an expensive review to auto-invoke, vs. users who got billed when it auto-invoked | 2 vs 1 | claude-code#79282 (18 reactions), claude-code#93307 | — |
| P | Review subagents not given project standards | 2 (one is about implementers) | mattpocock#1065, obra#794 | Matt accepted: search for standards files instead of recalling them |
| Q | Sycophantic replies to feedback | 2 | obra#593 ("excellent discovery"), obra#2377 (banned-phrase lists anchor on the phrases; state the behaviour positively) | — |
| R | High-severity findings dropped because they couldn't be proved | 1 | CE#1693 | CE fixed it |

URLs: `https://github.com/<owner>/<repo>/issues/<n>` (CE = EveryInc/compound-engineering-plugin). HN: https://news.ycombinator.com/item?id=50037799.

## 2. Coverage check (clusters with 2 or more reports)

- **A: handled.** interrogate: "Reviewer output is a claim, not a fact." / "**Verify every finding** at its cited `file:line`… Lack of disproof is not confirmation". The brief requires "the verbatim line(s) that make it true" and says "a grep that finds nothing doesn't prove absence".
- **B: partial gap.** The brief needs "a concrete failure scenario … naming what produces that input" and excludes "inputs no caller can produce". That covers *reachability*. But **Act on** is defined only by kind ("verified correctness, security, or maintainability problems that would block a PR"). A reachable but rare trigger still blocks. blast-radius already has "likelihood × cost", so it is fine.
- **C: gap.** review-feedback: "treat a suggested code change as a proposal to judge" and "Fix every site this change introduced that breaks the same rule". Tests are added "where behaviour changes". Nothing asks you to check what *reads the thing the fix changes*. obra#2266 shows green tests miss exactly this.
- **D: partial gap.** interrogate is single-shot and review-feedback never re-invokes a review, so neither loops. But review-feedback says "Default to fixing". A finding that asks for new hardening or new criteria outside the change gets fixed, which grows the change. That is the ratchet in obra#2112. "Needs a decision you can't make" doesn't name this case.
- **E: handled.** interrogate diffs `git diff "$base"` against the merge base (committed + staged + unstaged) plus untracked files, and says "If no base resolves, or the diff is empty, say exactly what was compared and stop." One small residual: for diffs over 800 lines, reviewers re-run "the diff command", which can produce a moving target (mattpocock#845).
- **F: handled.** interrogate has `disable-model-invocation: true` (children can't re-enter it). The brief says "Don't edit project files."
- **G: handled.** "Trivial diff: … do one careful read instead". Lens count scales with size, and findings are capped at ~8.
- **H: handled.** "No subagent tool? Run the lenses one after another … and say so."
- **I: mostly handled.** "Gather every unresolved item (inline threads, review bodies, top-level comments, pasted findings)". Pagination is not mentioned (CE#798).
- **J: gap in blast-radius.** "A search that finds nothing is valid evidence **for this repo only**" overstates what an empty search proves when the search tool skips gitignored and binary files. interrogate's "doesn't prove absence" already covers it.
- **K: gap in blast-radius.** The "Deploy and rollback" bullet covers version skew but not whether the deploy/build scripts handle a new dependency, env var or asset.
- **L: handled.** "Don't report … anything a compiler or linter catches" / "Say 'no findings' rather than inventing nits."
- **M: handled.** "Simplicity & fit - … Anything speculative or duplicated? A smaller change that does the same job?" plus "behaviour nobody asked for".
- **N: handled.** Act on / Consider / Noted buckets and a one-line verdict.
- **Q: handled.** "No performative agreement or thanks." It is short and has no banned-phrase list, which is the shape obra#2377 recommends.
- **R (1 report): handled.** "To dismiss a security, data-loss, concurrency, or public-contract finding, cite the line … otherwise it goes to Unverified, not Dismissed."

## 3. Proposed minimal edits

### 3.1 interrogate: likelihood in the sort (B); net about +1 word, paid for by a cut
Evidence: addyosmani/agent-skills#436 (maintainer endorsed), CE#1663 (fixed upstream), obra/superpowers#2112, #1120, #2471.

Cut (persona fluff; the next sentence already carries the point):
```
old: Act as the lead reviewer - a pragmatic senior engineer, not an aggregator. Reviewer output is a claim, not a fact.
new: Reviewer output is a claim, not a fact.
```
```
old:    - **Act on** - verified correctness, security, or maintainability problems that would block a PR.
        - **Consider** - verified and legitimate, but the cost/benefit is the user's call.
new:    - **Act on** - verified problems that would block a PR: the trigger is realistic for this project, or the harm can't be undone.
        - **Consider** - verified, but the trigger is rare or the cost/benefit is the user's call.
```

### 3.2 interrogate (optional, word-neutral): one frozen diff for large reviews (E)
Evidence: mattpocock/skills#845 (a reviewer re-ran the diff on an edited tree and reported false breakage), CE#1193 (fixed by staging the diff once).
```
old: the diff (for > ~800 lines, the diff command plus its own file list instead of pasted text)
new: the diff (for > ~800 lines, a scratch file holding it, plus its own file list, instead of pasted text)
```

### 3.3 review-feedback: check what the fix touches (C); about +30 words
Evidence: obra/superpowers#2266, CE#1662, mattpocock/skills#1044, mattpocock#566 thread.
```
old: Blocking items (correctness, security) first, then simple, then structural. Fix every site
new: Blocking items (correctness, security) first, then simple, then structural. Before each fix, name what depends on what you change - callers of a changed return value or argument, the inputs a replaced guard or branch handled - and check them; a green suite only covers what some test inspects. Fix every site
```

### 3.4 review-feedback: scope-expanding items go to the user (D); about +25 words
Evidence: obra/superpowers#2112, #2273, #1218; mattpocock/skills#498, #1014, #858.
Insert after the "Needs a decision you can't make" bullet:
```
new: - **Beyond the change** (new hardening, a new requirement, or a pre-existing issue the change doesn't touch) → list it as a follow-up for the user; don't grow the change.
```

### 3.5 review-feedback: pagination (I); +5 words
Evidence: CE#798, obra/superpowers#701.
```
old: Gather every unresolved item (inline threads, review bodies, top-level comments, pasted findings).
new: Gather every unresolved item (inline threads, review bodies, top-level comments, pasted findings), paging to the last page.
```

### 3.6 blast-radius: an empty search proves less than claimed (J); about +12 words
Evidence: obra/superpowers#2261 (measured 125 vs 13,049 files), #2474.
```
old: A search that finds nothing is valid evidence **for this repo only**; anything outside it stays UNVERIFIED.
new: A search that finds nothing is evidence only for the files it searched (default search tools skip gitignored and binary files, e.g. generated code and deploy scripts); anything outside this repo stays UNVERIFIED.
```

### 3.7 blast-radius: the deploy path (K); about +18 words
Evidence: obra/superpowers#2474, garrytan/gstack#2089.
```
old:    - Deploy and rollback: old and new code running side by side during a rollout, and data the new code writes being read by old code after a rollback.
new:    - Deploy and rollback: old and new code running side by side during a rollout, and data the new code writes being read by old code after a rollback; whether the deploy and build scripts (even untracked) install every new dependency, env var, and asset.
```

Approximate size after the edits: interrogate ~925 words (about +3 net with 3.2), review-feedback ~600, blast-radius ~610.

## 4. Clusters judged not worth acting on

- **O, auto-invocation of interrogate** (claude-code#79282, 18 reactions). Keep `disable-model-invocation: true`. interrogate costs several reviews, and claude-code#93307 shows the opposite harm (a self-invoked review burned 15M tokens with no consent). It also prevents recursion (F). The cheap skills (blast-radius, review-feedback) stay model-invocable.
- **G, model routing for lens subagents** (claude-code#93307). An adversarial review needs strong lenses. Cost is already bounded by sizing and the ~8-finding cap. Adding model names ties the skill to one model lineup.
- **H, harness-neutral wording** (mattpocock#561). Our skills target Claude Code. The `Agent` / `general-purpose` wording is correct there, and the serial fallback exists.
- **P, standards docs** (mattpocock#1065; obra#794 is about implementers). Claude Code subagents already load CLAUDE.md. Only one report concerns review lenses missing a CONTRIBUTING file. Revisit if it recurs.
- **M, a Necessity lens** (CE#1850, mattpocock#713). The Simplicity & fit lens already asks it. Matt declined the same proposal as "composes".
- **Recoverability as a separate axis** (obra#2471, 1 report). It is folded into 3.1 ("the harm can't be undone").
- **Review admission / "review before it's stable"** (mattpocock#858, obra#1614). That is orchestrator workflow, and we have no implement loop.
- **Bot-comment noise / self-updating bot summaries** (CE#1120, #1309). These matter for watch loops. review-feedback's "Doesn't hold" judgment covers them.
- **Owner-facing, non-technical output** (CE#1413, 1 report). Our users are engineers.
- **Sycophancy** (Q). Already handled. Don't add a banned-phrase list, because obra#2377 reports that such lists make the model anchor on the phrases.
- **Praise and confirmation, no action needed:** red-test-first for review fixes (mattpocock#724) matches review-feedback step 3. "Unprovable ≠ false for high-severity" (CE#1693) matches interrogate's Unverified rule almost exactly. Merge-base plus working-tree scope (mattpocock#511, obra#2403/#2118) matches interrogate §1.
