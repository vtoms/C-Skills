# Agent Skills leaderboard and gap analysis (as of 2026-10-10)

## Method and caveats
- Stars and forks were read from github.com repo and topic pages via WebFetch on 2026-10-10. The GitHub REST and search APIs are blocked in this session; the MCP github tools were not used.
- Last activity is the HEAD commit date from `git clone --depth 1` into `scratchpad/grid/clones/` (read only, nothing executed).
- Trending data comes from github.com/trending (daily and weekly) on 2026-10-10.
- Install counts are skills.sh All Time figures (https://skills.sh). **Caveats on installs:**
  - Counts are inflated by bulk installs. `npx skills add mattpocock/skills` installs the whole pack, so every mattpocock skill gets a similar floor of about 200-400K.
  - Count gaming is visible. Many impersonator repos named `*/superpowers` (magentosh, 101-skills, skills-shell, qu-skills, bankai-skills, its-a-skill-issue) sit near the top with ai-image or video skills, and they dominate the 24h trending view.
  - Use relative rank inside one pack as the signal, not the absolute numbers.
- Stars are rounded as GitHub displays them.

## 1. Leaderboard (skill and workflow packs for coding agents)

| # | Repo | Stars | Forks | Last commit | Trending / notes |
|---|---|---|---|---|---|
| 1 | [obra/superpowers](https://github.com/obra/superpowers) | 297k | 26.5k | 2026-10-09 | The canonical methodology pack: 15 skills (brainstorming, writing-plans, executing-plans, subagent-driven-development, worktrees, finishing-a-branch, writing-skills, TDD, debugging, verification). v5.1 reworked worktrees to "never fight the harness" ([blog](https://blog.fsck.com/2026/05/04/superpowers-5.1/)). |
| 2 | [mattpocock/skills](https://github.com/mattpocock/skills) | 284k | 23.8k | 2026-10-09 | **#2 weekly trending (+8,156/wk) and daily trending (+1,737/day).** Holds 9 of the top 22 all-time skills on skills.sh. 38 SKILL.md files. |
| 3 | [multica-ai (forrestchang)/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) | 218k | 22.0k | 2026-04-20 | A single CLAUDE.md of Karpathy-derived rules. Daily trending (+279). |
| 4 | [anthropics/skills](https://github.com/anthropics/skills) | 180k | 21.3k | 2026-10-09 | Official. Includes frontend-design (972K installs), skill-creator (402K), webapp-testing, mcp-builder, doc-coauthoring, docx/pdf/pptx/xlsx. |
| 5 | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | 160k | 8.6k | 2026-10-10 | "Laziest senior dev": minimal-code persona plus /ponytail-review, /ponytail-audit, /ponytail-debt. #2 on topic agent-skills. |
| 6 | [github/spec-kit](https://github.com/github/spec-kit) | 141k | 12.6k | n/a | Spec-driven development toolkit. |
| 7 | [garrytan/gstack](https://github.com/garrytan/gstack) | 136k | 20.2k | 2026-10-10 | 63 SKILL.md files: /office-hours, /plan-*-review, /qa with a persistent Chromium daemon, /ship, /land-and-deploy, /careful, /freeze, /guard, /cso, /investigate, /retro. [aicoolies review](https://aicoolies.com/reviews/gstack-review) scored it 88 and called /qa the standout. |
| 8 | [juliusbrussee/caveman](https://github.com/juliusbrussee/caveman) | 111k | 6.4k | 2026-10-08 | Token-saving terse output; caveman alone has 567K installs. |
| 9 | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | 104k | n/a | 2026-10-10 | 25 skills: spec-driven, planning, incremental-implementation, browser-testing-with-devtools, security-and-hardening, ADRs, shipping-and-launch, code-simplification. |
| 10 | [thedotmack/claude-mem](https://github.com/thedotmack/claude-mem) | 99.2k | n/a | 2026-10-08 | Persistent cross-session memory. **Weekly trending +3,850.** #1 on topic claude-skills. |
| 11 | [leonxlnx/taste-skill](https://github.com/leonxlnx/taste-skill) | 94.4k | 6.4k | 2026-10-09 | Frontend "taste" and anti-slop UI skills; design-taste-frontend has 589K installs. |
| 12 | [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) | 76.8k | n/a | 2026-07-24 | Curated list (864 SKILL.md files, mostly integrations). |
| 13 | [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | 55.4k | n/a | 2026-10-10 | Curated list. |
| 14 | [blader/humanizer](https://github.com/blader/humanizer) | 55.4k | n/a | 2026-09-27 | Removes AI-writing tells. Same type as our `unslop`. |
| 15 | [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done) | 64.3k | 5.4k | 2026-05-31 (archived) | Spec-driven and meta-prompting system. Continues as [open-gsd/gsd-core](https://github.com/open-gsd/gsd-core) (10.4k). |
| 16 | [bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) | 54.0k | 6.1k | 2026-10-06 | Agile persona-driven method (37 SKILL.md files). |
| 17 | [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser) | 43.8k | 3.0k | 2026-10-09 | Browser CLI for agents; its skill has 1.1M installs (#5 all time). |
| 18 | [wshobson/agents](https://github.com/wshobson/agents) | 40.3k | n/a | 2026-10-04 | Multi-harness marketplace (184 skills). |
| 19 | [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | 35.5k | n/a | 2026-10-08 | Curated list of more than 1,000 skills. |
| 20 | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | 32.2k | 2.8k | 2026-08-28 | React best practices (787K installs), web-design-guidelines (720K). |
| 21 | [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) | 28k | n/a | 2026-08-26 | More than 380 skills, broad and shallow. |
| 22 | [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) | 27.4k | n/a | 2026-10-10 | File-based planning with session recovery and a completion gate. |
| 23 | [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) | 25.5k | 2.1k | 2026-10-10 | 36 skills: brainstorm, plan, work, code-review, compound, worktree, commit-push-pr, babysit-pr, resolve-pr-feedback, prototype, test-browser, noslop, handoff. |
| 24 | [cursor/plugins](https://github.com/cursor/plugins) | 10.7k | 1.0k | 2026-10-09 | Weekly trending (+1,125). Bundles pstack, ralph-loop, continual-learning, orchestrate, thermos, advisor. |
| 25 | [trailofbits/skills](https://github.com/trailofbits/skills) | 7.5k | 634 | 2026-10-09 | 44 security plugins: differential-review, insecure-defaults, sharp-edges, variant-analysis, supply-chain-risk-auditor, property-based-testing, mutation-testing, second-opinion. |
| 26 | [backnotprop/pstack](https://github.com/backnotprop/pstack) | 1.5k | 106 | 2026-10-07 | Our closest sibling: blast-radius, interrogate, reflect, unslop, tdd, architect, swarm, arena, create-verification-skill, plus 24 principle skills. Distributed through cursor/plugins. |

Adjacent repos with high stars that are not engineering-workflow packs: nexu-io/open-design (100k), tt-a1i/archify (81.6k, codebase diagrams), Egonex-AI/Understand-Anything (85.8k, code knowledge graph), coreyhaines31/marketingskills (54.1k), cathrynlavery/diagram-design (48.8k, **daily trending +1,189**), K-Dense-AI/scientific-agent-skills (48.3k), heygen-com/hyperframes (60.3k, **weekly +4,003**), morluto/rea (69.3k, **daily #1 +25.8k**, agentic reverse engineering), anthropics/knowledge-work-plugins (28.7k, daily trending).

Topic pages: https://github.com/topics/agent-skills?o=desc&s=stars and https://github.com/topics/claude-skills?o=desc&s=stars

### skills.sh all-time top engineering skills (installs)
These are rows from the skills.sh All Time list, keeping engineering-relevant entries in their original order. Rank shows each entry's position on that list. Rows marked (type we have) or (overlaps built-in) are marked again in the third column.

| Rank | Skill | Installs | Repo | We have? |
|---|---|---|---|---|
| 1 | find-skills | 3.8M | vercel-labs/skills | n/a (installer) |
| 2 | grill-me | 1.3M | mattpocock | **yes (grill)** |
| 3 | grill-with-docs | 1.1M | mattpocock | partly (grill + spec) |
| 4 | **improve-codebase-architecture** | 1.1M | mattpocock | **no** |
| 5 | agent-browser | 1.1M | vercel-labs | **no** |
| 6 | tdd | 1.1M | mattpocock | yes |
| 8 | **frontend-design** | 972K | anthropics | **no** |
| 9 | handoff | 958K | mattpocock | yes |
| 11 | **triage** | 920K | mattpocock | **no** |
| 12 | **prototype** | 916K | mattpocock | **no** |
| 17 | domain-modeling | 795K | mattpocock | partly (grill) |
| 19 | **teach** | 789K | mattpocock | **no** |
| 22 | **codebase-design** | 772K | mattpocock | **no** |
| 28 | diagnosing-bugs | 757K | mattpocock | yes (diagnose) |
| 56 | code-review | 708K | mattpocock | built-in /code-review + interrogate |
| 58 | **implement** | 698K | mattpocock | **no** |
| 61 | wayfinder | 645K | mattpocock | no |
| 70 | **resolving-merge-conflicts** | 551K | mattpocock | **no** |
| 123 | **git-guardrails-claude-code** | 451K | mattpocock | **no** |
| 125 | setup-pre-commit | 441K | mattpocock | no |
| 164 | skill-creator | 402K | anthropics | built-in (anthropic-skills:skill-creator) |
| 167 | writing-for-agents | 396K | mattpocock | no |
| 175 | brainstorming | 387K | obra | partly (grill) |
| 210 / 221 | to-prd / to-issues | 352K / 339K | mattpocock | partly (spec) |
| 239 | writing-great-skills | 307K | mattpocock | built-in skill-creator |
| 243 | systematic-debugging | 286K | obra | yes (diagnose) |
| 248 | writing-plans | 269K | obra | yes (spec) |
| 260 | requesting-code-review | 247K | obra | built-in |
| 269 | verification-before-completion | 233K | obra | yes (prove-it) |
| 272 | **executing-plans** | 230K | obra | **no** |
| 275 | **subagent-driven-development** | 223K | obra | **no** |
| 277 | write-a-skill | 220K | mattpocock | built-in |
| 278 | zoom-out | 219K | mattpocock | no |
| 279 | implement-spec | 218K | mattpocock | **no** |
| 286 | retro | 208K | mattpocock | partly (reflect) |
| 287 | dispatching-parallel-agents | 207K | obra | no |

## 2. Skill types we lack (by evidence)

**Coverage today.** Our pack covers interview (grill), spec, debugging (diagnose), verification (prove-it), impact (blast-radius), TDD, adversarial review (interrogate), handoff, plain, unslop (humanizer-type) and reflect (retro-type).

**Built-ins in this Claude Code.** /code-review, /security-review, /simplify, /init, anthropic-skills:skill-creator, /run (launch and drive the app), /loop, update-config (hooks), EnterWorktree and `--worktree` (native worktrees), and the built-in browser and Claude in Chrome.

| Type | Repos (stars) | Installs | Reception | Overlap with built-ins |
|---|---|---|---|---|
| **Codebase architecture / deep modules** | mattpocock improve-codebase-architecture plus codebase-design (284k); pstack architect | 1.1M + 772K | #4 all time. Many mirrors (hackernoon, tessl, ui-skills, skillselion). Rests on Ousterhout's deep-modules idea. | Low. /simplify is diff-scoped cleanup; this is a repo-wide refactor search. |
| **Throwaway prototype** | mattpocock prototype; EveryInc ce-prototype (25.5k) | 916K | AI Hero video "Don't waste time on specs: /prototype instead" (2026-07-23). The SKILL.md is only 26 lines. | None. |
| **Execute a plan / implement slices (subagent-driven)** | mattpocock implement plus implement-spec; obra executing-plans, subagent-driven-development, dispatching-parallel-agents; EveryInc ce-work; addyosmani incremental-implementation | 698K + 218K; obra 230K / 223K / 207K | Core of superpowers (297k). Reviewers warn the plan-then-TDD ceremony is overkill for small tasks ([dupple](https://dupple.com/learn/best-claude-code-skills-2026)). | None. It is the natural next step after our `spec`. |
| **PR writing / finishing a branch / merge conflicts** | mattpocock pr plus resolving-merge-conflicts; obra finishing-a-development-branch; EveryInc ce-commit-push-pr, ce-babysit-pr, ce-resolve-pr-feedback; gstack /ship, /land-and-deploy | 551K (merge conflicts) | Appears in 4 of the top 6 engineering packs. | Low. No built-in for PR bodies or conflict resolution. |
| **Git / destructive-command guardrails** | mattpocock git-guardrails-claude-code; gstack /careful, /freeze, /guard | 451K | Present in both top-traffic packs. Low cost: a hook setup. | Partial: permission rules, auto mode and update-config can do it by hand. |
| Browser QA | vercel-labs agent-browser (43.8k); gstack /qa; addyosmani browser-testing-with-devtools; EveryInc ce-test-browser; anthropics webapp-testing | 1.1M | gstack /qa praised as the standout ([aicoolies](https://aicoolies.com/reviews/gstack-review)). HN Show HN: Playwright skill (189 points). | **High.** Built-in /run plus Chrome or the built-in browser, and our prove-it. |
| Frontend design / taste | anthropics frontend-design; leonxlnx taste-skill (94k); vercel web-design-guidelines; gstack design-* | 972K, 589K, 720K | The most-cited UI pick in roundups ([dupple](https://dupple.com/learn/best-claude-code-skills-2026)). | None, but it is domain-specific and off-theme for a process pack. |
| Issue triage | mattpocock triage | 920K | Install rank is high (bundle effect). | None. Needs an issue tracker. |
| Teach / learning | mattpocock teach; cursor teaching; [DrCatHicks/learning-opportunities](https://github.com/DrCatHicks/learning-opportunities) (HN 253 points) | 789K | HN interest in learning-not-skipping (Lathe, 402 points). | None. |
| Research to markdown | mattpocock research (12 lines) | not in top 287 | v1.1 video. | Partial (deep-research skill exists in this environment). |
| Writing skills / skill-creator | obra writing-skills (681 lines); anthropics skill-creator; mattpocock writing-great-skills | 402K / 307K / 220K | Superpowers meta-skill. | **High.** Built-in skill-creator. |
| Security review | trailofbits (7.5k, 44 plugins); addyosmani security-and-hardening; gstack /cso | modest | Trail of Bits brand. | **High.** Built-in /security-review; interrogate has a security lens. |
| Git worktrees | obra using-git-worktrees; EveryInc ce-worktree | not in top 287 | superpowers 5.1 moved to "never fight the harness" now that worktrees are native. | **High.** Native EnterWorktree and --worktree. |
| Memory / context | thedotmack/claude-mem (99k, trending); planning-with-files (27k); caveman (111k) | 567K (caveman) | Strong trending. | Partial (CLAUDE.md, auto memory). Tooling, not a skill type. |

## 3. Top 5 candidate additions (value vs cost and ceremony)

1. **improve-architecture (deep-module refactor search)** has the strongest evidence of any gap: 1.1M installs (#4 all time), plus 772K for its companion codebase-design.
   - Cost: medium, about 70 lines plus a vocabulary section.
   - Built-in overlap: none. It complements blast-radius and grill.
   - Ceremony to keep: findings first, then grill the one the user picks.
2. **prototype (throwaway, never committed)** has 916K installs (#12), a dedicated AI Hero video, and is also in EveryInc.
   - Cost: very low (a 26-line exemplar).
   - It fills the gap between grill/spec and tdd. Our tdd already says "not for prototypes", so there is a natural seam.
3. **implement (execute spec slices, optionally through subagents with per-slice verification)** draws on mattpocock implement (698K) and implement-spec (218K), plus obra executing-plans (230K) and subagent-driven-development (223K).
   - It is the core loop of the #1 pack and the obvious next step after our `spec`.
   - Ceremony risk is high (reviewers call superpowers overkill on small tasks). Keep it lean: one slice, then prove-it, then commit.
4. **pr / finish-branch (PR body, conflict resolution, landing)** combines mattpocock pr and resolving-merge-conflicts (551K) with obra finishing-a-development-branch, EveryInc commit-push-pr and resolve-pr-feedback, and gstack /ship.
   - It appears in 4 of the top 6 packs, and no built-in covers it.
   - Cost: low to medium.
5. **git-guardrails (hook that blocks push, reset --hard, clean -f, branch -D)** has 451K installs from mattpocock and matching gstack /careful, /freeze and /guard.
   - Cost: very low; it can be a one-shot setup skill.
   - Partial overlap with permission rules and update-config, but packaged guardrails are popular.

**Not recommended:** worktrees (native now), skill-creator/writing-skills (built-in), security review (built-in /security-review plus interrogate), browser QA (built-in /run, browser tools and prove-it), and frontend-design (domain-specific; it can be installed from anthropics/skills directly).

## Sources
- https://skills.sh (All Time); https://skills.sh/trending
- https://github.com/trending?since=daily ; https://github.com/trending?since=weekly
- https://github.com/topics/agent-skills?o=desc&s=stars ; https://github.com/topics/claude-skills?o=desc&s=stars
- Repo pages linked in the tables above
- https://blog.fsck.com/2026/05/04/superpowers-5.1/
- https://aicoolies.com/reviews/gstack-review ; https://codex.danielvaughan.com/2026/03/30/gstack-garry-tan-production-skills-toolkit/
- https://dupple.com/learn/best-claude-code-skills-2026 ; https://designrevision.com/blog/best-claude-code-skills
- https://podwise.ai/podcasts/18410 (AI Hero videos: /prototype, mattpocock/skills v1.1)
- https://hackernoon.com/skills/mattpocock-improve-codebase-architecture
- HN: https://hn.algolia.com/api/v1/search?query=claude%20skills&tags=story&numericFilters=points%3E150 (Claude Skills 816 points; Playwright skill 189; learning-opportunities 253; Lathe 402)
- https://emelia.io/hub/superpowers-claude-code-framework
