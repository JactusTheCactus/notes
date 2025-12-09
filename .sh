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
touch "$DOC"
for i in pages/*.md
	do
		t="$(cat "$i")"
		if [[ ! -z "$t" ]]
			n=$(echo "$i" | perl -pe 's/pages/(.*?)\.md/$1/g')
			then echo -e "# ${n^}\n$t" >> "$DOC"
		fi
done
