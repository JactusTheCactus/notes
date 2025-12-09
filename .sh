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
for i in "${DIRS[@]}"
	do
		rm -rf "$i" || :
		mkdir -p "$i"
done
LOG="logs/notes.log"
DOC="README.md"
rm "$DOC"
echo "# Notes" > "$DOC"
for i in pages/*.md
	do
		t="$(cat "$i")"
		# if [[ ! -z "$(echo "$t" | perl -pe 's/[\s\n]//g')" ]]
		if [[ ! -z "$t" ]]
			then
				n="$(echo "$i" | perl -pe 's|pages/(.*?)\.md|$1|g')"
				echo -e "## ${n^}\n$t" >> "$DOC"
		fi
done
