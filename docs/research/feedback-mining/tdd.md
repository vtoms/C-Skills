# TDD skill vs first-hand feedback

**Corpus:** 651 keyword hits (obra/superpowers 172, mattpocock/skills 142, HN 127, gstack 94, others 116). I triaged by title and keyword density, then read about 45 threads in full. The scripts are `analysis/tdd_filter.py` and `tdd_list.py`, and the extracts are `tdd_hits.json`, `tdd_gh.txt` and `tdd_hn.txt`. Issue text was treated as data only.

**Our skill:** `.claude/skills/tdd/SKILL.md` (37 lines).

## 1. Clusters (independent reports)

| # | Cluster | Reports | Ours? |
|---|---------|---------|-------|
| A | **Structural RED.** A compile, import or missing-symbol failure was taken as RED, so the assertion was never shown to catch anything. | mattpocock#24, #1210 (maintainer accepted a one-line fix), obra#2046, obra#2146 (kylekellogg, a separate harness), obra#2452; HN cadamsdotcom 45296208, Nizoss 44844503 | **Handled.** L17: "It must fail **on an assertion**, not on an import or syntax error. If the unit doesn't exist yet, add a stub…" |
| B | **RED fails, but not on the named bug.** The arrange step or the stub never exercises the behaviour. A BOM test stayed green with the stripping code deleted, and guard tests only went red after each safeguard was weakened. | obra#2092, obra#2452, plus the proxy-RED half of #1210 and #2046 | **Partial.** L17 "first name the bug this test would catch" and "If the test passes immediately, check it can fail at all". The stub only has to return *a* wrong value, not the wrong value of the named bug. **Gap → E1** |
| C | **Edge and boundary cases skipped.** Tests sample the middle of a range, and edge cases are left unasked. | mattpocock#1074 (research eval: untested edges caused 37.6% of false greens), obra#489 ([0,1) tested only at 0.25/0.5/0.75), mattpocock#590, #514 (asks for hardening after green); HN giancarlostoro 49168692 | **Gap.** L13 "simplest first" and L24 "add a behaviour for any requirement no test covers". Nothing prompts for edges. **→ E2** |
| D | **No proof that RED happened.** The agent claims TDD but never showed a failing run. | obra#994 (merged by the maintainer) plus lucasburkholder in its thread ("only when I ask 'Did you ever see a test fail?' does it admit it never did"); HN cadamsdotcom 45281161 ("can we watch it fail"); obra#2458 (test and implementation run in one command) | **Partial.** L17 "Run it." The L24 report doesn't ask for the evidence. **→ E3 (optional)** |
| E | Tautological or can't-fail assertions | obra#2494; HN torben-friis 46586118 (`assert.Equal(true,true)`) | **Handled.** L29 "Never recompute them the way the code does… Reject a test that would still pass if the code returned `undefined`" |
| F | Agent edits or weakens tests to get green | HN sReinwald 46693275; mattpocock#1060; HN theYipster 48110605 | **Handled.** L18 and L36 |
| G | Writes all tests first (horizontal slicing) | HN Nizoss 44844503, esperent 47331445; obra#2047 | **Handled.** L36 and the one-at-a-time loop |
| H | Refactor step skipped (praised when kept) | mattpocock disc#641 (Finster evals); HN Nizoss 44778147 | **Handled.** L19 |
| I | No test harness for a layer | obra#2422; mattpocock#967 | **Handled.** L10 "If there is no test setup, propose one and confirm before installing anything" |
| J | Seam prompt gives no trade-offs; no human attached | mattpocock#607, disc#1091, #883 | **Handled.** L11 "each with one line on what it catches and misses… otherwise pick… and state it" |
| K | Ceremony and token cost; TDD used where it doesn't fit (browser, config) | mattpocock#529, #746, #1124, #894; HN tmach32 48772878, wccrawford 48977845 | **Handled** by the description's exclusions: "Not for… UI/glue/config changes, or prototypes" |
| L | Skill not invoked, or TDD silently skipped inside orchestrators | mattpocock#367, #479, #1035, #111; obra#384, #566, #853, #1576, #373, #2386; HN hooks posts (cadamsdotcom, Nizoss) | Triggering and orchestration problem (see §4) |
| M | Praise: red/green TDD makes agent code trustworthy | HN simonw 46576201, 46384118, 48417571; sd9 47245046; czk 43336341; vnglst 46432394 | Supports the core loop |

## 2–3. Proposed edits (gaps only)

**E1 (cluster B).** L17. Evidence: obra#2092, obra#2452, mattpocock#1210.
- old: `If the unit doesn't exist yet, add a stub with the final signature that returns a wrong value.`
- new: `If the unit doesn't exist yet, add a stub with the final signature that returns the wrong result of the bug I named (e.g. the input unchanged), so red shows the test catches that bug.`

**E2 (cluster C).** L13. Evidence: mattpocock#1074, obra#489, mattpocock#590.
- old: `a short ordered list of test *names*, simplest first.`
- new: `a short ordered list of test *names*, simplest first, ending with the edges the spec implies (empty, each limit and the values either side, invalid input).`
- An edge left out is already reported, because L24 says "report… what was deferred".

**E3 (cluster D, optional, low cost).** L24. Evidence: obra#994 (plus lucasburkholder in the same thread), HN 45281161.
- old: `report what is covered and what was deferred`
- new: `report what is covered (quoting the red assertion failure for each behaviour) and what was deferred`

## 4. Not worth acting on

- **L (invocation and enforcement):** this is a routing or hook problem, not skill text. Commenters on HN say prose rules get ignored and hooks are the fix. Our description already has explicit triggers.
- **K (cost and fit):** our scope exclusions already cover it. mattpocock rejected #746 and #1124 because they argued from reading the text, not from a failing session.
- **Bug-fix RED must reproduce the bug** (#1210, the extraction case in #2146): our skill sends bug fixes to `diagnose`. Check that skill instead, not this one.
- **Single reports:**
  - testability causing design pollution (obra#1248; closed as stale, and it pulls against our "inject the clock")
  - property-based testing (mattpocock disc#339)
  - tests as the deliverable (obra#2230)
  - judging prompt or content quality (obra#1900)
  - conflict over running the full suite (obra#2445)
  - flaky same-tick race (obra#2485; belongs to debugging, and L31 already bans fixed sleeps)
  - ecosystem neutrality (addyosmani#404; ours is already language-neutral)
- **Refactoring examples** (obra#437): declined upstream to keep the skill concise, and our L19 already covers it.
