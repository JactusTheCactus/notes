#!/usr/bin/env bash
set -euo pipefail
jq+() {
	local temp
	temp="$(mktemp)"
	trap "rm -f \"$temp\"" RETURN
	while read -r i
		do IN="$1" node $i > "$temp"
	done < <(find scripts -name \*.js)
	jq -rf "$temp"
}
find . -empty -delete
DOC=README.md
rm -rf "$DOC" &> /dev/null || :
touch "$DOC"
exec &> "$DOC"
tsc
trap 'rm scripts/switch-case.js' EXIT
while read -r i
	do
		# file names can be prefixed with numbers
		# if ordering is necessary
		# <#><filename>
		# e.g.
			# 0file.log
			# 1file.log
			# 2file.log
		printf '# %s\n' "$(perl -pe '
			s|^pages/\d*(\w+)\.\w+$|$1|g;
			s|_| |g;
			s|\b(\w)(\w*)\b|\u$1\L$2|g;
		' <<< "$i"
		)"
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
done < <(find pages -type f | sort)