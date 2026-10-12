# Testing

The store resolver is the tested code: `scripts/kru-store.sh` has `scripts/kru-store.test.sh`, a plain bash table test.

```sh
bash scripts/kru-store.test.sh
```

- **Every run under `env -u`** for `KRU_HOME`, `KRU_PROJECT` and `KRU_PROJECT_STORE`, so nothing set in the parent shell turns a case green.
- **A new case proves nothing until it has gone red.** Break the branch the case covers in a scratch copy, run it, then delete the copy.

The team's own drift checks (counts, orphans, version equality, frontmatter shape, stale host mechanics) are `skills/roster/audit.md`; `scripts/audit.sh` runs the mechanical ones.

The Claude Code hook tests and plugin evals were retired with the hooks; the evals are kept as reference cases in `docs/legacy-claude-code/evals/`.
