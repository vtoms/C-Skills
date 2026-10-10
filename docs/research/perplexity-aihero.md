# How Developers Actually Use Matt Pocock’s “Skills for Real Engineers”

## Executive finding

The durable value is concentrated in a small subset, not the whole pack. Developers repeatedly keep the **requirements/alignment layer** (`grill-me`, `grill-with-docs`, `to-spec`, `to-tickets`) and the **context-continuity layer** (`handoff`); `tdd`, `implement`, and `code-review` have narrower but credible repeat use. `diagnosing-bugs` is the only named skill for which a public controlled test found essentially no improvement over placebo or no skill.[^1]

The most defensible interpretation is that the pack is an **inspectable menu of engineering rituals**, not a demonstrated performance system. Its strongest evidence is qualitative—better requirement discovery, more explicit decisions, and better workflow structure—while the small amount of quantitative evidence is mixed and sometimes unfavorable.[^2][^3][^4]

## Method and limitations

This review counted a “positive mention” only when a distinct public source described actual or recurring use, a favorable result, or retention in a workflow. Marketing copy, install counts, stars, reposts, directory listings, and Matt Pocock’s own claims were excluded from the counts; GitHub issues were used mainly for observed defects and workarounds. Counts are therefore **minimum observed counts in the retrieved corpus**, not platform-wide popularity statistics.

Publicly indexed Reddit posts, Hacker News comments, GitHub issues, X posts/replies, and video transcripts were accessible. YouTube comment bodies were not reliably exposed by search, private Discord messages were not accessible, and X reply/quote-tweet indexing was sparse; consequently, no claim below is represented as a complete census of those channels. No located first-hand report in this review predates April 2026; if an older item is mentioned, it is explicitly marked **possibly outdated**.

## Skill retention ranking

“Mention count” below means **distinct, positive first-hand reports located**, using a deliberately conservative coding rule. Closely related aliases are grouped as requested.

| Rank | Skill | Sentiment | Positive mentions found | Best representative quote | Evidence and interpretation |
|---:|---|---|---:|---|---|
| 1 | `grilling` / `grill-me` | Mixed-positive | 10 | “It has been absolutely amazing and felt like a step change in the output quality.” | Regular-mileage reports say it improves understanding and adherence on complex features; others call it labor-intensive and overloaded with minor questions.[^4][^5][^6] |
| 2 | `grill-with-docs` | Positive | 5 | “I’ve found Grill with docs incredibly helpful; it identifies numerous overlooked issues.” | It is the preferred coding variant because it grounds the interview in the repository and preserves terminology/decisions; one team report says it adds effective structure.[^7][^8] |
| 3 | `to-spec` / `to-tickets` | Positive | 5 | “The most effective method for clarifying intent before diving into any coding.” | Users retain these as the bridge from discussion to durable, reviewable work items, including Go/C# projects and multi-agent orchestration.[^8][^9][^10][^11] |
| 4 | `handoff` | Positive, with durability caveat | 4 | “It condenses the dialogue into a document… [so] the subsequent agent [can] pick up.” | Users recommend it for context limits and cross-session continuity, but one long-term handoff user calls Pocock’s version temporary and vulnerable if the session ends before the handoff is written.[^12][^13][^14][^15] |
| 5 | `tdd` | Mixed-positive | 2 | “I only use 4–5… daily (`/tdd`, `/grill-with-docs`, `/diagnose`, `/to-issues`, `/zoom-out`).” | It appears in selective daily-use sets, but reports also warn that a single interleaved red-green loop can dilute attention; Pocock himself now emphasizes direct proof over mandatory formal TDD.[^16][^17][^18][^19] |
| 6 | `wayfinder` | Positive, niche | 2 | “Wayfinder and Grill-Me have provided me with insights… I hadn’t anticipated.” | It is kept for ambiguous, multi-stage projects and decision maps, not routine feature work; users add review gates before converting its output into tickets.[^20] |
| 7 | `implement` / `implement-spec` | Mixed | 1 | “I utilize mattpocock’s `/implement` skill for handling GitHub issues.” | One user reports effective use across roughly 140k lines of Go/C#, but another replaces generic implementation with company-specific specialist agents. The original `implement` also shipped temporarily unregistered, and `implement-spec` was new in v1.3, so retention evidence is immature.[^9][^8][^21][^22] |
| 8 | `code-review` | Mixed | 1 | “The review agent has consistently identified these issues for correction.” | It caught an over-specific 15-function design in one reported workflow, but users/issues question unverified subagent findings and command-name collisions.[^9][^23][^24] |
| 9 | `wait-what` | Mixed, easily replaced | 1 | “Matt Pocock wrote a skill `/wait-what`, to have Opus restate its response.” | It is referenced as a useful escape hatch for opaque prose, but persistent Claude output styles are a stronger replacement when readability is an always-on preference.[^25][^26] |
| 10 | `diagnosing-bugs` | Negative/uncertain | 0 | “The results were essentially the same across all groups.” | The only located controlled evaluation found no autonomous invocation in 16 trials and nearly identical hidden-test scores: 61.8 without a skill, 61.8 with placebo, and 62.6 with the real skill.[^1] |
| 11 | `prototype` | Mixed, insufficient retention evidence | 0 | “A small interactive prototype makes the trade-off concrete in seconds.” | The use case is persuasive for visual decisions, but no clear post-first-week endorsement was located; reports instead focus on command collision and accumulating “throwaway” branches.[^27][^28][^29] |

