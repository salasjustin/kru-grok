---
name: run-log
description: Run an autonomous or unattended stretch of work on a written contract and an append-only decision log, then hand back through a cross-model review. Run by the lead, or by a delegate the lead hands the run to.
disable-model-invocation: true
---

<!-- adapted from `cursor/plugins` (main) → `pstack/skills/show-me-your-work` (incl. `scripts/log.sh`) and `pstack/skills/poteto-mode/playbooks/autonomous-run.md` (MIT, © 2026 Lauren Tan). Adapted, not verbatim: the trail lives in the plan store, the contract is a file, and the review hands back through the lead. See `NOTICE`. -->

An autonomous run is work nobody watches until it hands back. The contract fixes what done means before the first iteration; the log is how the user trusts the result after.

Paths: `bash scripts/kru-store.sh path runs` → `<project store>/runs/`; one run is `runs/<slug>/`, holding `contract.md` and `decisions.tsv`.

## 1. Load the process
A delegate running this — a headless builder on another model, a subagent handed the run — reads `GROK.md` and `skills/lead/SKILL.md` first. Done when both are read.

## 2. Write the contract
`runs/<slug>/contract.md`, before the first iteration:
- **Exit predicate** — a statement a command or file settles: named tests green, the repro fixed, N tickets `done`, a count reached.
- **Scope** — the paths and tickets the run may touch.
- **Off-limits** — paths it leaves alone, and the one-way doors that stop it: push, merge, deploy, publish, a migration on shared data, a deletion, any message off the box (`GROK.md` → Approval).

Done when the predicate can be checked by running something.

## 3. Iterate
Each iteration makes the smallest change the evidence justifies, checks it against the predicate, commits locally if it advanced, and reverts if it didn't — a change that only "might help" is reverted. What turns up along the way inside scope (a flaky check, a broken helper, fixable drift) is yours to fix; a question an experiment settles gets the experiment (`skills/lead/SKILL.md` → *Talk to a PM*). Log a row per iteration.

**Stop** when the predicate is met, or at a real dead end or a one-way door, logged as the last row with what stopped it. A plateau is a cue to change approach. The predicate stays as written: a run that can't meet it hands back saying so.

## The log
`runs/<slug>/decisions.tsv`, append-only, one row per decision — columns `ts · phase · decision · why · evidence · result`. Write rows with the helper:

```sh
bash skills/run-log/scripts/log.sh "$(bash scripts/kru-store.sh path runs)/<slug>/decisions.tsv" <phase> <decision> <why> <evidence> <result>
```

It stamps `ts`, writes the header on first use, flattens tabs and newlines, and quotes a cell starting with `=` `+` `-` `@` so a spreadsheet never runs it.
- A row is a decision point: a fork taken, an iteration and its check result, a revert and its trigger, a blocker — in plain words, the way you'd tell a teammate.
- **evidence** is a pointer: commit sha, test name, command, artifact path. **result** is the predicate's state after the row: `tests green`, `reverted`, `open`.
- A wrong row is superseded by a new row; earlier rows stay as written.
- **A new run on an existing log** — a pickup, a replacement agent, a new session — opens with a row of phase `start`, naming the `ts` range of earlier rows it did not write, with who it is as evidence. `start` marks only that.

## 4. Hand back
1. **Audit the log** against what happened: each row maps to a real action, each evidence pointer resolves (`git show`, the file exists, the command reproduces), each fork that shaped the work has a row. Correct by superseding rows.
2. **Cross-model review.** A reviewer on a different model family from the builder reads `contract.md`, `decisions.tsv` and the run's diff against its base, and returns an Attention list: rows with weak or missing evidence, checks claimed without proof, choices that look premature, scope-creeping or symptom-patching, and what a skim would miss. On this box `claude -p` reviews Grok-built work and a Grok `executor` reviews work a headless Claude built; the builder reviewing itself is not this step.
3. **Reply** with the predicate and its final state, iterations run, what landed, what was reverted, then a section headed `Attention — reviewed by <model>` listing the reviewer's flags, each pointing at a row or commit (`No flags` is a valid list).

Done when the reply carries that section with the reviewer's model named.
