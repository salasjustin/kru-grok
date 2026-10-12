#!/bin/bash
# live end-to-end check, local only (needs ANTHROPIC_API_KEY and the `claude` CLI; costs
# a few cents to a dollar). a fresh headless agent, in a temp HOME and a throwaway git repo,
# reads GROK.md + the lead skill and adds a function with a test under run-log and
# pause-resume. asserts the handoff names a done-check and proof per behavior, that
# decisions.tsv and resume.md were written to the store, and re-runs the test itself.
#   SMOKE_MODEL (default sonnet) · SMOKE_MAX_TURNS (default 40) · SMOKE_MAX_USD (default 3)
#   SMOKE_KEEP=1 keeps the temp dir.
set -uo pipefail
repo=$(cd "$(dirname "$0")/.." && pwd)
[ -n "${ANTHROPIC_API_KEY:-}" ] || { echo "smoke: ANTHROPIC_API_KEY not set" >&2; exit 2; }
command -v claude >/dev/null || { echo "smoke: claude CLI not on PATH" >&2; exit 2; }

t=$(mktemp -d)
[ "${SMOKE_KEEP:-}" = 1 ] || trap 'rm -rf "$t"' EXIT
mkdir -p "$t/home" "$t/store" "$t/demo"
work="$t/demo"; store="$t/store/demo"
git -C "$work" init -q -b main
git -C "$work" config user.name smoke; git -C "$work" config user.email smoke@example.invalid
cat > "$work/textutil.py" <<'EOF'
"""Small text helpers."""


def shout(s: str) -> str:
    return s.upper() + "!"
EOF
cat > "$work/test_textutil.py" <<'EOF'
import unittest

from textutil import shout


class ShoutTest(unittest.TestCase):
    def test_shout(self):
        self.assertEqual(shout("hi"), "HI!")


if __name__ == "__main__":
    unittest.main()
EOF
printf '__pycache__/\n' > "$work/.gitignore"
git -C "$work" add -A && git -C "$work" commit -qm init

read -r -d '' prompt <<EOF
You are a headless delegate running kru's own process on a small project. The kru team repo is
checked out at $repo; every kru path below is relative to it.

1. Read $repo/GROK.md and $repo/skills/lead/SKILL.md before anything else, then
   $repo/skills/run-log/SKILL.md and $repo/skills/pause-resume/SKILL.md.
2. The project is the git repo at $work (stdlib Python, tests run with
   \`python3 -m unittest\`). Run every kru store command from inside $work, e.g.
   \`cd $work && bash $repo/scripts/kru-store.sh path runs\`; KRU_HOME is already set.
3. Task, as an autonomous run under run-log (run slug \`slugify\`): add
   \`slugify(s: str) -> str\` to textutil.py — lowercase, runs of non-alphanumeric characters
   become one "-", no leading or trailing "-" — with tests in test_textutil.py, test-first.
   Write the run's contract.md, log each decision with $repo/skills/run-log/scripts/log.sh,
   and commit locally on main. There is no second model on this box: skip run-log's
   cross-model review and say so in the reply instead of an Attention section.
4. Then pause per pause-resume: write the resume note at the path the store resolver gives.
5. Reply with the handoff: for each behavior, a line starting \`Done-check:\` (the predicate a
   command settles) and a line starting \`Proof:\` (the command and its output).
Never push or touch anything outside $work and the store.
EOF

echo "smoke: running headless agent (model ${SMOKE_MODEL:-sonnet}) in $t" >&2
(cd "$work" && HOME="$t/home" KRU_HOME="$t/store" claude -p "$prompt" \
  --dangerously-skip-permissions --model "${SMOKE_MODEL:-sonnet}" \
  --max-turns "${SMOKE_MAX_TURNS:-40}" --max-budget-usd "${SMOKE_MAX_USD:-3}" \
  --output-format json) > "$t/out.json" 2> "$t/err.log"
rc=$?

results=(); failed=0
check() { if eval "$2"; then results+=("PASS  $1"); else results+=("FAIL  $1"); failed=1; fi; }
reply=$(jq -r '.result // empty' "$t/out.json" 2>/dev/null)
tsv=$(ls "$store"/runs/*/decisions.tsv 2>/dev/null | head -1)

check "agent exited 0 (rc=$rc)" '[ $rc = 0 ] && [ "$(jq -r .is_error "$t/out.json" 2>/dev/null)" = false ]'
check "handoff names a done-check" 'grep -qiE "done-check:" <<<"$reply"'
check "handoff names proof" 'grep -qiE "^[[:space:]*-]*proof:" <<<"$reply"'
check "run-log wrote decisions.tsv with its header" '[ -n "$tsv" ] && [ "$(head -1 "$tsv")" = "$(printf "ts\tphase\tdecision\twhy\tevidence\tresult")" ]'
check "decisions.tsv has decision rows" '[ -n "$tsv" ] && [ "$(wc -l < "$tsv")" -ge 2 ]'
check "run contract written" '[ -s "$store/runs/slugify/contract.md" ]'
check "pause-resume wrote resume.md" '[ -s "$store/resume.md" ]'
check "store stayed out of the repo" '[ -z "$(git -C "$work" status --porcelain)" ] && [ -z "$(git -C "$work" ls-files | grep -E "decisions\.tsv|resume\.md|contract\.md")" ]'
check "slugify landed in a commit" 'git -C "$work" grep -q "def slugify" main -- textutil.py'
check "tests pass when re-run here" '(cd "$work" && python3 -m unittest -q >/dev/null 2>&1)'

cost=$(jq -r '.total_cost_usd // "?"' "$t/out.json" 2>/dev/null); turns=$(jq -r '.num_turns // "?"' "$t/out.json" 2>/dev/null)
if [ $failed = 1 ]; then
  echo "--- reply ---"; printf '%s\n' "${reply:-<none>}"; echo "--- stderr ---"; tail -20 "$t/err.log"
  [ -n "$tsv" ] && { echo "--- $tsv ---"; cat "$tsv"; }
fi
echo; echo "smoke summary (turns $turns, \$$cost):"; printf '  %s\n' "${results[@]}"
[ $failed = 0 ] && echo "smoke: PASS" || echo "smoke: FAIL"
exit $failed
