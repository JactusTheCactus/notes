#!/usr/bin/env bash
set -euo pipefail
DOC=README.md
rm -f $DOC
touch $DOC
for i in pages/*; do
	case ${i#*.} in
		[[ -n "$(<$i)" ]] || continue
		md)
			{
				echo $i | perl -pe '
					s|^pages/(\w+)\.\w+$|# $1|g;
					s|_| |g;
					s|\b(\w)(\w*)\b|\u$1\L$2|g;
				'
				cat $i | perl -pe '
					s|^#|##|g
				'
			} >> $DOC
		;;
	esac
done
