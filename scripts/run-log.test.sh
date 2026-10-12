#!/bin/bash
# plain table test for skills/run-log/scripts/log.sh (skills/run-log/SKILL.md → The log).
L="$(cd "$(dirname "$0")/.." && pwd)/skills/run-log/scripts/log.sh"
pass=0; fail=0
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
check() { # name want got
  if [ "$2" = "$3" ]; then pass=$((pass+1)); else fail=$((fail+1)); printf 'FAIL: %s\n  want [%s] got [%s]\n' "$1" "$2" "$3"; fi
}
f="$t/runs/demo/decisions.tsv"
bash "$L" "$f" plan "pick A" "cheaper" "abc123" open
check "creates the dir and writes a header first" $'ts\tphase\tdecision\twhy\tevidence\tresult' "$(head -1 "$f")"
check "one row after the header" 2 "$(wc -l < "$f" | tr -d ' ')"
check "row has six tab-separated cells" 6 "$(sed -n 2p "$f" | awk -F'\t' '{print NF}')"
check "ts is UTC ISO-8601" 1 "$(sed -n 2p "$f" | cut -f1 | grep -cE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$')"
bash "$L" "$f" build $'two\nlines' $'a\tb' "=SUM(1)" "-1"
check "appends, never rewrites the header" 1 "$(grep -c '^ts' "$f")"
check "newlines and tabs flatten" "two lines|a b" "$(sed -n 3p "$f" | cut -f3,4 --output-delimiter='|')"
check "formula-leading cells are quoted" "'=SUM(1)|'-1" "$(sed -n 3p "$f" | cut -f5,6 --output-delimiter='|')"
bash "$L" "$f" too few >/dev/null 2>&1; check "wrong arg count exits 64" 64 "$?"
printf '%s passed, %s failed\n' "$pass" "$fail"; [ "$fail" = 0 ]
