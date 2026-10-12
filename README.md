# kru-grok

*(said “crew”)* — an engineering department for **Grok Bot**: a lead plus ~40 specialist seats, each with an official-sources-first prompt, and ~100 skills.

This is a fork of [`ap-justin/kru`](https://github.com/ap-justin/kru), a Claude Code plugin, repurposed to run natively on Grok Bot. The seat definitions, skills, routing and shared blocks are the original's substance; the Claude Code mechanics (plugin manifests, hooks, slash commands, subagent frontmatter) are gone. See `NOTICE` for attribution and `docs/legacy-claude-code/` for what was removed (reference only, nothing there is loaded).

## How Kru uses it

- **Kru is the lead.** A Grok Bot assistant that acts as Justin's engineering manager, reporting through Tali (the user's single point of contact). Kru reads `skills/lead/SKILL.md` before building, reviewing or dispatching, and follows `GROK.md`.
- **Seats are background subagents.** Kru spawns an `executor` (or `computerUse` for browser work) with a brief that starts *"Read `agents/<seat>.md` and work as that lens,"* then the slice's brief (`skills/lead/SKILL.md` → Step 3 has the seven items). Reviewers are read-only and write their report to a path in the brief.
- **Skills are `SKILL.md` files** with `name` + `description` frontmatter, loaded by reading the file. Seats load the skills their prompts name; the lead loads `brief`, `setup`, `roster` and the rest by name.
- **Routing**: `references/routing.md` maps what a repo contains to the seat that owns it; `ROSTER.md` lists seats and tiers; `SOURCES.md` lists each stack's official source.
- **Plan store**: `/workspace/kru-store/<project>/` (briefs, plans, tickets, todos, issues, the project's `sheet.md`, `dispatch.log`). Resolved by `scripts/kru-store.sh`; never inside the working repo. Format: `TRACKER.md`; preference loop: `PREFERENCES.md`.
- **Approval**: Kru never pushes, merges, deploys, publishes or messages anyone outside the box without the user's approval in chat.

## First run on a project

Kru runs the `setup` skill: derive the repo's stack, seat ownership and test/verify commands, grill a blank repo first, and write `sheet.md` to the store after approval. Then ask for work in plain words: *"add feature Y"*, *"fix Z"*, *"build a landing page for X"*.

## Skills by name (the former slash commands)

Getting started: `setup`, `verify-setup`, `lead`. Long runs: `run-log`, `pause-resume`. Planning: `brainstorm`, `brief`, `briefs`, `copy-deck`. Capture: `todo`, `todos`, `issue`, `issues`, `todos-loop`, `issues-loop`, `remember`. Hygiene: `landed`, `text-fix` (`comment-fix`, `doc-fix`, `prose-fix`), `reflect`. Audits: `seo-review`, `ux-review`, `visual-review`, `accessibility-review`, `review-animations`, `improve-animations`, `design-gallery`, `design-system`. Team care: `roster` (`hire`/`author`/`audit`/`learn`/`retire`), `update`. User-invoked skills in the original are run by Kru when the user asks, via Tali.

## Stack

UI: React, Svelte 5, Web Components. Frameworks: React Router 7, Next.js, TanStack Start, SvelteKit, Go-served React, Python. Data: Postgres, SQLite, Turso, Sanity. Auth, payments, accounting: Better Auth, Stripe, PayPal, Chariot, NOWPayments, QuickBooks. Integrations: Zapier. Platform: Vercel, Cloudflare, Fly.io. Tooling: pnpm, Turborepo, Biome. Packages: Vite plugins, MCP servers, small Node libraries. A stack with no seat is a question Kru brings to the user before guessing.

## Adding a seat

Kru runs `roster hire <role>` (`skills/roster/hire.md`), which writes `agents/<name>.md` (frontmatter: `name`, `description` only; shared blocks copied from `skills/roster/shared-blocks.md`), then registers it in `ROSTER.md`, `SOURCES.md` and `references/routing.md`, bumps `VERSION` and the `ROSTER.md` header together, and runs `bash scripts/audit.sh`. Skills: `roster author`. The commit stays on a branch; pushing waits for the user.

## Checks

```sh
bash scripts/verify.sh           # the static gate CI runs on every PR: all of the below, plus JSON/YAML/frontmatter
                                 # validity, version consistency and a scan for other-platform leftovers
bash scripts/audit.sh            # counts, orphans, version equality, frontmatter shape, stale host mechanics
bash scripts/kru-store.test.sh   # the store resolver
bash scripts/run-log.test.sh     # the run-log row writer
bash scripts/smoke.sh            # local only, needs ANTHROPIC_API_KEY: a headless agent runs lead + run-log + pause-resume end to end
```

## Version

`VERSION` is the single version (plain semver, `0.150.0` = upstream `0.148.0` plus the Grok Bot repurposing and the pstack reliability pass); `ROSTER.md`'s header equals it.

## License

MIT. See `LICENSE` (original © ap-justin) and `NOTICE`. Vendored upstream skills keep their own licenses.
