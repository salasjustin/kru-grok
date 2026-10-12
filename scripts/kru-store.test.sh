#!/bin/bash
# plain table test for scripts/kru-store.sh (Grok Bot layout).
S="$(cd "$(dirname "$0")" && pwd)/kru-store.sh"
pass=0; fail=0
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
mkdir -p "$t/acme-web" && git -C "$t/acme-web" init -q
check() { # name want got
  if [ "$2" = "$3" ]; then pass=$((pass+1)); else fail=$((fail+1)); printf 'FAIL: %s\n  want [%s] got [%s]\n' "$1" "$2" "$3"; fi
}
run() { (cd "$t/acme-web" && env -u KRU_HOME -u KRU_PROJECT -u KRU_PROJECT_STORE "$@" bash "$S" "${ARGS[@]}"); }
ARGS=(slug);            check "slug is the repo dir name" acme-web "$(run env)"
ARGS=(slug);            check "KRU_PROJECT pins the slug" pinned "$(run env KRU_PROJECT=pinned)"
ARGS=(home);            check "default home" /workspace/kru-store "$(run env)"
ARGS=(project);         check "default project root" /workspace/kru-store/acme-web "$(run env)"
ARGS=(project);         check "KRU_HOME moves both" "$t/h/acme-web" "$(run env KRU_HOME="$t/h")"
ARGS=(project);         check "KRU_PROJECT_STORE wins" "$t/p" "$(run env KRU_PROJECT_STORE="$t/p")"
ARGS=(path plan);       check "plan path" /workspace/kru-store/acme-web/plan "$(run env)"
ARGS=(path issues/x);   check "issue path" /workspace/kru-store/acme-web/issues/x.md "$(run env)"
ARGS=(path inbox);      check "inbox is cross-project" /workspace/kru-store/inbox.md "$(run env)"
ARGS=(path nope);       run env >/dev/null 2>&1; check "unknown logical name exits 64" 64 "$?"
ARGS=(path sheet); check "sheet path" /workspace/kru-store/acme-web/sheet.md "$(run env)"
ARGS=(path dispatch); check "dispatch log path" /workspace/kru-store/acme-web/dispatch.log "$(run env)"
mkdir -p "$t/wt" && git -C "$t/acme-web" -c user.name=a -c user.email=a@a commit -q --allow-empty -m i && git -C "$t/acme-web" worktree add -q "$t/wt/feat" -b feat
ARGS=(slug); check "a linked worktree keeps the main repo's slug" acme-web "$( (cd "$t/wt/feat" && env -u KRU_PROJECT bash "$S" slug) )"
printf '%s passed, %s failed\n' "$pass" "$fail"; [ "$fail" = 0 ]
