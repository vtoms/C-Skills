# Session-cluster edits: handoff + reflect

Body word counts: handoff 306 -> 398 (+92); reflect 303 -> 466 (+163).
Validator: handoff and reflect pass; the only remaining FAIL is diagnose (description 531 chars), from another agent's concurrent edit, not touched here.

## handoff
1. State item: verified (command + result) vs unverified tags, "never write a belief as a fact", one status command, output/errors quoted verbatim.
   Source: session.md H1 (Pocock docs/productivity/handoff.md "a belief written as a fact becomes a false premise"; gstack context-save provenance; ce-handoff "Verification performed"; claude-mem verbatim errors; arXiv 2606.20662 confidence laundering).
2. Decisions: whose call (user vs agent) + what the user said not to do.
   Source: session.md H2 (ce-handoff references/create.md; claude-mem "explicitly said NOT to do").
3. Resume prompt: check State against `git log`/`git status` + status command, report mismatch before acting.
   Source: session.md H5 (ce-handoff Resume; arXiv 2606.02875; 288-commits-behind report; gzkit).
Kept unchanged: path-limited `git commit -m "..." -- <file>` rule, default-branch ask, ask-before-push, decline fallback (tdd-handoff.md R1/R2 fixes stay intact).

## reflect
1. Step 1: quote the session moment per lesson; counterfactual bar ("would the next agent, reading the final code, still make this mistake?"); drop SHA/version-bound facts.
   Source: session.md R1 (Pocock retro FAQ "invents generic advice"; pstack Evidence: field; ce-compound counterfactual; pstack synthesizer durability filter).
2. Repo mode (`/reflect repo`, ~50 commits/reverts/review comments, counts at 2 occurrences) - one sentence + argument-hint + description clause.
   Source: left-behind.md section 3 FOLD-INTO-reflect (pstack correct, Pocock retro, #1207).
3. CLAUDE.md only for repo-wide facts; narrower ones in a path-scoped rule file (e.g. `.claude/rules/<topic>.md`) or skill; near 200 lines pair addition with removal.
   Source: session.md R2, citing official docs https://code.claude.com/docs/en/memory ("target under 200 lines", path-scoped `.claude/rules/`). Feature verified via that cited doc; still phrased "e.g." so it reads as an example location.
4. Escalation: a written rule still broken needs a check, not another line.
   Source: pstack correct; Claude Code issue #36296 (6 variant MEMORY.md entries, no behaviour change). Consistent with the existing hook bullet (plain-unslop-reflect.md fix #2 kept: one-line conventions still go to CLAUDE.md first).
5. Step 3.4: error message names the fix; fail only on new occurrences (ratchet). New 3.5: propose deleting prose the check supersedes.
   Source: session.md R3 (pstack correct / encode-lessons "Delete the instruction"; AGENTS.md maturity curve; Pocock "pile up lint rules").
Kept: step 3.3 project-scope wording (plain-unslop-reflect.md regression 1 fix) unchanged.

## Rejected
- H3 (pointers say what matters) and H4 (current best theory): not in the requested scope; would push handoff past one page.
- R2 "skill didn't trigger -> tighten description" and "slow to find file -> pointer": not requested; word budget.
- Full enforcement ladder rewrite, rule->enforcer table, exception expiries (left-behind section 3 / pstack): too large for <=180 words; existing step 2 ordering already covers it.
- Session-transcript mining across workspaces (pstack recall): privacy, rejected in prior research.
- Delete-after-resume (GSD), temp-dir handoffs (Pocock), YAML format: see session.md section 6.