### What gets dropped

The clearest drop is **plain `grill-me` for repository coding**, replaced by `grill-with-docs`; even Pocock publicly said he had stopped using the former for code, while keeping it for open-ended, codebase-free decisions.[^30][^31] Developers also tend to drop the idea of installing or following the complete pack: one daily user named only five retained skills and described the rest as autocomplete noise, extra search tokens, and false-match risk.[^16]

`wait-what` is vulnerable to replacement by a global output style, generic `implement` is replaced by domain-specific implementation agents in at least one workflow, and `prototype` lacks evidence of regular retention.[^26][^8][^28] `diagnosing-bugs` should be treated as unproven rather than useful by default because the only controlled public comparison found no practically meaningful gain.[^1]

## Complaint prevalence

The prevalence labels are qualitative: **high** means repeated independent reports or a central recurring debate; **medium** means several concrete reports; **low** means one or two credible reports. They do not estimate a percentage of all users.

| Complaint requested | Observed prevalence | Evidence |
|---|---|---|
| Too many questions / too much grilling | High | Users describe useful sessions with 10+ questions, labor-intensive runs with many minor details, and batches where answering the first question invalidated four more.[^4][^5][^32] |
| Long sessions and context/token cost | High | Users explicitly move to clean sessions around 70% context; Pocock warns of a “dumb zone” around 120k tokens; the measured comparison took 148 minutes and an estimated $91.53 for the Pocock route.[^33][^34][^3] |
| Non-Claude behavior | Medium | GPT-family reports show premature implementation after grilling; Codex rejected unsupported frontmatter and lacked the wrapper’s expected generic Skill tool. A later GPT-6 Astra report described the model skipping `to-spec` and `to-tickets` entirely.[^35][^36][^37] |
| TypeScript/web-stack bias | Medium | Reviewers identify TypeScript/Node-specific skills such as `migrate-to-shoehorn` and Husky/lint-staged setup, while core planning skills remain mostly language-agnostic; successful Go/C# usage shows the bias is not universal.[^38][^39][^9] |
| Name clashes with built-ins | Medium | `/code-review` and `/prototype` collided with Claude Code built-ins; namespaced plugin invocation fixes the modern plugin case, while editable copies may require a local rename/fork.[^24][^28][^40] |
| Update/versioning pain | Medium | The official Claude marketplace remained pinned to 1.2.3 after v1.3, and local renames were overwritten by `skills update`; switching marketplace or fully forking were the reported workarounds.[^41][^24] |
| Desktop app vs CLI / harness mismatch | Low-medium | The Mac app made Matt’s global `code-review` unreachable in one report; Claude Desktop displays namespaced selection confusingly; Codex setup could write only to `CLAUDE.md` even though Codex reads `AGENTS.md`.[^24][^28][^42] |

## Top 10 criticisms

1. **The interview can become work rather than leverage.** A favorable user still described `grill-me` as labor-intensive, with a few important questions buried among many minor details; another observed five dependent questions in one batch, four of which became obsolete after answering the first.[^5][^32]

