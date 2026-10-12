#!/bin/bash
# the static gate: every check that needs no network and no model. CI runs it on every
# pull request (.github/workflows/verify.yml); run it before a commit. exit 0 when all pass.
# the live end-to-end run is scripts/smoke.sh, local only.
cd "$(dirname "$0")/.." || exit 2
results=(); failed=0
step() { # name, then the command
  local name=$1 out; shift
  if out=$("$@" 2>&1); then results+=("PASS  $name")
  else results+=("FAIL  $name"); failed=1; printf '\n--- %s ---\n%s\n' "$name" "$out"; fi
}

# a python that can import yaml: the system one, else a throwaway uv env.
py=()
if python3 -c 'import yaml' 2>/dev/null; then py=(python3)
elif command -v uv >/dev/null 2>&1; then py=(uv run -q --no-project --with pyyaml python3)
fi

check_syntax() {
  local f bad=0
  while IFS= read -r f; do bash -n "$f" || { echo "syntax: $f"; bad=1; }; done \
    < <(git ls-files '*.sh' 'skills/*/scripts/*' | grep -v -e '\.mjs$' -e '\.ts$')
  return $bad
}

run_tests() {
  local t bad=0
  while IFS= read -r t; do echo "== $t"; bash "$t" || bad=1; done < <(git ls-files '*.test.sh')
  return $bad
}

check_data_files() {
  [ ${#py[@]} -gt 0 ] || { echo "need python3 with PyYAML, or uv"; return 1; }
  git ls-files '*.json' '*.yml' '*.yaml' 'agents/*.md' 'skills/*/SKILL.md' | "${py[@]}" -c '
import json, sys, yaml
bad = 0
def fail(f, why):
    global bad; bad = 1; print(f"{f}: {why}")
for f in sys.stdin.read().split():
    text = open(f, encoding="utf-8").read()
    try:
        if f.endswith(".json"):
            json.loads(text); continue
        if not f.endswith(".md"):
            yaml.safe_load(text); continue
        if not text.startswith("---\n"):
            fail(f, "no frontmatter"); continue
        end = text.find("\n---\n", 4)
        if end < 0:
            fail(f, "frontmatter not closed"); continue
        fm = yaml.safe_load(text[4:end])
    except Exception as e:
        fail(f, f"parse error: {e}".splitlines()[0]); continue
    if not isinstance(fm, dict):
        fail(f, "frontmatter is not a mapping"); continue
    for k in ("name", "description"):
        if not isinstance(fm.get(k), str) or not fm[k].strip():
            fail(f, f"frontmatter {k} missing or not a string")
sys.exit(bad)
'
}

check_versions() {
  local v bad=0 f
  v=$(tr -d '[:space:]' < VERSION)
  [[ $v =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "VERSION is not semver: $v"; bad=1; }
  [ "$(sed -n '1s/^# Roster — v//p' ROSTER.md)" = "$v" ] || { echo "ROSTER.md header != $v"; bad=1; }
  grep -q "^\`VERSION\` is the single version (plain semver, \`$v\`" README.md || { echo "README.md ## Version does not name $v"; bad=1; }
  # any live manifest carrying a version must carry this one (legacy manifests are history)
  while IFS= read -r f; do
    local mv; mv=$(jq -r '.version // empty' "$f")
    [ -z "$mv" ] || [ "$mv" = "$v" ] || { echo "$f version $mv != $v"; bad=1; }
  done < <(git ls-files '*.json' | grep -v -e '^docs/legacy-claude-code/' -e 'package-lock\.json$')
  return $bad
}

# strings from the hosts this team ran on before Grok Bot. a hit is a live instruction pointing
# somewhere that no longer exists. allowed: history and credit (docs/legacy-claude-code, NOTICE,
# LICENSE), the checkers that name the tokens, and vendored provenance lines.
check_leftovers() {
  local hits
  hits=$(git grep -nE '~/\.claude/kru|~/\.kru/|CLAUDE_PLUGIN_(ROOT|DATA)|\bopencode\b|\.opencode/|/kru[:]' -- . \
      ':!docs/legacy-claude-code' ':!NOTICE' ':!LICENSE' ':!scripts/verify.sh' ':!scripts/audit.sh' ':!skills/roster/audit.md' \
    | grep -vE '^skills/shadcn/mcp\.md:[0-9]+:\| OpenCode ')
  [ -z "$hits" ] || { echo "$hits"; return 1; }
}

step "bash syntax (every tracked .sh)" check_syntax
step "scripts/audit.sh" bash scripts/audit.sh
step "script tests (*.test.sh)" run_tests
step "JSON/YAML + agent/skill frontmatter" check_data_files
step "version consistency" check_versions
step "no leftover other-platform strings" check_leftovers

echo; echo "verify summary:"; printf '  %s\n' "${results[@]}"
[ $failed = 0 ] && echo "verify: PASS" || echo "verify: FAIL"
exit $failed
