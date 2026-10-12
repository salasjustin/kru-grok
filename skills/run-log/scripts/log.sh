#!/usr/bin/env bash
# append one row to a run's decisions.tsv (skills/run-log/SKILL.md → The log).
# adapted from cursor/plugins pstack/skills/show-me-your-work/scripts/log.sh (MIT, (c) 2026 Lauren Tan); not verbatim.
# usage: log.sh <logfile> <phase> <decision> <why> <evidence> <result>
set -euo pipefail

if [ "$#" -ne 6 ]; then
	printf 'usage: log.sh <logfile> <phase> <decision> <why> <evidence> <result>\n' >&2
	exit 64
fi

logfile="$1"
shift
mkdir -p "$(dirname "$logfile")"

# `>>`, never `>`: a stat that misreads an existing log costs one stray header, not the rows.
[ -s "$logfile" ] || printf 'ts\tphase\tdecision\twhy\tevidence\tresult\n' >> "$logfile"

# one line per cell; a leading = + - @ is quoted so a spreadsheet opening the log
# never runs a cell taken from a branch name, a test title or generated text.
clean() {
	local v
	v=$(printf '%s' "$1" | tr '\t\n\r' '   ')
	case "$v" in
		=*|+*|-*|@*) printf "'%s" "$v" ;;
		*) printf '%s' "$v" ;;
	esac
}

printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
	"$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$(clean "$1")" "$(clean "$2")" "$(clean "$3")" "$(clean "$4")" "$(clean "$5")" \
	>> "$logfile"
