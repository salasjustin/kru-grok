---
name: pause-resume
description: Pause work at a safe point with a resume note a cold agent can pick up from, or pick paused work back up from that note without redoing it. Run by the lead, or by a delegate handed a pickup.
disable-model-invocation: true
---

<!-- adapted from `cursor/plugins` (main) → `pstack/skills/poteto-mode/playbooks/pause-safely.md` and `session-pickup.md` (MIT, © 2026 Lauren Tan). Adapted, not verbatim: the note lives in the plan store and the pickup routes back into the lead. See `NOTICE`. -->

The resume note is `bash scripts/kru-store.sh path resume` → `<project store>/resume.md`, one per project; a new pause replaces it.

## Pause
Runs on an explicit ask to stop or pause; "keep going" means keep going.
1. **Stop at a safe boundary** — finish the current atomic step or back it out, start nothing new, and let in-flight seats return or stop them, logging each (`GROK.md` → Dispatching a seat).
2. **Take only reversible steps** — pausing pushes nothing and opens nothing.
3. **Make it durable** — commit uncommitted edits as one `wip: <what>` commit on the current branch, staging the slice's paths by name; a broken tree gets one line saying so in the commit body.
4. **Write `resume.md`** — intent, branch and base, what landed and what is verified (with its proof), current state, in-flight seats and their briefs, next steps in order, key files, gotchas. Where a run log exists (`skills/run-log/SKILL.md`), point at it instead of restating it.

Done when the tree is clean or committed and `resume.md` names the first action on resume. Reply with where the work stands, the `wip:` commit, and that first action.

## Pickup
1. **Load the process** — a delegate picking up reads `GROK.md` and `skills/lead/SKILL.md` before anything else.
2. **Read the trail** — `resume.md`, the run log's last rows where one exists, the worklist, then `git log` and `git diff` against the base. Rows this pickup adds open with a `start` row (`skills/run-log/SKILL.md` → The log).
3. **Trust the trail** — name the resume point from done against pending; completed work and earlier repros stay done.
4. **Verify inherited claims on the real artifact** — re-run the named test or command behind each claim the next step builds on (`skills/lead/references/gates.md` → *Done is judged on evidence*).
5. **Route the rest into the lead** — the remaining work goes through Step 3 as ordinary slices.

Done when each claim the next step builds on has had its proof re-run and the resume point is on the worklist. Reply with where the prior work stopped, what was inherited against redone, and the resume point.