2. **The full workflow can cost more time and tokens than a more autonomous framework.** In the only located same-feature comparison, Superpowers finished in about 78 active minutes versus 148 and had an estimated API-equivalent cost of $34.04 versus $91.53. The Pocock run produced broader functionality but needed repair, and only three of eight workers received the full implementation skill, so this is directional rather than conclusive.[^3]

3. **The “63% token reduction” is not an end-to-end productivity result.** The original claim concerns the cost of **skill descriptions** after progressive disclosure, not total task tokens, developer time, or output quality; independent write-ups repeating the number do not add validation.[^43]

4. **Some instructions may duplicate—or degrade—knowledge already present in frontier models.** Hacker News critics argue that “always follow TDD” in `AGENTS.md` may be enough, and that verbose definitions can hamper a model if they are less accurate than its training; another critic describes much of the prose as low-utility “wax.”[^44]

5. **Public skill packs are not automatically transferable.** Experienced users argue that durable value tends to come from project- and organization-specific tribal knowledge, while imported instruction banks can produce surprising behavior and drift across agents.[^44]

6. **Model portability is claimed more strongly than it is delivered.** GPT-family models have skipped workflow gates and started implementation; Codex encountered unsupported metadata, missing dependency packaging, and a wrapper that expected a non-existent generic Skill tool.[^35][^37][^36]

7. **Review findings are not independently verified.** The current `code-review` design can aggregate two subagent reports without a mandatory primary-code verification phase, creating risk of false positives, missed files, and unsupported claims.[^23][^40]

8. **State and artifacts can be lost or become clutter.** Original `grill-me` decisions lived only in chat, while prototype/Wayfinder artifacts can accumulate on supposedly throwaway but permanently referenced branches.[^45][^29]

9. **Glossary language can improve compression but also create needless jargon.** One HN reader preferred the plain description “a lesson… is made real” over “materialization cascade”; a reply defended the term because it had been explicitly defined to avoid repeated explanation.[^44] The critique is therefore not that ubiquitous language is wrong, but that a glossary should encode domain distinctions rather than manufacture clever names.

10. **The ecosystem surface area creates operational friction.** Users have hit plugin version lag, missing skill registration, selective-install dependency failures, incorrect install syntax, built-in command clashes, and harness-specific instruction-file behavior.[^41][^21][^46][^47][^42]

## Measured evidence

### Debugging placebo test

A Reddit evaluator ran 16 headless trials to test autonomous activation of `diagnosing-bugs`; Claude never loaded it on its own. In forced-use testing on Haiku 5.5, five runs each produced mean hidden-test scores of 61.8 with no skill, 61.8 with a same-shaped placebo, and 62.6 with the real skill; the agent followed the methodology but the outcome was essentially unchanged.[^1] This is the strongest controlled evidence located, but it covers one bug/task design and one evaluator, so it rejects a broad performance claim rather than proving the skill never helps.

### Superpowers comparison

The Gray Cat tested the same frozen feature with Opus 5: Superpowers took roughly 78 minutes and 55.9 million tokens at an estimated $34.04, while the Pocock route took 148 minutes and an estimated $91.53. Superpowers passed the tested flow immediately; Pocock’s repaired version delivered more functionality, but the evaluator disclosed an invocation defect in which only three of eight workers received the full `implement` skill.[^3] A later comparison summarized this as 53% fewer tokens for Superpowers and approximately 861 versus 236 lines of code in favor of the broader Pocock implementation.[^2]

### Qualitative before/after reports

The best positive evidence is repeated but subjective: one HN user calls exhaustive grilling a “step change” in output quality and says Claude followed decisions exactly; a Reddit user says review consistently caught questionable implementation choices; another team says `grill-with-docs` effectively adds structure.[^4][^9][^7] No controlled A/B tests were located against gstack, GSD, BMAD, Spec-Kit, or plain plan mode, and one proposed GPT-6/Fable refinement explicitly disclosed that no controlled before/after runs had been performed.[^48]

## Top 5 workarounds

1. **Choose single-question or batch grilling explicitly.** Add a repository or global instruction such as “ask one question at a time” for careful decision trees, or invoke batch mode when throughput matters; users proposed preserving both modes because each fits a different cognitive workflow.[^49] For Claude Code, `AskUserQuestion` can render a batch as structured choices rather than an unreadable text wall.[^50]

