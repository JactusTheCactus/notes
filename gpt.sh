exec &> tmp/gpt.md
echo Thoughts?
while read -r i; do
	printf '`%s`\n```%s\n%s\n```\n' \
		"${i#./}" \
		"$(perl -pe 's|^.*?\.([^.]*?)$|\1|g' <<< "$i")" \
		"$(<"$i")"
done < <(find . \
	-type f \
	-path \*/scripts/\* -o \
	-name .sh
)