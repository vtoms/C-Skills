# Most-starred Claude skill and Claude Code repos we hadn't studied (2026-10-12)

Live star counts come from the GitHub search API (signed-in `gh`), using 20 topic and keyword queries (676 unique repos). This list excludes the ~30 repos studied earlier (mattpocock/skills, superpowers, gstack, anthropics/skills, pstack, compound-engineering, addyosmani, wshobson, humanizer, karpathy-skills, ponytail, spec-kit, caveman, claude-mem, trailofbits, the awesome-lists, GSD, BMAD, OpenSpec and others), as well as general AI apps that only matched a keyword.

**Caution on stars.** Several repos created in April–May 2026 already show 80–100k stars. GitHub stars can be bought or gamed, and fake "superpowers" repos have been seen gaming install counts. Treat very fast growth as a reason to check real usage (issues, skills.sh installs) before trusting a repo.

## 1. Design and UI taste
| Stars | Repo | Purpose |
|---|---|---|
| 134.8k | nextlevelbuilder/ui-ux-pro-max-skill | Design intelligence for UI/UX across platforms: styles, palettes, layout rules |
| 100.6k | nexu-io/open-design | Local-first desktop design app and plugin, pitched as an open "Claude Design" alternative |
| 94.7k | Leonxlnx/taste-skill | Gives the agent design "taste"; stops generic AI-looking UI |
| 82.0k | tt-a1i/archify | Turns an idea, plan or codebase into an interactive diagram |
| 50.1k | cathrynlavery/diagram-design | Editorial-quality diagrams, 44 types |
| 30.5k | zarazhangrui/frontend-slides | Web slide decks built by the coding agent |
| 29.9k | Nutlope/hallmark | Anti-AI-slop design skill |

## 2. Codebase understanding (knowledge graphs and code intelligence)
| Stars | Repo | Purpose |
|---|---|---|
| 125.5k | Graphify-Labs/graphify | Turns code, docs, schemas and PDFs into a queryable knowledge graph (`/graphify`); already in your user skills |
| 85.9k | Egonex-AI/Understand-Anything | Interactive, teachable knowledge graph of any codebase |
| 73.7k | colbymchenry/codegraph | Pre-indexed code graph that auto-syncs on changes |
| 46.4k | DeusData/codebase-memory-mcp | MCP server that indexes repos into a persistent graph |
| 32.0k | tirth8205/code-review-graph | Code map so tools read only what a review needs |
| 30.2k | oraios/serena | MCP toolkit for semantic retrieval and editing ("IDE for your agent") |

## 3. Token and cost savers
| Stars | Repo | Purpose |
|---|---|---|
| 83.0k | rtk-ai/rtk | CLI proxy that cuts tokens 60–90% on common dev commands |
| 75.1k | headroomlabs-ai/headroom | Compresses tool output, logs and files before they reach the model |

## 4. Big general packs, harnesses and orchestration
| Stars | Repo | Purpose |
|---|---|---|
| 277.1k | affaan-m/ECC | "Everything Claude Code": harness optimisation with skills, instincts, memory, security and research-first development |
| 74.4k | ruvnet/ruflo | Multi-agent swarm orchestration (successor to claude-flow) |
| 70.0k | code-yeongyu/oh-my-openagent | Agent orchestration harness, keyword-driven ("ulw") |
| 67.4k | shanraisshan/claude-code-best-practice | Practices and configs, "vibe coding to agentic engineering" |
| 47.5k | sickn33/agentic-awesome-skills | Very large skills catalog with agent-side discovery and selection |
| 41.8k | luongnv89/claude-howto | Visual, example-driven Claude Code guide with templates |
| 39.8k | Yeachan-Heo/oh-my-claudecode | Teams-first multi-agent orchestration for Claude Code |
| 32.6k | davila7/claude-code-templates | CLI to install and configure agents, commands and settings, plus monitoring |

## 5. Output style
| Stars | Repo | Purpose |
|---|---|---|
| 56.4k | ayghri/i-have-adhd | Answer-first, scannable output; stops the agent from burying the answer |

## 6. Research and web reach
| Stars | Repo | Purpose |
|---|---|---|
| 95.9k | Panniantong/Agent-Reach | Lets the agent read and search Twitter, Reddit, YouTube, GitHub, Bilibili and others. Check how it accesses each site against that site's terms |
| 64.0k | mvanhorn/last30days-skill | Researches a topic across Reddit, X, YouTube, HN, Polymarket and the web, then writes a grounded summary. Check its data sources against site terms |

## 7. Domain skill libraries
| Stars | Repo | Purpose |
|---|---|---|
| 97.8k | morluto/rea | Reverse engineering, from app behaviour down to native binaries |
| 74.1k | career-ops-hq/career-ops | Job search: scans job boards and scores each job against your CV |
| 66.9k | calesthio/OpenMontage | Agentic video production, 700+ skills |
| 54.2k | coreyhaines31/marketingskills | Marketing: CRO, copywriting, SEO, analytics |
| 51.3k | Imbad0202/academic-research-skills | Academic pipeline: research, write, review, revise |
| 49.4k | kepano/obsidian-skills | Obsidian CLI and its file formats (from Obsidian's CEO) |
| 48.4k | K-Dense-AI/scientific-agent-skills | Science: bioinformatics, chemistry and more |
| 47.4k | Yuan1z0825/nature-skills | Nature-style academic writing and scientific figures |
| 46.1k | MadsLorentzen/ai-job-search | Job applications: evaluate postings, tailor CVs |
| 40.9k | zhaoxuya520/reverse-skill | Reverse engineering and authorised pentest skill router |
| 36.5k | JCodesMore/ai-website-cloner-template | Clone a website with coding agents |
| 34.5k | virgiliojr94/book-to-skill | Turns a technical book PDF into a skill |
| 34.2k | mukul975/Anthropic-Cybersecurity-Skills | 817 cybersecurity skills mapped to MITRE and NIST |
| 31.8k | iOfficeAI/OfficeCLI | Agent tooling to read and edit Word, Excel and PowerPoint |
| 31.3k | googleworkspace/cli | Google Workspace CLI with agent skills (Drive, Gmail, Calendar…) |

## 8. Ecosystem infrastructure (not skills, but large)
| Stars | Repo | Purpose |
|---|---|---|
| 142.8k | farion1231/cc-switch | Desktop app to manage Claude Code, Codex, OpenCode and other configs and providers |
| 89.7k | stablyai/orca | Environment for running a fleet of parallel coding agents |
| 43.4k | herdrdev/herdr | Runtime for coding agents |
| 37.7k | anthropics/claude-plugins-official | Anthropic's official Claude Code plugin directory |
| 34.1k | openai/codex-plugin-cc | Use Codex from inside Claude Code (review or delegate) |
| 33.8k | vercel-labs/skills | `npx skills`, the open cross-agent skill installer |

## What this means for C-Skills

- **Mostly other purposes.** The top unseen repos are mainly not engineering-process packs like ours. They cluster around design taste, codebase knowledge graphs, token savers, output style and domain libraries. Our closest neighbours are ECC, oh-my-claudecode and claude-code-best-practice.
- **Ideas worth a look later:**
  - **i-have-adhd:** answer-first output overlaps with `plain`.
  - **taste-skill and hallmark:** the UI equivalent of `unslop`, a category we don't cover.
  - **last30days-skill:** a research pattern for gathering multi-source reception.
  - **ECC:** the biggest general pack, worth checking for overlap.
