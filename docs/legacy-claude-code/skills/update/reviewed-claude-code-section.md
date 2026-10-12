## Claude Code

### Swept through

**2.1.295** — 2026-10-10, read back to 2.1.289. Installed: 2.1.295.

Previous: 2.1.288 — 2026-10-03, read back to 2.1.281. 2.1.280 — 2026-09-23, read back to 2.1.251. Before that: 2.1.250 — 2026-08-28, first sweep, read back to 2.1.200.

### Adopted

| Shipped | Feature | Wired into |
|---|---|---|
| 2.1.78 | `effort:` on plugin-shipped agents (`low`\|`medium`\|`high`\|`xhigh`\|`max`) | `agents/*.md` frontmatter; policy in `ROSTER.md` → *Model tiers* |
| 2.1.248 | `experimental.cacheTtl: "1h"` per-agent prompt cache TTL | the re-dispatched seats' frontmatter (builders, `test-writer`, `code-reviewer`) |
| — | `claude plugin details <plugin>` — component inventory + projected always-on token cost | `skills/roster/audit.md`, as the roster's context-load read |
| 2.1.218 · 2.1.223 | `/code-review` runs as a background subagent, and with no level reuses the last one typed | `lead` SKILL.md → Step 4 |
| 2.1.261 | `/skill-doctor` — which loaded skills go unused and what each costs in context | `skills/roster/audit.md` → *Context load*, beside `claude plugin details`, as a read the user types |
| 2.1.280 | Claude Opus 5.5 (`claude-opus-5-5`) — 1M context, $4/$20 per Mtok, $0.20 cache reads | the 33 opus-tier seats' `model:`; `ROSTER.md` → *Model tiers*; `roster/hire.md` + `audit.md` pin text; README → *Requirements* (model access, floor ≥ 2.1.280) |
| — | Claude Sonnet 5.5 (`claude-sonnet-5-5`) — same $2/$10 as Sonnet 5, ~30% faster, fewer tokens per task | the 3 sonnet-tier seats' `model:`, plus `test-writer`, `visual-reviewer`, `accessibility-reviewer`, `graphic-designer` moved down from opus; `ROSTER.md` → *Model tiers*; `roster/hire.md` + `audit.md` pin text; README → *Requirements* |
| 2.1.283 | `/doctor prompt-audit` — audits CLAUDE.md, skills and agents for prompting written for older models; an installed plugin's files are reported, never edited | `skills/roster/audit.md` → *Context load*, as a read the user types beside `/skill-doctor` |
| 2.1.286 | Correction, not a feature: no built-in `/verify` ships; the CLI runs a *project or user* skill named `verify` before a commit. `/tdd` and `/diagnosing-bugs` are this plugin's vendored skills, not built-ins | `ROSTER.md` intro, `lead` → `references/gates.md` → *Behavior*, `claude.md` surface table |
| 2.1.286 | Claude Code runs a project skill named `verify` before a non-docs commit | `skills/setup/SKILL.md` → 1d writes `.claude/skills/verify/SKILL.md` from the sheet's `verify` line |
| 2.1.287 | *You should know* built-in mod — a side agent flagging mid-task what the turn missed | README → *Requirements* (recommended); `setup` cloud script enables it; `lead` → *Returns are input* triages its cards |
| 2.1.287 | Claude Mods — plugin function hooks with UI | `kru-board`, a row above the prompt naming the running seats; on trial as a session dev mod outside this repo, not yet shipped in the plugin |
| — | `userConfig` (values reach hooks as `CLAUDE_PLUGIN_OPTION_<KEY>`; `claude plugin configure` 2.1.286) | `plugin.json` → `KRU_STORE_REPO` + four `KRU_NO_*` switches; `scripts/kru-store.sh` maps each onto its unset env var |
| 2.1.290 | Correction: `/code-review` at `medium` on Opus 5.5 / Sonnet 5.5 also reports cleanup and CLAUDE.md-convention findings — not correctness only | `lead` → `references/gates.md` → *Correctness*; the comment pass stays the lead's (Block I isn't in CLAUDE.md) |
| — | Correction: `brainstorm-guard.sh` read any transcript line carrying an invocation, tool output included, and locked a session that never brainstormed | the anchor now matches only a string-content user turn; fixtures splice the name |

### Considered — the user's call

