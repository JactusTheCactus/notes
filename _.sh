#!/usr/bin/env bash
set -euo pipefail
jq+() {
	local temp
	temp="$(mktemp)"
	trap "rm -f \"$temp\"" RETURN
	while read -r i
		do awk -f $i "$1" > "$temp"
	done < <(find scripts -name \*.awk)
	cp "$temp" tmp/jq+.jq
	jq -rf "$temp"
}
find . -empty -delete
DOC=README.md
rm -rf "$DOC" tmp &> /dev/null || :
mkdir -p tmp
touch "$DOC"
exec &> "$DOC"
while read -r i
	do
		# file names can be prefixed with numbers
		# if ordering is necessary
		# i="$(perl -pe 's|^\d*||g' "$i")"
		printf '# %s\n' "$(perl -pe '
			s|^pages/(\w+)\.\w+$|$1|g;
			s|_| |g;
			s|\b(\w)(\w*)\b|\u$1\L$2|g;
		' <<< "$i")"
		page=""
		case "${i##*.}" in
			md)page="$(perl -pe 's|^#|##|g' "$i")";;
			yml)
				page="$(yq -o json "$i" \
					| jq+ scripts/yml-to-md.jq
				)"
			;;
		esac
		printf '%s\n' "$page"
done < <(find pages -type f)