2. **Persist decisions, then reset context.** Convert the grill into a spec/PRD, handoff, ADR, or glossary and start a clean session near 70% context rather than dragging the entire interview into implementation.[^33][^12][^34] For robust continuity, some users split handoff into a durable narrative plus a short reconstruction prompt or use hooks to log activity continuously.[^12][^15]

3. **Install only the working set—or fork it.** A reported daily set was `/tdd`, `/grill-with-docs`, `/diagnose`, `/to-issues`, and `/zoom-out`; selective installation reduces autocomplete clutter and routing noise.[^16] Where updates overwrite changes, copy the skill under a new name, remove it from `skills-lock.json`, record upstream provenance, and manually resync.[^24]

4. **Namespace commands and use the upstream marketplace.** Invoke collisions as `/mattpocock-skills:code-review` or `/mattpocock-skills:prototype`; to escape the marketplace’s stale pinned release, uninstall the official copy and install `mattpocock-skills@mattpocock`, then enable marketplace auto-update.[^40][^28][^41]

5. **Use Pocock for “what,” specialists for “how.”** One practitioner keeps `grill-with-docs → to-spec → to-tickets` upstream, then routes implementation and review to company-specific Python/standards agents; others combine `grill-me` with Superpowers or embed it into OpenSpec/C4/ADR workflows.[^8][^51]

## Senior-engineer critique

### Grilling before code

The strongest defense is that grilling externalizes requirements that otherwise remain tacit: users report 10+ questions producing exact adherence and unexpected insight into the problem domain.[^4] The strongest critique is proportionality—use it for consequential ambiguity, not every change—and model agency: repeated minor questions can obscure the few decisions that actually reshape the design tree.[^5][^32]

### Ubiquitous language and `GLOSSARY.md`

A durable domain vocabulary reduces repeated explanation across amnesiac sessions and gives generated names a stable source of truth; this is why `grill-with-docs` displaced plain `grill-me` for coding.[^31][^52] The senior-engineering failure mode is vocabulary theater: if a term such as “materialization cascade” is less comprehensible than the underlying sentence, the glossary has compressed text while increasing human decoding cost.[^44]

### Deep modules

The philosophy—large behavior behind a small, testable interface—is well aligned with agent constraints because it reduces the surface an agent must understand and limits change propagation. The critique is evidentiary: public praise largely explains the idea rather than measuring maintainability, defect rate, or agent token savings; HN critics also object that generic engineering concepts need not be redefined in elaborate prompt prose.[^53][^44]

### Tracer-bullet tickets

Vertical slices are one of the pack’s more defensible ideas: users keep `to-spec`/`to-tickets`, and the method produces independently deliverable features rather than schema/API/UI layers that only work after all are complete.[^8] The risk is process inflation: with strong frontier models, one critic argues that writing a full spec and ticket hierarchy is unnecessary for many tasks—discuss a few shippable PRs and execute them sequentially instead.[^54]

## Practical adoption verdict

For an experienced developer, the evidence supports starting with **four components**: `grill-with-docs` for ambiguous brownfield work, `to-spec`/`to-tickets` when work must survive across agents or people, `handoff` for deliberate context resets, and a locally adapted review/checklist. Keep `grill-me` for greenfield or non-code decisions; add `tdd`, `wayfinder`, and `prototype` only where the project’s risk profile justifies their overhead.[^8][^12][^27]

Do not adopt the pack as a monolithic methodology. Treat every skill as editable source, remove generic prose that does not change model behavior, encode organization-specific standards, and benchmark on representative tasks before claiming savings. The current public evidence does not establish that the full pack outperforms Superpowers, plain plan mode, or a concise project `AGENTS.md`; it establishes that a small subset helps developers create alignment and durable artifacts.[^1][^3][^44]

---

## References

