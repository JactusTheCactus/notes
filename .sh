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
		if [[ ! -z "$(cat "$i")" ]]
			then
				n="$(echo "$i" | perl -pe 's|pages/(.*?)\.md|$1|g')"
				{
					echo "# ${n^}"
					cat "$i"
				} >> "$DOC"
		fi
done
