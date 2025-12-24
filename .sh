#!/usr/bin/env bash
set -euo pipefail
DOC=README.md
rm -f "$DOC"
touch "$DOC"
exec > "$DOC" 2>& 1
find pages -empty -delete
for i in pages/*; do
	case "${i#*.}" in
		md)
			echo "$i" | perl -pe '
				s|^pages/(\w+)\.\w+$|# $1|g;
				s|_| |g;
				s|\b(\w)(\w*)\b|\u$1\L$2|g;
			'
			cat "$i" | perl -pe 's|^#|##|g'
			echo
		;;
	esac
done
