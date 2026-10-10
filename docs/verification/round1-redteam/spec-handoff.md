# Red-team review: spec + handoff skills

Scope: only `.claude/skills/spec/SKILL.md` and `.claude/skills/handoff/SKILL.md` were read.

---

## Skill 1: spec

### A. Identification

**Manual mode (`disable-model-invocation: true`, L5).**
- For manual: the skill writes a file into the repo (L19) and can lead to creating tracker items. Writing a spec is a deliberate step the user chooses, and auto-firing whenever someone says "plan" would be noisy.
- Against manual: the side effects are already gated (L44 says to ask before anything external). The description's own triggers ("turn this into tickets", "plan the PRs", "when work must survive across sessions", L3) only help if the model can see the description. In manual mode it cannot, so a user who types "turn this into tickets" gets nothing. "when work must survive across sessions or people" is a condition only the model could judge, and manual mode means the model never judges it.
- Verdict: manual is defensible. The description, though, is written for model invocation. Either drop manual mode, or rewrite the description as menu text for a human.

**/ menu usefulness.** The first sentence works. The "Use when..." clause is dead weight in manual mode. Of the description, only the menu text matters, and it should say what the user gets: a file at docs/specs/, slices, nothing created externally. The argument-hint `"[decisions file, issue, or topic]"` is good.

**Proposed frontmatter:**
```yaml
---
name: spec
description: Turns already-settled decisions (a grill's decisions file, an issue, or this conversation) into a one-page spec at docs/specs/<topic>.md with 2-6 vertical slices, each with a Done-when check, that another agent or person can execute. Writes only the spec file; creates no issues or code unless asked afterwards. Not for single-PR work.
argument-hint: "[decisions file, issue URL, or topic]"
disable-model-invocation: true
---
```

### B. Functioning

1. **The explicit invocation gets refused (L14).** "Work that fits one PR: skip the spec; a 3-line plan in chat is enough." The user typed /spec on purpose. Read literally, the skill overrides them. Fix: "say it fits one PR and offer a 3-line plan instead; write the spec anyway if the user still wants it."
2. **Dead end when there are more than 6 slices (L15).** "say so and propose a split" gives no stop or continue rule. Does the agent stop, or write the spec for part 1? Fix: "stop, propose the split, and write the spec only for the part the user picks."
3. **The blocking-question escape is ambiguous (L10).** "rather than starting a grill - unless it blocks every slice" implies the agent then starts a grill. That depends on another skill that may be absent or manual-only, which contradicts "Synthesis, not another interview." Fix: "if one open decision blocks every slice, ask the user that one question and wait."
4. **"Independently shippable" vs `Blocked by:` (L3, L30 vs L37).** The description promises independently shippable slices, but the template has a dependency field, and L40 orders slices by risk. Say "mergeable on its own once its blockers have merged."
5. **The file is written with no consent and no durability plan (L19, L44).** The spec file is created before the "ask before creating anything" step. That is acceptable, because it is the skill's purpose. But nothing says to commit it, and in an ephemeral container an uncommitted spec is lost. L44 says issues "link back to the spec", but a link to an uncommitted or unpushed file is dead. Fix: after writing, state that the file is uncommitted and offer to commit it. Create issues only after the spec is pushed, or inline the spec text.
6. **No input means undefined behaviour.** With an empty argument the skill never says to fall back to the current conversation, or to ask if the conversation holds no decisions. A fresh session with `/spec` and no argument invites a made-up spec. Fix: "If no decisions are in the argument or conversation, ask for the source; don't invent requirements."
7. **Smaller issues:**
   - "under a page and a half" (L19) is unmeasurable. Use "~80 lines".
   - "in the user's words" (L21) is ambiguous when the source is an issue written by someone else.
   - The docs/decisions/<topic>.md link (L23) assumes the same topic slug. Say "check docs/decisions/ for a matching file."
   - Nothing covers an existing docs/specs/<topic>.md. Does the agent overwrite it? It should update in place, or ask first.
   - "Touches: best guess from reading the code" (L35) sets no reading budget. Acceptable.

### C. Scenarios

- **Ideal.** A grill produced `docs/decisions/auth.md`, and the user runs `/spec docs/decisions/auth.md`. The agent writes `docs/specs/auth.md` with Problem, Outcome, Decisions linked, 4 slices, S1 as a risk spike, then shows the slice list and stops. This works. It breaks at the end: the spec is uncommitted. If the user says "create the issues", the agent links them to a path that exists only in a container that is about to die.
- **Edge.** A fresh session with `/spec add dark mode` and no prior discussion. The skill says "Synthesis, not another interview" and sets no rule for missing decisions. The agent either invents Problem, Outcome and Decisions (a hallucinated spec), or lists nearly everything under Open questions. If it judges dark mode a one-PR job, L14 tells it to skip the spec the user explicitly asked for.

### D. Verdict: PASS-WITH-FIXES

