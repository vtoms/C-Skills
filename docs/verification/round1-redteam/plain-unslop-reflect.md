# Red-team review: plain, unslop, reflect

Scope: only the three SKILL.md files were read. All three have `disable-model-invocation: true`, so their descriptions are NOT in model context. They only show in the `/` menu, and the trigger phrases in them ("wait what", "make this sound human", "retro") can never fire.

---------------------------------------------------------------------
## 1. plain  (.claude/skills/plain/SKILL.md)

### A. Identification
- For manual: re-explaining is cheap and the model already does it unprompted when a user says "wait what". An auto skill would also add a fixed structure (context sentence, closing question) to ordinary follow-ups where it doesn't fit.
- For auto: the user who says "I don't follow" is exactly the user who won't know `/plain` exists. The description's whole trigger list (L3) is written for auto-invocation and is wasted under manual.
- Verdict: manual is acceptable. Trim the description to what a human scanning the `/` menu needs, and add an argument-hint, because users will type `/plain the second part`.
- No `argument-hint`, and the body never says what to do with arguments (for example "only re-explain the part the user names").

Proposed frontmatter:
```yaml
---
name: plain
description: Re-explains the previous assistant reply in plain, short, jargon-free language, keeping its facts, options and question intact.
argument-hint: "[optional: which part to re-explain]"
disable-model-invocation: true
---
```

### B. Functioning
- L9 "My last message didn't land." Skill bodies arrive in the user-side turn when invoked. From that seat, "my last message" naturally reads as *the user's* last message. That inverts the task: "you misunderstood me" instead of "re-explain yourself". L14 "not my invented labels" has the same problem, since the user invented no labels. The model will probably guess right from context, but the wording works against it. Fix: "Your previous reply did not land with the user."
- L9 "don't just shorten it" vs L17 "Under 120 words". When the source is about 120 words or more, the limit forces shortening. That isn't a contradiction, but the L9 intent ("re-frame, don't compress") has no concrete instruction behind it.
- L13 vs L14 conflict. L13 says define or replace any term the user didn't use first. L14 says use the project's own names. Project names (`acquireLease`, "reconciler") are often the jargon the user didn't follow. Nothing says "keep the project name AND gloss it once".
- L14 `GLOSSARY.md`: if it doesn't exist, a literal reader may go searching the repo (tool calls, latency) for a 100-word reply. It should say "if present".
- Missing preservation rules:
  - Keep option labels. If the original said (a)/(b)/(c), the user may answer "b", so relabelling or reordering breaks that. In my test I naturally reordered the options.
  - Keep numbers and file paths.
  - Keep any recommendation as it was.
  - Add no new claims.
  - Say how to handle code blocks.
- "Previous assistant message" is undefined when the last turn was a long tool-using turn with several text chunks. Which one is it: the final summary, or the whole turn?
- Arguments are not handled (see A).
- L17 "unless the content truly needs more" is an escape hatch with no test. It's fine, but it will be used.
- No unsafe side effects; there are no tools involved.

### C. Hand test
Dense "previous message" (about 125 words):
> The flake is a TOCTOU race in the lease reconciler: `acquireLease()` reads the etcd revision, then the CAS in `renew()` uses a stale `modRevision` when the informer's resync coalesces two watch events, so the second write 409s and the backoff jitter (base 50ms, cap 2s, full jitter) occasionally exceeds the test's 1.5s deadline. Options: (a) switch the CAS precondition to `leaseID` + `generation` instead of `modRevision`, which is idempotent under coalescing but needs a CRD schema bump (v1beta2→v1beta3, conversion webhook); (b) keep `modRevision` but re-GET on 409 before retrying, a ~15-line change with an extra round-trip per conflict; (c) bump the test deadline to 3s, which masks it. I'd do (b) now and file (a). Want me to proceed?

