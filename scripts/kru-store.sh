#!/bin/bash
# the store's roots, resolved in one place (Grok Bot: /workspace/kru-store/<project>/). skills and seats
# call it as a command — `bash scripts/kru-store.sh project` —
# so no prompt re-derives a path and drifts from this one.
#
# two roots: the CROSS-PROJECT root (kru_home — inbox, patterns, audit logs; follows
# the user) and the PROJECT root (kru_project — one project's plan of record).
# KRU_HOME overrides the home; KRU_PROJECT_STORE overrides the project root;
# KRU_PROJECT pins the slug. defaults: /workspace/kru-store and /workspace/kru-store/<slug>.
#
# sourcing defines functions and prints nothing.

# the repo the session is working in. a linked worktree resolves to the MAIN
# repo (--git-common-dir), so a slice dispatched into a worktree keeps the same
# slug — and the same store — as the session that spawned it.
kru_repo_root() {
  local common
  common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
  case "$common" in
    */.git) printf '%s' "${common%/.git}"; return 0 ;;
    /*) printf '%s' "$common"; return 0 ;;
  esac
  common=$(git rev-parse --show-toplevel 2>/dev/null)
  [ -n "$common" ] && { printf '%s' "$common"; return 0; }
  printf '%s' "$PWD"
}

# one name identifies a project across both stores — the inbox line /remember
# stamps and the plan dir the planner writes carry the same slug. the dir name
# differs by machine — a cloud vm names the clone after the github repo — so
# KRU_PROJECT pins it (export it for the session),
# it reaches every surface.
kru_slug() { printf '%s' "${KRU_PROJECT:-$(basename "$(kru_repo_root)")}"; }

kru_home() { printf '%s' "${KRU_HOME:-/workspace/kru-store}"; }

kru_project() {
  [ -n "${KRU_PROJECT_STORE:-}" ] && { printf '%s' "$KRU_PROJECT_STORE"; return 0; }
  printf '%s/%s' "$(kru_home)" "$(kru_slug)"
}

# which backend holds the cross-project root. the project root is always files.
kru_backend() {
  [ -n "${KRU_STORE_URL:-}" ] && { printf 'artifact'; return 0; }
  printf 'fs'
}

# logical name -> filesystem path. the names are the seam's vocabulary
# (references/store.md); callers name the thing, never the layout.
kru_path() {
  case "${1:-}" in
    inbox)       printf '%s/inbox.md' "$(kru_home)" ;;
    refusals)    printf '%s/refusals.jsonl' "$(kru_home)" ;;
    patterns)    printf '%s/patterns' "$(kru_home)" ;;
    patterns/*)  printf '%s/patterns/%s.md' "$(kru_home)" "${1#patterns/}" ;;
    audit)       printf '%s/audit' "$(kru_home)" ;;
    audit/*)     printf '%s/audit/%s.jsonl' "$(kru_home)" "${1#audit/}" ;;
    sheet)       printf '%s/sheet.md' "$(kru_project)" ;;
    dispatch)    printf '%s/dispatch.log' "$(kru_project)" ;;
    todos)       printf '%s/TODOS.md' "$(kru_project)" ;;
    issues)      printf '%s/issues' "$(kru_project)" ;;
    issues/*)    printf '%s/issues/%s.md' "$(kru_project)" "${1#issues/}" ;;
    notes)       printf '%s/notes' "$(kru_project)" ;;
    notes/*)     printf '%s/notes/%s.md' "$(kru_project)" "${1#notes/}" ;;
    plan)        printf '%s/plan' "$(kru_project)" ;;
    plan/*)      printf '%s/plan/%s' "$(kru_project)" "${1#plan/}" ;;
    agent-memory) printf '%s/agent-memory' "$(kru_project)" ;;
    verify)      printf '%s/verify' "$(kru_project)" ;;
    runs)        printf '%s/runs' "$(kru_project)" ;;
    resume)      printf '%s/resume.md' "$(kru_project)" ;;
    *) return 1 ;;
  esac
}

# the line a skill reports when the store is not where a reader assumes.
# silent when both roots sit at their local defaults and files hold them.
kru_where() {
  local h p b notes=""
  h=$(kru_home); p=$(kru_project); b=$(kru_backend)
  [ "$h" != "/workspace/kru-store" ] && notes="preferences: $h"
  [ "$b" = artifact ] && notes="${notes:+$notes; }preferences: artifact store $KRU_STORE_URL"
  [ -n "${KRU_STORE_REPO:-}" ] && notes="${notes:+$notes; }synced to $KRU_STORE_REPO"
  case "$p" in
    "$h/"*) ;;
    *) notes="${notes:+$notes; }plan store: $p" ;;
  esac
  [ -n "$notes" ] && printf 'kru store — %s\n' "$notes"
  return 0
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  case "${1:-}" in
    home)    kru_home; echo ;;
    project) kru_project; echo ;;
    slug)    kru_slug; echo ;;
    backend) kru_backend; echo ;;
    where)   kru_where ;;
    path)
      [ $# -ge 2 ] || { printf 'usage: kru-store.sh path <logical>\n' >&2; exit 64; }
      kru_path "$2" || { printf 'kru-store: no such logical path: %s\n' "$2" >&2; exit 64; }
      echo ;;
    *)
      printf 'usage: kru-store.sh home|project|slug|backend|where|path <logical>\n' >&2
      exit 64 ;;
  esac
fi
