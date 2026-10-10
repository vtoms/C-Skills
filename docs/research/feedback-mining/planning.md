# Planning-skill feedback vs our grill / spec / spike

Sources: feedback JSON in `cskills-run/feedback/` (filtered with `plan_filter.py`, `plan_dump.py`, `plan_hn.py` in this folder). 759 title hits across repos: mattpocock/skills 371, obra/superpowers 229, garrytan/gstack 76, EveryInc 52, addyosmani 14, anthropics 16. HN: 227 AI-related planning comments, mostly about grill-me and superpowers brainstorming.
Counting rules: one report per distinct reporter. Same-author duplicates (e.g. mp#198/#199) count once. AI-triage comments are not counted as reports. I give extra weight to maintainer rationale, both accepted and wontfix. URLs are `github.com/<repo>/issues/<n>` (mp = mattpocock/skills, sp = obra/superpowers, gs = garrytan/gstack, ce = EveryInc/compound-engineering-plugin).

## Praise (context for the bloat budget)
- HN keeps praising grill-me because it is short: "grill-me is literally 4 sentences!" (news.ycombinator.com/item?id=49714383), "a 5 line skill ... works quite well" (48440332), "Terse, to the point, and delivers outsized results" (48768350). Other praise: 49853409, 47804495, 49860859, 49948197. Superpowers brainstorming gets similar praise: 48846955, 47624894, 47217231, 47107125.
- HN complaints point the same way: sessions are front-loaded and exhausting, and the output is too big to review (48008938); "~3 hours, 20-40 questions" (47999687); "extraneous cognitive load" (49939666); "ceremony" (48772878).
- **Implication:** our grill is already 61 lines against the 4-5 line skill people praise. Every edit below is a word swap or about one line. Net growth is about +75 words in grill and +30 in spec.

## Clusters with ≥2 independent reports

### C1. Grill asks while exploration is still running; a subagent report gets treated as the user's answer (5 reports) — GAP
- Evidence: mp#948, mp#1104, mp#1245, mp#802, plus a second reporter in the #802 thread (toverux) and benshields, who keeps "a local fork specifically to stop this". The maintainer triaged #802 and #948 as observed failures and a "design call" (ready-for-human).
- Ours, grill L33: "Read the code or send a subagent while asking the rest of the frontier." This line *invites* the reported failure. A round goes out, then a subagent's result rewrites it, or the subagent's return is taken as the cue for round 2.
- Related (2 reports): the agent re-asks what the user or the issue already said (mp#1106, mp#1145 needs-info). Our "Never ask what can be looked up" covers the code but not the conversation.

### C2. Round format: options run inline, numbering restarts, statements instead of questions (≥6 reports) — GAP
- Options on one line each: mp#834 (11 reactions, plus 2 more +1s), mp#933 (6 reactions), mp#1057, mp#789. The maintainer kept #834 open as an observed failure.
- Numbering restarts at Q1 in a later round, so "q1 a" is ambiguous: mp#1154. The maintainer's agent brief there says "number questions across the whole conversation, never per round". Related: mp#789 (inconsistent numbering), mp#1115 (back-references by number).
- "Word each question so 'yes' accepts" turns questions into statements: mp#1249. Our L53 has exactly this wording.
- Jargon and hard-to-parse questions: mp#962, mp#994, mp#1067, mp#1096. The maintainer declined #1067 for lack of a real session. That is weak on its own, but a two-word fix comes free with the line above.
- Ours, L48-50: `**Q1 — <short title>** / <question, with concrete options>`. Nothing says how options are laid out or how numbering continues across rounds.

### C3. Agent starts implementing after the interview, even after "Agreed" (≥10 reports, 4 repos) — PARTIAL GAP
- Evidence: mp#134, mp#240 (several reporters in thread), mp#570 (2), mp#975 (2), mp#1068, mp#729; sp#1030; gs#287, gs#66; ce#514.
- Ours, L57: "**Do not implement until the user confirms the summary**". mp#1068 and mp#975 are exactly the case where the user confirmed or agreed and the agent took that as a go-ahead. Our gate opens at the same point theirs did.

### C4. Native question tool: AskUserQuestion vs plain text (pro ≈13, con ≈6) — HANDLED, one small gap
- Pro: mp#850 (10 reactions), mp#840 (4), mp#1107 (2), mp#798, mp#643, mp#192, mp#185, mp#19, mp#411; sp#114 (5), sp#388 (7); HN 49851420, 49948197, 49060902.
- Con: mp#149, mp#168, a commenter in mp#850, a commenter in sp#388 (jmonloop), mp#824 (toverux).
- Maintainers: mattpocock refuses on portability grounds (.out-of-scope/native-question-tool.md). obra says the tool "guided [users] to always pick from list".
- Ours prefers the tool, which matches the majority of reports. The concrete failure people describe is that the tool covers the background text written above it: mp#850 (WhiskyTangoFawks), sp#114 (j10t-dev), mp#986, gs#1208, gs#879. A plain-text opt-out is also missing.

### C5. Decisions get lost between grill → spec → tickets (≥9 reports) — GAP in spec
- Evidence: mp#341 (18 reactions; the maintainer called it "a really good idea"), mp#689, mp#853 (2), mp#924, mp#959, mp#1078 (2 reactions), mp#310; sp#602, sp#1783.
- Ours: spec L28 links the decisions file. But the builder check (L53) only looks for places a builder would *guess*. Nothing checks that every decision or Outcome item is owned by a slice. Issues created from slices inline only the slice text (L56), so the decisions never reach the issue.

### C6. ADR misuse (≥5 reports) — small GAP
- Planning-stage ADRs read as if they were in force: mp#299 (3 reactions; maintainer: "This makes sense to me"; open bug). No ADR lifecycle and too many ADRs: mp#822 (10 reactions), mp#1089, mp#932. "Define ADR?": mp#830 (5 reactions).
- Ours, L61: "Propose a separate ADR ... only for decisions that are hard to reverse, surprising, and a real trade-off". This already covers over-production (#1089). It gives no status for unshipped work and never spells out the acronym.

## Proposed edits (minimal; exact old → new)

**E1. grill L33 (C1)**
- Old: `Never ask what can be looked up - file layout, existing patterns, versions, what a function does. Read the code or send a subagent while asking the rest of the frontier.`
- New: `Never ask what can be looked up - file layout, existing patterns, versions, what a function does - or what the user or the source issue already said. Finish any reading or subagent whose result could change a question before asking it; a subagent reporting back is not the user's answer.`
- Evidence: mp#948, #1104, #1245, #802, #1106, #1145.

**E2. grill L48-50 and L53 (C2)**
- Old template:
  ```
  **Q1 — <short title>**
  <question, with concrete options>
  → Recommended: <answer> — <one-line why>
  ```
- New template:
  ```
  **Q<n> — <short title>**
  <question>
    a) <option>
    b) <option>
  → Recommended: <answer> — <one-line why>
  ```
- Old: `Word each question so "yes" accepts the recommendation.`
- New: `Number questions across the session, never restarting at Q1. Word each as a plain-language question, so "yes" accepts the recommendation.`
- Evidence: mp#834, #933, #1057, #789, #1154, #1249, #962, #994.

**E3. grill L45 (C4)**
- Old: `Prefer the \`AskUserQuestion\` tool when available (up to 4 questions with options; put the recommendation first, labelled "(Recommended)"). Otherwise:`
- New: `Prefer the \`AskUserQuestion\` tool when available (up to 4 questions with options; put the recommendation first, labelled "(Recommended)"; put the background each choice needs inside the question, since the tool covers the chat). If the user prefers plain text, or the tool is unavailable:`
- Evidence: mp#850 (thread), sp#114 (thread), mp#986, gs#1208, gs#879; opt-out: mp#149, mp#168, sp#388 (thread).

**E4. grill L57 (C3)**
- Old: `**Do not implement until the user confirms the summary** - running out of questions is not permission to start.`
- New: `**Do not implement until the user asks for it** - running out of questions, or confirming the summary, is not permission to start.`
- Evidence: mp#1068, #975, #134, #240, #570, #729; sp#1030; gs#287, #66; ce#514.

**E5. grill L61 (C6)**
- Old: `Propose a separate ADR (in the repo's ADR folder, if any) only for`
- New: `Propose a separate ADR (architecture decision record; in the repo's ADR folder, if any; status Proposed until the work ships) only for`
- Evidence: mp#299, #822, #830.

**E6. spec L53 (C5)**
- Old: `list only the places where it would have to guess and a wrong guess would change what gets built.`
- New: `list only the places where it would have to guess and a wrong guess would change what gets built, plus any decision or Outcome item that no slice delivers and Out of scope doesn't exclude.`
- Evidence: mp#341, #310, #924, #959, #689; sp#602.

**E7. spec L56 (C5)**
- Old: `otherwise inline the slice text.`
- New: `otherwise inline the slice text and the decisions it depends on.`
- Evidence: mp#1078, #959, #341.

**spike: no edits.** Its reported failures are already covered:
- Throwaway branches pile up (mp#1020): our "Delete the scratch files (and any spike worktree and branch)".
- Grill should be able to spike a question (sp#2065, mp#336, mp#1125): our grill L18 offers `/spike`.

## Clusters judged NOT worth acting on
| Cluster (reports) | Why not |
|---|---|
| Challenge the premise / "should this exist" / Option Zero (mp#244, #947, #1172, #182; sp#530 11 reactions, #834, #2128, #1098; gs#1058, #1644) | Both maintainers declined: mattpocock said "annoying more times than not" (mp#244); obra said "a different kind of tool" (sp#530). Ours already does it on request ("Holes first" when asked to challenge or find gaps). |
| One-at-a-time vs batches (mp#831 35 reactions, #1167, #221 6, #16, #663, #895 4; sp#1989 wants 5-10) | Handled: "at most 4 questions", the frontier rule ("If any plausible answer to Q1 would change or remove Q2, Q2 waits"), and the "one at a time" switch. mattpocock refused a mode switch (#663) and points users to CLAUDE.md. |
| Progress header "Q N of ~M" (mp#597) | Maintainer: per-user preference. Our "~6 real decisions; 2–3 short rounds" line covers it. |
| Hard question cap (mp#282 policy) | Ours caps per round, not per session. Matches their policy. |
| Auto-fires on trivial work (sp#2076, #2079, #2000 5 reactions, #73, #1222; HN 48772878) | Handled: grill's "≤2 decisions, triggered automatically" path; spec and spike are `disable-model-invocation`. |
| Plans too detailed / code inside plans (sp#895 38 reactions, #86, #694, #194; ce#163, #1769; HN 47439082) | Handled: one page, ≤6 slices, no code. obra keeps code on purpose so Haiku can implement. |
| Auto-committing specs and plans (sp#807 14 reactions, #123, #2473) | Handled: "Say the spec file is uncommitted and offer to commit it". |
| Configurable output location (sp#337 8, #939, #1690, #975; mp#294 7; ce#904; addy#50, #482) | Handled: "(or the user's preferred place)" and "the repo's existing decisions location". |
| Fresh context between phases (sp#1503 8, #478 9; anthropics#38472 18, #18599 40) | Handled: "suggest continuing in a fresh session that starts from that file". |
| Tracker plumbing: native sub-issues, parent still pickable, status/completion (mp#47 13, #292 5, #554, #569, #1204, #1099, #990, #508; sp#1075; gs#1343) | Tracker- and harness-specific. Our spec only creates issues when asked; implementation isn't our skill. Adding this would be bloat. |
| Hidden interface blockers between parallel slices (mp#265, #1116, #918) | Maintainer calls it a "design call". "Blocked by", S1-riskiest-first and the builder check already cover most of it. A heuristic would add lines for an edge case. |
| User stories don't fit technical work (mp#362 9 reactions, #1129, #790) | Not applicable: our spec has no user-stories section. |
| Token cost (mp#826; sp#1648, #1152; HN 48020962, 48472810) | General. Argues for staying lean, which these edits respect. |
| Back-reference by number only (mp#1115), reset the tree when the goal is corrected (mp#1002), language drift (mp#198/#199, same author) | Each has a single reporter. "Re-plan the frontier after every answer" partly covers #1002. |
| Wayfinder, office-hours and plan-tune internals (dozens) | No equivalent skill in our set. |
