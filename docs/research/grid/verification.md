# Grid search: verification / QA / "prove it works" skills

Date: 2026-10-10. Baseline: `/home/user/C-Skills/.claude/skills/prove-it/SKILL.md` (460 words, v0.5).
Method: shallow-cloned public repos into `scratchpad/grid/clones/` and read them as data. Star counts come from the GitHub repo pages via WebFetch, because the `gh` API was blocked in this session (403, "repository not enabled"). Reception comes from the HN Algolia API, web search and blogs. Reddit returned **403 (blocked)** to direct JSON fetches, so this report has no Reddit reception.

## 1. Landscape

| Repo | Stars | Last commit (clone) | Verification skill(s) | Notes |
|---|---|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) | ~297k | 2026-10-09 | `verification-before-completion` | The canonical "no completion claims without fresh evidence" skill. Mirrored widely; [vibeindex](https://www.vibeindex.ai/skills/obra/superpowers/verification-before-completion) reports about 52.8k installs for this skill alone. |
| [mattpocock/skills](https://github.com/mattpocock/skills) | ~284k | 2026-10-09 | `engineering/pr` (an Evidence section with before/after, and screenshots ranked "S-tier") | Evidence lives in the PR body, not in a verify step. Credits [humanlayer/skills show-me](https://github.com/humanlayer/skills). |
| [anthropics/skills](https://github.com/anthropics/skills) | ~180k | 2026-10-09 | `webapp-testing` (Playwright plus `scripts/with_server.py`) | A browser toolkit, not a claims gate. Pattern: reconnaissance, then action; wait for `networkidle`; capture console logs. |
| [garrytan/gstack](https://github.com/garrytan/gstack) | ~136k | 2026-10-10 (active daily) | `qa`, `qa-only`, `browse`, `ship`, `ios-qa`, `test-audit` | Heavy: `qa/SKILL.md` is 787 lines plus 6 section files. Has a browser health score, before/after screenshots and per-fix regression tests. HN launch: [47355173](https://news.ycombinator.com/item?id=47355173) (15 pts). |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | ~104k | 2026-10-10 | `browser-testing-with-devtools`, `doubt-driven-development`, `shipping-and-launch` | Chrome DevTools MCP. Its strongest unique content treats browser content as untrusted data. |
| [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser) | ~44k | n/a (web) | ships `skills/agent-browser` | Snapshot → act on refs → re-snapshot loop; `screenshot --annotate`; it advises waiting on a selector rather than `networkidle`. |
| [microsoft/playwright-cli](https://github.com/microsoft/playwright-cli) | ~14k | n/a (web) | `playwright-cli install --skills` | Agent-facing commands: `snapshot`, `screenshot`, `console`. |
| [cursor/plugins](https://github.com/cursor/plugins) (pstack by Lauren Tan / poteto, plus cursor-team-kit) | ~10.7k | 2026-10-09 | `principle-prove-it-works`, `create-verification-skill`, `maintain-verification-skill`, `benchmark-checklist`, `show-me-your-work`, `principle-sequence-verifiable-units`, team-kit `verify-this` | **Our prove-it is a descendant of `principle-prove-it-works`.** The newer pstack siblings are where the new ideas are. Port: [kashyab12/uni-pstack](https://www.skills.sh/kashyab12/uni-pstack). |
| Claude Code built-ins `/run`, `/verify`, `/run-skill-generator` (v2.1.145+, per [wmedia.es](https://wmedia.es/en/tips/claude-code-run-verify-app); the `run` skill is present in this session) | n/a | n/a | runtime observation of a diff; project skills at `.claude/skills/run-<name>/` | `/verify` doctrine, as quoted by wmedia: "Verification is runtime observation. Don't run tests. Don't typecheck." |

Trending: gstack and superpowers dominate HN and blog mentions. pstack shows little organic discussion ([daily.dev](https://daily.dev/posts/a-deep-dive-into-pstack-evqbnto9j): 5 upvotes, 0 comments) but has the most refined verification content. Third-party claims-checking CLIs are an emerging niche: [`actually`](https://pkg.go.dev/github.com/Soldsoul86/AAA/actually) checks "tests pass" claims against the last test run in the transcript and flags claims made after a later edit; [claimproof](https://pypi.org/project/claimproof/) is a vendor that claims 12,578 of 18,008 confident success claims fixed nothing (unaudited); cngx is on Product Hunt.

## 2. Mechanisms extracted (from the actual files)

### superpowers `verification-before-completion` (`skills/verification-before-completion/SKILL.md`)
- **Iron Law:** "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE. If you haven't run the verification command in this message, you cannot claim it passes."
- **Gate:** IDENTIFY the command → RUN the full command fresh → READ the full output, check the exit code, count failures → VERIFY → only then claim.
- **"Requires / Not sufficient" table:** "Build succeeds" requires exit 0, and "linter passing" does not count. "Regression test works" requires the red-green cycle, and "test passes once" does not count. "Agent completed" requires a VCS diff, and "agent reports success" does not count. "Requirements met" requires a line-by-line checklist, and "tests passing" does not count.
- **Red flags:** "should", "probably", "seems to"; satisfaction before verification ("Great!", "Perfect!", "Done!"); "just this once"; "ANY wording implying success".
- **Regression red-green:** "Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)".
- **Requirements:** "Re-read plan → Create checklist → Verify each → Report gaps".

### pstack `principle-prove-it-works` (`cursor/plugins/pstack/skills/principle-prove-it-works/SKILL.md`)
- Check the real thing, not a proxy: process liveness, the actual value, "suspect the observation method before suspecting the system". **We already have all of this.**
- "Script the check": a deterministic, re-runnable script whose output is kept as an artifact. The uni-pstack port adds "Check the full chain: does data flow from input to output? … test the full communication path end-to-end."

### pstack `create-verification-skill` / `maintain-verification-skill`
- Generates `.cursor/skills/verify-<app>/` with **Launch** (plus readiness signal and teardown), **Doctor** (a read-only "is this instance worth driving?" check), **Drive** (real selectors and stable handles), **Evidence**, **Cleanup** ("kill what you started", evidence survives teardown), **Helpers**, and a `features/` map with one file per user feature.
- Proof standards in the Evidence section: "exercise the real user path, not internal setters or test-only endpoints; capture the action and the resulting state, not just the final screen; verify side effects (files written, rows inserted, messages sent) alongside what's visible; … When the safe path is a dry-run or test mode, verify what it actually skips by observing … some dry-runs still touch the network."
- "A generated skill that was never executed is a draft, not a deliverable." The maintain pass drives every feature live and opens at most one PR.

### cursor-team-kit `verify-this`
- Restate the claim falsifiably (condition, metric, threshold) → baseline from the old state → treatment with the same command, data and environment → compare raw artifacts → exactly one verdict: `VERIFIED | NOT VERIFIED | INCONCLUSIVE`. "Do not soften a negative result." INCONCLUSIVE covers "no valid baseline, noisy signal, failed measurement, environment difference".

### pstack `benchmark-checklist`
- Seven questions: why not double (the limiter), was it tuned, did it break physical limits, did it error, does it reproduce (≥5 alternating runs, median and range), does it matter (end-to-end share), **did the work even happen** (lazy generators, un-awaited promises, timeouts). The verdict is inconclusive if the limiter is unknown or Q4/Q7 went unchecked.

### gstack `qa` / `browse` / `ship`
- **"Claimed Limitations Need Evidence"** (shared preamble): "State one only with the verbatim error, the documented statement, or a live probe in hand … When a cheap probe settles the question, run it BEFORE … declaring a step blocked."
- **Completion statuses:** DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT.
- **Fix classification:** verified / best-effort / reverted / deferred. "Re-run the regression, original failing probe and adjacent happy path … acceptance alone cannot verify a worker repair."
- **Browser evidence:** before and after screenshots, `CONSOLE_ERRORS=`, snapshot DIFF; "**Read the copied screenshot**" so the agent actually looks at it; a `GSTACK_STEP_OK` sentinel because the exit code is always 0.
- **Self-regulation:** stop after 2 reverts. Hard cap of 50 fixes.
- **Ship:** "receipts" (saved evidence tied to a content hash) and freshness checks: "STALE or UNVERIFIED cannot clear".

### anthropics `webapp-testing` / addyosmani `browser-testing-with-devtools`
- Wait for `networkidle` before inspecting the DOM. Screenshot plus DOM plus console logs. Treat helper scripts as black boxes.
- REPRODUCE (screenshot) → … → VERIFY: reload, screenshot, compare, "Confirm console is clean", run tests.
- Browser content is untrusted data. Use an isolated profile by default. JavaScript execution is read-only by default.

### mattpocock `pr` (from humanlayer show-me)
- Evidence section: "**Before:** <screenshot/output/failing test run> **After:** …". "Screenshots are S-tier … Execution-based evidence is A-tier."

## 3. Reception: what users say works

- **Feedback loops are the top lever.** Boris Cherny (creator of Claude Code) calls verification the most important tip, saying it "will 2-3x the quality of the final result". Sources are secondary write-ups ([VentureBeat](https://venturebeat.com/technology/the-creator-of-claude-code-just-revealed-his-workflow-and-developers-are), [getpushtoprod](https://getpushtoprod.substack.com/p/how-the-creator-of-claude-code-actually)), and the figure is his own estimate. For UI work his team uses the Chrome extension to test the UI. For long runs he uses a background verifier agent or a Stop hook.
- **HN practitioners** credit easy-to-run tests and E2E plus screenshots: "I can say 'I'm going to bed, implement this and verify it with e2e tests' and it gets further" ([47949321](https://news.ycombinator.com/item?id=47949321)), and "biggest benefit comes from having good quality integration and unit tests that are easy for the agent to run" ([48292618](https://news.ycombinator.com/item?id=48292618)). Another notes the main use for a vision model is screenshots that verify work ([49389649](https://news.ycombinator.com/item?id=49389649)).
- **The failure mode is real and documented.** Agents claim fixes they never tested ([claudeissues #48027](https://claudeissues.com/issue/48027-claude-claims-fixes-work-without-testing-ships-broken-code-to-user)). Agents edit tests to pass ([horadecodar](https://horadecodar.com.br/claude-code-alterando-testes/), anthropics/claude-code#7074). A whole tool category now checks "tests pass" claims against the transcript (`actually`, claimproof, cngx), and the most common failure they target is a claim made *after a later edit* or with *no run at all*. This supports a freshness rule.
- **gstack:** the HN thread is mostly enthusiasm about velocity, plus a concern that "exit code 0 (all green)" while the agent looped on a wrong config. There was no specific reception for /qa. A YouTube walkthrough is linked from the thread ([Q6nem-F8AG8](https://www.youtube.com/watch?v=Q6nem-F8AG8)).
- **superpowers:** the HN launch ([47341827](https://news.ycombinator.com/item?id=47341827)) drew little discussion. Adoption shows in install counts and mirrors instead (dozens of forks of `verification-before-completion` on skills.sh, claudemarketplaces and others).
- **No controlled study** found comparing verified and unverified agent runs. All evidence is anecdotal.

## 4. Comparison with our prove-it

Where we are already stronger than most sources:
- The 5-level evidence ladder, with "Below level 4, don't write done". No other skill grades evidence. gstack's verified/best-effort and verify-this's three verdicts are coarser.
- Sizing (text-only edits skip the skill), safety tiers for environments, "suspect the check before the system" combined with "never weaken a red check", and the throwaway-script rule.
- Brevity: 460 words, versus superpowers at about 900 and gstack qa at about 8k or more.

Gaps found:
1. **Freshness.** Nothing says evidence must postdate the *last edit*. This is the #1 pattern the claims-checking tools catch, and it is superpowers' Iron Law.
2. **Reading the whole output.** There is no rule against tail/grep/filtered runs or ignoring the exit code. Superpowers' gate step 3 covers it, and so does gstack's sentinel ("exit code is always 0").
3. **Requirements coverage.** We report "one line per claim" but never say the claims are *the user's requirements*. Superpowers: "Requirements met → line-by-line checklist, not tests passing".
4. **Real user path and side effects.** We say "check the real thing" but not "not via internal setters or test-only endpoints", "check side effects", or "dry-run modes may still act". All three come from pstack create-verification-skill.
5. **Negative or blocked results.** There is no verdict wording for "it does not work". Our "Not verified" line invites a story instead of the verbatim blocker (gstack's Claimed Limitations; verify-this's "do not soften").
6. **UI evidence.** Level 5 has no guidance for UI. A screenshot that was taken but not looked at, or that has console errors, is the common miss (gstack "Read the copied screenshot"; addyosmani "confirm console is clean"). The built-in `run` skill exists and should be named.
7. **Red-flag wording.** We forbid "done/fixed/works" but not hedges ("should work now", "probably") that imply success.
8. **Perf claims.** Nothing covers them. benchmark-checklist Q5 and Q7 are cheap and catch the worst errors.

## 5. Proposed edits (exact text)

Net growth is about 130 words, bringing the skill to about 590. Each edit gives its source and the evidence for it.

**E1 – Freshness rule (new first rule).** Source: superpowers Iron Law; `actually` CLI. Evidence: the claims-checking tool category exists to catch claims made after a later edit.
Old (line 29):
```
- **Check directly.** Read the actual value, query the real process, open the real file - not mtimes, cached output, or a subagent's self-report.
```
New:
```
- **Fresh evidence only.** Output from before my last edit doesn't count - re-run after the final change, in this turn.
- **Check directly.** Read the actual value, query the real process, open the real file - not mtimes, cached output, or a subagent's self-report (check its diff and output yourself).
```

**E2 – Read the whole result.** Source: superpowers gate step 3 ("Full output, check exit code, count failures"); gstack's sentinel rule.
Insert after E1:
```
- **Read all of it.** Check the exit code and the pass/fail/skip counts, not a `tail` or `grep`. A filtered run (`-k`, one file) proves only that subset; say so.
```

**E3 – Real path and side effects.** Source: pstack `create-verification-skill` (Evidence proof standards).
Old (line 30):
```
- **Re-run the original failure.** For a fix, run the exact repro that failed before and show it passing now.
```
New:
```
- **Re-run the original failure.** For a fix, run the exact repro that failed before and show it passing now.
- **Use the user's path.** Drive the real entry point, not internal setters or test-only endpoints, and check side effects (files written, rows, messages sent) as well as what's shown. Don't trust a dry-run flag's name - observe what it skips.
```

**E4 – UI and live evidence.** Source: gstack browse ("Read the copied screenshot"; `CONSOLE_ERRORS=`); addyosmani ("Confirm console is clean"); anthropics webapp-testing (`networkidle`); built-in `run` skill (`.claude/skills/run-<name>/`). Evidence: Cherny's team verifies UI through a browser; HN users report screenshots as the main vision use.
Insert after E3:
```
- **UI changes:** drive the page (the `run` skill, or Playwright if installed) after it has loaded, then open the screenshot and look at it, and check the console for errors. A screenshot I haven't viewed is not evidence.
```

**E5 – Report: requirements, verbatim blockers, honest negatives, no hedges.** Source: superpowers (requirements checklist; red-flag words), verify-this ("Do not soften a negative result"), gstack ("Claimed Limitations Need Evidence").
Old (lines 38–46):
````
One line per claim, then the overall level (the lowest of them):

```
Verified: <claim> — <command or method> — <result> — level <n>
Overall: level <n>
Not verified: <what I could not check, and why>
```

Below level 4, don't write "done", "fixed", or "works" - write what was checked and what remains unproven.
````
New:
````
One line per claim - one for each thing the user asked for, re-read from the request, not just the ones the tests cover - then the overall level (the lowest of them):

```
Verified: <claim> — <command or method> — <result> — level <n>
Failed: <claim> — <command> — <actual output>
Overall: level <n>
Not verified: <what I could not check> — <the verbatim error or missing access>
```

Below level 4, don't write "done", "fixed", or "works", and don't hedge into them ("should work now", "probably fixed") - write what was checked and what remains unproven. Report a failure as a failure.
````

**E6 – Perf claims (optional, one line).** Source: pstack `benchmark-checklist` Q4, Q5 and Q7.
Insert into Rules:
```
- **Speed or memory claims:** same machine, at least 5 alternating runs per side, report the median and range; count errors and confirm the work actually ran in the timed region. A gap within run-to-run noise is "no measurable difference".
```

**E7 – Description triggers (small).** Source: verify-this's trigger list ("prove it works", "did this fix it", "show me the evidence").
Old: `...and when the user asks to verify, confirm, or check that something actually works (locally or on staging).`
New: `...and when the user asks to verify, confirm, prove, or show evidence that something actually works (locally or on staging).`

Optional, low priority. Source: superpowers red-green regression pattern. Add to "Re-run the original failure": "If I added a regression test, show it fails with the fix stashed." `diagnose` step 5 already covers this for bug fixes, so it is only worth adding if prove-it is used on fixes that bypass diagnose.

## 6. New skill?

- **Project-local "create a verification skill": not warranted as our own skill.** pstack's `create-verification-skill` is excellent, but Claude Code now bundles `/run` plus `/run-skill-generator`, which write `.claude/skills/run-<project>/` (SKILL.md plus driver), and `/verify`, per the [wmedia.es tip](https://wmedia.es/en/tips/claude-code-run-verify-app) (third-party). The `run` skill is visible in this session and "first looks for a project skill". Building a parallel generator would duplicate and conflict with it. Do this instead: E4 names `run`. If we want something, add one optional line to prove-it: "If I drove the app by hand twice, offer to save the recipe as a project run skill (`/run-skill-generator`)". That extends our existing "propose scripting it" rule. Borrowing pstack's **Doctor** and **evidence survives cleanup** ideas is worthwhile only if we ever write such a generator.
- **Browser QA skill: rejected.** gstack `/qa` depends on its own browser binaries, telemetry, report directories and per-fix commits (787 lines plus sections). anthropics `webapp-testing` and the built-in `run` already cover driving a browser. The marginal value lies in the evidence rules (E4), not in a new skill.
- **`benchmark-checklist` as a separate skill: maybe later.** It is the one standalone idea with no overlap. Fold E6 in now. Promote it to a `measure` skill only if perf claims become frequent; pstack keeps it separate because it is about 700 words.

## 7. Rejected ideas and why

| Idea (source) | Why rejected |
|---|---|
| ALL-CAPS Iron Law, "Skip any step = lying", the rationalization table (superpowers) | Anthropic's Claude 4.x prompting guidance warns that aggressive emphasis now overtriggers; the content is kept in calm form in E1, E2 and E5. The tables roughly double the length. |
| "Don't run tests. Don't typecheck." (built-in `/verify`) | Conflicts with our ladder, where tests are level 4 and the repo's checks come first. We keep runtime observation as level 5 instead. |
| Health score, per-fix atomic commits, 50-fix cap, TODOS.md updates, learnings log, telemetry (gstack qa) | This is a QA-and-fix workflow, not a verification gate, and commits are out of scope for prove-it. The HN thread raised the telemetry concern. |
| Artifact directory `/tmp/verify-this/<slug>/{baseline,treatment,diff}` (verify-this) | Clutter, and a sensitive-data risk; verify-this itself hedges this. Our throwaway script plus inline output is enough. |
| Separate VERIFIED / NOT VERIFIED / INCONCLUSIVE verdict (verify-this) | Overlaps the level ladder. The useful part, honest negatives, is kept as the `Failed:` line in E5. |
| Baseline-vs-treatment capture for every claim (verify-this) | Too expensive by default. "Re-run the original failure" already gives a before/after for fixes, and E6 covers perf. |
| TSV decision log plus cross-model trail review (pstack show-me-your-work) | Built for long unattended runs and needs another model family. It belongs with `handoff`/`reflect` if anywhere. |
| PR-body Evidence section with before/after screenshots (mattpocock pr) | A PR-writing concern, not verification. Could go into a future PR skill. |
| Untrusted browser content, profile isolation (addyosmani) | Important but belongs to browser tooling (the `run`, Chrome and built-in browser skills already carry it), not to the claims gate. |
| Doubt-driven fresh-context adversarial reviewer (addyosmani) | A review posture, not evidence of behaviour. It overlaps `interrogate` and `code-review`. |
| Stop hook that enforces verification deterministically (Cherny) | A harness setting, not skill text. Could be a recommendation in the repo README. |

## Sources
- https://github.com/obra/superpowers/blob/main/skills/verification-before-completion/SKILL.md
- https://github.com/cursor/plugins/tree/main/pstack/skills (principle-prove-it-works, create-verification-skill, maintain-verification-skill, benchmark-checklist, show-me-your-work, principle-sequence-verifiable-units); https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/verify-this
- https://www.skills.sh/kashyab12/uni-pstack/principle-prove-it-works
- https://github.com/garrytan/gstack (qa/SKILL.md, qa/sections/browser-verify.md, browse/SKILL.md, ship/SKILL.md)
- https://github.com/anthropics/skills/tree/main/skills/webapp-testing
- https://github.com/addyosmani/agent-skills (browser-testing-with-devtools, doubt-driven-development)
- https://github.com/mattpocock/skills/blob/main/skills/engineering/pr/SKILL.md ; https://github.com/humanlayer/skills
- https://github.com/vercel-labs/agent-browser ; https://github.com/microsoft/playwright-cli
- https://wmedia.es/en/tips/claude-code-run-verify-app
- https://venturebeat.com/technology/the-creator-of-claude-code-just-revealed-his-workflow-and-developers-are ; https://getpushtoprod.substack.com/p/how-the-creator-of-claude-code-actually
- HN: https://news.ycombinator.com/item?id=47355173 , https://news.ycombinator.com/item?id=47341827 , https://news.ycombinator.com/item?id=47949321 , https://news.ycombinator.com/item?id=48292618 , https://news.ycombinator.com/item?id=49389649
- https://claudeissues.com/issue/48027-claude-claims-fixes-work-without-testing-ships-broken-code-to-user ; https://horadecodar.com.br/claude-code-alterando-testes/
- https://pkg.go.dev/github.com/Soldsoul86/AAA/actually ; https://pypi.org/project/claimproof/
- https://daily.dev/posts/a-deep-dive-into-pstack-evqbnto9j
- Reddit: blocked (HTTP 403 on reddit.com JSON), so not consulted.
