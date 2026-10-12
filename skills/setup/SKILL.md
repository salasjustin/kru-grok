---
name: setup
description: Set the team up for a project — derive the repo's standing answers (which seats own which directories, which skills apply, how to test and verify) and write them as a sheet in the plan store. A blank repo is grilled first.
---

Setup records, once per project, **who is on the team here**, so every later dispatch routes off written answers instead of re-deriving them. It is run by the lead (Kru) when a project is first taken on, and re-run when the repo or this team's version moves. It never edits the project repo unless the user approves in chat.

The Claude Code original also wrote cloud-VM install hooks, a `verify` project skill and permission grants; none of that exists here. The full original is kept at `docs/legacy-claude-code/skills/setup/SKILL.md` for reference only.

## Do

1. **Load the standard.** Read `skills/lead/SKILL.md`, `ROSTER.md`, `references/routing.md` and `skills/writing-for-agents/SKILL.md` (for the bars on the sheet's own prose).
2. **Resolve the store.** `bash scripts/kru-store.sh project` prints `/workspace/kru-store/<project>/`. Create it on first write. The sheet is `sheet.md` in that directory.
3. **Derive the sheet from the repo, not from guesses.** Read manifests (`package.json`, lockfiles, `go.mod`, `pyproject.toml`, `wrangler.*`, framework configs), the repo's own `AGENTS.md`/`README`/CI config, and the directory layout. Fill the fields in `skills/setup/sheet.md` — `project seats` · `skills` · `tokens` · `screens` · `test` · `verify` · `mcp` — one line per key, each citing what it was derived from (a manifest entry, or the user's decision with the date). A seat line names the directories its seat owns, in backticks, so the lead's handoff check can compare a brief's files against them.
4. **Pick seats by `references/routing.md`**: detected stack → seat, and the *Conditional skills* table for the skill line. A stack with no seat is not covered by a nearby seat; record it as a gap (`skills/lead/SKILL.md` → *Handling gaps*).
5. **Blank repo.** Grill first (`skills/grilling/SKILL.md`; the lead's *Step 2*), settle stack and decisions with the user, then record each decision as the derivation of its line (`← decided <date>`).
6. **Dependency drift.** A dependency a major behind its skill's *Reproduced on* pin becomes a `discovered` todo (`todo` skill); patch/minor bumps file as one catch-up line.
7. **Show, then write.** Present the sheet in chat. Write `sheet.md` to the store after the user's yes. If the user also wants it in the repo's `AGENTS.md`, show that diff separately and wait for approval; a committed change to their repo is theirs to approve.
8. **Report** what the team may now do unasked: nothing beyond reading the repo and writing to the store. Everything that edits the repo, pushes, merges or deploys still needs chat approval (`GROK.md`).

## Re-run

Re-running is the full update path: the sheet is a function of (team version × repo state). Re-derive, diff against the stored `sheet.md`, update only lines whose cited source changed, and leave lines the user wrote by hand.