Applying L11–L17 literally:
> We're looking at why the lease test fails now and then. Sometimes two updates to the same lease arrive bundled together. Then `renew()` checks against an out-of-date version number, the save is rejected, and the retry wait can run past the test's 1.5-second limit.
> Three ways to fix it:
> (b) When a save is rejected, fetch the latest version and retry. About 15 lines; one extra request per conflict.
> (a) Check the lease's ID and generation instead of the version number. Sturdier, but needs a new schema version and a conversion step.
> (c) Give the test 3 seconds. That only hides the bug.
> I suggest (b) now and a ticket for (a).
> Should I make the (b) fix?

- Word count is about 110, so under 120. The context sentence, short sentences and closing question are all present.
- Meaning: the core cause, the three options, their costs, the recommendation and the 1.5 s / 15-line numbers survive. Dropped: etcd, 409, jitter parameters, v1beta2→v1beta3. That is acceptable for plain.
- The instructions were *mostly* sufficient. Gaps found:
  - My first draft dropped the (a)/(b)/(c) labels and reordered the options. Nothing in the skill prevented that.
  - L13/L14 left it unclear whether to keep `renew()`. I kept it, but that was a judgment call.
  - L14 told me to check `GLOSSARY.md`. In a real run that is a tool call with no fallback.

### D. Verdict: PASS-WITH-FIXES
1. L9: replace "My last message didn't land. Say it again, better - don't just shorten it." with "Your previous reply did not land with the user. Re-explain it from a different angle; do not just compress it."
2. Add a step after L14: "6. Keep every number, file path, option label (a/b/c) and recommendation from the original, in the same order. Add no new claims. If the user named a part (`$ARGUMENTS`), re-explain only that part."
3. L13–14: "Keep the project's own names for things (from the code, or `GLOSSARY.md` if present), and gloss each one the user didn't use in a few plain words the first time. Replace your own invented labels."

---------------------------------------------------------------------
## 2. unslop  (.claude/skills/unslop/SKILL.md)

### A. Identification
- For manual: auto-invocation would rewrite user text that wasn't offered for editing. L29 "edit the file" makes an unwanted auto-trigger destructive. Manual is right.
- Against manual: L3 "asks to polish a README, PR description, doc…" is an auto-trigger clause that can never fire. It also undersells the skill, because users who would benefit won't think to type /unslop.
- The argument-hint is good. The description is too long for the menu and front-loads less well than it could.

Proposed frontmatter:
```yaml
---
name: unslop
description: Edits prose to remove AI-writing tells (filler, inflated words, hedging, chatbot phrases, decorative formatting) while keeping every fact, code block, quote and name unchanged.
argument-hint: "[file path or pasted text; empty = your last reply]"
disable-model-invocation: true
---
```

### B. Functioning
- **Contradiction, L10 vs L18.** L10 says "Keep every fact, claim, and instruction." L18 says vague claims get a source or number, "otherwise cut". The model cannot invent a source, so a literal reader must either break L10 or ignore L18. In my test, "Experts say Redis is best-in-class" had to go, so a claim was deleted. L28's meaning pass then says "restore anything lost", which would put it back. The skill loops on itself.
- L16 "groups of three that exist for rhythm… state the point once" and L20 "cut" also delete content (for example "scalability, reliability, and speed"). Same conflict.
- L10 protected set is incomplete. It leaves out:
  - inline code
  - URLs and link targets
  - YAML frontmatter
  - tables
  - HTML or comments
  - headings that are anchors (renaming "## Getting Started" to "## Getting started" changes the `#getting-started` slug in some renderers and breaks inbound links).
- L21 "Title Case Headings → sentence case" conflicts with L10 "never change names" when a heading contains product names. It is also an anchor risk (see above).
- No default input. With no argument, which text is meant: the last assistant reply, the open file, or the clipboard? Nothing says.
- L29 "or edit the file". Given a path, it edits in place with no diff, no backup, and no check of whether the file is generated, vendored, a CHANGELOG with past entries, or a legal/licence text. That is an unsafe side effect with no confirmation step. It should show a diff, or at least list the changed lines, and never touch LICENSE, CHANGELOG history or generated files.
- L26 "keep tone" vs L14 (delete "Certainly!"). Fine for prose, but for chat messages where warmth is intended, cutting the closers changes tone. Minor.
- L17 "could potentially → may" shifts the meaning toward permission in some contexts. Minor.
- L29 "how many changes": the unit is undefined (edits, sentences, words?). Ceremony with no fixed meaning.
- Word lists (L15) without a context exception: "robust" (statistics), "leverage" (finance), "surface" (UI noun) are legitimate terms. A literal reader will over-edit technical docs.
- Missing tells: "simply/just", "seamlessly", em-dash overuse, "Here's the thing". Not fatal.
- L31 gives a stop condition for clean text. Good.