- **`hooks:` in agent frontmatter** (PreToolUse/PostToolUse/Stop, agent-scoped). The obvious target is the conformance gate, but that gate is built in the *target* repo at Phase 0 and keyed to that repo's token file — a plugin-level hook can't know it. Worth revisiting as a builder-authored hook written into the target repo's own `.claude/settings.json` alongside the test.
- **`isolation: worktree`** on builders — declarative parallel builds without collision. Against it: parallel worktrees plus `tsc` is the fan-out a machine budget in `~/AGENTS.md` forbids.
- **`context: fork` + `background:`** on the read-only skills (`todos`, `issues`, `comment-fix`'s audit). Forked skills run in the background by default (2.1.218), which is the wrong shape for a list the user typed and is waiting on.
- **`claude plugin eval`** — `evals/**/case.yaml` with an `--ablation` arm scores the plugin against a no-plugin baseline, which is the only mechanical answer to *did the lead route to the right seat*. Shipped 2.1.269 and reachable on this install as of 2.1.280 (`--help` answers, no early-access reply). The cost is authoring and paying for the suite. Banked 2026-09-23: the user tracks it on a todo/branch of its own.

### Declined

- **`--restricted` / `CLAUDE_CODE_RESTRICTED`** — every seat here needs Bash or file writes.
- **`maxTurns` on agents** — a builder truncated mid-change costs more than the runaway it prevents; the per-session spawn caps already bound the fan-out.
- **`disallowedTools` on agents** — the seats that need a bound already carry an explicit `tools:` allowlist.
- **`modelPicker`, `modelPricing`, `promptCacheTtl`/`subagentPromptCacheTtl`, `spinnerTipsOverride`** — user or managed settings, outside a plugin's reach.
- **Cross-session `SendMessage` / `ListAgents`** — the lead already owns its subagents' results; peer sessions are a workflow the team doesn't run.
- **`omitClaudeMd`** (2.1.271) — the machine budget, the comment standard and the repo's `setup` sheet reach seats only through CLAUDE.md (`lead` SKILL.md → *Ambient blocks*). `dispatch-auditor`, which reads only the ledger, was the one candidate; the user declined it 2026-09-23.
- **`claude plugin validate --json`, `plugin install|update --json` / `--accept-command`, `--plugin-dir` over a folder of plugins** — no sweep or audit step here parses their output.
- **`CLAUDE_CODE_SUBAGENT_MODEL` / `_FORCE`** (2.1.251 · 2.1.257) — user env. As of 2.1.251 a seat's `model:` wins over the non-forced one, which is what the pins assume.
- **`PreModelSwitch` / `PostModelSwitch` hooks, the `PermissionRequest` agent-hook removal** — the plugin ships no model-switch or `PermissionRequest` hook.
- **Current, no line moves:** subagent returns now arrive under a subagent-output header (2.1.277; `lead` → *Returns are input* still holds). `TaskOutput` was removed (2.1.277), and no team file names it. `/code-review` uses leaner inline prompts on untuned models (2.1.274); the background-run claim in `gates.md` still holds.
- **`SendFeedback`, `/usage-credits`, self-hosted runner, GitLab marketplaces + MR support, `archive` plugin source, IDE and terminal rendering, managed/enterprise settings, provider plumbing** — no surface in this repo.
- **`/code-review --max-findings`** (2.1.288), **agent-teams plugin-agent fix**, **`claude plugin validate` MCP checks**, foreground-subagent task-tools fix — no line moves: `lead` passes no finding cap, the team runs no agent teams, the plugin ships no MCP server, and `check-task-tools.sh` still covers a session with the tools off.
- **`onFailure: "block"` on command hooks** (2.1.295) — the gates (`require-lead`, `check-handoff`, `brainstorm-guard`) fail open on purpose: a gate that can't start would otherwise lock every tool call in the session.
- **Agent tool `effort` parameter** (2.1.292) — seat effort is policy in frontmatter (`ROSTER.md` → *Model tiers*); no routing rule asks for a per-dispatch override.
- **`claude plugin install --marketplace`** (2.1.292) — not in this install's `--help`; the two-line add + install works on every CLI above the floor.
- **Claude Haiku 5.5** (2.1.293) — no seat is on the haiku tier.
- **Current, no line moves:** subagents preload ≤32 `skills:` (2.1.295; no seat uses the field). `<system-reminder>` escaped in hook output (2.1.292; no hook emits one). `prompt`/`agent` hook judging (2.1.294; plugin ships command hooks only). `claude plugin validate` README install-line advice and the marketplace-manifest fix (2.1.289/2.1.295; validate passes clean). Skill `allowed-tools`/`effort` drop fixes, mod API additions (`$.ui.notify`, `isDeferred`, `agent.spawn`, `tool.check` `agentId`; `kru-board` isn't shipped), `subagentStatusLine` `agentType`.
- **Plan mode under `brainstorm`** — the user rejects it: every piece of feedback re-raises the plan-approval prompt. `brainstorm-guard.sh` stays, its anchor fixed.

