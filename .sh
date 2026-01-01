#!/usr/bin/env bash
set -euo pipefail
find . -empty -delete
DOC=README.md
rm -f "$DOC"
touch "$DOC"
exec &> "$DOC"
for i in pages/*
	do
		printf '# %s\n' "$(echo "$i" | perl -pe '
			s|^pages/(\w+)\.\w+$|$1|g;
			s|_| |g;
			s|\b(\w)(\w*)\b|\u$1\L$2|g;
		')"
		page=""
		case "${i#*.}" in
			md) page="$(cat "$i" | perl -pe 's|^#|##|g')";;
			yml)
				#page="$(cat "$i" | perl -pe 's|:$||g;s|  |\t|g;')"
				page="$(printf '> [!WARNING]\n> YAML conversion is currently broken :(\n> ```md\n%s\n> ```\n' "$(cat "$i" \
					| yq -o json \
					| jq -r -f scripts/to_md.jq \
					| perl -pe 's|^|> |g'
				)")"
			;;
		esac
		printf '%s\n' "$page"
done
