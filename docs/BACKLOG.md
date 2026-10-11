# Backlog

These are parked items we'll come back to. Each one goes through the usual cycle when picked up: research → edits → tests → independent regression checks → fixes → regression.

## Repos to evaluate (from the 2026-10-12 star search)

Full details and star counts are in [research/star-landscape-2026-10.md](research/star-landscape-2026-10.md).

### Priority: closest to C-Skills

| Repo | Stars | Why look | Status |
|---|---|---|---|
| affaan-m/ECC | 277k | Biggest general pack (skills, memory, security). Check for overlap with ours and for ideas we lack | todo |
| ayghri/i-have-adhd | 56k | Answer-first output style; overlaps with `plain` | todo |
| Leonxlnx/taste-skill | 95k | UI design "taste"; a category we don't cover (UI version of `unslop`) | todo |
| Nutlope/hallmark | 30k | Anti-slop design skill; compare with taste-skill | todo |
| Yeachan-Heo/oh-my-claudecode | 40k | Multi-agent orchestration for Claude Code; compare with `interrogate` and fan-out patterns | todo |
| shanraisshan/claude-code-best-practice | 67k | Practices and configs; check against our README install notes | todo |

### Later: other purposes, review if useful

| Area | Repos |
|---|---|
| Design and diagrams | nextlevelbuilder/ui-ux-pro-max-skill (135k), nexu-io/open-design (101k), tt-a1i/archify (82k), cathrynlavery/diagram-design (50k), zarazhangrui/frontend-slides (30k) |
| Codebase knowledge graphs | Graphify-Labs/graphify (125k, already installed), Egonex-AI/Understand-Anything (86k), colbymchenry/codegraph (74k), DeusData/codebase-memory-mcp (46k), tirth8205/code-review-graph (32k), oraios/serena (30k) |
| Token and cost savers | rtk-ai/rtk (83k), headroomlabs-ai/headroom (75k) |
| Orchestration and harnesses | ruvnet/ruflo (74k), code-yeongyu/oh-my-openagent (70k), davila7/claude-code-templates (33k), luongnv89/claude-howto (42k), sickn33/agentic-awesome-skills (47k) |
| Research and web reach | mvanhorn/last30days-skill (64k), Panniantong/Agent-Reach (96k). Check each site's terms first; Reddit forbids scraping |
| Domain libraries | rea, career-ops, OpenMontage, marketingskills, academic-research-skills, obsidian-skills, scientific-agent-skills, nature-skills, Anthropic-Cybersecurity-Skills, book-to-skill, OfficeCLI, googleworkspace/cli |
| Infrastructure | cc-switch, orca, herdr, anthropics/claude-plugins-official, openai/codex-plugin-cc, vercel-labs/skills |

**Caution.** Some of these repos gained 80–100k stars within months of creation. Confirm real usage (issues, skills.sh installs) before trusting their popularity.

## Other parked items

- **`unslop` writing sample.** Let it match a writing sample the user provides (a "style fingerprint"). Evidence is moderate; see `research/reddit-via-antigravity.md`.
- **Optional wording tweaks from the v0.7 final check.**
  - `grill`: add "in reply to that question" after "implement".
  - `plain`: say "one separate statement (not a question)".
- **Reddit via the official API.** Run `tools/reddit/reddit_research.py` once the Reddit app keys exist, then fold the full threads into the research.
- **`improve-architecture` / `deepen` skill.** 1.1M installs for Pocock's version. Deferred as heavy (see `research/grid/leaderboard.md`).
