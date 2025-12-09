#!/usr/bin/env bash
set -euo pipefail
shopt -s expand_aliases
flag() {
	for f in "$@"
		do [[ -e ".flags/$f" ]] || return 1
	done
}
DOC="README.md"
rm -f "$DOC"
touch "$DOC"
for i in pages/*; do
	case "${i#*.}" in
		md)
			{
				echo "$i" | perl -pe '
					s|^pages/(\w+)\.\w+$|# $1|g;
					s|_| |g;
					s|\b(\w)(\w*)\b|\u$1\L$2|g;
				'
				echo "$(<"$i")" | perl -pe '
					s|^[\s\n]*(?=\n)$|N/A|g;
				'
			} >> "$DOC"
		;;
	esac
done
