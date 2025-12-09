#!/usr/bin/env bash
set -euo pipefail
shopt -s expand_aliases
flag() {
	for f in "$@"
		do [[ -e ".flags/$f" ]] || return 1
	done
}
DIRS=(
	logs
)
LOG="logs/notes.log"
DOC="README.md"
for i in "${DIRS[@]}"
	do
		rm -rf "$i" || :
		mkdir -p "$i"
done
rm "$DOC"
touch "$DOC"
exec > "$LOG" 2>& 1
for i in notes/*.md
	do
		{
			echo "# $i"
			cat "$i"
		} >> "$DOC"
done
