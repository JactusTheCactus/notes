#!/usr/bin/env bash
set -euo pipefail
DOC=README.md
rm -f "$DOC"
touch "$DOC"
exec > "$DOC" 2>& 1
find . -empty -delete
for i in pages/*
	do
		printf '# %s\n' "$(echo "$i" | perl -pe '
			s|^pages/(\w+)\.\w+$|$1|g;
			s|_| |g;
			s|\b(\w)(\w*)\b|\u$1\L$2|g;
		')"
		case "${i#*.}" in
			md) printf '%s\n' "$(cat "$i" | perl -pe 's|^#|##|g')";;
		esac
done