### C. Hand test
Input (about 150 words):
> Great question! In today's fast-paced development landscape, caching serves as a crucial pillar of robust performance. By leveraging Redis, our API became significantly faster — response times dropped from 420 ms to 95 ms, ensuring a seamless user experience. As our CTO put it, "Caching is not just an optimization, it's a pivotal part of our architecture." To enable it, simply run:
> ```bash
> export CACHE_BACKEND=redis  # utilize the robust default
> npm run start -- --cache
> ```
> It's important to note that this could potentially increase memory usage. Experts say Redis is best-in-class for this use case. 🚀 **Key takeaway:** caching unlocks scalability, reliability, and speed. In summary, caching makes the API faster. The future looks bright! I hope this helps — let me know if you have any questions.

Output after applying L26–L29 literally:
> Using Redis as a cache cut our API response times from 420 ms to 95 ms. As our CTO put it, "Caching is not just an optimization, it's a pivotal part of our architecture." To enable it, run:
> ```bash
> export CACHE_BACKEND=redis  # utilize the robust default
> npm run start -- --cache
> ```
> This may increase memory usage.
>
> 11 changes; most common: chatbot residue and fake depth.

- Protected spans:
  - The code block is byte-identical. The comment "utilize the robust default" stayed, which is correct under L10, although the L15 list tempts an edit.
  - The quote is byte-identical, even though it contains the L16 "not just X but Y" pattern and the L15 word "pivotal". L10 wins, but a less careful reader could edit it, because the skill doesn't say "patterns inside quotes and code are exempt".
- Numbers: 420 ms and 95 ms are preserved. "significantly faster" was correctly replaced by the existing number.
- Meaning lost:
  - "Experts say Redis is best-in-class" was deleted (L18 says cut; L10 says keep; I followed L18).
  - "scalability, reliability" was deleted (L16, L20, L21).
  - The opening "caching matters for performance" sentence was deleted.
  - Whether these losses are acceptable is exactly the L10/L18 ambiguity.
- "simply" isn't in any list. I cut it on judgment.
- Sufficiency: good enough for prose. The contradiction and the missing protected span types (inline code, links, headings) are real gaps.

### D. Verdict: PASS-WITH-FIXES
1. L10: replace with "Keep every fact, number, and instruction. Never change code blocks, inline code, commands, URLs, quotes, names, or frontmatter, even if they contain the patterns below. Cutting an unsupported claim (see Vague claims) or a pure restatement is allowed; list each cut claim after the text so the user can restore it."
2. L29: "4. For a file, apply the edits and show a diff, or list the changed lines; skip generated files, licences, and past CHANGELOG entries. With no argument, edit your own last reply. Then one line: number of edits and the two most common patterns."
3. L21: append "Do not change headings that are link anchors or contain product names."

---------------------------------------------------------------------
## 3. reflect  (.claude/skills/reflect/SKILL.md)

### A. Identification
- For manual: L11 itself says reflecting every session is overhead. Its outputs (hooks, CLAUDE.md, skill edits) change future behaviour project-wide, so they should be human-initiated. Manual is right.
- Against manual: the moment it is most valuable (right after the user corrects the agent repeatedly) is when the user is frustrated and least likely to remember the command. That is an acceptable cost.
- The description overclaims: "so the mistake cannot recur". Rung 4 (CLAUDE.md) only warns.
- Add an argument-hint for focus (`/reflect the deploy failure`).

