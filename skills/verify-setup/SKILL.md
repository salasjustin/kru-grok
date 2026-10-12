---
name: verify-setup
description: Write a project's verify recipe — launch the real app, drive a feature the way a user does, capture evidence — plus a feature map, into the plan store, proven end to end once. Run by the lead or the user when a project has no `verify/`.
disable-model-invocation: true
---

<!-- adapted from `cursor/plugins` (main) → `pstack/skills/create-verification-skill` and `pstack/skills/maintain-verification-skill` (MIT, © 2026 Lauren Tan). Adapted, not verbatim: the output is a recipe in the plan store rather than a project-local skill, and maintenance is the last section here rather than its own skill. See `NOTICE`. -->

The proof for a user-facing behavior is the real app, driven the way a user drives it, with evidence captured. This skill writes that recipe once per project so every later slice drives the same path. Its reader is a seat or the lead mid-task, cold, who has never seen the app.

Output: `bash scripts/kru-store.sh path verify` → `<project store>/verify/` — `README.md` (the recipe) and `features/` (the map). It lives in the store, outside the working repo (`references/store.md`).

## 1. Interview the repo
Answer from the codebase, starting with the sheet's `test` and `verify` lines (`bash scripts/kru-store.sh path sheet`) when it exists; ask the user only what no file shows.
- **Surface** — what a user touches: web UI, CLI/TUI, API, desktop app, library. Pick the primary; note the rest.
- **Run** — the repo's own dev command (package scripts, Makefile, README), ports, env vars, seed data, auth.
- **Drive** — an existing harness first (Playwright specs, curl-able endpoints, a PTY helper); else the generic one: a `computerUse` browser for web, a tmux/PTY session for a CLI or TUI, HTTP for a service.
- **Observe** — screenshots, terminal transcripts, response bodies, exit codes, rows.
- **Isolate** — whether two instances run side by side (ports, data dirs). Where they can't, the recipe says so.

A checkout that won't build or start is fixed or reported precisely first — a recipe written against a broken base teaches wrong steps. Done when all five have an answer citing the file it came from, or a named question.

## 2. Write the recipe
`verify/README.md`, every section grounded in step 1, no placeholders left:
- **Launch** — the exact start command, its ready signal (a log line, a port answering) and teardown. A short-lived CLI builds once, then runs each drive in its own PTY session.
- **Doctor** — one read-only check that this instance is worth driving: process up, right build, port ours, auth valid. It runs first, and again after anything surprising.
- **Drive** — the harness with this repo's real handles: ARIA names, data attributes, routes, prompt strings.
- **Evidence** — what a proof captures and where it lands (`verify/evidence/<slice>/`): the real user path rather than a test-only endpoint; the action and the state it produced; side effects (rows, files, messages sent) beside what is visible; a dry-run's skips observed rather than trusted from its name.
- **Cleanup** — stop what this run started, by PID or session name; remove scratch state; keep the evidence.
- **Helpers** — each script in `verify/bin/`, executable, its invocation shown in the README.

Done when every section names a real command or handle from this repo.

## 3. Seed the feature map
`verify/features/README.md` — the index plus baseline preconditions — and one file per user-facing feature, the top 3–5 from routes, commands or menus. Each file: an H1, one paragraph of the behavior a user sees, then four H2s in order — `Sub-features` (short IDs) · `How to get to it (user POV)` (every entry point) · `Driving it with <harness>` (preconditions, then each action paired with its exact command and observable result) · `Gotchas`. User paths and stable handles only. A proof that drives one entry point of a feature the map lists three for is a partial proof. Done when the index links every feature file.

## 4. Prove it once
Run the recipe end to end: launch, doctor, drive one mapped feature, capture evidence, clean up — then confirm the evidence still sits where *Evidence* says. Fix what fails, running Cleanup after every failed attempt. Done when one feature's evidence exists at its path after teardown; a recipe never run is a draft.

## Keep the map honest
A slice that changes a mapped feature's entry point, handle or end state updates that feature file in the same slice, and its build proof drives the updated file. A feature the app dropped leaves the map. A mapped behavior the app no longer does is a product regression, captured to `issues/` (`skills/lead/references/reconcile.md`) while the map keeps the intended behavior.
