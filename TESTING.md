# Testing

`bash scripts/verify.sh` is the gate: it runs every check below and every tracked `*.test.sh`, and CI (`.github/workflows/verify.yml`) runs it on each pull request. It needs `jq` and a `python3` that imports PyYAML (or `uv`, which fetches it).

The tested code is the scripts: `scripts/kru-store.sh` has `scripts/kru-store.test.sh` and `skills/run-log/scripts/log.sh` has `scripts/run-log.test.sh`, plain bash table tests.

```sh
bash scripts/kru-store.test.sh
bash scripts/run-log.test.sh
```

- **Every run under `env -u`** for `KRU_HOME`, `KRU_PROJECT` and `KRU_PROJECT_STORE`, so nothing set in the parent shell turns a case green.
- **A new case proves nothing until it has gone red.** Break the branch the case covers in a scratch copy, run it, then delete the copy.

`scripts/smoke.sh` is the live check, local only: with `ANTHROPIC_API_KEY` set, a fresh `claude -p` agent in a temp HOME and a throwaway repo reads `GROK.md` and the lead skill, adds a function with a test under `run-log` and `pause-resume`, and the script asserts the handoff's done-checks and proof, `decisions.tsv`, `resume.md`, the commit and a re-run of the tests. About $0.15 on Sonnet; `SMOKE_MODEL`, `SMOKE_MAX_TURNS`, `SMOKE_MAX_USD` tune it.

The team's own drift checks (counts, orphans, version equality, frontmatter shape, stale host mechanics) are `skills/roster/audit.md`; `scripts/audit.sh` runs the mechanical ones.

The Claude Code hook tests and plugin evals were retired with the hooks; the evals are kept as reference cases in `docs/legacy-claude-code/evals/`.
