#!/bin/bash
# mechanical checks from skills/roster/audit.md. exit 0 when clean.
cd "$(dirname "$0")/.." || exit 2
fail=0; bad() { echo "FAIL: $*"; fail=1; }
v=$(tr -d '[:space:]' < VERSION)
h=$(sed -n '1s/^# Roster — v//p' ROSTER.md)
[ "$v" = "$h" ] || bad "VERSION ($v) != ROSTER.md header ($h)"
for f in agents/*.md; do
  n=$(basename "$f" .md)
  keys=$(sed -n '2,/^---$/p' "$f" | grep -E '^[A-Za-z_]+:' | cut -d: -f1 | sort | tr '\n' ' ')
  [ "$keys" = "description name " ] || bad "$f frontmatter keys: $keys"
  [ "$(sed -n 's/^name: //p' "$f" | head -1)" = "$n" ] || bad "$f name != file stem"
  grep -q "^| \`$n\` |" ROSTER.md || bad "$n has no ROSTER.md row"
done
while read -r n; do [ -f "agents/$n.md" ] || bad "ROSTER.md row names missing agent $n"; done < <(sed -n '/^## Current specialists/,/^## Dispatch tiers/p' ROSTER.md | grep -oE '^\| `[a-z0-9-]+` \|' | tr -d '|` ')
for d in skills/*/; do [ -f "$d/SKILL.md" ] || bad "$d has no SKILL.md"; done
for f in skills/*/SKILL.md; do
  head -1 "$f" | grep -q '^---$' || bad "$f has no frontmatter"
  [ "$(sed -n 's/^name: //p' "$f" | head -1 | tr -d '"')" = "$(basename "$(dirname "$f")")" ] || bad "$f name != dir"
done
stale=$(grep -rnE 'CLAUDE_PLUGIN_ROOT|/kru:|hooks\.json|subagent_type|plugin\.json|marketplace\.json' agents skills references README.md GROK.md ROSTER.md SOURCES.md PREFERENCES.md TRACKER.md scripts 2>/dev/null | grep -v -e '^scripts/audit.sh' -e '^skills/roster/audit.md')
[ -z "$stale" ] || { echo "$stale"; bad "stale host mechanics (above)"; }
# every agent file named in references/routing.md exists
for n in $(grep -oE '`[a-z0-9]+(-[a-z0-9]+)+`' references/routing.md | tr -d '`' | sort -u); do
  case "$n" in *-builder|*-specialist|*-architect|*-reviewer|*-engineer|*-designer|*-developer|*-auditor|*-writer|*-optimizer|*-copywriter) [ -f "agents/$n.md" ] || bad "routing.md names missing agent $n";; esac
done
echo "agents: $(ls agents/*.md | wc -l) · skills: $(ls -d skills/*/ | wc -l) · version $v"
[ $fail = 0 ] && echo "audit: clean"; exit $fail