Top fixes:
1. **L14:** replace it with "- Work that fits one PR: say so and offer a 3-line plan in chat instead; write the spec only if the user still wants it."
2. **L44:** add "Tell the user the spec file is uncommitted and offer to commit it; issue links must point to a pushed path (or inline the slice text)."
3. **L10:** replace it with "Synthesis, not another interview. Source is the argument, else this conversation; if neither holds decisions, ask for one. List unsettled decisions under **Open questions**; if one blocks every slice, ask that single question and stop." Also add to L15: "...propose a split and stop until the user picks a part."

---

## Skill 2: handoff

### A. Identification

**Manual mode (L5).**
- For manual: the skill commits and pushes (L3, L14), which are side effects that should never run unprompted.
- Against manual: the skill's own rationale is model-driven. "when context is getting long" (L3) and "Write the handoff **before** context runs low" (L14) are judgments only the model can make, and manual mode leaves them unreachable. That is an internal contradiction: L14 instructs a timing the skill cannot act on. The real durability risk (context running out, or the container dying) is exactly the case where the user will not remember to type /handoff.
- Verdict: keep manual because of the commit and push. Remove the model-only triggers. Optionally recommend a CLAUDE.md line or hook that suggests /handoff to the user.

**/ menu usefulness.** The description is fine as a capability statement. The "Use when..." clause is invisible in manual mode except as menu text, and "when context is getting long" is not something the user can see. The argument-hint is a question, not a placeholder. Use a bracketed form so the menu shows it as optional.

**Proposed frontmatter:**
```yaml
---
name: handoff
description: Writes a one-page handoff (goal, state with SHAs, decisions, dead ends, next steps, resume prompt) to docs/handoffs/<date>-<topic>.md so a fresh session can continue cold. Commits only that file and asks before pushing; prints the paste-able resume prompt in chat. Run before ending a session with unfinished work or when context is long.
argument-hint: "[focus for the next session]"
disable-model-invocation: true
---
```

### B. Functioning

1. **Unsafe side effect (L14):** "commit and push it with the work". Read literally, the agent commits all uncommitted work (possibly half-broken, possibly including .env or other secret files; the L30 redaction rule covers only the document) and pushes it, possibly to the default branch, without asking. Pushing may also be denied by permissions, and the skill has no fallback. Fix: commit only the handoff file. Never commit other changes without asking. Don't commit on the default branch; ask first. Ask before pushing, and if the push is refused, say so plainly.
2. **Wrong order (L14):** "If the user doesn't want it in the repo, put it in the scratchpad". The agent can only learn that after it has already committed. Either ask up front or default to non-destructive behaviour.
3. **Impossible timing (L14):** "before context runs low". In manual mode the model cannot trigger this. Delete the sentence or turn it into advice for the user.
4. **The resume prompt can point to nothing (L25).** It includes "this file's path", but if the file was not pushed, the next fresh container never has it. Fix: print the resume prompt in chat, which L25 never says to do. If the file is unpushed, inline the essential next steps into the prompt.
5. **The State section ignores durability (L19).** It asks for commit SHAs but not which are pushed, or what uncommitted or untracked changes exist. Those changes die with the container, and the next agent needs to know they are gone. Add: "pushed? yes/no; uncommitted changes listed or stashed/committed on a WIP branch with the user's OK."
6. **Ceremony and overrun.** Eight sections "under a page" (L32) plus "Suggested skills" (L24) invites made-up skill names. Restrict it to skills that actually exist, or drop it. Sections with nothing in them should be omitted, not filled with "None".
7. **Smaller issues:**
   - <topic> slug and date source are unspecified. Fine, but name the source: `date +%F`.
   - Repeated handoffs pile up in docs/handoffs/ with nothing about superseding older ones.
   - "personal data" redaction conflicts slightly with "in their words" (L18) when the goal quotes names.

### C. Scenarios

- **Ideal.** A feature branch `feat/x`, all work committed and pushed, the user runs `/handoff finish the parser tests`. The agent writes docs/handoffs/2026-10-10-parser.md, commits and pushes it to feat/x, and the user copies the resume prompt. The only friction: the prompt is only in the file, so the user has to open it or ask.
- **Edge.** On `main` with a dirty tree: a half-done refactor that fails tests, plus a modified `.env.local`. The user runs `/handoff`. L14 "commit and push it with the work" leads the agent to commit everything, possibly .env.local included, and push broken code to main. If the push is permission-denied instead, the agent has no instruction. The resume prompt then cites a path that the next container will not have, and the uncommitted refactor is lost without any mention in the doc.

### D. Verdict: FAIL as written (easy to fix to PASS)

Top fixes:
1. **L14:** replace it with "Save it to `docs/handoffs/<YYYY-MM-DD>-<topic>.md` and commit **only that file** on the current branch (if it is the default branch, ask first). Ask before pushing; never commit or push other changes without the user's OK. If the push is declined or fails, say the file will die with the container and include the full next steps in the resume prompt." Also drop "before context runs low".
2. **L25:** append "Print the resume prompt in chat as the last thing you output. If the file is not pushed, inline the next steps instead of relying on the path."
3. **L19:** replace it with "**State** - branch; commits (SHA, pushed yes/no); uncommitted/untracked changes and whether they survive; in progress; untouched." Also change L24 to "**Suggested skills** - only skills that exist in this repo; omit if none."
