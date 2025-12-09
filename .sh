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
for i in pages/*
	do
		t="$(cat "$i")"
		if [[ ! -z "$t" ]]
			then
				case "${i#*.}" in
					md)
						n="$(echo "$i" \
							| perl -pe '
								s|^pages/(\w+)\.\w+$|$1|g;
								s|_| |g;
								s|\b(\w)(\w*)\b|\u$1\L$2|g;
							'
						)"
						echo -e "# $n\n$t" >> "$DOC"
					;;
				esac
		fi
done
