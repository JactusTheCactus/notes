#!/usr/bin/env bash
set -euo pipefail
jq+() {
	local temp
	temp="$(mktemp)"
	IN="scripts/$1" node scripts/jq_p.js > "$temp"
	jq -rf "$temp"
}
find . -empty -delete
DOC=README.md
rm -rf "$DOC" &> /dev/null || :
touch "$DOC"
exec &> "$DOC"
find scripts -name \*.js -delete
tsc
while read -r i
	do
		# file names can be prefixed with numbers
		# if ordering is necessary
		# <#><filename>
		printf '# %s\n' "$(perl -pe '
			s|^pages/\d*(\w+)\.\w+$|$1|g;
			s|_| |g;
			s|\b(\w)(\w*)\b|\u$1\L$2|g;
		' <<< "$i"
		)"
		page=""
		case "${i##*.}" in
			md)page="$(perl -pe 's|^#|##|g' "$i")";;
			yml)page="$(yq -o json "$i" | jq+ yml-to-md.jqp)";;
		esac
		printf '%s\n' "$page"
done < <(find pages -type f | sort)