1. [I tested a popular Claude Code debugging skill against ...](https://www.reddit.com/r/ClaudeAI/comments/1x1nvh8/i_tested_a_popular_claude_code_debugging_skill/) - Wanted to know if skills actually do anything, so I tested diagnosing-bugs from mattpocock/skills (o...

2. [Matt Pocock Skills vs Superpowers: 10 Things You Need to Know (Claude Code)](https://www.youtube.com/watch?v=RkWlEkPkxXo) - Matt Pocock skills vs Superpowers: the two biggest Claude skills packs for Claude Code, compared in ...

3. [I Tested Superpowers v6 vs Grill Me: The Results Are Shocking](https://www.youtube.com/watch?v=d8lxLTQhmPo) - Superpowers v6 used 53% fewer tokens than my Matt Pocock retry. I tested both on the same feature in...

4. [I have been using this super simple skill[0] to make Claude ...](https://news.ycombinator.com/item?id=49853409)

5. [Two skills I use to stop Claude from writing code before the ...](https://www.reddit.com/r/ClaudeAI/comments/1wjfmnf/two_skills_i_use_to_stop_claude_from_writing_code/) - Grill-me by Matt Pocock is amazing and a lot of inspiration for this came from that, what I found ab...

6. [what is agentic development, what am i missing?](https://www.reddit.com/r/ClaudeCode/comments/1wqm1ts/what_is_agentic_development_what_am_i_missing/) - what is agentic development, what am i missing?

7. [Recently was asked to become AI Lead for my team ...](https://www.reddit.com/r/ExperiencedDevs/comments/1ueibp5/recently_was_asked_to_become_ai_lead_for_my_team/) - A lot of my work over the last 1.5 years hasn’t involved a ton of dev work, so while I’m familiar wi...

8. [Matt Pocock's skills + my own specialist subagents: does this make sense?](https://www.reddit.com/r/ClaudeAI/comments/1wnszxk/matt_pococks_skills_my_own_specialist_subagents/) - Matt Pocock's skills + my own specialist subagents: does this make sense?

9. [Fable 5.1 Low uses about 15-30% more limits in my 20x](https://www.reddit.com/r/ClaudeCode/comments/1w6v4ji/fable_51_low_uses_about_1530_more_limits_in_my_20x/) - Fable 5.1 Low uses about 15-30% more limits in my 20x

10. [How do you keep up with 5+ agents at the same time?](https://www.reddit.com/r/ClaudeAI/comments/1wqroed/how_do_you_keep_up_with_5_agents_at_the_same_time/) - How do you keep up with 5+ agents at the same time?

11. [[Workflow] A Comprehensive 7-Step Claude Code ...](https://www.reddit.com/r/ClaudeWorkflows/comments/1wqlv1t/workflow_a_comprehensive_7step_claude_code/) - Generate specifications with /to-spec and then tickets with /to-tickets (Matt Pocock), followed by a...

12. [Handoffs are becoming a first-class pattern in Claude workflows. Here is how I have been thinking about them.](https://www.reddit.com/r/ClaudeAI/comments/1tjzqrx/handoffs_are_becoming_a_firstclass_pattern_in/) - Handoffs are becoming a first-class pattern in Claude workflows. Here is how I have been thinking ab...

13. [How to deal with small context?](https://www.reddit.com/r/Qwen_AI/comments/1vqexst/how_to_deal_with_small_context/) - How to deal with small context?

14. [deepseek users, how do you keep track of a long coding session](https://www.reddit.com/r/DeepSeek/comments/1ulmdih/deepseek_users_how_do_you_keep_track_of_a_long/) - deepseek users, how do you keep track of a long coding session

15. [I’ve been keeping some form of a handoff file since February, and the thing that always broke it was me forgetting to update it. I built one where the hooks do that part instead.](https://www.reddit.com/r/ClaudeCode/comments/1w4kv5f/ive_been_keeping_some_form_of_a_handoff_file/) - I’ve been keeping some form of a handoff file since February, and the thing that always broke it was...

16. [Add skills-manifest.json and per-skill CHANGELOG for selective install · Issue #159 · mattpocock/skills](https://github.com/mattpocock/skills/issues/159) - Problem The npx skills@latest add mattpocock/skills installer pulls the entire catalog. In practice,...

17. [Which skills do you usually add to your project?](https://www.reddit.com/r/ClaudeCode/comments/1wm837g/which_skills_do_you_usually_add_to_your_project/) - Which skills do you usually add to your project?

18. [Enhance TDD skill with a two-phase workflow to reduce ...](https://github.com/mattpocock/skills/issues/590) - This approach aims to reduce attention dilution by preventing the model from constantly switching be...

19. [AI Skills with Matt Pocock | VibeLeaderboard](https://www.vibeleaderboard.ai/intel/80f294f6-0ba5-4f80-a5d6-020999bf6134) - Matt Pocock, creator of the popular 'grill-me' Claude skill, explains why strong software fundamenta...

20. [Solo devs: what's your actual LLM agent orchestration setup for side projects?](https://www.reddit.com/r/LLMDevs/comments/1w6alkg/solo_devs_whats_your_actual_llm_agent/) - Solo devs: what's your actual LLM agent orchestration setup for side projects?

21. [implement is in engineering/ but missing from README.md ...](https://github.com/mattpocock/skills/issues/371) - skills/engineering/implement/SKILL.md exists on main, but implement is absent from both the top-leve...

22. [Matt Pocock](https://x.com/mattpocockuk/status/2107062474914550098) - mattpocock/skills v1.3 is out! - /pr (new) writes easy-to-read PR bodies, showing hard evidence that...

23. [Code Review Skill Should Verify Subagent Output Instead ...](https://github.com/mattpocock/skills/issues/582) - Add a mandatory verification phase to the code-review skill. The primary agent must: Treat every sub...

24. [code-review name clash with Claude Code built-in #483 - GitHub](https://github.com/mattpocock/skills/issues/483) - The /code-review skill name clashes with Claude Code's own internal /code-review skill. They serve s...

25. [nopus - deterministically detect and rewrite complex ...](https://www.reddit.com/r/PiCodingAgent/comments/1vp7p2m/nopus_deterministically_detect_and_rewrite/) - Matt Pocock wrote a skill /wait-what, to have opus restate it's response in more straightforward lan...

26. [Claude Code Output Styles Made Opus 5 Readable Again](https://www.youtube.com/watch?v=FQlhJE0rCk0&xstg=CAMSBhUDze3xHw==) - Claude Code output styles fixed what Opus 5 broke: readable answers. I'm an ex-Amazon AI engineer, a...

27. [grill-with-docs: detect UI/UX decision points and resolve ...](https://github.com/mattpocock/skills/issues/336) - Summary: Let grill-with-docs switch to a quick prototype path when the unresolved decision is clearl...

28. [Shorthand `/prototype` conflicts with hidden new Claude ...](https://github.com/mattpocock/skills/issues/1019) - CC is now bundling a hidden, not-yet-enabled, built-in "prototype" skill, as of 2.1.221 from a month...

29. ["throwaway" research and prototype branches can never ...](https://github.com/mattpocock/skills/issues/1020) - /prototype (step 6) captures the finished prototype on a prototype/<name> branch out of main. But th...

30. [Matt Pocock on X: "/grill-me is my most popular skill ever. I get 5-10 ...](https://x.com/mattpocockuk/status/2054808143041908936) - /grill-me is my most popular skill ever. I get 5-10 messages a day about how it’s changed people’s w...

31. [I stopped using /grill-me for coding. Here's what I use... - Daily.dev](https://daily.dev/posts/i-stopped-using-grill-me-for-coding-here-s-what-i-use-instead--q2ukv8cjn)

32. [grilling: rounds asked dependent questions together, fix ...](https://github.com/mattpocock/skills/issues/895) - The problem I kept hitting a case where dependent questions got asked in the same batch. Worst was f...

33. [How should /grill-me, /to-prd and /to-issues flow? #102](https://github.com/mattpocock/skills/issues/102) - You have a lot of concern about the context window, and I assumed that grill-me and to-prd would be ...

34. [9 Things People Get Wrong With My /grill-* skills — Summary & Key ...](https://rewiz.app/channels/@matt-pocock/9-things-people-get-wrong-with-my-grill-skills) - Matt Pocock reveals nine common mistakes in using grill-me/ gril-* style AI planning, plus practical...

35. [GPT 5.5 often jumps straight to implementation after /grill-me](https://github.com/mattpocock/skills/issues/240) - I've had this happen quite a few times already. When GPT runs out of questions, it begins implementi...

36. [Codex compatibility: unsupported SKILL.md frontmatter ...](https://github.com/mattpocock/skills/issues/360) - Codex compatibility: unsupported SKILL.md frontmatter keys in productivity skills Hi Matt, I tried i...

37. [grill-with-docs: gpt-6-Astra-low skips to-spec and to-tickets ...](https://github.com/mattpocock/skills/issues/1068) - Using gpt-6-Astra-low, I started with /grill-with-docs. After I answered the final interview questio...

38. [Matt Pocock's Skills Review: 54k Stars for Claude Code](https://andrew.ooo/posts/matt-pocock-skills-claude-code-review/) - Matt Pocock's 'Skills for Real Engineers' hit 53k GitHub stars in 90 days. Hands-on review of grill-...

39. [Matt Pocock's Skills, Actually Explained: A Critical Guide for ...](https://kaizencode.art/notepad/matt-pocock-skills-guide/) - Quick context if you haven't run into this: Matt Pocock is the TypeScript educator behind Total Type...

40. [code-review is clobbered by Claude built-in skill #1234](https://github.com/mattpocock/skills/issues/1234) - Claude's built-in skill and your skill shares the same name: "code-review". If you do not set disabl...

41. [Claude Code plugin does not update - still stuck on version ...](https://github.com/mattpocock/skills/issues/1164) - When following the installation instructions, to run claude plugins install mattpocock-skills the in...

42. [Make setup-matt-pocock-skills harness-aware when ...](https://github.com/mattpocock/skills/issues/558) - Summary setup-matt-pocock-skills currently prefers CLAUDE.md whenever that file already exists, even...

43. [Matt Pocock on X: "Announcing mattpocock/skills v1](https://x.com/mattpocockuk/status/2067259590488510471) - Announcing mattpocock/skills v1 - Achieved a 63% reduction in token cost for skill descriptions - Sp...

44. [AI Coding Agent Skills for Real Engineers - Hacker News](https://news.ycombinator.com/item?id=49529329)

45. [grill-me: no durable output artifact — decisions are lost ...](https://github.com/mattpocock/skills/issues/311) - Problem /grill-me produces excellent structured decisions through the interview, but writes nothing ...

46. [Skills cannot be installed independently/have ...](https://github.com/mattpocock/skills/issues/685) - Problem I ran into an issue when selectively installing skills from this repository. For example, I ...

47. [The documented one-skill install installs all 37, and three ...](https://github.com/mattpocock/skills/issues/1012) - Two things bit me while installing grill-with-docs from its docs page. Both are docs, not skills. I ...

48. [skill workflow refinements for GPT-6 Astra and Fable 5.1 ... - GitHub](https://github.com/mattpocock/skills/issues/1053) - Contribution The proposed changes are ready for review in amanthanvi/skills#1. Compare against upstr...

49. [Concern / Request: Don't replace grilling with batch-grill-me ... - GitHub](https://github.com/mattpocock/skills/issues/663) - @mattpocock I am concerned about the Batch Grill Me skill replacing grilling. After heavy usage the ...

50. [grilling: ask via native structured-question UI where ...](https://github.com/mattpocock/skills/issues/798) - grilling already batches every frontier question into one round instead of asking one at a time, tha...

51. [Spec-Driven Development with OpenCode and OpenSpec](https://www.youtube.com/watch?v=M3dp9u1wZes&vl=pt-BR) - OpenCode + OpenSpec for Spec-Driven Development with skills for git commit discipline, interviewing ...

52. [别急着让 AI 写代码，先把项目里的词讲清楚](https://gptkit.eth.limo/600117E4-40DD-4C26-90EF-42011932421B/) - 最近看了 Matt Pocock 的一段视频： 视频只有 15 分钟，讲的却不是某个新模型或提示词技巧，而是一个更基础的问题：让 AI 参与一个已有代码库时，怎样避免每次都从头解释业务名词和历史决定？...

53. [Matt Pocock's Claude Code Skills Beat Superpowers Now](https://www.youtube.com/watch?v=8D8ewFBJfFM&pp=ugUHEgVlbi1DQQ==) - Matt Pocock's Claude Code skills passed 13M downloads, so I studied all 51. As an ex-Amazon engineer...

54. [x.com · rockatanescu · statusAndrei Maxim on X: "I don't think writing a spec and splitting it...](https://x.com/rockatanescu/status/2107216121749209237) - I don't think writing a spec and splitting it into tickets is how you should use agents since Sol 5....

