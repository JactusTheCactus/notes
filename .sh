#!/usr/bin/env bash
set -euo pipefail
jq+() {
	local temp
	temp="$(mktemp)"
	node scripts/jq_p.js \
		file \
		"scripts/$1" \
		> "$temp"
	jq -rf "$temp" || {
		cp "$temp" "tmp/$1"
		code "tmp/$1"
	}
}
DOC=README.md
rm -rf "$DOC" tmp &> /dev/null || :
mkdir -p tmp
touch "$DOC"
exec &> "$DOC"
tsc
rm pages/project_ideas.md
echo "- Whalefall incremental" > pages/project_ideas.yml
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
done < <(find pages -type f ! -empty | sort)
find . -empty -o -name \*.js -delete