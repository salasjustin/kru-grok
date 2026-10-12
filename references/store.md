# The store — two roots, one resolver

The team writes two kinds of durable state, with different lifetimes. On Grok Bot both live on the box under `/workspace/kru-store/`:

- **Cross-project** (`/workspace/kru-store/`) — the preference loop: `inbox.md`, `patterns/`, `refusals.jsonl`, and the audit bookkeeping. It follows the **user**, across every engagement.
- **Project** (`/workspace/kru-store/<project>/`) — one project's plan of record: `TODOS.md`, `issues/`, `notes/`, `plan/` (`TRACKER.md` owns its layout), plus `sheet.md` (from `setup`), `dispatch.log` (the lead's dispatch ledger), `agent-memory/<seat>.md`, `verify/` (from `verify-setup`), `runs/<slug>/` (from `run-log`) and `resume.md` (from `pause-resume`).

**`scripts/kru-store.sh` resolves both** and is the single source of truth for where the store sits:

```sh
bash scripts/kru-store.sh path plan/checkout/brief.md
bash scripts/kru-store.sh project      # /workspace/kru-store/<slug>
bash scripts/kru-store.sh where        # a line to report only when the store is not at its defaults
```

Ask it for a path; never assemble one.

## The logical names

| Cross-project | Project |
|---|---|
| `inbox` · `patterns/<slug>` · `refusals` · `audit/<name>` | `todos` · `issues/<slug>` · `notes/<slug>` · `plan` · `plan/<effort>/<file>` · `sheet` · `dispatch` · `agent-memory` · `verify` · `runs` · `resume` |

## Overrides

| Variable | Effect |
|---|---|
| `KRU_HOME` | moves the cross-project root (and the project roots under it) |
| `KRU_PROJECT` | pins the `<slug>` (default: the repo's dir name; a linked worktree resolves to the **main** repo, so a slice in a worktree writes to the same store) |
| `KRU_PROJECT_STORE` | pins the whole project path |

## Rules

- **The working repo stays clean — no management files in it, ever.** The store is outside the repo; the repo never points at it.
- **Every writer writes plain files.** There is no sync, no artifact backend and no hook; the box's disk is the store. Anything the user must see is reported through Tali, not left in a file.
- The original Claude Code design (cloud vm roots, `KRU_STORE_REPO` git sync, an artifact backend) is kept in `docs/legacy-claude-code/store-original.md`.