Proposed frontmatter:
```yaml
---
name: reflect
description: Reviews the current session for repeated mistakes and reusable facts, then proposes a concrete guard for each (test, lint rule, hook, skill edit, or CLAUDE.md line) and applies only the ones the user approves.
argument-hint: "[optional: which problem to focus on]"
disable-model-invocation: true
---
```

### B. Functioning
- L3 "finished session". The skill runs inside the session, and after compaction the early corrections may be gone. There is no instruction to say "early context was compacted; findings may be incomplete".
- L22 "Discard one-offs" vs L19 "Facts I had to discover". Most discovered facts were discovered once. The real criterion is "plausibly recurs", which L22's second sentence states, but "one-off" invites counting occurrences instead.
- L26–32: the routing ladder has no proportionality rule. A simple convention ("use `uv run pytest`") gets pushed to rung 2 (a hook), which:
  - edits `.claude/settings.json`, a config change with project-wide effect
  - can block legitimate commands
  - is heavier than a one-line CLAUDE.md entry.
  It should be "the strongest home whose cost fits the lesson".
- Rung 1 "type, test, or lint rule" is a poor fit for *agent-behaviour* mistakes, which are the commonest kind. Rung 1 suits only code-defect lessons.
- L28/L29 never ask for the guard to be proven to work: a new test failing on the old mistake, a hook firing on the bad command. Without that, "make it impossible" is unverified.
- L30 "Skill edit": a skill could edit itself or other skills that aren't in this repo (user-level `~/.claude/skills`). Scope isn't stated. "CLAUDE.md" doesn't say which one (project, user, or nested).
- L36 approval gate. Good, this is the key safety property. Missing: a stop condition when the user approves nothing, and handling for a partly approved row.
- L36 "Never add a rule that contradicts an existing one" requires reading all existing CLAUDE.md, skills and hooks. Fine, but that isn't stated as a step.
- L11 gives a stop condition for smooth sessions. Good.
- First-person "I got wrong" (L18) has the same voice issue as plain, but it is harmless here.

### C. Hand test
Invented session:
- (1) Repeated: the agent ran bare `pytest` three times. The repo needs `uv run pytest`, and the user corrected it twice.
- (2) One-off: a typo in a branch name (`feat/lgoin`), fixed immediately.
- (3) One-off: misread one field of a JSON API response once.

Steps:
- Step 1 collects all three. L22 discards (2) clearly. (3) is a judgment call: "misread API field" could plausibly recur, but is too vague to guard. I discarded it.
- Step 2 for (1):
  - Rung 1: a type/test/lint rule can't catch a shell command choice.
  - Rung 2: a PreToolUse hook that rejects bare `pytest` is possible, so the ladder says pick it.
  - Proportionate answer: CLAUDE.md line "Run tests with `uv run pytest`; bare `pytest` lacks deps."
  - The ladder pushed me toward the heavier option with no cost guidance.
- Step 3 table:

| lesson | home | edit |
|---|---|---|
| tests need `uv run pytest` | CLAUDE.md (alt: PreToolUse hook) | `+ Run tests with \`uv run pytest\`, never bare \`pytest\`.` |

- Then wait for approval.
- Result: the skill produced a sensible outcome. Weak points were the subjective one-off call and the hook-vs-CLAUDE.md choice. No verification step was required, so I could not "prove" the guard.

### D. Verdict: PASS-WITH-FIXES
1. L26: replace with "Pick the strongest home whose cost fits the lesson. A one-line convention belongs in CLAUDE.md, not a hook. Use a test, type or lint rule for code defects, and a hook only for mistakes that are costly or repeated despite a written rule:"
2. After L36, add: "For a test, hook or lint rule, show it catching the original mistake before calling it done. If the user approves nothing, stop. Use the project CLAUDE.md and `.claude/skills/` only, never user-level files, unless the user asks."
3. L22: replace with "Keep a candidate only if it is likely to come up again in this project; drop typos and one-time slips. If early context was compacted, say so." Also fix the L3 description overclaim ("cannot recur" → "is less likely to recur").
